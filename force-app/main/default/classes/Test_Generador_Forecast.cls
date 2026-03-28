@isTest

public class Test_Generador_Forecast{
    // ******************* TEST INDIVIDUALES Y CASOS ESPECIALES ******************* 
    // 
    
    public static User u1;
    public static User u2;
    public static User u3;
    public static User u4;
    public static User u5;
    public static User u6;
    public static User u7;
    
    @isTest
    static void ForecastImpxprob() 
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
            Probability=50,
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
            Importe_total_2__c=8000
            
        ));
        
        insert projectLines;
        
        
        integer i=0;
        List<Linea_de_Proyecto__c>   linea = new List<Linea_de_Proyecto__c>();
        List<Opportunity>   Oportunidad1 = new List<Opportunity>();
        
        integer prob =0;
        linea = [SELECT   Id,
                 Gerencia__c,
                 Area__c, 
                 CurrencyISOCode,
                 Oportunidad__r.OwnerId,
                 RecordType.Name, 
                 Oportunidad__r.AccountId,
                 Duracion_de_Linea__c, 
                 Importe_prorrateado_x_prob__c, 
                 Fecha_Inicio__c,
                 Fecha_Fin__c,
                 Duracion_lineas_por_meses__c,
                 Importe_a_elevar__c,
                 Coste_real__c,
                 Oportunidad__c,
                 Oportunidad__r.probability,
                 Oportunidad__r.Sede_Venta__c,
                 Oportunidad__r.Owner.Name,
                 Oportunidad__r.Multibooking__c,
                 Oportunidad__r.mercado__c,
                 Oficina_tecnica__c,
                 EsIntercompany__c,
                 Sede__c,
                 Importe_Total_Intercompany__c,
                 Importe_x_Prob__c 
                 from Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1.id
                 
                 
                ];
        Oportunidad1 = [SELECT   Id,probability,StageName  ,Importe_total__c,Fecha_de_fin__c,Fecha_de_inicio__c,Multibooking__c,SumaImportesIntercompany__c from Opportunity  where Id= :opp1.id];     
        map<Id,Opportunity>  oportunidad = new map<Id,Opportunity> ();
        oportunidad.put(Oportunidad1.get(0).Id, Oportunidad1.get(0));   
        
        
        test.startTest();
        GeneradorForecast.GenerarForecastNuevasLineas(linea, 'opor');
    
        List<Analitica__c> analitica = [SELECT Id ,Importe_Forecast__c,tipo__c,GeneradoIntercompany__c FROM Analitica__c WHERE   Oportunidad__c =:opp1.id];
        
        Decimal SumProb=0;
		system.debug('Anaaaliticaa' +analitica );        
        ///sumamos importe por ortundidad  
        for (Analitica__c ana: analitica){
            if(ana.tipo__c=='ForecastDeOportunidades' && ana.GeneradoIntercompany__c==false )
            	SumProb+=ana.Importe_Forecast__c;
           
        }
        //(8000x50prob=4000 )
 		system.assertEquals(Integer.Valueof(SumProb), 4000);
        
        opp1.Probability=80;
        update opp1;
        GeneradorForecast.GenerarForecastNuevasLineas(linea,'Linea');
        List<Analitica__c> analitica2 = [SELECT Id ,Importe_Forecast__c,tipo__c,GeneradoIntercompany__c FROM Analitica__c WHERE   Oportunidad__c =:opp1.id and Tipo__c='ForecastDeLinea'];
     
        Decimal Sumlinea=0;
        
        ///sumamos importe por ortundidad  
        for (Analitica__c ana: analitica2){
            if(ana.tipo__c=='ForecastDeLinea' && ana.GeneradoIntercompany__c==false )
            	Sumlinea+=ana.Importe_Forecast__c;
           
        }
        system.assertEquals(Integer.Valueof(Sumlinea), 8000);
        
           GeneradorForecast.ModificarForecast(projectLines);
           GeneradorForecast.GenerarForecastOportunidad(opptys);
			GeneradorForecast.ModificarForecastFromOpportunity(opptys,1);
        
   		
        test.stopTest();
       
        system.assertEquals(GeneradorForecast.CumpleCondicionesOportunidadForecast(Oportunidad1,oportunidad),0);
        


    }
    
    
    
     @isTest
    static void ForecastInter() 
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
        sede.sede__c='1110';
        sede.Sede_Analitica__c='1000';
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
            Importe_total_2__c=8000
            
        ));
        
        insert projectLines;
        
        
        integer i=0;
        List<Linea_de_Proyecto__c>   linea = new List<Linea_de_Proyecto__c>();
        List<Opportunity>   Oportunidad1 = new List<Opportunity>();
        
        integer prob =0;
        linea = [SELECT   Id,
                 Gerencia__c,
                 Area__c, 
                 CurrencyISOCode,
                 Oportunidad__r.OwnerId,
                 RecordType.Name, 
                 Oportunidad__r.AccountId,
                 Duracion_de_Linea__c, 
                 Importe_prorrateado_x_prob__c, 
                 Fecha_Inicio__c,
                 Fecha_Fin__c,
                 Duracion_lineas_por_meses__c,
                 Importe_a_elevar__c,
                 Coste_real__c,
                 Oportunidad__c,
                 Oportunidad__r.probability,
                 Oportunidad__r.Sede_Venta__c,
                 Oportunidad__r.Owner.Name,
                 Oportunidad__r.Multibooking__c,
                 Oportunidad__r.mercado__c,
                 Oficina_tecnica__c,
                 EsIntercompany__c,
                 Sede__c,
                 Importe_Total_Intercompany__c,
                 Importe_x_Prob__c 
                 from Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1.id
                 
                 
                ];
        Oportunidad1 = [SELECT   Id,probability,StageName  ,Importe_total__c,Fecha_de_fin__c,Fecha_de_inicio__c,Multibooking__c,SumaImportesIntercompany__c from Opportunity  where Id= :opp1.id];     
        map<Id,Opportunity>  oportunidad = new map<Id,Opportunity> ();
        oportunidad.put(Oportunidad1.get(0).Id, Oportunidad1.get(0));   
        
        
        test.startTest();
        GeneradorForecast.GenerarForecastNuevasLineas(linea, 'opor');
    
        List<Analitica__c> analitica = [SELECT Id ,Importe_Forecast__c,tipo__c,GeneradoIntercompany__c FROM Analitica__c WHERE   Oportunidad__c =:opp1.id];
        
        Decimal SumProb=0;
		system.debug('Anaaaliticaa' +analitica );        
        ///sumamos importe por ortundidad  
        for (Analitica__c ana: analitica){
            if(ana.tipo__c=='ForecastDeOportunidades' && ana.GeneradoIntercompany__c==false )
            	SumProb+=ana.Importe_Forecast__c;
           
        }
        //(8000x50prob=4000 )
 		//system.assertEquals(Integer.Valueof(SumProb), 4000);
        
        opp1.Probability=80;
        update opp1;
        GeneradorForecast.GenerarForecastNuevasLineas(linea,'Linea');
        List<Analitica__c> analitica2 = [SELECT Id ,Importe_Forecast__c,tipo__c,GeneradoIntercompany__c FROM Analitica__c WHERE   Oportunidad__c =:opp1.id and Tipo__c='ForecastDeLinea'];
     
        Decimal Sumlinea=0;
        
        ///sumamos importe por ortundidad  
        for (Analitica__c ana: analitica2){
            if(ana.tipo__c=='ForecastDeLinea' && ana.GeneradoIntercompany__c==false )
            	Sumlinea+=ana.Importe_Forecast__c;
           
        }
        //system.assertEquals(Integer.Valueof(Sumlinea), 8000);
        
           GeneradorForecast.ModificarForecast(projectLines);
           GeneradorForecast.GenerarForecastOportunidad(opptys);
			GeneradorForecast.ModificarForecastFromOpportunity(opptys,1);
        
   		
        test.stopTest();
       
       // system.assertEquals(GeneradorForecast.CumpleCondicionesOportunidadForecast(Oportunidad1,oportunidad),0);
        


    }
    
    
       @isTest
    static void ForecastLicencias() 
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
        integer i=0;
        List<Linea_de_Proyecto__c>   linea = new List<Linea_de_Proyecto__c>();
        List<Opportunity>   Oportunidad1 = new List<Opportunity>();
        
        integer prob =0;
        linea = [SELECT   Id,
                 Gerencia__c,
                 Area__c, 
                 CurrencyISOCode,
                 Oportunidad__r.OwnerId,
                 RecordType.Name, 
                 Oportunidad__r.AccountId,
                 Duracion_de_Linea__c, 
                 Importe_prorrateado_x_prob__c, 
                 Fecha_Inicio__c,
                 Fecha_Fin__c,
                 Duracion_lineas_por_meses__c,
                 Importe_a_elevar__c,
                 Coste_real__c,
                 Oportunidad__c,
                 Oportunidad__r.probability,
                 Oportunidad__r.Sede_Venta__c,
                 Oportunidad__r.Owner.Name,
                 Oportunidad__r.Multibooking__c,
                 Oportunidad__r.mercado__c,
                 Oficina_tecnica__c,
                 EsIntercompany__c,
                 Sede__c,
                 Importe_Total_Intercompany__c,
                 Importe_x_Prob__c 
                 from Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1.id
                 
                 
                ];
        Oportunidad1 = [SELECT   Id,probability,StageName  ,Importe_total__c,Fecha_de_fin__c,Fecha_de_inicio__c,Multibooking__c,SumaImportesIntercompany__c from Opportunity  where Id= :opp1.id];     
        map<Id,Opportunity>  oportunidad = new map<Id,Opportunity> ();
        oportunidad.put(Oportunidad1.get(0).Id, Oportunidad1.get(0));   
        
        
        test.startTest();
        GeneradorForecast.GenerarForecastNuevasLineas(linea,'Linea');
        test.stopTest();
            
    
    }


    @isTest
    static void GenerarForecastNuevasLineas_Test(){
         // Inserta lineas de proyecto
         List<Linea_de_Proyecto__c> lineasDeProyecto = new List<Linea_de_Proyecto__c>();
         List<Opportunity> opptys = new List<Opportunity>();
         List<Account> accs = TestUtil.generaCuentasTest();
         Id licenciaID = [select Id,Name from RecordType where sObjectType='Linea_de_Proyecto__c' AND name = 'Licencias'].id;
         Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
         User admin = [SELECT Id FROM User WHERE ProfileId =: adminProfileId AND IsActive = true LIMIT 1];
         Account sede = new Account();
         Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();    
         Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
        sede.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        sede.NIF_CIF__c='111111';
        sede.Name='test';
        sede.Razon_Social__c='rtee';
        insert sede;

        
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
            Sede_venta__c=sede.id
        );
        
        opptys.add(opp1);
        insert opptys;
        
        lineasDeProyecto.add(new Linea_de_Proyecto__c(
            RecordTypeId = licenciaID,
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
         
         insert lineasDeProyecto;

         Licencia__c l1;
        l1=new Licencia__c(

            Coste_unitario__c=2999,
            Fecha_de_activacion__c=Date.newInstance(2019, 12, 16),
            Fecha_de_expiracion__c=Date.newInstance(2020, 12, 30),
            Linea_de_Proyecto__c=lineasDeProyecto.get(0).id,
            Name='test',
            Precio_unitario__c=3000,
            Unidades__c=1,
            Activa__c=True

        );
        insert l1;

         //llamará a este método para intentar replicar la llamada desde el trigger serializeandGenerateForecastLinea
         GeneradorForecast.serializeandGenerateForecastLinea(lineasDeProyecto,'Licencias');

         }
    }


    @isTest
    static void GenerarForecastNuevasLineasLicenciasIntercompany_Test(){
         // Inserta lineas de proyecto
         List<Linea_de_Proyecto__c> lineasDeProyecto = new List<Linea_de_Proyecto__c>();
         List<Opportunity> opptys = new List<Opportunity>();
         List<Account> accs = TestUtil.generaCuentasTest();
         accs.get(0).Sede_Analitica__c = '1100';
         update accs;
         Id licenciaID = [select Id,Name from RecordType where sObjectType='Linea_de_Proyecto__c' AND name = 'Licencias'].id;
         Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
         User admin = [SELECT Id FROM User WHERE ProfileId =: adminProfileId AND IsActive = true LIMIT 1];
         Account sede = new Account();
         Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();    
         Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
        sede.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        sede.NIF_CIF__c='111111';
        sede.Name='test';
        sede.Razon_Social__c='rtee';
        insert sede;

        
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
            Sede_venta__c=sede.id
        );
        
        opptys.add(opp1);
        insert opptys;
        
        lineasDeProyecto.add(new Linea_de_Proyecto__c(
            RecordTypeId = licenciaID,
             Oportunidad__c = opp1.Id,
             Venta_Extraordinaria__c = true,
             Responsable_de_LDP__c = u1.Id,
             Fecha_Inicio__c=date.newInstance(2019, 01, 01),
             Fecha_Fin__c=date.newInstance(2019, 02, 30),
             Oficina_tecnica__c='1000',
             Sede__c='1100',
             Area__c='ES00T02002',
             Gerencia__c='Digital Experience',
             Importe_total_2__c=8000
             
         ));
         
         insert lineasDeProyecto;

         Licencia__c l1;
        l1=new Licencia__c(

            Coste_unitario__c=2999,
            Fecha_de_activacion__c=Date.newInstance(2019, 12, 16),
            Fecha_de_expiracion__c=Date.newInstance(2020, 12, 30),
            Linea_de_Proyecto__c=lineasDeProyecto.get(0).id,
            Name='test',
            Precio_unitario__c=3000,
            Unidades__c=1,
            Activa__c=True

        );
        insert l1;

         //llamará a este método para intentar replicar la llamada desde el trigger serializeandGenerateForecastLinea
         GeneradorForecast.serializeandGenerateForecastLinea(lineasDeProyecto,'Licencias');

         }
    }

    @isTest
    static void GenerarForecastNuevasLineasIntercompany_Test(){
         // Inserta lineas de proyecto
         List<Linea_de_Proyecto__c> lineasDeProyecto = new List<Linea_de_Proyecto__c>();
         List<Opportunity> opptys = new List<Opportunity>();
         List<Account> accs = TestUtil.generaCuentasTest();
         accs.get(0).Sede_Analitica__c = '2110';
         update accs;
         Id licenciaID = [SELECT Id,Name from RecordType where sObjectType='Linea_de_Proyecto__c' AND name = 'Rate Card'].id;
         Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
         User admin = [SELECT Id FROM User WHERE ProfileId =: adminProfileId AND IsActive = true LIMIT 1];
         Account sede = new Account();
         Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();    
         Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
        sede.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        sede.NIF_CIF__c='111111';
        sede.Name='test';
        sede.Razon_Social__c='rtee';
        insert sede;

        
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
                 LocaleSidKey = 'en_US',
                 sede__c = '4410'
             );
             insert u1;
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
            Sede_venta__c=sede.id
        );
        
        opptys.add(opp1);
        insert opptys;
        
        
            lineasDeProyecto.add(new Linea_de_Proyecto__c(
            RecordTypeId = licenciaID,
             Oportunidad__c = opp1.Id,
             Venta_Extraordinaria__c = true,
             Responsable_de_LDP__c = u1.Id,
             Fecha_Inicio__c=date.newInstance(2019, 01, 01),
             Fecha_Fin__c=date.newInstance(2019, 02, 30),
             Oficina_tecnica__c='1000',
             Sede__c='2110',
             Area__c='ES00T02002',
             Gerencia__c='Digital Experience',
             Importe_total_2__c=8000
             
         ));
         
         insert lineasDeProyecto;
        
        

         Licencia__c l1;
        l1=new Licencia__c(

            Coste_unitario__c=2999,
            Fecha_de_activacion__c=Date.newInstance(2019, 12, 16),
            Fecha_de_expiracion__c=Date.newInstance(2020, 12, 30),
            Linea_de_Proyecto__c=lineasDeProyecto.get(0).id,
            Name='test',
            Precio_unitario__c=3000,
            Unidades__c=1,
            Activa__c=True

        );
        insert l1;

        List<Linea_de_Proyecto__c> lps = [select id,EsIntercompany__c,Comprobacion_Fecha__c,No_aplica_para_ejecucion__c,Agrupacion_Tipo_Registro__c from Linea_de_Proyecto__c];
        for (Linea_de_Proyecto__c lp : lps) {
            system.debug('Linea de proyecto EsIntercompany__c---> '+lp.EsIntercompany__c);
            system.debug('Linea de proyecto Comprobacion_Fecha__c---> '+lp.Comprobacion_Fecha__c);
            system.debug('Linea de proyecto No_aplica_para_ejecucion__c---> '+lp.No_aplica_para_ejecucion__c);
            system.debug('Linea de proyecto Agrupacion_Tipo_Registro__c---> '+lp.Agrupacion_Tipo_Registro__c);
        }

         //llamará a este método para intentar replicar la llamada desde el trigger serializeandGenerateForecastLinea
         GeneradorForecast.serializeandGenerateForecastLinea(lineasDeProyecto,'Lineas');

         }
    }
}