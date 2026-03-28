Global class BatchHistoricoActionPlan implements Database.Batchable<sObject> {
global final string query;

        //Example query, obviously Im sure you might even use another object
    global BatchHistoricoActionPlan(){
        query = Label.Query_Historico_ActionPlan;
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<sObject> scope) {
       List<Historico_Action_Plan__c> objs = new List< Historico_Action_Plan__c >();
        Database.DMLOptions dlo = new Database.DMLOptions();
		dlo.OptAllOrNone=false;
         //Assuming the snapshots you want are of Contact dataa
        for(Sobject s : scope){
            Task a = (Task) s;
            
                        
           Historico_Action_Plan__c ht= new Historico_Action_Plan__c();
            if(a.WhatId!=null){
            if(a.whatid.getSObjectType().getDescribe().getName()=='Account'){
                ht.Account__c=a.WhatId;
            }
           if(a.whatid.getSObjectType().getDescribe().getName()=='Opportunity'){
                ht.Oportunidad__c=a.WhatId;
           }}
            if(a.whoid!=null){
            if(a.whoid.getSObjectType().getDescribe().getName()=='Contact'){
                	ht.Contact__c=a.whoid;
            }}
                	ht.Campaign__c=a.Campaing__c;
            

                	ht.CurrencyIsoCode=a.CurrencyIsoCode;
                	ht.Fabricantes__c=a.Fabricantes__c;
                	ht.Fecha_Fin__c=a.ActivityDate;
                	ht.Mercado__c=a.Mercado__c;
                	ht.Propietario__c=a.OwnerId;
                	ht.Sede__c=a.sede__c;
					ht.Solucion__c=a.SolucionTask__c;
                	ht.Status__c=a.Status;
					ht.Type__c=a.type;
       				ht.Nombre_Tarea__c=a.subject;
            		ht.knowledge_Area__c=a.Technology_2__c;
            		ht.Strategic_Porfolio_BIG7__c=a.Strategic_Porfolio_BIG7__c;
            
    		objs.add(ht);
                
            
        }
        
        system.debug('Insert:'+ Database.insert(objs,true));
        system.debug('scope'+Scope);
   }

   global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.WARN,'Batch Job is Complete!!!!!');
   }
}