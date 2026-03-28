public with sharing class LOBCalculation {

    public class Request {
        @InvocableVariable(label='Id de Línea de Proyecto' required=true)
        public String lineaDeProyectoId;
    }

    @InvocableMethod(label='Actualizar LOB según Gerencia y Oportunidad' description='Actualiza LOB en línea de proyecto y oportunidad relacionada')
    public static void actualizarLOB(List<Request> requests) {
        if (requests == null || requests.isEmpty()) {
            throw new IllegalArgumentException('Se debe proporcionar al menos un Id de Linea_de_Proyecto__c');
        }

        // 1. Recoger todos los nombres de líneas para consulta masiva
        Set<String> nombresLinea = new Set<String>();
        for(Request req : requests) {
            if(String.isNotBlank(req.lineaDeProyectoId)) {
                nombresLinea.add(req.lineaDeProyectoId);
            }
        }

        // 2. Consulta de líneas con relaciones a Oportunidad
        List<Linea_de_Proyecto__c> lineas = [
            SELECT Id, Name, Gerencia__c, lob__c, Linea_principal__c, 
                   Oportunidad__c, Oportunidad__r.lob__c, Oportunidad__r.Mercado__c
            FROM Linea_de_Proyecto__c
            WHERE Name IN :nombresLinea
        ];

        // 3. Mapeo completo Gerencia -> LOB
        Map<String, String> gerenciaToLOB = new Map<String, String>{
            'CRI' => '04',
            'Customer Centric' => '02',
            'Customer Experience' => '02',
            'Regulatory & Data' => '01',
            'Delivery Cross' => '04',
            'Digital Experience' => '02',
            'Escrita - VaSS' => '04',
            'Governance & Infrastructure' => '01',
            'Innovación (BV)' => '04',
            'Integration & Processes' => '04',
            'Intelligent Technology' => '05',
            'Comunytek' => '04',
            'Nateevo - Brand Services' => '03',
            'Nateevo-Business Value' => '03',
            'Nateevo - Consulting' => '03',
            'Nateevo - Data & Analytics' => '03',
            'Nateevo - Delivery Success' => '03',
            'Nateevo - Development' => '03',
            'Nateevo - Experience' => '03',
            'Nateevo - Marketing Digital' => '03',
            'Nateevo - Media' => '03',
            'Nateevo - Smartech' => '03',
            'One Inside' => '02',
            'SAP CX' => '05',
            'S/4' => '05',
            'Servicios Diversos (Serb)' => '04',
            'Sin Asignar' => '04',
            'Tailor-Made Solutions' => '04',
            'Staffing (MX)' => '04',
            'Intelligent Enterprise' => '05'
        };

        // 4. Estructuras para actualizaciones
        List<Linea_de_Proyecto__c> lineasParaActualizar = new List<Linea_de_Proyecto__c>();
        Map<Id, String> oportunidadesLOBs = new Map<Id, String>();
        Set<Id> oportunidadesConMercadoEspecial = new Set<Id>();

        // 5. Procesar cada línea
        for(Linea_de_Proyecto__c linea : lineas) {
            // Actualizar LOB de la línea
            String nuevoLOB = gerenciaToLOB.get(linea.Gerencia__c);
            if(nuevoLOB == null) nuevoLOB = '04';
            
            if(linea.lob__c != nuevoLOB) {
                linea.lob__c = nuevoLOB;
                lineasParaActualizar.add(linea);
            }

            // Procesar oportunidad relacionada si es línea principal
            if(linea.Linea_principal__c && linea.Oportunidad__c != null) {
                // Registrar mercado especial si aplica
                if(linea.Oportunidad__r.Mercado__c == 'Banca-Banca' || 
                   linea.Oportunidad__r.Mercado__c == 'Seguros-Seguros') {
                    oportunidadesConMercadoEspecial.add(linea.Oportunidad__c);
                }
                
                // Obtener LOB base de la línea principal
                oportunidadesLOBs.put(linea.Oportunidad__c, nuevoLOB);
            }
        }

        // 6. Preparar actualizaciones de oportunidades
        List<Opportunity> oppsParaActualizar = new List<Opportunity>();
        for(Id oppId : oportunidadesLOBs.keySet()) {
            String lobBase = oportunidadesLOBs.get(oppId);
            Set<String> valoresLOB = new Set<String>{lobBase};
            
            // Añadir '06' si tiene mercado especial
            if(oportunidadesConMercadoEspecial.contains(oppId)) {
                valoresLOB.add('06');
            }
            
            // Mantener valores existentes si los hay
            String lobExistente = lineas[0].Oportunidad__r.lob__c; // Usar primera línea como referencia
            if(String.isNotBlank(lobExistente)) {
                valoresLOB.addAll(lobExistente.split(';'));
            }
            
            system.debug('yhyeye'+String.join(new List<String>(valoresLOB), ';'));
            
            // Construir nuevo valor LOB
            Opportunity opp = new Opportunity(
                Id = oppId,
                lob__c = String.join(new List<String>(valoresLOB), ';')
            );
            oppsParaActualizar.add(opp);
        }

        // 7. Ejecutar actualizaciones con seguridad
        if(!lineasParaActualizar.isEmpty() && 
           Schema.sObjectType.Linea_de_Proyecto__c.isUpdateable()) {
            update lineasParaActualizar;
        }
        
        if(!oppsParaActualizar.isEmpty() && 
           Schema.sObjectType.Opportunity.isUpdateable()) {
            update oppsParaActualizar;
        }
    }
}