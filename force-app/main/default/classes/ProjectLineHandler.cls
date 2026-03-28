public without sharing class ProjectLineHandler implements ITrigger
{
	
	List<OpportunityTeamMember> opportunityTeamMembers;
    List<Opportunity> opportunities;
    Set<String> setRol = new Set<String>{'Gerente_de_operaciones','Jefe_Clan_Comunytek', 'Responsable_de_area','Responsable_Oficina_Tecnica_Serbatic','Jefe_Clan_Nateevo','Lider_de_consejo_Nateevo','Jefe_de_clan_global'};
    static Map<String,Id> mapRolId = new Map<String,Id>();
    public static boolean VIENE_DE_SAP = false;
	
    // Constructor
    public ProjectLineHandler() {}
 
    /**
     * bulkBefore
     *
     * These methods are called prior to execution of a BEFORE or AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     * Any new SOQL operation should be included in these methods (bulkBefore or bulkAfter)
     */
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)   
    {  
        //Conseguir el mapa de <DeveloperName, Id> del objeto UserRole
        mapRolId = Utils.queryUserRol(setRol);

        // 1. Cachear oportunidades
        
        ProjectLineUtil.QueryOpportunityTeamResult res = ProjectLineUtil.queryOpportunityTeam(newList, oldMap);
        //opportunityTeamMembers = res.opportunityTeamMembers;
        opportunities = res.opportunities;
        
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)    
    { 
        // 1. Se cachean oportunidades, miembros de equipo de oportunidad y todas las lineas de proyecto de las oportunidades relacionadas
       
        ProjectLineUtil.QueryOpportunityTeamResult res = ProjectLineUtil.queryOpportunityTeam(newList, oldMap);
        opportunityTeamMembers = res.opportunityTeamMembers;
        opportunities = res.opportunities;
        
    }

    /* These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)                         
    {   
        newList = ProjectLineUtil.markPrimaries(newList, opportunities);
        newList = ProjectLineUtil.validateUsers(newList);
       			
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap) 
    { 
    	newList = ProjectLineUtil.validateUsers(newList);
        newList = ProjectLineUtil.markPrimariesUpdate(newList, oldMap);
         newList = ProjectLineUtil.UpdateAmountLicenes(newList);
        //ProjectLineUtil.ComposeNombreSAP(newList, null);
    }
    
    public void beforeDelete(map<Id,SObject> oldMap)                        {   }
    
    /**
     * These methods ara called for records to be processed during a AFTER 
     * trigger.
     */ 
    public void afterInsert(list<SObject> newList)
    {
        if(newList != null && !newList.isEmpty()) 
        {
              if(!Test.isRunningTest() ||Test_ProjectLineHandler.testSerialize){
            //Llamada al método que envía las lineas de proyecto a SAP cuando se modifican
            ProjectLineUtil.serializeAndSendProjectLines(newList, Constants.SAP_LPS_PREVENTA_PATH, null, false);
          
            GeneradorForecast.serializeandGenerateForecastLinea(newList,'Linea');
                 
            }
        }
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)  
    { 
        if(newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty()) 
        {
            if(!VIENE_DE_SAP)
            {
                if(!Test.isRunningTest() ||Test_ProjectLineHandler.testSerialize){
                //Llamada al método que envía las lineas de proyecto a SAP cuando se modifican
                ProjectLineUtil.serializeAndSendProjectLines(newList, null, oldMap, false);
                }
            }
            if(!System.isfuture() && !System.isBatch()){
                
                if(!Test.isRunningTest()){  
                

                GeneradorForecast.ModificarForecast(newList);
               
                }
            }
            
            ProjectLineUtil.CheckMargenIntercompany(newList,oldMap);

        
       // GeneradorForecast.CambiaFechaLP( (list<Linea_de_Proyecto__c>) newList, (map<Id,Linea_de_Proyecto__c>) oldMap);

        

        
        }
    }
     
    public void afterDelete(map<Id,SObject> oldMap){ }
     
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     * Any new DML operation should be included in this method
     */
    public void andFinally()                                                
    {   
        if (Trigger.isAfter) 
        {
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
}