@isTest
public with sharing class Test_Batch_Pipeline {

     @isTest
    static void TestBatch()
    {
        List<Account> accs = TestUtil.generaCuentasTest();
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Mercado__c='Banca-Banca',
            Probability=50,
            Amount=99,
            AccountId=accs.get(0).id
        );

        insert(opp1);
        Test.startTest();
        Batch_Pipeline_Analitica batch = new Batch_Pipeline_Analitica(); 
        ID batchprocessid = Database.executeBatch(Batch); 

        Test.stopTest();
         Analitica__c analitica = [SELECT Id,importe__c FROM Analitica__c WHERE   Oportunidad__c =:opp1.id];
         system.assert(analitica.importe__c >0);
    }
}