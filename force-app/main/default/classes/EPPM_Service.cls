public with sharing class EPPM_Service {
    private static final EPPM_MappingUtility mapper = EPPM_MappingUtility.getInstance();
    private static final Set<String> STAGE_FILTER = new Set<String>{'Identificada','Solicitada'};

    public static Boolean checkChanges(Opportunity oldOpp, Opportunity newOpp) {
        return ( checkStageChange(oldOpp, newOpp) || 
               checkExcelChange(oldOpp, newOpp) || 
               checkFieldChanges(oldOpp, newOpp));
    }

    private static Boolean checkStageChange(Opportunity oldOpp, Opportunity newOpp) {
        Boolean isTargetStage = newOpp.StageName == 'Preventa' || 
                               newOpp.StageName == 'Entregada' || 
            				   newOpp.StageName == 'Presentada' || 
            				   
                               newOpp.isClosed != oldOpp.isClosed;
        
        return isTargetStage && newOpp.StageName != oldOpp.StageName ;
    }

    private static Boolean checkExcelChange(Opportunity oldOpp, Opportunity newOpp) {
        return newOpp.N_Cargas_Excel__c != oldOpp.N_Cargas_Excel__c;
    }

    private static Boolean checkFieldChanges(Opportunity oldOpp, Opportunity newOpp) {
        if(STAGE_FILTER.contains(newOpp.StageName)) return false;
        
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Opportunity.fields.getMap();
        for(String field : EPPM_Config.TRACKED_FIELDS) {
            if(fields.containsKey(field) && newOpp.get(field) != oldOpp.get(field)) {
                return true;
            }
        }
        return false;
    }
}