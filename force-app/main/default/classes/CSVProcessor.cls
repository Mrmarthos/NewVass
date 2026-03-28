public with sharing class CSVProcessor {
    public class CSVResult {
        @AuraEnabled public List<String> headers;
        @AuraEnabled public List<Map<String, String>> rows;
        @AuraEnabled public String warningMessage;
        @AuraEnabled public String csvContent;
    }

    @AuraEnabled
    public static CSVResult processCSV(Id documentId, Id opportunityId) {
        CSVResult result = new CSVResult();
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('INICIO processCSV');
            if (documentId == null || opportunityId == null) {
                System.debug('FALTAN PARÁMETROS');
                throw new AuraHandledException('Document ID and Opportunity ID are required');
            }

            ContentVersion csvFile = [SELECT VersionData FROM ContentVersion 
                                    WHERE ContentDocumentId = :documentId 
                                    AND IsLatest = true 
                                    LIMIT 1];
            
            if (csvFile == null || csvFile.VersionData == null) {
                System.debug('NO SE ENCONTRO EL ARCHIVO');
                throw new AuraHandledException('CSV file not found');
            }

            Blob csvBlob = csvFile.VersionData;
            result.csvContent = EncodingUtil.base64Encode(csvBlob);
            String csvContent = csvBlob.toString();
            List<String> lines = csvContent.replace('\r\n', '\n')
                                         .replace('\r', '\n')
                                         .split('\n');
            
            if (lines.size() < 2) {
                System.debug('CSV VACÍO');
                throw new AuraHandledException('Empty CSV or no data');
            }

            String headerLine = lines[0].trim().replace('\uFEFF', '');
            result.headers = new List<String>();
            for (String h : headerLine.split(';')) {
                result.headers.add(h.trim());
            }

            Integer versionIndex = result.headers.indexOf('ID_FILE');
            if (versionIndex == -1) {
                System.debug('NO HAY COLUMNA ID_FILE');
                throw new AuraHandledException('CSV version column (ID_FILE) not found');
            }
            
            // Validación de versión
            validateCSVVersion(lines, versionIndex);

            Integer opCodeIndex = result.headers.indexOf('OPPCODE');
            if (opCodeIndex == -1) {
                System.debug('NO HAY COLUMNA OPPCODE');
                throw new AuraHandledException('OPPCODE column not found');
            }

            Opportunity opp = [SELECT Codigo_de_oportunidad__c 
                             FROM Opportunity 
                             WHERE Id = :opportunityId 
                             LIMIT 1];
            if (opp == null) {
                throw new AuraHandledException('Opportunity not found');
            }

            result.rows = new List<Map<String, String>>();
            for (Integer i = 1; i < lines.size(); i++) {
                processCSVRow(lines[i], result.headers, opCodeIndex, opp.Codigo_de_oportunidad__c, i+1, result.rows);
            }

            validateProjectLines(opportunityId, result);

            System.debug('FIN processCSV');
            return result;

        } catch (Exception e) {
            System.debug('EXCEPCION EN processCSV: ' + e.getMessage());
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static void validateCSVVersion(List<String> lines, Integer versionIndex) {
        List<VersionExcel__mdt> versions = [SELECT Code__c FROM VersionExcel__mdt LIMIT 1];
        if (versions.isEmpty()) {
            throw new AuraHandledException('Version configuration not found');
        }
        String expectedVersion = versions[0].Code__c;

        for (Integer i = 1; i < lines.size(); i++) {
            List<String> dataRow = lines[i].split(';', -1);
            if (dataRow.size() > versionIndex) {
                String csvVersion = dataRow[versionIndex].trim();
                if (csvVersion != expectedVersion) {
                    AuraHandledException e = new AuraHandledException('Invalid Excel Version');
                    e.setMessage('Invalid Excel Version, please download the latest template');
                    throw e;
                }
            }
        }
    }

    public static void validateProjectLines(Id opportunityId, CSVResult result) {
        List<Linea_de_Proyecto__c> projectLines = [
            SELECT Sede__c, Gerencia__c, Area__c, No_aplica_para_ejecucion__c, RecordTypeId, GerenciaCode__c, RecordType.Name
            FROM Linea_de_Proyecto__c
            WHERE Oportunidad__c = :opportunityId
            AND No_aplica_para_ejecucion__c = false
            AND RecordTypeId NOT IN ('0120N000000UzjmQAC', '0120N000000kPcVQAU', '0120N000000kPcaQAE') 
            AND (Gerencia__c != null OR Gerencia__c != 'Innovación (BV)')
        ];

        Set<String> projectKeys = new Set<String>();
        for (Linea_de_Proyecto__c lp : projectLines) {
            projectKeys.add(getProjectKey(lp));
        }

        Set<String> csvKeys = new Set<String>();
        for (Map<String, String> row : result.rows) {
            csvKeys.add(getCSVKey(row));
        }

        List<Linea_de_Proyecto__c> missingLines = new List<Linea_de_Proyecto__c>();
        for (Linea_de_Proyecto__c lp : projectLines) {
            if (!csvKeys.contains(getProjectKey(lp))) {
                missingLines.add(lp);
            }
        }

        if (!missingLines.isEmpty()) {
            result.warningMessage = 'One or more project lines are missing in CSV';
        }
    }

    private static void processCSVRow(String dataLine, List<String> headers, Integer opCodeIndex, String oppCode, Integer lineNumber, List<Map<String, String>> rows) {
        if (String.isBlank(dataLine)) return;
        List<String> dataRow = dataLine.split(';', -1);
        if (dataRow.size() <= opCodeIndex) {
            throw new AuraHandledException('Incomplete CSV row at line ' + lineNumber);
        }

        // Validar OPPCODE
        if (dataRow[opCodeIndex].trim() != oppCode) {
            AuraHandledException e = new AuraHandledException('The excel OfferCode does not match the Opp offer code');
            e.setMessage('The excel OfferCode does not match the Opp offer code');
            throw e;
        }

        Map<String, String> rowMap = new Map<String, String>();
        for (Integer j = 0; j < headers.size(); j++) {
            rowMap.put(headers[j], j < dataRow.size() ? dataRow[j].trim() : '');
        }
        rows.add(rowMap);
    }

    @AuraEnabled
    public static void updateProjectLines(Id opportunityId, List<Map<String, String>> csvRows, String csvContent) {
        Savepoint sp = Database.setSavepoint();
        try {
            if (String.isBlank(csvContent)) {
                throw new AuraHandledException('csvContent no puede estar vacío.');
            }

            // Agrupar filas CSV por clave de línea de proyecto
            Map<String, List<Map<String, String>>> csvGroups = new Map<String, List<Map<String, String>>>();
            for (Map<String, String> row : csvRows) {
                String key = getCSVKey(row);
                if (!csvGroups.containsKey(key)) {
                    csvGroups.put(key, new List<Map<String, String>>());
                }
                csvGroups.get(key).add(row);
            }

            List<Linea_de_Proyecto__c> lineasProyecto = [
                SELECT Id, Sede__c, Gerencia__c, Area__c, 
                       Precio_Venta__c, Importe_total_2__c, GerenciaCode__c,
                       Coste_Bruto__c, Coste_estimado__c, Coste_real__c, RecordType.Name,
                       fecha_inicio__c, fecha_fin__c
                FROM Linea_de_Proyecto__c
                WHERE Oportunidad__c = :opportunityId
            ];

            List<Linea_de_Proyecto__c> toUpdate = new List<Linea_de_Proyecto__c>();
            for (Linea_de_Proyecto__c lp : lineasProyecto) {
                String key = getProjectKey(lp);
                if (csvGroups.containsKey(key)) {
                    List<Map<String, String>> groupRows = csvGroups.get(key);

                    Decimal totalPrice = 0;
                    Decimal totalCost = 0;
                    
                    for (Map<String, String> row : groupRows) {
                        totalPrice += parseDecimal(row.get('PRICE_ROL'));
                        totalCost += parseDecimal(row.get('COST_ROL'));
                    }
                    
                    lp.Precio_Venta__c = totalPrice;
                    lp.Importe_total_2__c = totalPrice;
                    lp.Coste_Bruto__c = totalCost;
                    lp.Coste_estimado__c = totalCost;

                    toUpdate.add(lp);
                }
            }

            if (!toUpdate.isEmpty()) {
                System.debug('Actualizando ' + toUpdate.size() + ' líneas de proyecto');
                update toUpdate;
                
                // SE GENERA EL HISTÓRICO SOLO SI SE ACTUALIZAN LÍNEAS DE PROYECTO
                crearHistorico(csvContent, 'CSV procesado exitosamente', opportunityId);
            } else {
                System.debug('No hay líneas de proyecto para actualizar');
            }

        } catch (Exception e) {
            System.debug('EXCEPCION EN updateProjectLines: ' + e.getMessage());
            Database.rollback(sp);
            AuraHandledException e2 = new AuraHandledException(e.getMessage());
            e2.setMessage(e.getMessage());
            throw e2;
        }
    }

    private static String getProjectKey(Linea_de_Proyecto__c lp) {
        String key = (lp.Sede__c != null ? lp.Sede__c.trim() : '') + '|' +
                     (lp.Gerencia__c != null ? lp.GerenciaCode__c.trim() : '') + '|' +
                     (lp.Area__c != null ? lp.Area__c.trim() : '');
        if (lp.RecordType.Name != null) {
            if (lp.RecordType.Name == 'AM') {
                key += '|AM';
            } else if (lp.RecordType.Name == 'Llave en Mano') {
                key += '|Llave_en_Mano';
            } else if (lp.RecordType.Name == 'T&M') {
                key += '|T&M';
            }
        }
        return key;
    }

    private static String getCSVKey(Map<String, String> row) {
        String key = (row.get('ID_BUSINESSUNIT') != null ? row.get('ID_BUSINESSUNIT').trim() : '') + '|' +
                     (row.get('ID_SERVICELINE') != null ? row.get('ID_SERVICELINE').trim() : '') + '|' +
                     (row.get('ID_PRACTISE') != null ? row.get('ID_PRACTISE').trim() : '');
        String idType = row.get('DESC_TYPE') != null ? row.get('DESC_TYPE').trim() : '';
        if (idType == 'Managed Services') {
            key += '|AM';
        } else if (idType == 'Project') {
            key += '|Llave_en_Mano';
        } else if (idType == 'T&M') {
            key += '|T&M';
        }
        return key;
    }

    public static Decimal parseDecimal(String value) {
        if (String.isBlank(value)) return 0;
        try {
            return Decimal.valueOf(value.replace(',', '.'));
        } catch (Exception e) {
            System.debug('Error parseando decimal: ' + value);
            AuraHandledException e2 = new AuraHandledException('Invalid Number format in CSV');
            e2.setMessage('Error procesando valor numérico: ' + value);
            throw e2;
        }
    }

    public static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) return null;
        try {
            List<String> parts = dateStr.split('/');
            if (parts.size() != 3) return null;
            return Date.newInstance(
                Integer.valueOf(parts[2]), 
                Integer.valueOf(parts[1]), 
                Integer.valueOf(parts[0])
            );
        } catch (Exception e) {
            System.debug('Error parseando fecha: ' + dateStr);
            return null;
        }
    }
