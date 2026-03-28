@isTest
public class Test_Queueable_Analytics
{

    @testSetup
    static void test_setup(){
        
        Account acc = new Account();
        acc.name = 'Setup1';
        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        acc.sede__c = '1000';
        acc.NIF_CIF__c = '3';
        acc.ID_SAP__c = '2';
        insert acc;
    }


    @isTest
    public static void test_Queueable_Analytics_SaveResultError()
    {
        List<Account> listAccounts =  [SELECT id FROM Account];
        List<Analitica__c> analiticas = new List<Analitica__c>();
        Analitica__C analitica = new Analitica__C(Cuenta__c = listAccounts[0].id,
        RecordTypeId = Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get('Backlog').RecordTypeId,
        Descripcion__c = 'Test',
        Fecha__c = Date.today(),
        importe__c = 85,
        CurrencyIsoCode = 'EUR',
        Consejo__c = 'ES000K500000');
        analiticas.add(analitica);
        Test.startTest();
        System.enqueueJob(new Queueable_Analytics(analiticas));
        Test.stopTest();

        List<Log__c> logs =  [SELECT id FROM Log__c];
        System.AssertEquals(logs.isEmpty(),false);
    }
}