@isTest
public class Test_Datatable_Controller {
    
    @testSetup
	private static void testScenario()
    {
        Id internalRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        Account acc1;
        acc1 = new Account(
            Name = 'Account 1',
            RecordTypeId = internalRecordTypeId
        );
        insert acc1;
        
        Task tarea= new Task();
        tarea.WhatId=acc1.id;
        tarea.RecordTypeId=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(Constants.TASK_RECORDTYPE_DEVCACTIONPLAN).getRecordTypeId();
        tarea.Mercado__c='Banca-Banca';
        tarea.Sede__c='1000';
        tarea.OwnerId=userinfo.getUserId();
			
        insert tarea;
        
            Campaign cmp= new Campaign();
        cmp.Name='test';
        cmp.Description='test';
        cmp.StartDate=system.today();
        cmp.EndDate=system.today()+2;

			
        insert cmp;
        
              Campaign cmp2= new Campaign();
        cmp2.Name='test2';
        cmp2.Description='test';
        cmp2.StartDate=system.today();
        cmp2.EndDate=system.today()+2;
		cmp2.parentid=cmp.id;
			
        insert cmp2;
        
        

    }
    
    
    @isTest    
    static void TestfetchTaskWrapperAcc(){
        String identificador=[Select id from Account].id;
        dataTableCtrl.fetchTaskWrapperAcc(identificador);
    }
    
       @isTest    
    static void TestfetchTaskWrapperCmp(){
        String identificador=[Select id from Campaign where name='test'].id;
        dataTableCtrl.fetchTaskWrapperAcc(identificador);
    }
    
     @isTest    
    static void TestfetchTaskWrapperAccNoId(){

        dataTableCtrl.fetchAccountWrapper();
    }
    
}