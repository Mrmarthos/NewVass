@isTest
private class TestTieneAdjunto {

    @isTest
    static void testAttachmentUpdate() {
        
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




        // 2. Crear un ContentVersion (archivo) para asociarlo a la oportunidad
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testfile.pdf',
            VersionData = Blob.valueOf('Test data'),
            Origin = 'H'
        );
        insert cv;
        system.debug('sdsdsdsdd'+CV);

        // 3. Obtener el ContentDocumentId asociado al ContentVersion
        ContentDocument cd = [SELECT Id FROM ContentDocument];
        Test.stopTest();
        // 4. Crear un ContentDocumentLink para vincular el archivo con la oportunidad
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cd.Id,
            LinkedEntityId = opp1.Id,
            ShareType = 'V', // 'V' para que sea visible para los usuarios
            Visibility = 'AllUsers' // Esto puede variar dependiendo de la configuración de tu org
        );
        insert cdl;

        // 5. Consultar la oportunidad para verificar que el campo 'tieneattachment__c' se actualiza a true
        Opportunity updatedOpp = [SELECT Id, tieneattachment__c FROM Opportunity WHERE Id = :opp1.Id];
      

        // 6. Eliminar el archivo asociado y verificar que el campo 'tieneattachment__c' se actualiza a false
        delete cdl;

        // Consultar la oportunidad después de eliminar el archivo
        updatedOpp = [SELECT Id, tieneattachment__c FROM Opportunity WHERE Id = :opp1.Id];
    
    }

   
}