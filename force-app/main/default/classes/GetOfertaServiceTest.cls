@isTest
private class GetOfertaServiceTest {
    @isTest
    static void testGetOferta() {
        // Create test Opportunity record with necessary fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Codigo_de_oportunidad__c = 'TEST123',
            StageName = 'Identificada',
            Amount=11,
            CloseDate = Date.today()
        );
        insert opp;

        // Create test Historial_Excel_Economico__c record linked to Opportunity
        Historial_Excel_Economico__c hist = new Historial_Excel_Economico__c(
            Oportunidad__c = opp.Id
        );
        insert hist;

            // Insert ContentVersion
            ContentVersion cv = new ContentVersion(
                Title = 'TestFile',
                VersionData = Blob.valueOf('Test data'),
                PathOnClient = 'TestFile.csv',
                IsMajorVersion = true
            );
            insert cv;
            
            // After insertion, get the related ContentDocumentId from the inserted ContentVersion
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            
            // Now create ContentDocumentLink with this ContentDocumentId
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = hist.Id,
                ShareType = 'V'
            );
insert cdl;
		String code= [Select Codigo_de_oportunidad__c  from Opportunity limit 1  ].Codigo_de_oportunidad__c;
        // Setup REST Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('codoferta',code);
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        GetOfertaService.getOferta();
        Test.stopTest();

        // Assert response status code is 200 OK
        System.assertEquals(200, RestContext.response.statusCode);

        // Assert that the responseBody contains expected JSON keys
        String responseBody = RestContext.response.responseBody.toString();
        System.assert(responseBody.contains('stageName'));
        System.assert(responseBody.contains('FileName'));
        System.assert(responseBody.contains('versionNumber'));
        System.assert(responseBody.contains('fileBase64'));
    }
    
      @isTest
    static void testGetOferta400() {
        // Create test Opportunity record with necessary fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Codigo_de_oportunidad__c = 'TEST123',
            StageName = 'Identificada',
            Amount=11,
            CloseDate = Date.today()
        );
        insert opp;

        // Create test Historial_Excel_Economico__c record linked to Opportunity
        Historial_Excel_Economico__c hist = new Historial_Excel_Economico__c(
            Oportunidad__c = opp.Id
        );
        insert hist;

            // Insert ContentVersion
            ContentVersion cv = new ContentVersion(
                Title = 'TestFile',
                VersionData = Blob.valueOf('Test data'),
                PathOnClient = 'TestFile.csv',
                IsMajorVersion = true
            );
            insert cv;
            
            // After insertion, get the related ContentDocumentId from the inserted ContentVersion
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            
            // Now create ContentDocumentLink with this ContentDocumentId
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = hist.Id,
                ShareType = 'V'
            );
insert cdl;
		String code= [Select Codigo_de_oportunidad__c  from Opportunity limit 1  ].Codigo_de_oportunidad__c;
        // Setup REST Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('codoferta','22');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        GetOfertaService.getOferta();
        Test.stopTest();

        // Assert response status code is 200 OK
        System.assertEquals(404, RestContext.response.statusCode);

    }
    
         @isTest
    static void testGetOferta404() {
        // Create test Opportunity record with necessary fields
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            Codigo_de_oportunidad__c = 'TEST123',
            StageName = 'Identificada',
            Amount=11,
            CloseDate = Date.today()
        );
        insert opp;

        // Create test Historial_Excel_Economico__c record linked to Opportunity
        Historial_Excel_Economico__c hist = new Historial_Excel_Economico__c(
            Oportunidad__c = opp.Id
        );
        insert hist;

            // Insert ContentVersion
            ContentVersion cv = new ContentVersion(
                Title = 'TestFile',
                VersionData = Blob.valueOf('Test data'),
                PathOnClient = 'TestFile.csv',
                IsMajorVersion = true
            );
            insert cv;
            
            // After insertion, get the related ContentDocumentId from the inserted ContentVersion
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
            
            // Now create ContentDocumentLink with this ContentDocumentId
            ContentDocumentLink cdl = new ContentDocumentLink(
                ContentDocumentId = contentDocumentId,
                LinkedEntityId = hist.Id,
                ShareType = 'V'
            );
insert cdl;
		String code= [Select Codigo_de_oportunidad__c  from Opportunity limit 1  ].Codigo_de_oportunidad__c;
        // Setup REST Context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.params.put('codoferta','');
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        GetOfertaService.getOferta();
        Test.stopTest();

        // Assert response status code is  OK
        System.assertEquals(400,RestContext.response.statusCode);

    }
}