@TestVisible
    private static void crearHistorico(String csvContentBase64, String comentarios, Id oppId) {
        try {
            System.debug('INICIO crearHistorico');
            Historial_Excel_Economico__c historico = new Historial_Excel_Economico__c(
                Comentarios__c = comentarios.left(255),
                Oportunidad__c = oppId
            );
            insert historico;

            ContentVersion conVer = new ContentVersion(
                ContentLocation = 'S',
                PathOnClient = 'economic_data_' + System.now().getTime() + '.csv',
                Title = 'Economic_Excel_' + Datetime.now().format('yyyy-MM-dd'),
                VersionData = EncodingUtil.base64Decode(csvContentBase64)
            );
            insert conVer;

            // Se elimina el bucle While porque ContentDocumentId se genera sincrónicamente al hacer insert.
            ContentVersion conVerInserted = [SELECT ContentDocumentId 
                                             FROM ContentVersion 
                                             WHERE Id = :conVer.Id 
                                             LIMIT 1];

            if (conVerInserted == null || conVerInserted.ContentDocumentId == null) {
                throw new AuraHandledException('No se pudo obtener ContentDocumentId.');
            }

            ContentDocumentLink conDocLink = new ContentDocumentLink(
                LinkedEntityId = historico.Id,
                ContentDocumentId = conVerInserted.ContentDocumentId,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert conDocLink;
            System.debug('FIN crearHistorico');
        } catch (Exception e) {
            System.debug('EXCEPCION EN crearHistorico: ' + e.getMessage());
            throw new AuraHandledException('Error en crearHistorico: ' + e.getMessage());
        }
    }
}