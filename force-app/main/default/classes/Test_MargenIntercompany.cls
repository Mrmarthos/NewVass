@isTest
public class Test_MargenIntercompany {
       public static User u1;
    public static User u2;
    public static User u3;
    public static User u4;
    public static User u5;
    public static User u6;
    public static User u7; 
    @testSetup
    static void testScenario() 
    {
        // Insertar 5 usuarios
        Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
        Id gerenteOperacionesRolId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Gerente_de_operaciones'].Id;        
        Id responsableAreaRolId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Responsable_de_area'].Id;
        User admin = [SELECT Id FROM User WHERE ProfileId =: adminProfileId AND IsActive = true LIMIT 1];
       
       System.runAs(admin){
         u1 = new User(
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
            Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u1;
        
         u2 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp2@vass.com',
            Username = 'resp2@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
                         Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u2;


       

        // Insertar dos oportunidades
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        List<Opportunity> opptys = new List<Opportunity>();

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Bid_Manager__c = u2.Id,
            Offering__c = u2.Id,
            Business_Value__c = u1.Id
        );
        opptys.add(opp1);
        
       

              
        insert opptys;
        
        opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'];
        
        // Insertar cuatro lineas de proyecto
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            Responsable_de_LDP__c = u1.Id,
          Fecha_Inicio__c=date.newInstance(2019, 01, 01),
            Fecha_Fin__c=date.newInstance(2019, 02, 30),
            Oficina_tecnica__c='1000',
            Sede__c='1000',
            Area__c='ES00T02002',
            Gerencia__c='Digital Experience',
            Importe_total_2__c=8000
       
        ));
    



        insert projectLines;
       }
    }
    
	@isTest    
    static void testMargen(){
        
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'];
      

        Linea_de_Proyecto__c lp= new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
             Fecha_Inicio__c=date.newInstance(2019, 01, 01),
            Fecha_Fin__c=date.newInstance(2019, 02, 30),
            Oficina_tecnica__c='1000',
            Sede__c='1000',
            Area__c='ES00T02002',
            Gerencia__c='Digital Experience',
            Importe_total_2__c=8000
       
        );
    
	


        insert lp;
        
        lp.Margen_Intercompany__c=2;
        update lp;
        

        
        
        
        
    }


}