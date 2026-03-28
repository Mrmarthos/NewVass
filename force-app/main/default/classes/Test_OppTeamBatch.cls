@isTest
public  class Test_OppTeamBatch {
    
    @testSetup
    static void testScenario() 
    {
        List<Opportunity> opps = new List<Opportunity>();

        Id sysAdminId = [SELECT Id FROM Profile WHERE Name like '%System Admin%'].Id;
        User usuarioSede = new User(
            ProfileId = sysAdminId,
            EmployeeNumber = '0000301',
            LastName = 'last',
            Email = 'resp1@vass.com.invalid',
            Username = 'resp1@vass.com.invalid.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Gerente__c=True,
            LocaleSidKey = 'en_US',
            Sede__c = '1000'
        );

        insert usuarioSede;

        Map<String, List<Object>> camposMapAcc = new Map<String, List<Object>>
        {
            'Name' => new List<String>{'AccTest1', 'AccTest2', 'AccTest3'},
            'Sede__c' => new List<String>{'2110', '2110', '2110'},
            'oficina_tecnica_SAP__c' => new List<String>{'1000', '1000', '1000'},
            'Mercado__c' => new List<String>{'Industria-Industria', 'Industria-Industria', 'Industria-Industria'},
            'ID_SAP__c' => new List<String>{'IDSAPTEST1','IDSAPTEST2', 'IDSAPTEST3'},
            'NIF_CIF__c' => new List<String>{'NIFCIF1','NIFCIF2', 'NIFCIF3'},
            'Razon_social__c' => new List<String>{'CUENTATEST1','CUENTATEST2', 'CUENTATEST3'},
            'BillingCountryCode' => new List<String>{'ES','ES', 'ES'},
            'SAP_Grupo_ID__c' => new List<String>{'IDSAPTEST1','IDSAPTEST2', 'IDSAPTEST3'},
            'CurrencyIsoCode' => new List<String>{'EUR','EUR', 'EUR'},
            'Validacion_NIF__c' => new List<Boolean>{true,true,true},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).RecordTypeId}
    
        }; 
        
        
        List<Account> accs = TestUtil.rellenarSObject(Account.SObjectType, camposMapAcc);
        
        insert accs;
 
        Map<String, List<Object>> camposMapCont = new Map<String, List<Object>>
        {
            'LastName' 				=> new List<String>{'ContTest1', 'ContTest2', 'JEFEPROYECTO'},
			'Codigo_de_empleado__c'	=> new List<String>{'12312378', '12345698', '11144477'},                
            'AccountId' => new List<String>{accs[0].Id, accs[1].Id, accs[2].Id},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                               Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                               Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId}
        }; 
         
        List<Contact> conts = TestUtil.rellenarSObject(Contact.SObjectType, camposMapCont);
        
        insert conts; 
 
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' => new List<String>{'Opp101234','OppTest2','OppTest3'},
            'Amount' => new List<Integer>{10000,10000,10000},
            
			'ID_SAP__c'	=> new List<String>{'oprtunidadidsap1234', 'oprtunidadidsap12345','oprtunidadidsap123456'},    // una Opp con ID sap, ya en SAP, la otra para prueba enviar SAP            
            'CloseDate' => new List<Date>{date.newInstance(2018, 12, 12), date.newInstance(2018, 12, 12), date.newInstance(2018, 12, 12)},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId,
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId},
            'StageName' => new List<String>{'Identificada', 'Identificada', 'Identificada'},
            'Mercado__c' => new List<String>{'Industria-Industria', 'Industria-Industria', 'Industria-Industria'},
            'AccountId' => new List<String>{accs[0].Id, accs[1].Id, accs[2].Id},
            'Contacto_del_cliente__c' => new List<String>{conts[0].Id, conts[1].Id, conts[2].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c' => new List<Date>{date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11)},
            'Codigo_de_oportunidad__c' => new List<String>{'VASS20180123456701', 'VASS20180123456702', 'VASS20180123456703'},
            'Clan_Principal__c' => new List<String>{'Digital Experience','Digital Experience','Digital Experience'}
        };
       
        
        opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
        System.runAs(usuarioSede){
            insert opps;
        }
        

        Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
        {
            'Oportunidad__c' => new List<String>{opps[0].Id, opps[1].Id},
            'Gerencia__c' => new List<String>{'Digital Experience', 'Digital Experience'},
            'oficina_tecnica__C' => new List<String>{'1000','1000'},
            'Responsable_de_LDP__c' => new List<String>{ UserInfo.getUserId(), UserInfo.getUserId()},
            'Area__c' => new List<String>{ 'ES00T02002', 'ES00T02002'},
            'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[2].Id, conts[2].Id},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId,
                                               Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId}
        };
          
        List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP);
        
        insert lps;

        

        
    }

    @isTest
    public static void test_batch_add_OppTeamMember_noLP(){
        List<User> users = [SELECT id,sede__c,name FROM user WHERE sede__c = '1000' AND Email = 'resp1@vass.com.invalid'];
        List<Opportunity> opps = [SELECT id,CLAN_PRINCIPAL__C,Owner.sede__C FROM Opportunity];
        OppTeamBatch batch = new OppTeamBatch(String.valueOf(users[0].id),'Digital Experience','1000', false);
        ID batchprocessid = Database.executeBatch(Batch);
        

        List<OpportunityTeamMember> oppTeamMembers = [SELECT id,user.Name FROM OpportunityTeamMember ];
        system.assertEquals(false, oppTeamMembers.isEmpty());
    }

    @isTest
    public static void test_batch_add_OppTeamMember_siLP(){
        List<User> users = [SELECT id,sede__c,name FROM user WHERE sede__c = '1000' AND Email = 'resp1@vass.com.invalid' ];
        List<Opportunity> opps = [SELECT id,CLAN_PRINCIPAL__C,Owner.sede__C FROM Opportunity];

        OppTeamBatch batch = new OppTeamBatch(String.valueOf(users[0].id),'Digital Experience','1000', true);
        ID batchprocessid = Database.executeBatch(Batch);
        

        List<OpportunityTeamMember> oppTeamMembers = [SELECT id,user.name FROM OpportunityTeamMember];
        system.assertEquals(false, oppTeamMembers.isEmpty());
    }
}