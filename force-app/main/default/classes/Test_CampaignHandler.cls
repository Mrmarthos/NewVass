@isTest
private class Test_CampaignHandler 
{
    
	@testSetup
    static void testSceneario() 
    {
        // Insertar dos usuarios
        Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
       
        User u1 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'com1@vass.com',
            Username = 'com1@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u1;
        
        User u2 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'com2@vass.com',
            Username = 'com2@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u2;
        
        // Insertar tres campañas
        List<Campaign> campaigns = new List<Campaign>();
        
        Campaign c1 = new Campaign(
            Name = 'Campaign 1',
            Description = 'First campaign',
            EndDate = Date.newInstance(2018, 12, 16),
            Status = Constants.CAMPAIGN_STATE_PLANIFIED
        );
        campaigns.add(c1);
        
        Campaign c2 = new Campaign(
            Name = 'Campaign 2',
            Description = 'Second campaign',
            EndDate = Date.newInstance(2018, 12, 24),
            Status = Constants.CAMPAIGN_STATE_PLANIFIED
        );
        campaigns.add(c2);
        
        Campaign c3 = new Campaign(
            Name = 'Campaign 3',
            Description = 'Third campaign',
            EndDate = Date.newInstance(2018, 12, 31),
            Status = Constants.CAMPAIGN_STATE_PLANIFIED
        );
        campaigns.add(c3);
        
        insert campaigns;
        
        c1 = [SELECT Id, Name, Status FROM Campaign WHERE Name = 'Campaign 1'];
        c2 = [SELECT Id, Name, Status FROM Campaign WHERE Name = 'Campaign 2'];
        
        // Insertar relaciones; 2 usuarios con campaña 1, 1 usuario con campaña 2, 0 usuarios con campaña 3
        List<Usuario_de_Campana__c> usersToCampaigns = new List<Usuario_de_Campana__c>();
        
       	usersToCampaigns.add(new Usuario_de_Campana__c(
            Campana__c = c1.Id, 
            Usuario__c = u1.Id
        ));
        usersToCampaigns.add(new Usuario_de_Campana__c(
            Campana__c = c1.Id, 
            Usuario__c = u2.Id
        ));
        usersToCampaigns.add(new Usuario_de_Campana__c(
            Campana__c = c2.Id, 
            Usuario__c = u1.Id
        ));

        insert usersToCampaigns;
    }
        
    // Se prueba que se creen un número correcto de tareas
    @isTest
    static void testCreatedTaskNumber() 
    {
        List<Campaign> campList = [SELECT Status FROM Campaign WHERE Name = 'Campaign 1' OR Name = 'Campaign 2'];
        for(Campaign camp : campList)
        {
            camp.Status = Constants.CAMPAIGN_STATE_ACTIVE;
        }
        
        Test.startTest();
        update campList;
        Test.stopTest();
    
    }
    
    // Se prueba el contenido de una tarea, para validar que es el correcto
    @isTest
    static void testTaskContent() 
    {
        Campaign c2 = [SELECT Status FROM Campaign WHERE Name = 'Campaign 2'];
        c2.Status = Constants.CAMPAIGN_STATE_ACTIVE;
        
        Test.startTest();
        update c2;
        Test.stopTest();
        

      
    }
    
    // Se realiza una prueba completa para validar todo
    @isTest
    static void testAll() 
    {
        List<Campaign> campList = [SELECT Status FROM Campaign];
        for(Campaign camp : campList)
        {
            camp.Status = Constants.CAMPAIGN_STATE_ACTIVE;
        }
        
        Test.startTest();
        update campList;
        Test.stopTest();
        
   
     

    }
    
}