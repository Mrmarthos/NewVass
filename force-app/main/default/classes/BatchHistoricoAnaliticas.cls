global  class BatchHistoricoAnaliticas implements Database.Batchable<sObject> {
global final string query;

        //Example query, obviously Im sure you might even use another object
    global BatchHistoricoAnaliticas(){
        query = Label.Query_Historico_Analiticas;
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<sObject> scope) {
       List<Historico_Analiticas__c> objs = new List< Historico_Analiticas__c >();
        Database.DMLOptions dlo = new Database.DMLOptions();
		dlo.OptAllOrNone=false;
         //Assuming the snapshots you want are of Contact dataa
        for(Sobject s : scope){
            Analitica__c a = (Analitica__c) s;
            
                        	SYSTEM.debug('recordtype NAME' +Schema.SObjectType.Historico_Analiticas__c.getRecordTypeInfosByName().get(Schema.SObjectType.Analitica__c.getRecordTypeInfosById().get(a.recordtypeid).getname()).getRecordTypeId() );
                SYSTEM.debug('rECORD TYUPE ID' +Schema.SObjectType.Historico_Analiticas__c.getRecordTypeInfosByName().get(Schema.SObjectType.Analitica__c.getRecordTypeInfosById().get(a.recordtypeid).getname()).getRecordTypeId());
            objs.add(new Historico_Analiticas__c(
               		Clan__c=a.Clan__c,
                	Consejo__c=a.Consejo__c,
                	Cuenta__c=a.Cuenta__c,
                	CurrencyIsoCode=a.CurrencyIsoCode,
                	Fecha__c=a.Fecha__c,
                	Importe__c=a.Importe__c,
                	Mercado__c=a.Mercado__c,
                	Oportunidad__c=a.Oportunidad__c,
                	Propietario__c=a.Propietario__c,
                	Importe_Forecast__c=a.Importe_Forecast__c,
					Presupuesto__c=a.Presupuesto__c,
                	Ingresos_Reales__c=a.Ingresos_Reales__c,
					Linea_de_Proyecto__c=a.Linea_de_Proyecto__c,
       				Tipo__c=String.valueOf((system.today())),
    
                	RecordTypeId= Schema.SObjectType.Historico_Analiticas__c.getRecordTypeInfosByName().get(Schema.SObjectType.Analitica__c.getRecordTypeInfosById().get(a.recordtypeid).getname()).getRecordTypeId(),
                	Sede_Venta__c=a.Sede_Venta__c
                
            ));
        }
        Database.insert(objs,false);
        system.debug('scope'+Scope);
   }

   global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.WARN,'Batch Job is Complete!!!!!');
   }
}