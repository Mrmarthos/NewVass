@IsTest
private class ServicioAccountTest {

    @IsTest
    static void testGetAccounts() {
        // Crear datos de prueba
        Account acc1 = new Account(Name = 'Account 1', Sectores__c = 'Sector 1', Regiones__c = 'Region 1');
        Account acc2 = new Account(Name = 'Account 2', Sectores__c = 'Sector 2', Regiones__c = 'Region 2');
        insert new List<Account>{ acc1, acc2 };
        
        // Llamar al método REST
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/Accounts';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        // Llamar al método del servicio
        ServicioAccount.getAccounts();

        // Obtener la respuesta
        String jsonResponse = res.responseBody.toString();

        // Parsear la respuesta JSON
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
        List<Object> recordsList = (List<Object>) responseMap.get('records');

        // Verificar la estructura de la respuesta
        System.assertEquals(2, recordsList.size());
        System.assertEquals(2, responseMap.get('totalSize'));
        System.assertEquals(true, responseMap.get('done'));

        Map<String, Object> firstRecord = (Map<String, Object>) recordsList.get(0);
        Map<String, Object> firstAttributes = (Map<String, Object>) firstRecord.get('attributes');
        
        System.assertEquals('Account 1', firstRecord.get('Name'));
        System.assertEquals('Sector 1', firstRecord.get('Sectores__c'));
        System.assertEquals('Region 1', firstRecord.get('Regiones__c'));
        System.assertEquals('Account', firstAttributes.get('type'));
        System.assertEquals('/services/data/v50.0/sobjects/Account/' + acc1.Id, firstAttributes.get('url'));

        Map<String, Object> secondRecord = (Map<String, Object>) recordsList.get(1);
        Map<String, Object> secondAttributes = (Map<String, Object>) secondRecord.get('attributes');
        
        System.assertEquals('Account 2', secondRecord.get('Name'));
        System.assertEquals('Sector 2', secondRecord.get('Sectores__c'));
        System.assertEquals('Region 2', secondRecord.get('Regiones__c'));
        System.assertEquals('Account', secondAttributes.get('type'));
        System.assertEquals('/services/data/v50.0/sobjects/Account/' + acc2.Id, secondAttributes.get('url'));
    }
}