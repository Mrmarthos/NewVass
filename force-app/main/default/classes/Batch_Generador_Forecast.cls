global  class Batch_Generador_Forecast implements Database.Batchable<sObject> {
global final string query;

 
    global Batch_Generador_Forecast(){
        query = Label.Query_Batch_Forecast;
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){
          return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC,List<sObject> scope) {
        list<Linea_de_Proyecto__c> lineasProyecto = new list<Linea_de_Proyecto__c>();
        
 
        
    	GeneradorForecast.GenerarForecastNuevasLineas(scope,'Linea');
        
    }
    
      global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.WARN,'Batch Job is Complete!!!!!');
   }
}