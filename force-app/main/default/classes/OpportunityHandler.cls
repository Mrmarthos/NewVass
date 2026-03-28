public class OpportunityHandler implements ITrigger
{
	Map<String,Id> mapRolId = new Map<String,Id>();

	private List<Opportunity> listOppsConAcc = new List<Opportunity>();
	    private static Set<Id> processedOppIds = new Set<Id>();

    // Equipo de oportunidad - Variables usadas
    List<OpportunityTeamMember> opportunityTeamMembers;
    List<Opportunity> opportunities;

    // Oportunidades pendientes de actualización
    private List<Opportunity> updateOpportunities;

    // Para hacer las DML e insertar nuevas oportunidades al ganar Licencias o AMs
    private List<Opportunity> insertOpportunities;

    // Depende de insertOpportunities
    private Map<Opportunity, List<Linea_de_Proyecto__c>> insertProjectLines;

    // Depende de insertProjectLines
    private Map<Linea_de_Proyecto__c, List<Licencia__c>> insertLicenses;

    // Cuentas cacheadas relacionadas con las oportunidades
    private Map<Id, Account> accIdToAccount;

    // Contador de codigos de oportunidad
    private Opportunity_code_counter__c oppCodeCounter;
	
    // Constructor
    public OpportunityHandler() {}
 
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)   
    {   
        //Conseguir el mapa de <DeveloperName, Id> del objeto UserRole
        Set<String> setRol = new Set<String>{'Gerente_de_operaciones', 'Responsable_de_area'};
        mapRolId = Utils.queryUserRol(setRol);

        // Recuperar las cuentas asociadas a la oportunidad
        if (newList != null && !newList.isEmpty())
        {
            //accIdToAccount = OpportunityUtil.queryOpportunityAccounts((List<Opportunity>) newList);
        }

    	if ( newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty())
    	{
    		listOppsConAcc = OpportunityUtil.getOppWithAcc((list<Opportunity>) newList, (map<Id,Opportunity>) oldMap);
    	}
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)    
    {  
    	if ( newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty())
    	{
    		listOppsConAcc = OpportunityUtil.getOppWithAcc((list<Opportunity>) newList, (map<Id,Opportunity>) oldMap);
    	}
    }

    public void beforeInsert(list<SObject> newList)                         
    { 
    	if (newList != null && !newList.isEmpty())
        {

            // Asignar propietario - Asignar la oportunidad al propietario de la cuenta
            //newList = OpportunityUtil.assignOpptyOwnerFromAccountOwner((List<Opportunity>) newList, accIdToAccount);

            // Autogenerar nombres - Cambiamos los nombres de las oportunidades
    		OpportunityUtil.SetOppCodeResult res = OpportunityUtil.setOppCode((List<Opportunity>) newList);
            newList = res.opportunities;
            oppCodeCounter = res.opportunityCounter;

            // Autorellenar oficinas - Autorellenar la oficina de ventas y oficina tecnica
            newList = OpportunityUtil.defaultSalesAndTechnicalOffices((List<Opportunity>) newList);

        }
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap) 
    {
    	if ( newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty())
    	{
           
         
            
    		if(listOppsConAcc != null && !listOppsConAcc.isEmpty()) //No hace falta hacer este método si la List no contiene algo 
    		{
                
    			OpportunityUtil.checkCreateFolderSharePoint((list<Opportunity>) newList, (map<Id,Opportunity>) oldMap, listOppsConAcc);
    		} 
            
            // Generación de oportunidades para Licencias y AM - Generamos nuevas oportunidades para las licencias y AM asociadas que van a vencer
            OpportunityUtil.GenerateLicenseAndAMOpportunitiesResult res = OpportunityUtil.generateLicenseAndAMOpportunities((List<Opportunity>) newList, (Map<Id, Opportunity>) oldMap);
            system.debug('SALE DE LA RENOVACION');
            insertOpportunities = res.opportunities;
            insertProjectLines = res.opportunityToProjectLines;
            insertLicenses = res.projectLinesToLicenses;
            //el orden indica la prioridad
            //OpportunityUtil.CheckVentaExtra(newList,(map<Id,Opportunity>) oldMap);
            //OpportunityUtil.CheckProyectoEstra(newList,(map<Id,Opportunity>) oldMap);
            OpportunityUtil.CheckImporteExtra(newList,(map<Id,Opportunity>) oldMap);
            //OpportunityUtil.CheckMargen(newList,(map<Id,Opportunity>) oldMap);
            //OpportunityUtil.CheckMargenIntercompany(newList,(map<Id,Opportunity>) oldMap);


    	}
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)                        {   }
    
    /**
     * These methods ara called for records to be processed during a AFTER 
     * trigger.
     */ 
    public void afterInsert(list<SObject> newList)
    {
        // Equipo de oportunidad - Se cachean los datos del equipo en todos los insert
        if (newList != null && !newList.isEmpty())
        {
            ProjectLineUtil.QueryOpportunityTeamResult res = ProjectLineUtil.queryOpportunityTeam(newList);

            opportunityTeamMembers = res.opportunityTeamMembers; 
            opportunities = res.opportunities;

            
        //    Multibooking.AddComercialPrincipalMultibooking((list<Opportunity>) newList);
        }


    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)  
    {  
        if ( newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty())
        
    	{
            //Comprobar si ha cambiado el estado del new con el old.
            if( label.SwitchAccSAP=='True'){
                if(SendOpportunityToSAP.comprobarCambios((list<Opportunity>) newList, (map<Id,Opportunity>) oldMap)){
                system.debug('Dentro del trigger handler opp');
                SendOpportunityToSAP.sendOppToSAPPreventa(newList[0].id);
                }
            }
                   
    		if(listOppsConAcc != null && !listOppsConAcc.isEmpty()) //No hace falta hacer este método si la List no contiene algo
    		{
				OpportunityUtil.createFolderSharePoint((list<Opportunity>) newList, (map<Id,Opportunity>) oldMap, listOppsConAcc);
                	
    		}

        } 
        
 
            List<Opportunity> newOpportunities = (List<Opportunity>)newList;
            Map<Id, Opportunity> oldOpportunities = (Map<Id, Opportunity>)oldMap;
            
            // Identificar oportunidades que cumplan con las condiciones para llamar al servicio
             Set<Id> opportunitiesToProcess = new Set<Id>();
    
        for (Opportunity newOpp : newOpportunities) {
            Opportunity oldOpp = oldOpportunities.get(newOpp.Id);
            
            if (!processedOppIds.contains(newOpp.Id) && EPPM_Service.checkChanges(oldOpp, newOpp)) {
           
                opportunitiesToProcess.add(newOpp.Id);
                processedOppIds.add(newOpp.Id);
            }
        }
        
        // Llamar al servicio con las oportunidades
        if (!opportunitiesToProcess.isEmpty()) {
           String payload = EPPM_PayloadBuilder.generatePayload(opportunitiesToProcess);
          EPPM_HTTPService.sendPayload(payload, opportunitiesToProcess);
        }
        
        // Enviar lineas de proyecto preventa

        if (newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty()) 

        {

            OpportunityUtil.serializeAndSendProjectLinesPreventa(newList,null,oldMap);

        }
        
        
        // Equipo de oportunidad - Se cachean los datos del equipo solo para las oportunidades que se modifiquen los campos apropiados
        if (newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty())
        {
            ProjectLineUtil.QueryOpportunityTeamResult res = ProjectLineUtil.queryOpportunityTeam(newList, oldMap); 
            opportunityTeamMembers = res.opportunityTeamMembers;
            opportunities = res.opportunities;
        }
       
        Integer Flag =GeneradorForecast.CumpleCondicionesOportunidadForecast((list<Opportunity>) newList,(map<Id,Opportunity>) oldMap);
        if(!Test.isRunningTest() && Label.SwitchForecast=='True'){
             GeneradorForecast.ModificarForecastFromOpportunity((list<Opportunity>) newList,Flag);
        }
    }
     
    public void afterDelete(map<Id,SObject> oldMap)                         {   }
     
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     * Any new DML operation should be included in this method
     */
    public void andFinally()                                                
    {
        // Equipo de oportunidad - Solo afecta a los triggers afterX
        if (Trigger.isAfter && !Trigger.isDelete ) 
        {

            if(opportunityTeamMembers!=null){
            // 2. Borramos los miembros de equipo actuales
            if (!opportunityTeamMembers.isEmpty())
            {
			 List<OpportunityTeamMember> opportunityTeamMemberstodelete = new List<OpportunityTeamMember>();
               	
                for(OpportunityTeamMember oppt:opportunityTeamMembers ){
                    if(oppt.AutoGenerated__c==true){
                        opportunityTeamMemberstodelete.add(oppt);
                    }
                }
                delete opportunityTeamMemberstodelete;
            }

            // 3. Creamos de nuevo los equipos

            List<OpportunityTeamMember> newTeam = ProjectLineUtil.generateOpportunityTeam(opportunities, mapRolId);
            
            if (!newTeam.isEmpty())
            {
             
                insert newTeam;
            }

        }
           
        }

        // Actualizar contador de codigos de oportunidad
        if (oppCodeCounter != null)
        {
            // Actualizar el contador de oportunidad
            
             if (oppCodeCounter.Id != null)
             {
                 update oppCodeCounter;
             } else {
                 insert oppCodeCounter;
             }
         }

        // ------------------------- Inserción de oportunidades, lineas y licencias
        if (insertOpportunities != null && !insertOpportunities.isEmpty())
        {
            // Creamos la lista de todas las lineas de proyecto para "insertar"
            List<Linea_de_Proyecto__c> allProjectLines = new List<Linea_de_Proyecto__c>();
            for (Opportunity opp : insertProjectLines.keySet())
            {
                for (Linea_de_Proyecto__c projLine : insertProjectLines.get(opp))
                {
                    allProjectLines.add(projLine);
                }
            }

            // Creamos la lista de todas las licencias
            List<Licencia__c> allLicenses = new List<Licencia__c>();

            // Ordenamos las lineas por linea de proyecto => indice oportunidad
            Map<Linea_de_Proyecto__c, Integer> projectLineToOpptyIndex = new Map<Linea_de_Proyecto__c, Integer>();
            for (Opportunity opp : insertProjectLines.keySet())
            {
                for (Linea_de_Proyecto__c projLine : insertProjectLines.get(opp))
                {
                    projectLineToOpptyIndex.put(projLine, insertOpportunities.indexOf(opp));
                }
            }

            // Ordenamos las licencias por licencia => indice de linea de proyecto
            Map<Licencia__c, Integer> licenseToProjectLineIndex = new Map<Licencia__c, Integer>();
            for (Linea_de_Proyecto__c projLine : insertLicenses.keySet())
            {
                if(insertLicenses.get(projLine)!=null) {
                    for (Licencia__c license : insertLicenses.get(projLine))
                    {
                        licenseToProjectLineIndex.put(license, allProjectLines.indexOf(projLine));
                        allLicenses.add(license);
                    }
                }
            }

            // Insertamos las oportunidades
            insert insertOpportunities;

            // Relacionamos e insertamos las lineas de proyecto
            if (allProjectLines != null && !allProjectLines.isEmpty())
            {
                for (Linea_de_Proyecto__c projLine : allProjectLines)
                {
                    // Relacionamos la oportunidad, recuperando el indice de la oportunidad insertada, y de la lista el Id
                    projLine.Oportunidad__c = insertOpportunities.get(projectLineToOpptyIndex.get(projLine)).Id;
                    projLine.Codigo_SAP_Ejecucion__c = null;
                }

                insert allProjectLines;

                // Relacionamos e insertamos las licencias
                if (allLicenses != null && !allLicenses.isEmpty())
                {
                    for (Licencia__c license : allLicenses)
                    {
                        license.Linea_de_Proyecto__c = allProjectLines.get(licenseToProjectLineIndex.get(license)).Id;
                    }

                    insert allLicenses;

                }

            }

        } // ------------------------ Inserción de oportunidades, lineas y licencias

    }
}