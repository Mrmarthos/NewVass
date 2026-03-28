@IsTest
public class Test_CSV_Creator {
    
     public static User u1;
    @isTest
    public static void testComment(){
        
        Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
		Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
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
            
            
            //*******************************************/
        }
        List<Account> accs = TestUtil.generaCuentasTest();
        // Insertar dos oportunidades
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();    
        List<Opportunity> opptys = new List<Opportunity>();
        
        Account sede = new Account();
        sede.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        sede.NIF_CIF__c='111111';
        sede.Name='test';
        sede.Razon_Social__c='rtee';
        insert sede;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Bid_Manager__c = u1.Id,
            Offering__c = u1.Id,
            Business_Value__c = u1.Id,
            Mercado__c='Banca-Banca',
            Probability=50,
            Amount=99,
            AccountId=accs.get(0).id,
            Codigo_de_oportunidad__c='VASS1917120987',
            Sede_venta__c=sede.id
        );
        
        opptys.add(opp1);
        insert opptys;
        opptys.get(0).Codigo_de_oportunidad__c='VASS1917120987';
        update opptys;
        
        	
		 // Inserta lineas de proyecto
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            Responsable_de_LDP__c = u1.Id,
            Fecha_Inicio__c=date.newInstance(2019, 01, 01),
            Fecha_Fin__c=date.newInstance(2019, 02, 30),
            Oficina_tecnica__c='1000',
            Sede__c='1000',
            Area__c='ES00T02007',
            Gerencia__c='Digital Experience',
          
            Importe_total_2__c=8000
            
        ));
        
        insert projectLines;
        String oportunidad1 = [SELECT   Id from Opportunity ].id;     
        string cad=[SELECT Body FROM StaticResource WHERE Name = 'CSV' ].Body.toString();
      
        test.startTest();
        CSVObject co=CSVCreator.getCSVObject(cad,oportunidad1);
        CSVCreator.ActualizarLineas(co, cad,'Test', oportunidad1);
        CSVCreator.crearHistorico(EncodingUtil.base64Encode(Blob.valueof(cad)), 'test', oportunidad1);
        
        test.stopTest();
    }
    
      @isTest
    public static void testRate(){
        
        Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
		Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
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
            
            
            //*******************************************/
        }
        List<Account> accs = TestUtil.generaCuentasTest();
        // Insertar dos oportunidades
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();    
        List<Opportunity> opptys = new List<Opportunity>();
        
        Account sede = new Account();
        sede.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        sede.NIF_CIF__c='111111';
        sede.Name='test';
        sede.Razon_Social__c='rtee';
        insert sede;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Bid_Manager__c = u1.Id,
            Offering__c = u1.Id,
            Business_Value__c = u1.Id,
            Mercado__c='Banca-Banca',
            Probability=50,
            Amount=99,
            AccountId=accs.get(0).id,
            Codigo_de_oportunidad__c='VASS2300000574',
            Sede_venta__c=sede.id
        );
        
        opptys.add(opp1);
        insert opptys;
        opptys.get(0).Codigo_de_oportunidad__c='VASS2300000574';
        update opptys;
        
        	
		 // Inserta lineas de proyecto
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            Responsable_de_LDP__c = u1.Id,
            Fecha_Inicio__c=date.newInstance(2019, 01, 01),
            Fecha_Fin__c=date.newInstance(2019, 02, 30),
            Oficina_tecnica__c='1000',
            Sede__c='1000',
            Area__c='ES00T02007',
            Gerencia__c='Digital Experience',
          
            Importe_total_2__c=8000
            
        ));
        
        insert projectLines;
        String oportunidad1 = [SELECT   Id from Opportunity ].id;     
        string cad=[SELECT Body FROM StaticResource WHERE Name = 'CSVRate' ].Body.toString();
    
        test.startTest();
        CSVObject co=CSVCreatorRatecard.getCSVObject(cad,oportunidad1);
        CSVCreatorRatecard.ActualizarLineas(co, cad,'Test', oportunidad1);
        CSVCreatorRatecard.crearHistorico(EncodingUtil.base64Encode(Blob.valueof(cad)), 'test', oportunidad1);
        
        test.stopTest();
    }

}