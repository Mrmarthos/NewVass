@RestResource(urlMapping='/getcsv')
global with sharing class GetOfertaService {
      private static final EPPM_MappingUtility mapper = EPPM_MappingUtility.getInstance();
    @HttpGet
    global static void getOferta() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		  
        String codoferta = req.params.get('codoferta');
        System.debug('INFO: Código de oferta recibido: ' + codoferta);

        if (String.isEmpty(codoferta)) {
            System.debug('ERROR: No se proporcionó un código de oferta.');
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"error": "Invalid request. Please provide OfferCode"}');
            res.addHeader('Content-Type', 'application/json');
            return;
        }

        try {
            Historial_Excel_Economico__c excelRecord;
            try {
                excelRecord = [
                    SELECT Id, Oportunidad__c, Oportunidad__r.StageName,Oportunidad__r.N_Cargas_Excel__c 
                    FROM Historial_Excel_Economico__c 
                    WHERE Oportunidad__r.Codigo_de_oportunidad__c = :codoferta order by createddate desc
                    LIMIT 1
                ];
                System.debug('INFO: Registro encontrado: ' + excelRecord.Id);
            } catch (Exception e) {
                System.debug('ERROR: No se encontró un registro en Historial_Excel_Economico__c: ' + e.getMessage());
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "No Historial_Excel_Economico__c found for the given OfferCode"}');
                res.addHeader('Content-Type', 'application/json');
                return;
            }

            System.debug('INFO: Buscando ContentDocumentId asociado al registro: ' + excelRecord.Id);
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :excelRecord.Id order by ContentDocument.CreatedDate desc limit 1
            ];

            if (docLinks.isEmpty()) {
                System.debug('ERROR: No se encontraron documentos asociados.');
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "No file found for the given OfferCode"}');
                res.addHeader('Content-Type', 'application/json');
                return;
            }

            Id contentDocumentId = docLinks[0].ContentDocumentId;
            System.debug('INFO: Buscando ContentVersion asociado al documento: ' + contentDocumentId);
            List<ContentVersion> contentVersions = [
                SELECT Id, Title, VersionData, VersionNumber 
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];

            if (contentVersions.isEmpty()) {
                System.debug('ERROR: No se encontraron versiones de contenido.');
                res.statusCode = 404;
                res.responseBody = Blob.valueOf('{"error": "No file found for the given OfferCode"}');
                res.addHeader('Content-Type', 'application/json');
                return;
            }

            ContentVersion file = contentVersions[0];
            System.debug('INFO: Archivo encontrado: ' + file.Title + ' (ID: ' + file.Id + ')');

            // Convertir el archivo a Base64
            String base64File = EncodingUtil.base64Encode(file.VersionData);

            // Crear el JSON de respuesta
            Map<String, Object> responseMap = new Map<String, Object>();
            responseMap.put('stageName', mapper.getStageCode(excelRecord.Oportunidad__r.StageName));
            responseMap.put('FileName', file.Title + '.csv');
            responseMap.put('versionNumber', excelRecord.Oportunidad__r.N_Cargas_Excel__c );
            responseMap.put('fileBase64', base64File);

            // Convertir el mapa a JSON
            String jsonResponse = JSON.serialize(responseMap);

            // Configurar la respuesta HTTP
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(jsonResponse);
            res.addHeader('Content-Type', 'application/json');
        } catch (Exception e) {
            System.debug('ERROR: Se produjo una excepción: ' + e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"error": "Error occurred: ' + e.getMessage() + '"}');
            res.addHeader('Content-Type', 'application/json');
        }
    }
}