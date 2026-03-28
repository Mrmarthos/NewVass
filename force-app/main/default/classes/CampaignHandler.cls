public class CampaignHandler implements ITrigger
{
    
    // Listado de usuarios-campaña que han pasado a estar 'En desarrollo'
    List<Usuario_de_Campana__c> activeCampaignUserList;
    
    // Listado de tareas que se van a insertar
    List<Task> tasksToInsert;
        
    
    // Constructor
    public CampaignHandler() {}
 
    /**
     * bulkBefore
     *
     * These methods are called prior to execution of a BEFORE or AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     * Any new SOQL operation should be included in these methods (bulkBefore or bulkAfter)
     */
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap)   
    {
       
    }
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap)    
    {
       /* if (oldMap != null) {
            ID internalCampaignRecordType = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Constants.CAMPAIGN_RECORDTYPE_INTERNAL).getRecordTypeId();
            List<Campaign> campaignList = (List<Campaign>)newList;
            Set<ID> campaignIds = new Set<ID>();
            
            for (Campaign cmp : campaignList)
            {
                System.debug(cmp);
                System.debug(oldMap);
                //Conseguir el mismo registro que se modifica, pero su estado anterior en SF
                Campaign oldCmp = (Campaign)oldMap.get(cmp.Id);
                
                //Hacer la comprobación de que se haya cambiado el estado a "En desarrollo" (activo) y la campaña sea de tipo interno.
                if ((cmp.Status != oldCmp.Status) && (cmp.Status == Constants.CAMPAIGN_STATE_ACTIVE) && (cmp.RecordTypeId == internalCampaignRecordType))
                { 
                    campaignIds.add(cmp.Id);
                }
            }
            
            activeCampaignUserList = [SELECT Campana__c, Usuario__c FROM Usuario_de_Campana__c WHERE Campana__c = :campaignIds]; //, Campana__r.Name, Campana__r.Description, Campana__r.EndDate
        }*/
    }

    /* These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList)                         
    { 

    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap) 
    {

    }
    
    public void beforeDelete(map<Id,SObject> oldMap)                        {   }
    
    /**
     * These methods ara called for records to be processed during a AFTER 
     * trigger.
     */ 
    public void afterInsert(list<SObject> newList)
    {
     
    }
     
    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap)  
    {  
        if (newList != null && !newList.isEmpty() && oldMap != null && !oldMap.isEmpty())
        {
            // Crear una lista de tareas para todos los usuarios relacionados con datos de la campaña
            //comentado para test
           // tasksToInsert = CampaignUtil.createTaskToSalesReps(activeCampaignUserList, (Map<Id, Campaign>)Trigger.newMap);
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
        
    }
}