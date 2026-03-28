public without sharing  class Queueable_Analytics implements Queueable {
    
    public List<sObject> sObjectList;  
    public List<Log__c> errorLogs = new List<Log__c>();
    

   public Queueable_Analytics(List<sObject> sObjectListInput) {
       this.sObjectList = sObjectListInput;
   }

   public void execute(QueueableContext context) {
       try{
           if(!sObjectList.isEmpty()){
                insertObjects(sObjectList);
           }

       }catch(Exception ex){
                Log__c errorLog = new Log__c();
                errorLog.Error__c = 'Error creando analíticas '+ex.getCause()+'/'+ex.getMessage();
                errorlog.Type__C = 'Backlog';
                errorlog.Metodo__c = 'CreateAnalytics';
                errorLogs.add(errorLog); 
       }
   }


   /**
    * @author Adrián Bernardo
    * description Inserta los registros que le lleguen de tipo Log__C o Analitica__c y.
    * date 14/03/2023
    */
    public void insertObjects(List<sObject> sObjectsList){
    Schema.SObjectType sobjectType = sObjectsList.get(0).getSObjectType();

    if(sobjectType == Analitica__c.getSObjectType()){
        List<Database.SaveResult> sresultList =  Database.insert((List<Analitica__c>)sObjectsList,false);
        
        for (Database.SaveResult sr : sresultList) {
        if (!sr.isSuccess()) {
            for(Database.Error err : sr.getErrors()) {
                 	Log__c errorLog = new Log__c();
                	errorLog.Error__c = 'Error creando analíticas '+err.getStatusCode() + ': ' + err.getMessage()+': '+err.getFields();
                	errorlog.Type__C = 'Backlog';
                	errorlog.Metodo__c = 'CreateAnalytics';
                	errorLogs.add(errorLog);
            }
        }
    } 
    } else if(sobjectType == Log__c.getSObjectType()){
        errorLogs = (List<Log__c>)sObjectsList;
    }

    if(!errorLogs.isEmpty()){
        insert errorLogs;
    }

}

}