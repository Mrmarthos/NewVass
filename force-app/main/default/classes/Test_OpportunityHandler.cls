@isTest
public with sharing class Test_OpportunityHandler 
{

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

        User u2 = new User(
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
            LocaleSidKey = 'en_US',
            Gerente__c=True,
            EmployeeNumber = '0013'
        );
        insert u2;

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

    	Account acc2 = new Account(
    		Name = 'Account 2',
    		RecordTypeId = internalRecordTypeId
		);
		insert acc2;

		Account defAcc = new Account(
			Name = Constants.DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME,
			RecordTypeId = internalRecordTypeId
		);
		insert defAcc;

        Id projectManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).getRecordTypeId();

        Contact con1 = new Contact(
            LastName = 'Contact 1',
            RecordTypeId = projectManagerRecordTypeId,
            AccountId = acc1.Id
        );
        insert con1;

        /*Id regularRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Ordinario').getRecordTypeId();

        Contact con2 = new Contact(
            LastName = 'Contact 2',
            AccountId = acc1.Id,
            RecordTypeId = regularRecordTypeId
        );
        insert con2;*/
    } 
 
 	// Prueba que el codigo de oportunidad se genera de manera correcta en oportunidades individuales
    @isTest
    static void testIndividualOpportunityCodes()
    {
        //testScenario();

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

        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Email = 'resp2@vass.com' LIMIT 1];
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

        Test.stopTest();

        Opportunity opp1After = [SELECT Codigo_de_oportunidad__c FROM Opportunity WHERE Name = 'Opportunity 1' LIMIT 1];
        Opportunity opp2After = [SELECT Codigo_de_oportunidad__c FROM Opportunity WHERE Name = 'Opportunity 2' LIMIT 1];

        System.assertEquals('VASS' + String.valueOf(System.now().year()).substring(2) + '0012' + '0001', opp1After.Codigo_de_oportunidad__c);
        System.assertEquals('VASS' + String.valueOf(System.now().year()).substring(2) + '0013' + '0002', opp2After.Codigo_de_oportunidad__c);
    }

    // Prueba que el codigo de oportunidad se genera de manera correcta en oportunidades consecutivas
    @isTest
    static void testConsecutiveOpportunityCodes()
    {
        //testScenario();

        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        List<Opportunity> opptys = new List<Opportunity>();

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16)
        );
        opptys.add(opp1);

        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16)
        );
        opptys.add(opp2);

        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
 
        Test.startTest();

        System.runAs(u1)
        {
        	insert opptys;
        }

        Test.stopTest();

        Opportunity opp1After = [SELECT Codigo_de_oportunidad__c FROM Opportunity WHERE Name = 'Opportunity 1' LIMIT 1];
        Opportunity opp2After = [SELECT Codigo_de_oportunidad__c FROM Opportunity WHERE Name = 'Opportunity 2' LIMIT 1];

        System.assertEquals('VASS' + String.valueOf(System.now().year()).substring(2) + '0012' + '0001', opp1After.Codigo_de_oportunidad__c);
        System.assertEquals('VASS' + String.valueOf(System.now().year()).substring(2) + '0012' + '0002', opp2After.Codigo_de_oportunidad__c);
    }

    // Prueba que el owner se transfiere de cuenta a oportunidad
    /*@isTest
    static void testAccountOwnerIsOpportunityOwner()
    {
    	User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
    	User u2 = [SELECT Id FROM User WHERE Email = 'resp2@vass.com' LIMIT 1];

    	Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
    	Id internalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();

    	Account accForOppty = new Account(
			Name = 'Account 4',
			RecordTypeId = internalRecordTypeId,
			OwnerId = u1.Id
		);
		insert accForOppty;

		AccountShare accForOpptyShare = new AccountShare(
			AccountId = accForOppty.Id,
			UserOrGroupId = u2.Id,
			AccountAccessLevel = 'Read',
			OpportunityAccessLevel = 'Edit'			
		);
		insert accForOpptyShare;

        Test.startTest();

        System.runAs(u2)
        {
        	insert new Opportunity(
	            Name = 'Opportunity 1',
	            RecordTypeId = preventaRecordTypeId,
	            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
	            CloseDate = Date.newInstance(2018, 12, 16),
	            AccountId = accForOppty.Id
	        );
        }

        Test.stopTest();

        Opportunity opp1After = [SELECT OwnerId FROM Opportunity WHERE Name = 'Opportunity 1' LIMIT 1];

        System.assertNotEquals(u2.Id, opp1After.OwnerId);
        System.assertEquals(u1.Id, opp1After.OwnerId);
    }
	*/
    // Prueba que se rellena de manera automatica (y no cuando ya lo están) los campos de oportunidad
    @isTest
    static void testDefaultRelatedAccount()
    {
    	System.assertEquals(1, [SELECT Id FROM Account WHERE Name = :Constants.DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME LIMIT 1].size());

    	Account acc1 = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];
    	Account acc2 = [SELECT Id FROM Account WHERE Name = 'Account 2' LIMIT 1];
    	Account defAcc = [SELECT Id FROM Account WHERE Name = :Constants.DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME LIMIT 1];
        

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
            CloseDate = Date.newInstance(2018, 12, 16),
            Oficina_tecnica__c = acc1.Id
        );

        Opportunity opp3 = new Opportunity(
            Name = 'Opportunity 3',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Oficina_tecnica__c = acc2.Id,
            Sede_Venta__c = acc1.Id
        );
        Opportunity opp4 = new Opportunity(
            Name = 'Opportunity 3',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_WON,
            CloseDate = Date.newInstance(2018, 12, 16),
            Oficina_tecnica__c = acc2.Id,
            Sede_Venta__c = acc1.Id
        );

    	Test.startTest();

    	insert new List<Opportunity>{ opp1, opp2, opp3 };

    	Test.stopTest();

    	for (Opportunity opp : [SELECT Name, Oficina_tecnica__c, Sede_Venta__c FROM Opportunity])
    	{
    		if (opp.Name == 'Opportunity 1')
    		{
    			System.assertEquals(defAcc.Id, opp.Oficina_tecnica__c);
    			System.assertEquals(defAcc.Id, opp.Sede_Venta__c);
    		}
    		else if (opp.Name == 'Opportunity 2')
    		{
    			System.assertEquals(acc1.Id, opp.Oficina_tecnica__c);
    			System.assertEquals(defAcc.Id, opp.Sede_Venta__c);
    		}
    		else if (opp.Name == 'Opportunity 3')
    		{
    			System.assertEquals(acc2.Id, opp.Oficina_tecnica__c);
    			System.assertEquals(acc1.Id, opp.Sede_Venta__c);
    		}
            else if (opp.Name == 'Opportunity 4')
    		{
    			System.assertEquals(acc2.Id, opp.Oficina_tecnica__c);
    			System.assertEquals(acc1.Id, opp.Sede_Venta__c);
    		}
    	}

    }

    // Prueba de generación automática de oportunidades en base a una oportunidad con licencias ganada


    @isTest
    static void testOpportunityGeneradoraut(){
       
        Account acc1 = [SELECT Id FROM Account WHERE Name = 'Account 1' LIMIT 1];
    	Account acc2 = [SELECT Id FROM Account WHERE Name = 'Account 2' LIMIT 1];
    	Account defAcc = [SELECT Id FROM Account WHERE Name = :Constants.DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME LIMIT 1];

    	Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        Id licencias = Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_LICENSES).getRecordTypeId(); 
    	Id externalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).getRecordTypeId();
        
        acc1 = new Account(
				Name = 'Account 1',
				RecordTypeId = externalRecordTypeId
			);
    		insert acc1;

          Id ordinarioRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).getRecordTypeId();   
        
        Contact con1 = new Contact(
            LastName = 'Contact 1',
            RecordTypeId = ordinarioRecordTypeId,
            AccountId = acc1.Id
        );
        insert con1;

        Id internalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        Account acc33;

  
			acc33 = new Account(
				Name = 'Account 2',
				RecordTypeId = internalRecordTypeId,
                Sede__c = '1000'
			);
    		insert acc33;
    	

        Id projectManagerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).getRecordTypeId();

        Contact con2 = new Contact(
            LastName = 'Contact 2',
            RecordTypeId = projectManagerRecordTypeId,
            AccountId = acc33.Id
        );
        insert con2;

        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            AccountId=acc1.id,
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Amount=1000,
            Sede_venta__c = acc33.id,
            Fecha_de_propuesta_general__c= Date.newInstance(2018, 12, 16),
            Fecha_de_propuesta_economica_tecnica__c=Date.newInstance(2018, 12, 16),
            Contacto_del_cliente__c=con1.id,
            Mercado__c='A.Pub-Admin. Pública'


        );
          insert opp1;
        
        //opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'];
       
        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];

        // Insertar cuatro lineas de proyecto
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            RecordTypeId = licencias,
            Sede__c='1000',
            Fecha_Inicio__c=Date.newInstance(2018, 12, 16),
            Fecha_Fin__c=Date.newInstance(2019, 12, 16),
            Importe_total_2__c=51,
            Responsable_de_LDP__c=u1.id,
            Jefe_de_Proyecto_de_Preventa__c=con2.id,
            Area__c='ES00T02002',
            Coste_estimado__c=50,
            Gerencia__c='Digital Experience',
            Tecnologia__c='DEV'
        ));
        
         insert  projectLines;

         Licencia__c l1;
        l1=new Licencia__c(

            Coste_unitario__c=1500,
            Fecha_de_activacion__c=Date.newInstance(2019, 12, 16),
            Fecha_de_expiracion__c=Date.newInstance(2020, 12, 30),
            Linea_de_Proyecto__c=projectLines.get(0).id,
            Name='test',
            Precio_unitario__c=3000,
            Unidades__c=1

        );
  
        insert l1;

        opp1.StageName = 'Solicitada';
       
        update opp1;
        system.debug(opp1.stageName);
        opp1.StageName = 'Preventa';
        
         update opp1;
         system.debug(opp1.stageName);
         Historial_Excel_Economico__c excelEco = new Historial_Excel_Economico__c(
            Comentarios__c = 'Test Comentarios',     // Comentarios
            Oportunidad__c = opp1.id  // Oportunidad
        );
        insert excelEco;
        
        opp1.StageName = 'Entregada';
        update opp1;
        system.debug(opp1.stageName);
        
        opp1.StageName = 'Presentada';
        update opp1;
        system.debug(opp1.stageName);

        Hito_de_facturacion__c hito1;
        hito1=new  Hito_de_facturacion__c (

            Fecha__c=Date.newInstance(2019, 12, 16),
            //Name='test',
            Oportunidad__c=opp1.id,
            Porcentaje__c=100
        );
        insert hito1;

        
        Test.startTest();
        opp1.StageName = Constants.OPPORTUNITY_STAGE_WON;
        update opp1;
        Test.stopTest();

    }



    @isTest
    static void testOpportunityGenerationForLicensesAndAMs()
    {
        	Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
        
         User u1 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last2',
            Email = 'resp12@vass.com',
            Username = 'resp12@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany2',
            Title = 'Title2',
            Alias = 'Alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            EmployeeNumber = '00122',
            Gerente__c=True
        );
         insert u1;
        Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        //Inserta 2 Oportunidades preventa
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        //Inserta 2 Lineas con 2 Licencias cada una (dentro de la Opp anteior)  
        List<Linea_de_Proyecto__c> lpsL = TestUtil.generaLineasLicenciasTest(opps, conts);
        //Inserta 2 Lineas AM(dentro de la Opp anteior)  
        //List<Linea_de_Proyecto__c> lpsAM = TestUtil.generaLineasAMTest(opps, conts,u1);

        //Las Lineas de Proyecto tienen la fecha de venciomiento establecida en:
        //   									  date.newInstance(2019, 12, 11), 
        //Los datos cargados en Salesforce quedarían estructurados de la siguiente manera

        /////////////////////////////////////////////////////////////////////////////////
        //Opp 1 =>>
        //           LP11 (2019, 12, 11) =>> Licencias (2019, 11, 11)
        //                               =>> Licencias (2019, 12, 11)
        //           LP12 (2019, 12, 11) - AM
        //
        //Opp 2 =>>
        //           LP21 (2019, 12, 11) =>> Licencias (2019, 11, 11)
        //                               =>> Licencias (2019, 12, 11)
        //           LP22 (2019, 12, 11) - AM        
        //////////////////////////////////////////////////////////////////////////////////
        
        //Cuando las Opps cambien su estado a ganada, se generarán Opps para renovar estas licencias
        //para este caso se crearán 3 oportunidades más, una para agrupar las líneas de la Opp2 
        //y dos oportunidades más, una para cubrir la renovación de la licencia de la Opp 1 que caducan en : 2019, 11, 11
        //Y otra para cubrir la Línea de tipo AM de la Opp1 y la Línea de licencia de la Opp1 que finalinza en 2019, 12, 11,
        //esto es así porque las fechas de fin de las Líneas de
        // de la Opp 2, tienen distinto mes informado.

        opps[0].StageName = 'Solicitada';
        opps[1].StageName = 'Solicitada';
        update opps;

        opps[0].StageName = 'Preventa';
        opps[1].StageName = 'Preventa';
        

        opps[0].StageName = 'Entregada';
        opps[1].StageName = 'Entregada';
        

        opps[0].StageName = 'Presentada';
        opps[1].StageName = 'Presentada';
       

        // 1 Oportunidad
        // System.assertEquals(2, [SELECT Count() FROM Opportunity]);

        // // 3 Lineas de proyecto
        // System.assertEquals(4, [SELECT Count() FROM Linea_de_Proyecto__c]);

        // // 4 Licencias
        // System.assertEquals(4, [SELECT Count() FROM Licencia__c]);                                      

        
		Test.startTest();
        opps[0].StageName = Constants.OPPORTUNITY_STAGE_WON;
        opps[1].StageName = Constants.OPPORTUNITY_STAGE_WON;
        

        Test.stopTest();                                      

        // 2 Oportunidades + 3 Oportunidades creadas =5
        //System.assertEquals(5, [SELECT Count() FROM Opportunity]);

        // 1Lineas de proyecto + 1 creadas = 2
        System.assertEquals(2, [SELECT Count() FROM Linea_de_Proyecto__c]);

        // 4 Licencias + 4 creadas =8
      //  System.assertEquals(8, [SELECT Count() FROM Licencia__c]);

    }
    
    @isTest
    static void testCheckMargen()
    {
        //testScenario();

		Id TM= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).getRecordTypeId();
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
         List<Account> accs = TestUtil.generaCuentasTest();
         
        
        Contact jp= new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId,
                    Codigo_de_empleado__c   = '1',
                    FirstName               = 'test',
                    LastName                = 'test',
                    Activo__c               = true,
                    Email                   = 'test@test.es',
                    Phone                   = '6645535535',
                    Department              = 'vass'

               );
         Contact cont= new Contact(
                  
                    FirstName               = 'test2',
                    LastName                = 'test2',
                    Activo__c               = true,
                    Email                   = 'test2@test2.es',
                    Phone                   = '662222222',
                    Department              = 'vass2',
             		AccountID				=accs.get(0).id

               );

        
        insert cont;
        insert jp;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Amount=22,
            Accountid=accs.get(0).id,
            Contacto_del_cliente__c=cont.id,
            Fecha_de_propuesta_general__c=system.today(),
            Fecha_de_propuesta_economica_tecnica__c=system.today(),
            Proyecto_extraordinario__c=true
            
        );
        
		insert opp1;
        
         Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            RecordTypeId = tm,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Amount=22,
            Accountid=accs.get(0).id,
            Contacto_del_cliente__c=cont.id,
            Fecha_de_propuesta_general__c=system.today(),
            Fecha_de_propuesta_economica_tecnica__c=system.today(),
            Proyecto_extraordinario__c=true
        );
        
		insert opp2;
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).getRecordTypeId(),
            Sede__c='1000',
            Gerencia__c='Digital Experience',
            Area__c='ES00T02002',
            Importe_total_2__c=100,
            Coste_estimado__c=90,
            Tecnologia__c='ADO',
            Jefe_de_Proyecto_de_Preventa__c=jp.id
            
            
        ));
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_AM).getRecordTypeId(),
            Sede__c='1000',
            Gerencia__c='Digital Experience',
            Area__c='ES00T02002',
            Importe_total_2__c=100,
            Coste_estimado__c=90,
            Tecnologia__c='ADO',
            Jefe_de_Proyecto_de_Preventa__c=jp.id
            
            
        ));
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp2.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get('TM').getRecordTypeId(),
            Sede__c='1000',
            Gerencia__c='Digital Experience',
            Area__c='ES00T02002',
            Importe_total_2__c=100,
            Coste_estimado__c=90,
            Tecnologia__c='ADO',
            Jefe_de_Proyecto_de_Preventa__c=jp.id
            
            
        ));

        insert projectLines;
        
        Test.startTest();
        opp1.StageName = 'Solicitada';
		
        update opp1;
        opp1.StageName = 'Preventa';
        
        
        update opp1;
        opp1.StageName = 'Entregada';
        update opp1;

    Test.stopTest();    

    }
    
    @isTest
    static void testCheckPrExtra()
    {
        //testScenario();

		Id TM= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).getRecordTypeId();
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
         List<Account> accs = TestUtil.generaCuentasTest();

        
        Contact jp= new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId,
                    Codigo_de_empleado__c   = '1',
                    FirstName               = 'test',
                    LastName                = 'test',
                    Activo__c               = true,
                    Email                   = 'test@test.es',
                    Phone                   = '6645535535',
                    Department              = 'vass'

               );
         Contact cont= new Contact(
                  
                    FirstName               = 'test2',
                    LastName                = 'test2',
                    Activo__c               = true,
                    Email                   = 'test2@test2.es',
                    Phone                   = '662222222',
                    Department              = 'vass2',
             		AccountID				=accs.get(0).id

               );

        
        insert cont;
        insert jp;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Amount=22,
            Accountid=accs.get(0).id,
            Contacto_del_cliente__c=cont.id,
            Fecha_de_propuesta_general__c=system.today(),
            Fecha_de_propuesta_economica_tecnica__c=system.today(),
            Proyecto_extraordinario__c=true
            
        );
        
		insert opp1;
        

        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).getRecordTypeId(),
            Sede__c='1000',
            Gerencia__c='Digital Experience',
            Area__c='ES00T02002',
            Importe_total_2__c=100,
            Coste_estimado__c=20,
            Tecnologia__c='ADO',
            Jefe_de_Proyecto_de_Preventa__c=jp.id
            
            
        ));
  
        

        insert projectLines;
        
        Test.startTest();
        opp1.StageName = 'Solicitada';
		
        update opp1;
        opp1.StageName = 'Preventa';
        
        
        update opp1;
        opp1.StageName = 'Entregada';
        update opp1;

    Test.stopTest();    

    }
    @isTest
    static void testCheckMargenInter()
    {
        //testScenario();
		
		Id TM= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).getRecordTypeId();
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
         List<Account> accs = TestUtil.generaCuentasTest();
         
        
        Contact jp= new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId,
                    Codigo_de_empleado__c   = '1',
                    FirstName               = 'test',
                    LastName                = 'test',
                    Activo__c               = true,
                    Email                   = 'test@test.es',
                    Phone                   = '6645535535',
                    Department              = 'vass'

               );
         Contact cont= new Contact(
                  
                    FirstName               = 'test2',
                    LastName                = 'test2',
                    Activo__c               = true,
                    Email                   = 'test2@test2.es',
                    Phone                   = '662222222',
                    Department              = 'vass2',
             		AccountID				=accs.get(0).id

               );

        
        insert cont;
        insert jp;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Amount=22,
            Accountid=accs.get(0).id,
            Contacto_del_cliente__c=cont.id,
            Fecha_de_propuesta_general__c=system.today(),
            Fecha_de_propuesta_economica_tecnica__c=system.today()
            
        );
        
		insert opp1;
        

        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).getRecordTypeId(),
            Sede__c='1110',
            Org_Ventas__c='1110',
            Gerencia__c='Nateevo - Experience',
            Area__c='NT00T03001',
            Importe_total_2__c=100, 
            Coste_estimado__c=20,
            Tecnologia__c='ADO',
            Jefe_de_Proyecto_de_Preventa__c=jp.id,
            Margen_Intercompany__c=1
            
            
        ));
  
        

        insert projectLines;
        
        Test.startTest();
        opp1.StageName = 'Solicitada';
		
        update opp1;
        opp1.StageName = 'Preventa';
        
        
        update opp1;
        opp1.StageName = 'Entregada';
        update opp1;

   Test.stopTest();    

    }
    @isTest
    static void testCheckImporte()
    {
        
        //testScenario();

		Id TM= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).getRecordTypeId();
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
         List<Account> accs = TestUtil.generaCuentasTest();
         
        
        Contact jp= new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId,
                    Codigo_de_empleado__c   = '1',
                    FirstName               = 'test',
                    LastName                = 'test',
                    Activo__c               = true,
                    Email                   = 'test@test.es',
                    Phone                   = '6645535535',
                    Department              = 'vass'

               );
         Contact cont= new Contact(
                  
                    FirstName               = 'test2',
                    LastName                = 'test2',
                    Activo__c               = true,
                    Email                   = 'test2@test2.es',
                    Phone                   = '662222222',
                    Department              = 'vass2',
             		AccountID				=accs.get(0).id

               );

        
        insert cont;
        insert jp;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Amount=500000,
            Accountid=accs.get(0).id,
            Contacto_del_cliente__c=cont.id,
            Fecha_de_propuesta_general__c=system.today(),
            Fecha_de_propuesta_economica_tecnica__c=system.today()

            
        );
        
		insert opp1;
      
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).getRecordTypeId(),
            Sede__c='1000',
            Gerencia__c='Digital Experience',
            Area__c='ES00T02002',
            Importe_total_2__c=500000,
            Coste_estimado__c=90,
            Tecnologia__c='ADO',
            Jefe_de_Proyecto_de_Preventa__c=jp.id
            
            
        ));
       
        insert projectLines;
        
        
        Test.startTest();
        opp1.StageName = 'Solicitada';
		
        update opp1;
        opp1.StageName = 'Preventa';
        
        
        update opp1;
        opp1.StageName = 'Entregada';
        update opp1;

    Test.stopTest();    

    }
    
    
      @isTest
    static void testVentaExtra()
    {
        //testScenario();

		Id TM= Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).getRecordTypeId();
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        User u1 = [SELECT Id FROM User WHERE Email = 'resp1@vass.com' LIMIT 1];
         List<Account> accs = TestUtil.generaCuentasTest();

        
        Contact jp= new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId,
                    Codigo_de_empleado__c   = '1',
                    FirstName               = 'test',
                    LastName                = 'test',
                    Activo__c               = true,
                    Email                   = 'test@test.es',
                    Phone                   = '6645535535',
                    Department              = 'vass'

               );
         Contact cont= new Contact(
                  
                    FirstName               = 'test2',
                    LastName                = 'test2',
                    Activo__c               = true,
                    Email                   = 'test2@test2.es',
                    Phone                   = '662222222',
                    Department              = 'vass2',
             		AccountID				=accs.get(0).id

               );

        
        insert cont;
        insert jp;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Amount=22,
            Accountid=accs.get(0).id,
            Contacto_del_cliente__c=cont.id,
            Fecha_de_propuesta_general__c=system.today(),
            Fecha_de_propuesta_economica_tecnica__c=system.today()
           
            
        );
        
		insert opp1;
        

        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
            Responsable_de_LDP__c = u1.Id,
            RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).getRecordTypeId(),
            Sede__c='1000',
            Gerencia__c='Digital Experience',
            Area__c='ES00T02002',
            Importe_total_2__c=100,
            Coste_estimado__c=20,
            Tecnologia__c='ADO',
            Venta_Extraordinaria__c=true,
            Jefe_de_Proyecto_de_Preventa__c=jp.id
            
            
        ));
  
        

        insert projectLines;
        
        Test.startTest();
        opp1.StageName = 'Solicitada';
		
        update opp1;
        opp1.StageName = 'Preventa';
        
        
        update opp1;
        opp1.StageName = 'Entregada';
        update opp1;

    Test.stopTest();    

    }
}