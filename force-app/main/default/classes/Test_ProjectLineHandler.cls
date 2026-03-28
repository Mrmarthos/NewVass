@isTest
public with sharing class Test_ProjectLineHandler 
{
    public static User u1;
    public static User u2;
    public static User u3;
    public static User u4;
    public static User u5;
    public static User u6;
    public static User u7;
    public static boolean testSerialize = false;

    // ******************* TEST INDIVIDUALES Y CASOS ESPECIALES ******************* 
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

         u3 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp3@vass.com',
            Username = 'resp3@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
                         Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u3;

         u4 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp4@vass.com',
            Username = 'resp4@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',    
                         Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u4;

         u5 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp5@vass.com',
            Username = 'resp5@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
                         Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u5;
       
       //*******************************************/
       // Probar gerente/resp area en OppTeam
        u6 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp6@vass.com',
            Username = 'resp6@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',            
            Gerencia__c = 'Customer Centric',
            Area__c = 'ES00T04006',
            UserRoleId = gerenteOperacionesRolId,
                        Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u6;
       
        u7 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp7@vass.com',
            Username = 'resp7@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Gerencia__c = 'Customer Centric',
            Area__c = 'ES00T04006',            
            UserRoleId = responsableAreaRolId,
                        Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u7;
       //*******************************************/
       }

        // Insertar dos oportunidades
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        List<Opportunity> opptys = new List<Opportunity>();
        Account sede = new Account();
        sede.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        sede.NIF_CIF__c='111111';
        sede.Name='VASS Madrid';
        sede.Razon_Social__c='rtee';
        insert sede;
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Bid_Manager__c = u3.Id,
            Offering__c = u4.Id,
            Business_Value__c = u1.Id
        );
        opptys.add(opp1);
        
        Opportunity opp2 = new Opportunity(
            Name = 'Opportunity 2',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 24),
            Business_Value__c = u5.Id
        );
        opptys.add(opp2);

        //*******************************************/
        // Probar gerente/resp area en OppTeam
        Opportunity opp3 = new Opportunity(
            Name = 'Opportunity 3',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 24),
            Business_Value__c = u2.Id
        );
        opptys.add(opp3);
        //*******************************************/
              
        insert opptys;
        
        opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'];
        opp2 = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 2'];
        
        // Insertar cuatro lineas de proyecto
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            Responsable_de_LDP__c = u1.Id
       
        ));
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
      
            Responsable_de_LDP__c = u1.Id
        ));
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id, 
        
            Responsable_de_LDP__c = u2.Id
        ));
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp2.Id, 
          
            Responsable_de_LDP__c = u1.Id
        ));

        //*******************************************/
        // Probar gerente/resp area en OppTeam
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp3.Id,
   
            Gerencia__c = 'Delivery Cross',
            Area__c = 'ES00T16002', 
            Responsable_de_LDP__c = u2.Id
        ));
        //*******************************************/

        insert projectLines;
       
    }

    // ******************************** TEST OPPORTUNITY TEAM ********************************

    // Demuestra que a partir de a partir del insert del escenario se crean los grupos
    @isTest
    public static void testProjectLineInsert() {

        Test.startTest();

        // escenario

        Test.stopTest();

        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id opp2Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 2'].Id;

        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
        Id u2Id = [SELECT Id FROM User WHERE Email = 'resp2@vass.com'].Id;
        Id u3Id = [SELECT Id FROM User WHERE Email = 'resp3@vass.com'].Id;
        Id u4Id = [SELECT Id FROM User WHERE Email = 'resp4@vass.com'].Id;
        Id u5Id = [SELECT Id FROM User WHERE Email = 'resp5@vass.com'].Id;

        System.assertEquals(4, [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id AND (UserId = :u1Id OR UserId = :u2Id OR UserId = :u3Id OR UserId = :u4Id)]);
        System.assertEquals(0, [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id AND (UserId = :u5Id)]);

        System.assertEquals(2, [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp2Id AND (UserId = :u1Id OR UserId = :u5Id)]);
        System.assertEquals(0, [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp2Id AND (UserId = :u2Id OR UserId = :u3Id OR UserId = :u4Id)]);
    } 

    // Demuestra que al actualizar una linea de proyecto se añade al equipo y se quita al antiguo miembro 1L 0
    @isTest
    public static void testProjectLineUpdate()
    {
        Id opp2Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 2'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
        Id u5Id = [SELECT Id FROM User WHERE Email = 'resp5@vass.com'].Id;

        List<OpportunityTeamMember> teamBefore = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp2Id];

        Test.startTest();

        Linea_de_Proyecto__c projectLine = [SELECT Oportunidad__c, Responsable_de_LDP__c FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp2Id AND Responsable_de_LDP__c = :u1Id];
        projectLine.Responsable_de_LDP__c = u5Id;
        update projectLine;

        Test.stopTest();

        List<OpportunityTeamMember> teamAfter = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp2Id];

        System.assertEquals(2, teamBefore.size());
        System.assert((teamBefore.get(0).UserId == u1Id && teamBefore.get(1).UserId == u5Id) ||
                      (teamBefore.get(0).UserId == u5Id && teamBefore.get(1).UserId == u1Id));

        System.assertEquals(1, teamAfter.size());
        OpportunityTeamMember onlyMember = teamAfter.get(0);
        System.assertEquals(u5Id, onlyMember.UserId);
    }

    // Demuestra que al quitar una linea de proyecto se quita al miembro 1L 0
    @isTest
    public static void testProjectLineDelete() 
    {
        Id opp2Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 2'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
        Id u5Id = [SELECT Id FROM User WHERE Email = 'resp5@vass.com'].Id;

        List<OpportunityTeamMember> teamBefore = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp2Id];

        Test.startTest();

        Linea_de_Proyecto__c projectLine = [SELECT Oportunidad__c, Responsable_de_LDP__c FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp2Id AND Responsable_de_LDP__c = :u1Id];
        delete projectLine;

        Test.stopTest();

        List<OpportunityTeamMember> teamAfter = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp2Id];

        System.assertEquals(2, teamBefore.size());
        System.assert((teamBefore.get(0).UserId == u1Id && teamBefore.get(1).UserId == u5Id) ||
                      (teamBefore.get(0).UserId == u5Id && teamBefore.get(1).UserId == u1Id));

        System.assertEquals(1, teamAfter.size());
        OpportunityTeamMember onlyMember = teamAfter.get(0);
        System.assertEquals(u5Id, onlyMember.UserId);
    }

    // Demuestra que al quitar una linea de proyecto pero tener otra disponible, se mantienen los miembros 1L 1L
    @isTest 
    public static void testProjectLineDeleteOneOfTwo() 
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;
        Id u5Id = [SELECT Id FROM User WHERE Email = 'resp5@vass.com'].Id;

        Set<Id> teamBefore = new Set<Id>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id])
        {
            teamBefore.add(otm.UserId);
        }

        Test.startTest();

        Linea_de_Proyecto__c projectLine = [SELECT Oportunidad__c, Responsable_de_LDP__c FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1Id AND Responsable_de_LDP__c = :u1Id LIMIT 1];
        delete projectLine;

        Test.stopTest();

        Set<Id> teamAfter = new Set<Id>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id])
        {
            teamAfter.add(otm.UserId);
        }

        System.assertEquals(teamBefore, teamAfter);

    }

    // Demuestra que al quitar de un proyecto pero tener linea de proyecto, se mantienen los miembros 1P 1L
    @isTest 
    public static void testRemoveFromOpptyStayProjectLine() 
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u3Id = [SELECT Id FROM User WHERE Email = 'resp3@vass.com'].Id;

        Set<Id> teamBefore = new Set<Id>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id])
        {
            teamBefore.add(otm.UserId);
        }

        Test.startTest();

        Opportunity oppty = [SELECT Business_Value__c FROM Opportunity WHERE Id = :opp1Id];
        oppty.Business_Value__c = u3Id;
        update oppty;

        Test.stopTest();

        Set<Id> teamAfter = new Set<Id>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id])
        {
            teamAfter.add(otm.UserId);
        }

        System.assertEquals(teamBefore, teamAfter);
    }

    // Demuestra que al añadir una linea de proyecto y no tener permisos, luego se le otorgan 0 1L
    @isTest 
    public static void testAddProjectLine() 
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u5Id = [SELECT Id FROM User WHERE Email = 'resp5@vass.com'].Id;

        Integer permsBefore = [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id AND UserId = :u5Id];

        Test.startTest();

        Linea_de_Proyecto__c projectLine = new Linea_de_Proyecto__c(
            Oportunidad__c = opp1Id, 
            Oficina_tecnica__c='1000',
            Responsable_de_LDP__c = u5Id
        );
        insert projectLine;

        Test.stopTest();

        Integer permsAfter = [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id AND UserId = :u5Id];

        System.assertEquals(0, permsBefore);
        System.assertEquals(1, permsAfter);
    }

    // Demuestra que al añadirle a un proyecto y no tener permisos, luego se le otorgan 0 1P
    @isTest 
    public static void testAddToOpportunity() 
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u5Id = [SELECT Id FROM User WHERE Email = 'resp5@vass.com'].Id;

        Integer permsBefore = [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id AND UserId = :u5Id];

        Test.startTest();

        Opportunity oppty = [SELECT Business_Value__c FROM Opportunity WHERE Id = :opp1Id];
        oppty.Business_Value__c = u5Id;
        update oppty;

        Test.stopTest();

        Integer permsAfter = [SELECT Count() FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id AND UserId = :u5Id];

        System.assertEquals(0, permsBefore);
        System.assertEquals(1, permsAfter);
    }

    // Demuestra que al tener permisos por una linea pero estar en el proyecto, se mantienen los permisos 1L 1P
    @isTest 
    public static void testRemoveFromProjectLineStayOppty() 
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;

        Set<Id> teamBefore = new Set<Id>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id])
        {
            teamBefore.add(otm.UserId);
        }

        Test.startTest();

        List<Linea_de_Proyecto__c> projectLines = [SELECT Id FROM Linea_de_Proyecto__c WHERE Responsable_de_LDP__c = :u1Id AND Oportunidad__c = :opp1Id];
        delete projectLines;

        Test.stopTest();

        Set<Id> teamAfter = new Set<Id>();
        for (OpportunityTeamMember otm : [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp1Id])
        {
            teamAfter.add(otm.UserId);
        }

        System.assertEquals(teamBefore, teamAfter);
    }

    // Demuestra que se añade al OppTeam el representante de area/gerente de operaciones con el mismo área que la LDP
    // Noemi Escudero del Olmo (26/11/2018)
    @isTest 
    public static void testGerRepArea() 
    {
        Id opp3Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 3'].Id;
        Id u6Id = [SELECT Id FROM User WHERE Email = 'resp6@vass.com'].Id;
        Id u7Id = [SELECT Id FROM User WHERE Email = 'resp7@vass.com'].Id;

        List<OpportunityTeamMember> teamBefore = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp3Id];

        Test.startTest();

        //Fue creada así en la parte de arriba, testScenario()
        Linea_de_Proyecto__c projectLine = [SELECT Oportunidad__c, Gerencia__c, Area__c FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp3Id AND Gerencia__c = 'Delivery Cross' AND Area__c = 'ES00T16002'];
        projectLine.Gerencia__c = 'Customer Centric';
        projectLine.Area__c = 'ES00T04006';
        update projectLine;

        Test.stopTest();

        List<OpportunityTeamMember> teamAfter = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId = :opp3Id];
        Set<Id> userIDs = new Set<ID>();

        //System.assertEquals(3, teamAfter.size());
        for (OpportunityTeamMember oppMember : teamAfter)
        {
            userIDs.add(oppMember.UserId);
        }
        System.assert((userIDs.contains(u6Id)),'La lista de usuarios del OppTeam ' + userIDs + 'no contiene el usuario ' + u6Id);
        System.assert((userIDs.contains(u7Id)),'La lista de usuarios del OppTeam ' + userIDs + 'no contiene el usuario ' + u7Id);
    }

    // ******************************** TEST MAIN PROJECTLINES ********************************

    // Demuestra que se han creado unas lineas de proyecto principales de manera automática, pero solo una por proyecto
    @isTest
    public static void testProjectLineMain()
    {
        System.assertEquals(3, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true]);
    }

    // Demuestra que al borrar la principal y seguir habiendo, e insertar otra, no se marcará como principal (hay lineas previas)
    @isTest
    public static void testProjectLineRemovingButWithLeftoverLines()
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;

        Linea_de_Proyecto__c deleteProjLine = [SELECT Id FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1Id AND Linea_principal__c = true];

        Linea_de_Proyecto__c addProjLine = new Linea_de_Proyecto__c(
            Oportunidad__c = opp1Id, 
            Oficina_tecnica__c='1000',
            Responsable_de_LDP__c = u1Id
        );

        System.assertEquals(1, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp1Id]);

        Test.startTest();

        delete deleteProjLine;
        insert addProjLine;

        Test.stopTest();

        System.assertEquals(0, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp1Id]);
    }

    // Demuestra que al borrar la principal y ser la última, e insertar otra, se marcará como principal
    @isTest
    public static void testProjectLineRemovingAllLines()
    {
        Id opp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;

        List<Linea_de_Proyecto__c> deleteProjLines = [SELECT Id FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1Id];

        Linea_de_Proyecto__c addProjLine = new Linea_de_Proyecto__c(
            Oportunidad__c = opp1Id, 
            Oficina_tecnica__c='1000',
            Responsable_de_LDP__c = u1Id
        );

        System.assertEquals(1, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp1Id]);

        Test.startTest();

        delete deleteProjLines;
        insert addProjLine;

        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp1Id]);
    }

    // Demuestra que al insertar 2 lineas y ya estar marcada cuál es la principal, se mantiene la configuración indicada
    @isTest
    public static void testProjectLineRespectsPresetMains()
    {
        Id opp2Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 2'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;

        List<Linea_de_Proyecto__c> deleteProjLines = [SELECT Id FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp2Id];
        delete deleteProjLines;

        Linea_de_Proyecto__c projLine1 = new Linea_de_Proyecto__c(
            Oportunidad__c = opp2Id, 
            Responsable_de_LDP__c = u1Id,
        
            Hito_1__c = 'LProj 1 Hito 1'
        );

        Linea_de_Proyecto__c projLine2 = new Linea_de_Proyecto__c(
            Oportunidad__c = opp2Id, 
            Responsable_de_LDP__c = u1Id,
            Linea_principal__c = true,
   
            Hito_1__c = 'LProj 2 Hito 1'
        );

        System.assertEquals(0, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp2Id]);

        Test.startTest();

        insert new List<Linea_de_Proyecto__c>{ projLine1, projLine2 };

        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp2Id]);
        System.assertEquals(false, [SELECT Linea_principal__c FROM Linea_de_Proyecto__c WHERE Hito_1__c = 'LProj 1 Hito 1'].Linea_principal__c);
        System.assertEquals(true, [SELECT Linea_principal__c FROM Linea_de_Proyecto__c WHERE Hito_1__c = 'LProj 2 Hito 1'].Linea_principal__c);

    }

    // Demuestra que al no haber ninguna línea e insertar N, cualquiera es la principal
    @isTest
    public static void testProjectLineAutoselectsMainLine()
    {
        Id opp2Id = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 2'].Id;
        Id u1Id = [SELECT Id FROM User WHERE Email = 'resp1@vass.com'].Id;

        List<Linea_de_Proyecto__c> deleteProjLines = [SELECT Id FROM Linea_de_Proyecto__c WHERE Oportunidad__c = :opp2Id];
        delete deleteProjLines;

        Linea_de_Proyecto__c projLine1 = new Linea_de_Proyecto__c(
            Oportunidad__c = opp2Id, 
            Responsable_de_LDP__c = u1Id,
          

            Hito_1__c = 'LProj 1 Hito 1'
        );

        Linea_de_Proyecto__c projLine2 = new Linea_de_Proyecto__c(
            Oportunidad__c = opp2Id, 
            Responsable_de_LDP__c = u1Id,
       
            Hito_1__c = 'LProj 2 Hito 1'
        );

        System.assertEquals(0, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp2Id]);

        Test.startTest();

        insert new List<Linea_de_Proyecto__c>{ projLine1, projLine2 };

        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM Linea_de_Proyecto__c WHERE Linea_principal__c = true AND Oportunidad__c = :opp2Id]);
    }



    @isTest
    public static void testSerializeAndSendProjectLines()
    {
        test.startTest();
        Account sede = [SELECT id FROM Account WHERE Name = 'VASS Madrid' LIMIT 1];
        Set<Opportunity> opps = new Set<Opportunity>();
        User u = [SELECT id FROM User WHERE email like '%resp2@vass.com%' LIMIT 1];
        
        Account acc = new Account();
        acc.ID_SAP__c = '2134';
        acc.name = 'test acc';
        insert acc;
        Opportunity oppValida = [SELECT id FROM Opportunity limit 1];
        oppValida.stageName = 'Preventa';
        oppValida.amount = 1000;
        oppValida.sede_Venta__C = sede.id;
        update oppValida;

        Test_ProjectLineHandler.testSerialize = true;
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = oppValida.Id, 
            Responsable_de_LDP__c = u.Id,
            Gerencia__c = 'Digital Experience',
            Area__C = 'ES00T02002',
            Tecnologia__c = 'NET',
            Validacion_Crossobject_Preventa__c = true
        ));
        insert projectLines;
        projectLines.get(0).Tecnologia__c = 'ADO';
        update projectLines;
        Test_ProjectLineHandler.testSerialize = false;
        Linea_de_Proyecto__c lp =[SELECT id,Validado_para_Preventa__c FROM Linea_de_Proyecto__c WHERE id IN :projectLines LIMIT 1];
        system.debug('LP ---> '+lp);
        test.stopTest();
    }

}