@RestResource(urlMapping='/GetCSODdata')
global with sharing class CornestoneWS {
    
    @HttpGet
    global static void getConerData() {
        // Obtener los parámetros de fecha de la URL
        String startDate = RestContext.request.params.get('startDate');
        String endDate = RestContext.request.params.get('endDate');
        
        // Construir el query de SOQL
        String query = 'SELECT id, Oportunidad__r.Name ,Sede__c,Org_Ventas__c, CurrencyIsoCode,createddate, RecordType.Name, rate__c,lastmodifieddate, Ejecutado_en_cliente__c, ' +
                       'Direccion_cliente__c, Duracion_lineas_por_meses__c, Oportunidad__r.Mercado__c, Oportunidad__r.Account.Name, ' +
                       'ToLabel(Gerencia__c), Area__c, English__c, Profile_Description__c, Oportunidad__r.Owner.Name,working_model__c, ' +
                       'Jefe_de_Proyecto_de_Ejecucion__r.Name, n_vacantes__c, Estimated_date_of_incorporation__c, ' +
                       'Oportunidad__r.Codigo_de_oportunidad__c,Oportunidad__r.Probability,Margen_de_venta__c,Importe_total__c FROM Linea_de_Proyecto__c';
        
        // Verificar si se han proporcionado las fechas de inicio y fin
        if (startDate != null && endDate != null) {
            try {
                // Validar el formato de las fechas recibidas
                DateTime startDateTime = DateTime.valueOfGmt(startDate);
                DateTime endDateTime = DateTime.valueOfGmt(endDate);
                
                // Agregar cláusula WHERE para filtrar por la fecha de modificación
                query += ' where (LastModifiedDate >= :startDateTime AND LastModifiedDate <= :endDateTime) and Estimated_date_of_incorporation__c!=null and Is_Renewal__c=False   ORDER BY LastModifiedDate DESC ';
            } catch (Exception e) {
                // Manejo de error para fechas no válidas
                RestContext.response.statusCode = 400;
                RestContext.response.responseBody = Blob.valueOf('Invalid date format. Please provide dates in the format "YYYY-MM-DDTHH:MM:SSZ".');
                return;
            }
        }else {
             query += ' where Estimated_date_of_incorporation__c!=null and Is_Renewal__c=False    ORDER BY LastModifiedDate DESC ';
        }
        
        // Completar la consulta con orden y límite
       
        
        // Ejecutar la consulta
        List<Linea_de_Proyecto__c> projectLines = Database.query(query);
        
        // Crear una lista de objetos de salida
        List<Map<String, Object>> resultList = new List<Map<String, Object>>();
        String serviceLine;
        // Mapear los resultados a la estructura JSON solicitada
        for (Linea_de_Proyecto__c line : projectLines) {
            Map<String, Object> projectData = new Map<String, Object>();
            
            // Mapeo de campos específicos
            projectData.put('Id', line.id);
            projectData.put('Display_job_title', line.Oportunidad__r.Name);
            projectData.put('Company', line.Sede__c);
            projectData.put('Location', line.Org_Ventas__c);
            projectData.put('SalesforceID', line.Oportunidad__r.Codigo_de_oportunidad__c);
            projectData.put('Currency', line.CurrencyIsoCode);
            projectData.put('Range', line.rate__c);
            projectData.put('Type_of_Project', line.RecordType.Name);
            projectData.put('Working_Model', line.working_model__c);
            projectData.put('Address_of_Working Place', line.Direccion_cliente__c);
            projectData.put('Duration_of_contract', line.Duracion_lineas_por_meses__c);
            projectData.put('Business_Vertical', line.Oportunidad__r.Mercado__c);
            projectData.put('Customer', line.Oportunidad__r.Account.Name);
            if (line.Gerencia__c == 'Integration & Processes') {
                serviceLine = 'AUTOMATION & INTEGRATION';
            } else if (line.Gerencia__c == 'Infrastructure & SecDevOps') {
                serviceLine = 'CLOUD & SECDEVOPS';
            } else {
                serviceLine = line.Gerencia__c;
            }
            projectData.put('Service_Line', serviceLine);
            projectData.put('Practice', line.Area__c);
            projectData.put('English', line.English__c);
            projectData.put('Description', line.Profile_Description__c);
            projectData.put('Hiring_manager', line.Oportunidad__r.Owner.Name);
            projectData.put('Reviewer', line.Jefe_de_Proyecto_de_Ejecucion__r.Name);
            projectData.put('Openings', line.n_vacantes__c ?? 1);
            projectData.put('Target_hire_date', line.Estimated_date_of_incorporation__c);
            projectData.put('CreatedDate', line.createddate);
            projectData.put('Margin', line.Margen_de_venta__c);
            projectData.put('Probability', line.Oportunidad__r.Probability);
            projectData.put('Amount', line.Importe_total__c);
            projectData.put('ModifiedDate', line.lastmodifieddate);
            // Agregar el mapa a la lista de resultados
            resultList.add(projectData);
        }
        
        // Crear la estructura final de la respuesta
        Map<String, Object> finalResult = new Map<String, Object>();
        finalResult.put('records', resultList);
        finalResult.put('totalSize', projectLines.size()); // Número total de registros
        finalResult.put('done', true); // Estado de la operación
        
        // Devolver el resultado como JSON
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(finalResult));
        RestContext.response.statusCode = 200;
    }
}