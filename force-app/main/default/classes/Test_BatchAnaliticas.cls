@isTest
public class Test_BatchAnaliticas {
    
    public static User u1;
    
    @isTest
    static void testGenerar(){
        
        Account cuenta= new Account(Name='test_BATCH',Razon_Social__c='test2_BATCH',NIF_CIF__c='9233923923-A');
        insert cuenta;
        Analitica__c analitica = new Analitica__c(Importe__c=1,Presupuesto__c=2,Cuenta__c=cuenta.id,RecordTypeid=Schema.SObjectType.Analitica__c.getRecordTypeInfosByName().get('ForecastDeLinea').getRecordTypeId());
        
        insert analitica;
        
        
         Test.startTest();
          
        SchedulableContext sc = null;
        ScheludableHsitoricoAnaliticas tsc = new ScheludableHsitoricoAnaliticas();
        tsc.execute(sc);
	
        Test.stopTest();
        
        List<Historico_Analiticas__c> ha= [Select Importe__c from Historico_Analiticas__c ];
        
        system.equals(1, ha.get(0).Importe__c);
        
        
        
    }
    
        @isTest
    static void testGenerarLicencias(){
        
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
            
            
            //*******************************************/
        }
        List<Account> accs = TestUtil.generaCuentasTest();
        // Insertar dos oportunidades
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();    
        List<Opportunity> opptys = new List<Opportunity>();
        List<Opportunity> opptys2 = new List<Opportunity>();
        
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
            Probability=75,
            Amount=99,
            AccountId=accs.get(0).id,
            Sede_venta__c=sede.id
        );
        
        opptys.add(opp1);
        insert opptys;
        
        
        // Inserta lineas de proyecto
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
            recordtypeid= Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_LICENSES).getRecordTypeId(),

            Importe_total_2__c=8000
            
        ));
        
        insert projectLines ;
        
           Licencia__c l1;
        l1=new Licencia__c(

            Coste_unitario__c=2999,
            Fecha_de_activacion__c=Date.newInstance(2019, 12, 16),
            Fecha_de_expiracion__c=Date.newInstance(2020, 12, 30),
            Linea_de_Proyecto__c=projectLines.get(0).id,
            Name='test',
            Precio_unitario__c=3000,
            Unidades__c=1,
            Activa__c=True

        );
        
        insert l1;
       
  
        
        
        test.startTest();
        Batch_Generador_Forecast uca = new Batch_Generador_Forecast();
        
         Database.executeBatch(uca,25);
        
        Test.stopTest();
        
      //  List<Historico_Analiticas__c> ha= [Select Importe__c from Historico_Analiticas__c ];
        

        
        
    }

}