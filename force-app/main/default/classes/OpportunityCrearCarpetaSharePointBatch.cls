/** 
	  * @description: Batch que hará 1 vez por Execute la llamada a la integración con SharePoint para crear carpeta
	  * 				La condición es que estén rellenos los campos:
	  * 						· Acc.Mercado__c 
	  * 						· Acc.Name
	  * 						· Opp.Name
	  * 				Y que esté vacío:
	  * 						· URL_Sharepoint__c
	  **
	  * @Autor: Noemi Escudero del Olmo (05/11/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro:
	  **
	  */
global class OpportunityCrearCarpetaSharePointBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable 
{
	public String query;

	global OpportunityCrearCarpetaSharePointBatch() {}
	
	//global CaseAsociarCuentaACasosHuerfanosBatch(String p_query, boolean p_esTest) 
	global OpportunityCrearCarpetaSharePointBatch(String p_query)
	{
		query = p_query;
	}
 
	global Database.queryLocator start(Database.BatchableContext BC)
	{
		Set<String> stageName = new Set<String>{'Preventa','Entregada','Presentada','Ganada'};
		String urlSharepoint_c = '';
		String name = '';
		String accName = '';
		String mercado = '';
		String codigo = '';
		
		if(query == null)
		{
			
			//Conseguir las Opps que sean Preventa, tengan la URL vacía y tengan los datos rellenos
			query = 'Select Id, Name, Account.Name, Mercado__c, StageName, URL_Sharepoint__c, Codigo_de_oportunidad__c From Opportunity Where '+ 
					+'StageName IN :stageName AND '+
					+'URL_Sharepoint__c = \''+urlSharepoint_c+'\' AND '+
					+'Name != \''+name+'\' AND '+
					+'Account.Name != \''+accName+'\' AND '+
					+'Codigo_de_oportunidad__c != \''+codigo+'\' AND '+
					+'Mercado__c != \''+mercado+'\'';
		}
		
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<Opportunity> scope)
	{
		//Cualquier acción necesaria sobre los registros del scope
		
    	/////////////////////////////////////////////////////////////
    	List<ID> listIds = new List<ID>();
    	List<String> listPaths = new List<String>();
    	Opportunity opp;
    	/////////////////////////////////////////////////////////////  
		
		//Se hace solamente 1 Opp en cada execute del Batch porque con cada execute se reinician los límites
		if (scope != null)
		{
			if (scope.size() > 0)
			{
				//Solo ha venido 1
				opp = scope[0];
				system.debug('SCOPE BATCH: '+opp);
				
	        	//Formar la URL y meterla a una lista de URLs (paths) (Recordar hacer esto 4 veces por la estructura):
	        	//	- Opp.Mercado__c / Acc.Name / system.now().year()-Opp.Codigo_de_oportunidad__c.substring(10) / Economico
	        	//											 Enviado
	        	//											 Interno
	        	//											 Recibido
	        	//Guardar en una lista los Ids
    		    //Economico
        		listPaths.add(opp.Mercado__c + '/' + opp.Account.Name + '/' + System.now().year() +'-'+ opp.Codigo_de_oportunidad__c.substring(10) + '/Economico');
        		listIds.add(opp.Id);
        		
        		//Enviado
        		listPaths.add(opp.Mercado__c + '/' + opp.Account.Name + '/' + System.now().year() +'-'+ opp.Codigo_de_oportunidad__c.substring(10) + '/Enviado');
        		listIds.add(opp.Id);
        		
        		//Interno
        		listPaths.add(opp.Mercado__c + '/' + opp.Account.Name + '/' + System.now().year() +'-'+ opp.Codigo_de_oportunidad__c.substring(10) + '/Interno');
        		listIds.add(opp.Id);
        		
        		//Recibido
        		listPaths.add(opp.Mercado__c + '/' + opp.Account.Name + '/' + System.now().year() +'-'+ opp.Codigo_de_oportunidad__c.substring(10) + '/Recibido');
        		listIds.add(opp.Id);
        		
            	if (listPaths != null && listIds != null)
            	{
                	//Callout a no-@future para saltarse los límites de callouts en Batchs
                	IntegracionSharePointVass.crearCarpeta(listPaths , 'POST', listIds);  
                	system.debug('FIN DEL BATCH');
            		
            	}
			}
		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		//Cualquier acción necesaria para finalizar el proceso
	}
	
	global void execute(SchedulableContext SC)
	{
		//Se hace solamente 1 Opp en cada execute del Batch porque con cada execute se reinician los límites
		Database.executeBatch(new OpportunityCrearCarpetaSharePointBatch(), 1);
	}
}