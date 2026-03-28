/*
API : 49.00
Author : Rahul Joshi
Source : sfdcMonkey.com
Date : Dec,2020
*/
public class dataTableCtrl{
    @AuraEnabled 
    public static List<taskListWrapper> fetchAccountWrapper(){     
        List<taskListWrapper> lsttaskListWrapper = new List<TaskListWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
        
        String Name= [Select Name from Profile where id=:UserInfo.getProfileId()].Name;
        
        
        for(Task tarea : [Select id,Subject,Tipo__c,Mercado__c,ActivityDate,Status,Owner.Name,Priority
                          From Task
                          where  recordtype.Name=:Constants.TASK_RECORDTYPE_ACTIONPLAN and owner.id=:UserInfo.getUserid() and IsClosed=false ]){
                              // by default checkbox should be false 
                              lsttaskListWrapper.add(new taskListWrapper(false,tarea));
                          } 
        
        
        
        // return the 'lstaccountListWrapper' list 
        return lsttaskListWrapper; 
    }
    @AuraEnabled 
    public static List<taskListWrapper> fetchTaskWrapperAcc(id Identificador){     
        List<taskListWrapper> lsttaskListWrapper = new List<TaskListWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
      
        if(identificador.getSObjectType().getDescribe().getName()=='Account'){
        for(Task tarea : [Select id,Subject,Tipo__c,Mercado__c,ActivityDate,Status,IsClosed,Owner.Name,Priority
                          From Task
                          where Accountid =:Identificador and    recordtype.Name=:Constants.TASK_RECORDTYPE_ACTIONPLAN and IsClosed=false]){
                              // by default checkbox should be false 
                              lsttaskListWrapper.add(new taskListWrapper(false,tarea));
                          } 
            
        }else if(identificador.getSObjectType().getDescribe().getName()=='Campaign'){
             for(Task tarea : [Select id,Subject,Tipo__c,Mercado__c,ActivityDate,Status,IsClosed,Owner.Name,Priority
                          From Task
                          where (Campaing__c =:Identificador or  WhatId=:Identificador)  and    recordtype.Name=:Constants.TASK_RECORDTYPE_ACTIONPLAN and IsClosed=false]){
                              // by default checkbox should be false 
                              lsttaskListWrapper.add(new taskListWrapper(false,tarea));
                          } 
            
           

            
                list<Campaign> allcampaing= new list<Campaign>();
                allcampaing=[Select id  from Campaign where  ParentId=:Identificador];
            if(allcampaing.size()>0){
                set<id> setid= new set<id>();
                for(Campaign cp:allcampaing ){
                    setid.add(cp.id);
                }
                
                for(Task tarea : [Select id,Subject,Tipo__c,Mercado__c,ActivityDate,Status,IsClosed,Owner.Name,Priority
                          From Task
                          where (Campaing__c IN :setid or  WhatId IN :setid)  and    recordtype.Name=:Constants.TASK_RECORDTYPE_ACTIONPLAN and IsClosed=false]){
                              // by default checkbox should be false 
                              lsttaskListWrapper.add(new taskListWrapper(false,tarea));
                          } 
            }
            
        }
        // return the 'lstaccountListWrapper' list 
        return lsttaskListWrapper; 
    }

    
    /* wrapper class */  
    public class taskListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        @AuraEnabled public  Task Tarea{get;set;}
        public taskListWrapper(boolean isChecked, Task tarea){
            this.isChecked = isChecked;
            this.Tarea = tarea;
        }
    }
    
}