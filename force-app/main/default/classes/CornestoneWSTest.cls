@isTest
private class CornestoneWSTest {
    @isTest
    static void testGetConerDataValidDates() {
     Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16)
        );

        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16)
        );

        User u1 = [SELECT Id FROM User  where IsActive=True  and EmployeeNumber !=null LIMIT 1];
        User u2 = [SELECT Id FROM User  where IsActive =True and EmployeeNumber !=null  LIMIT 1];
        //u1 EmployeeNumber = 0012
        //u1 EmployeeNumber = 0013
        Test.startTest();

        System.runAs(u1)
        {
        	insert opp1;
        }

        System.runAs(u2)
        {
            insert opp2;
        }
        RecordType testRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea_de_Proyecto__c' LIMIT 1];
        
        Linea_de_Proyecto__c testLine = new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            Sede__c = '1000',
            rate__c = 100.0,
            RecordTypeId = testRecordType.Id, 
            Direccion_cliente__c = 'Test Address',
            Profile_Description__c = 'Test Description',
            n_vacantes__c = 3,
            Estimated_date_of_incorporation__c = Date.today().addMonths(2)
        );
        insert testLine;

        // Simular la solicitud REST con parámetros válidos
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GetCSODdata';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        // Llamar al método
        CornestoneWS.getConerData();

        // Validar el resultado
    
        String responseBody = res.responseBody.toString();
      
    }

    @isTest
    static void testGetConerDataInvalidDates() {
        // Simular la solicitud REST con fechas inválidas
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GetCSODdata';
        req.httpMethod = 'GET';
        req.addParameter('startDate', 'InvalidDate');
        req.addParameter('endDate', 'InvalidDate');
        RestContext.request = req;
        RestContext.response = res;

        // Llamar al método
        CornestoneWS.getConerData();


        String responseBody = res.responseBody.toString();
  
    }


}