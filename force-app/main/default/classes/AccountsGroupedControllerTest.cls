@IsTest private class AccountsGroupedControllerTest {
    

    @TestSetup
    static void setupData(){
        Account cuenta = new Account();
        cuenta.Name = 'Test Cuenta2';

        insert cuenta;



    }

    @isTest private static void getAccounts(){
        String body = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://salesforceintegrationsap.vass.es/sap/opu/odata/sap/ZWSSALESFORCE_SRV/"><id>https://salesforceintegrationsap.vass.es/sap/opu/odata/sap/ZWSSALESFORCE_SRV/grupo_clientes</id><title type="text">grupo_clientes</title><updated>2022-09-01T12:00:26Z</updated><author><name/></author><link href="grupo_clientes" rel="self" title="grupo_clientes"/><entry><id>https://salesforceintegrationsap.vass.es/sap/opu/odata/sap/ZWSSALESFORCE_SRV/grupo_clientes(\'01\')</id><title type="text">grupo_clientes(\'01\')</title><updated>2022-09-01T12:00:26Z</updated><category term="ZWSSALESFORCE_SRV.grupo_clientes" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/><link href="grupo_clientes(\'01\')" rel="self" title="grupo_clientes"/><content type="application/xml"><m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices"><d:id_grupo>01</d:id_grupo><d:descripcion>Test Cuenta</d:descripcion></m:properties></content></entry></feed>';        
        Integer status = 200;
        HTTPCalloutMockAccountsGroupedController mock = new HTTPCalloutMockAccountsGroupedController(body,status);
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        List<Account> cuentas = AccountsGroupedController.getAccs('test');
        

        Test.stopTest();

        System.assertEquals(cuentas[0].Name, 'Test Cuenta');
        System.assertEquals(cuentas[0].SAP_Grupo_ID__c, '01');

    }


    @isTest private static void getAccountsInvalidSearch(){
        
        
        
        Test.startTest();
        List<Account> cuentas = AccountsGroupedController.getAccs('');
        List<Account> cuentas2 = AccountsGroupedController.getAccs(null);
        

        Test.stopTest();

        System.assertEquals(cuentas.size(), 0);
        System.assertEquals(cuentas2.isEmpty(), true);

    }

    @isTest private static void aniadirIdExternaACuenta(){
        String Identificador = [SELECT id FROM Account LIMIT 1].id;
        String body = '<feed xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xml:base="https://salesforceintegrationsap.vass.es/sap/opu/odata/sap/ZWSSALESFORCE_SRV/"><id>https://salesforceintegrationsap.vass.es/sap/opu/odata/sap/ZWSSALESFORCE_SRV/grupo_clientes</id><title type="text">grupo_clientes</title><updated>2022-09-01T12:00:26Z</updated><author><name/></author><link href="grupo_clientes" rel="self" title="grupo_clientes"/><entry><id>https://salesforceintegrationsap.vass.es/sap/opu/odata/sap/ZWSSALESFORCE_SRV/grupo_clientes(\'01\')</id><title type="text">grupo_clientes(\'01\')</title><updated>2022-09-01T12:00:26Z</updated><category term="ZWSSALESFORCE_SRV.grupo_clientes" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/><link href="grupo_clientes(\'01\')" rel="self" title="grupo_clientes"/><content type="application/xml"><m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices"><d:id_grupo>01</d:id_grupo><d:descripcion>Test Cuenta</d:descripcion></m:properties></content></entry></feed>';        
        Integer status = 200;
        HTTPCalloutMockAccountsGroupedController mock = new HTTPCalloutMockAccountsGroupedController(body,status);
        List<Account> cuentasAntesDeAniadirId = [SELECT id,SAP_Grupo_ID__c FROM Account];
        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        List<Account> cuentas = AccountsGroupedController.getAccs('test');
        AccountsGroupedController.aniadirIdExterna(Identificador, cuentas);

        Test.stopTest();

        List<Account> cuentasDespuesDeAniadirId = [SELECT id,SAP_Grupo_ID__c FROM Account];

        

        System.assertNotEquals(cuentas[0].SAP_Grupo_ID__c, cuentasAntesDeAniadirId[0].SAP_Grupo_ID__c);
        System.assertEquals(cuentasAntesDeAniadirId[0].SAP_Grupo_ID__c, null);
        System.assertEquals(cuentasDespuesDeAniadirId[0].SAP_Grupo_ID__c, cuentas[0].SAP_Grupo_ID__c);

    }

}