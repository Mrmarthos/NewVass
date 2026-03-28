public class RelacionComercialHandler implements ITrigger {


    // Constructor
    public RelacionComercialHandler(){

    }
 
    /**
     * bulkBefore
     *
     * These methods are called prior to execution of a BEFORE or AFTER trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     * Any new SOQL operation should be included in these methods (bulkBefore or bulkAfter)
     */
    public void bulkBefore(list<SObject> newList, map<Id,SObject> oldMap){}
    
    public void bulkAfter(list<SObject> newList, map<Id,SObject> oldMap){}
 
    /* These methods ara called for records to be processed during a BEFORE 
     * trigger.
     */
    public void beforeInsert(list<SObject> newList){

        
    }
    
    public void beforeUpdate(list<SObject> newList, map<Id,SObject> oldMap){}


    
    public void beforeDelete(map<Id,SObject> oldMap){

        system.debug('--------------------DELETE-------------');

        system.debug( (map<Id,Comerciales_Multibooking__c>) oldMap );

        for (Id id : oldMap.keySet()){

            System.debug('field name is ' + id);
            Comerciales_Multibooking__c relacion= (Comerciales_Multibooking__c)oldMap.get(id);
            if(relacion.Principal__c){

                 relacion.AddError('No se puede eliminar la relacion principal');
            }else {

                    Multibooking.RemoveCoomercialTeamOportunidad(Relacion);
                       List<Opportunity> listOpp = new List<Opportunity>();
                       listOpp=[SELECT id from Opportunity WHERE  id in (SELECT  Oportunidad__c   from Comerciales_Multibooking__c WHERE  id=:relacion.id)];
                        System.debug('modificoooooo analiticaaaaaa');
                        GeneradorForecast.ModificarForecastFromOpportunity(listOpp,2);



            }
        }

        system.debug('--------------------DELETE-------------');




    }
    
    /**
     * These methods ara called for records to be processed during a AFTER 
     * trigger.
     */ 
    public void afterInsert(list<SObject> newList)
    {


         List<Comerciales_Multibooking__c> relaciones = (list<Comerciales_Multibooking__c>) newList;

       
        List<Opportunity> listOpp = new List<Opportunity>();
        listOpp=[SELECT id,RecordTypeId from Opportunity WHERE  id in (SELECT  Oportunidad__c   from Comerciales_Multibooking__c WHERE  id=:relaciones.get(0).id)];
        System.debug('modificoooooo analiticaaaaaa');
        if(Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_RENOVACION).getRecordTypeId()!=listOpp.get(0).RecordTypeId){
        GeneradorForecast.ModificarForecastFromOpportunity(listOpp,2);
        }
    
       Multibooking.AddCoomercialTeamOportunidad((list<Comerciales_Multibooking__c>) newList);



    }

    public void afterUpdate(list<SObject> newList, map<Id,SObject> oldMap) 
    {
            
    }
     
    public void afterDelete(map<Id,SObject> oldMap){} 
    
    /**
     * andFinally 
     * 
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     * Any new DML operation should be included in this method
     */
    public void andFinally(){}

}