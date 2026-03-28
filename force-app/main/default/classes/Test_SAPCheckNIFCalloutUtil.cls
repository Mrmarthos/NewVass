@IsTest 
private class Test_SAPCheckNIFCalloutUtil {
    @TestSetup
    static void setupData(){
        Account cuenta = new Account();
        cuenta.Name = 'Test Cuenta2';
        cuenta.Validacion_NIF__c = false;
        cuenta.BillingCountryCode = 'ES';
        cuenta.NIF_CIF__c = '32763578D';
        insert cuenta;



    }

    @IsTest
    private static void testCheckNIFValidationOK(){
        WebServiceMockGenerator mock = new WebServiceMockGenerator();
        system.debug(mock);
        List<Account> accs = [SELECT id,NIF_CIF__c,BillingCountryCode FROM Account Limit 1];
        Test.setMock(WebServiceMock.class, mock);
        Test.startTest();
        
        SAPCheckNIFCalloutUtil.hacerCalloutDesdeFlow(accs);


        Test.stopTest();

        system.debug('Cuentas ');
        List<Account> accsActualizadas = [SELECT id,NIF_CIF__c,BillingCountryCode,Validacion_NIF__c FROM Account Limit 1];
        system.debug('Cuentas '+accsActualizadas);
        System.assertEquals(true, accsActualizadas[0].Validacion_NIF__c);
    
    }

    @IsTest
    private static void testCheckNIFValidationKO(){
        WebServiceMockGenerator mock = new WebServiceMockGenerator();
        system.debug(mock);
        List<Account> accs = [SELECT id,NIF_CIF__c,BillingCountryCode FROM Account Limit 1];
        accs[0].NIF_CIF__c = 'FAIL';
        update accs;
        List<Account> accs2 = [SELECT id,NIF_CIF__c,BillingCountryCode FROM Account Limit 1];
        Test.setMock(WebServiceMock.class, mock);
        Test.startTest();
        
        SAPCheckNIFCalloutUtil.hacerCalloutDesdeFlow(accs2);


        Test.stopTest();

        system.debug('Cuentas ');
        List<Account> accsActualizadas = [SELECT id,NIF_CIF__c,BillingCountryCode,Validacion_NIF__c FROM Account Limit 1];
        system.debug('Cuentas '+accsActualizadas);
        System.assertEquals(false, accsActualizadas[0].Validacion_NIF__c);
    
    }

    @IsTest
    private static void testCheckNIFGetAccountRecord(){
        List<Account> accs = [SELECT id,NIF_CIF__c,BillingCountryCode FROM Account Limit 1];
        List<Account> accounts = SAPCheckNIFCalloutUtil.getCurrentAccount(accs.get(0).id);

        system.assertEquals(1, accounts.size());

    }
}