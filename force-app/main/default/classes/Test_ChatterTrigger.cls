@IsTest
public class Test_ChatterTrigger {
    
    @testSetup
	private static void testScenario()
    {
        // Insertar usuarios
    	Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
       
        User u1 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp1@vass.com',
            Username = 'resp1@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = '0012',
            Gerente__c=True
        );
        insert u1;

  
        Id internalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        Account acc1;

        System.runAs(u1)
        {
			acc1 = new Account(
				Name = 'Account 1',
				RecordTypeId = internalRecordTypeId
			);
    		insert acc1;
    	}

    	

		Account defAcc = new Account(
			Name = Constants.DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME,
			RecordTypeId = internalRecordTypeId
		);
		insert defAcc;

        Id projectManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).getRecordTypeId();

      
    }
        @isTest
    public static void testComment(){
        
	Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16)
        );       
        insert opp1;
        FeedItem  chatter =  new FeedItem();
        
        chatter.ParentId=opp1.Id;
        chatter.Type='TextPost';
        chatter.Body='Test';
        insert chatter;
        
    }
    
 
    

}