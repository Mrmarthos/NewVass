@RestResource(urlMapping='/Accounts')
global with sharing class ServicioAccount {

   @HttpGet
    global static void getAccounts() {
        // Realizar la consulta a las cuentas
        List<Account> accounts = [SELECT Id, Name, Sectores__c, Regiones__c FROM Account ];

        // Crear la estructura del JSON
        Map<String, Object> responseMap = new Map<String, Object>();
     

        List<Map<String, Object>> recordsList = new List<Map<String, Object>>();
		
        for (Account acc : accounts) {
            Map<String, Object> accountMap = new Map<String, Object>();
            Map<String, String> attributesMap = new Map<String, String>();
            
           

            accountMap.put('Regiones__c', acc.Regiones__c);
            accountMap.put('Sectores__c', acc.Sectores__c);
            accountMap.put('Name', acc.Name);
                attributesMap.put('url', '/services/data/v50.0/sobjects/Account/' + acc.Id);
            attributesMap.put('type', 'Account');
        

            accountMap.put('attributes', attributesMap);
			
            recordsList.add(accountMap);
        }
	
        responseMap.put('records', recordsList);
        responseMap.put('nextRecordsUrl', '');
          responseMap.put('done', true);
        responseMap.put('totalSize', accounts.size());
      
        // Convertir el mapa a JSON
        String jsonResponse = JSON.serializePretty(responseMap);
        
        // Establecer el tipo de contenido y devolver la respuesta
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(jsonResponse);
    }
}