@isTest
public with sharing class Test_OpportunityTeamMemberHandler
{

    
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
            LocaleSidKey = 'en_US'
        );
        insert u1;

        // Insertar cuentas
    	Account acc = new Account(Name = 'Account 1');
    	insert acc;

    	// Insertar oportunidades
    	Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            AccountId = acc.Id
        );
        insert opp1;
    }

    @isTest
    static void testNewTeamMember()
    {
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	testScenario();

    	Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
    	Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
    	Id acc1Id = [SELECT Id FROM Account WHERE Name = 'Account 1'].Id;

    	OpportunityTeamMember member = new OpportunityTeamMember(
            OpportunityId = opp1Id,
            OpportunityAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_OPPORTUNITY_TEAM,
            UserId = u1Id
        );

        List<AccountShare> accShareBefore = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE UserOrGroupId = :u1Id];

        Test.startTest();

        insert member;

        Test.stopTest();

        List<AccountShare> accShareAfter = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE UserOrGroupId = :u1Id];

        System.assertEquals(0, accShareBefore.size());
        System.assertEquals(1, accShareAfter.size());
        System.assertEquals(acc1Id, accShareAfter.get(0).AccountId);
        System.assertEquals(u1Id, accShareAfter.get(0).UserOrGroupId);
        System.assertEquals(Constants.DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY, accShareAfter.get(0).AccountAccessLevel);
    }

    @isTest
    static void testDuplicateAccountShare()
    {
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	testScenario();

    	Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
    	Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
    	Id acc1Id = [SELECT Id FROM Account WHERE Name = 'Account 1'].Id;

    	AccountShare accShareStart = new AccountShare(
			AccountId = acc1Id,
			UserOrGroupId = u1Id,
			AccountAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY,
			OpportunityAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY
		);
		insert accShareStart;

    	OpportunityTeamMember member = new OpportunityTeamMember(
            OpportunityId = opp1Id,
            OpportunityAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_OPPORTUNITY_TEAM,
            UserId = u1Id
        );

        List<AccountShare> accShareBefore = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE UserOrGroupId = :u1Id];

        Test.startTest();

        insert member;

        Test.stopTest();

        List<AccountShare> accShareAfter = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE UserOrGroupId = :u1Id];

        System.assertEquals(1, accShareBefore.size());
        System.assertEquals(1, accShareAfter.size());
        System.assertEquals(acc1Id, accShareAfter.get(0).AccountId);
        System.assertEquals(u1Id, accShareAfter.get(0).UserOrGroupId);
        System.assertEquals(Constants.DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY, accShareAfter.get(0).AccountAccessLevel);
    }

    @isTest
    static void testOpportunityWithoutAccount()
    {
    	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    	testScenario();

    	Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
    	Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
    	Id acc1Id = [SELECT Id FROM Account WHERE Name = 'Account 1'].Id;

    	Opportunity opp1 = [SELECT Id, AccountId FROM Opportunity WHERE Name = 'Opportunity 1'];
        opp1.AccountId = null;
        update opp1;

        OpportunityTeamMember member = new OpportunityTeamMember(
            OpportunityId = opp1Id,
            OpportunityAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_OPPORTUNITY_TEAM,
            UserId = u1Id
        );

        List<AccountShare> accShareBefore = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE UserOrGroupId = :u1Id];

        Test.startTest();

        insert member;

        Test.stopTest();

        List<AccountShare> accShareAfter = [SELECT AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE UserOrGroupId = :u1Id];

        System.assertEquals(0, accShareBefore.size());
        System.assertEquals(0, accShareAfter.size());
    }


}