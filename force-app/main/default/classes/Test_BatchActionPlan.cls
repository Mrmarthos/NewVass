@istest
public class Test_BatchActionPlan {
    
@isTest
    static void testBatchHistorico(){
        
        task t= new task();
        t.Subject='test';
        t.RecordTypeId=Schema.SObjectType.task.getRecordTypeInfosByName().get('Action Plan').getRecordTypeId();
		T.ActivityDate=SYSTEM.today();
        insert t;
        
        system.debug([select id,WhatId,Campaing__c,whoid,CurrencyIsoCode,Fabricantes__c,ActivityDate,Mercado__c,OwnerId,sede__c,SolucionTask__c, type,Status,subject from task where RecordType.Name='Action Plan' and ActivityDate=THIS_FISCAL_YEAR	]);
        
        Test.startTest();

            BatchHistoricoActionPlan obj = new BatchHistoricoActionPlan();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
        
            SchedulableContext sc = null;
        ScheludablehistoricoActionPlan tsc = new ScheludablehistoricoActionPlan();
        tsc.execute(sc);
        
    }
}