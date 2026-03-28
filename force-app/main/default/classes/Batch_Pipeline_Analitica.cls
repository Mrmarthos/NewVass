global  class  Batch_Pipeline_Analitica  implements  Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{

    global final string query;
    global Batch_Pipeline_Analitica() {

        query = Label.Query_Batch_Pipeline;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        List<analitica__c> Borradoprevio=[Select id from analitica__c where tipo__c='Pipeline'];
        delete(Borradoprevio);
        return Database.getQueryLocator(query);
    }
  
  
  global void execute(Database.BatchableContext BC,List<sObject> scope) {

        list<analitica__c> nuevas= new list<analitica__c>();
        Id PipeRecordTypeId = Schema.SObjectType.analitica__c.getRecordTypeInfosByName().get('Pipeline').getRecordTypeId();
        for(Sobject op : scope){
            Opportunity oportunidad = (Opportunity) op;
            analitica__c nueva= new analitica__c();
            nueva.RecordTypeid= PipeRecordTypeId;      
            nueva.importe__c=oportunidad.Importe_total__c;
            nueva.Clan__c =oportunidad.Clan_Principal__c;
            nueva.Oportunidad__c=oportunidad.id;
            nueva.Fecha__c=oportunidad.closedate;
            nueva.Propietario__c=oportunidad.OwnerId;
            nueva.tipo__c='Pipeline';
            nueva.Cuenta__c=oportunidad.AccountId;
            nueva.Mercado__c=oportunidad.Mercado__c;
            nueva.Sede_Venta__c=oportunidad.Sede_Venta__c;
            nueva.CurrencyIsoCode=oportunidad.CurrencyIsoCode;
            nuevas.add(nueva);
       }
    
      Database.SaveResult[] srList  =Database.insert(nuevas,false);
      for (Database.SaveResult sr : srList) {
        if (sr.isSuccess()) {
        }
        else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
        System.debug('The following error has occurred.');                    
        System.debug(err.getStatusCode() + ': ' + err.getMessage());
        System.debug('Account fields that affected this error: ' + err.getFields());
        }
        }
    }
    
  }
  
    global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.WARN,'Batch Job is Complete!!!!!');
 }
    global void execute(SchedulableContext sc) 
        {

        Batch_Pipeline_Analitica batch = new Batch_Pipeline_Analitica(); 
        ID batchprocessid = Database.executeBatch(Batch); 
        }
}