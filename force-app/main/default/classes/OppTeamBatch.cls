/**
 * @author Adrián Bernardo Monedero
 * Batch to insert Opportunity Team Members automatically
 */
global class OppTeamBatch implements Database.Batchable<sObject>{
    global string userId;
    global string query;
    global string clan;
    global string sede;
    global boolean hasLP;
    global string technicalOffice;

    global OppTeamBatch(String userId,String clan,String sede,boolean hasLP){
        this.userId = userId;
        this.clan = clan;
        this.sede = sede;
        this.hasLP = hasLP;
        this.query = createQuery(this.clan,this.sede,this.hasLP);
    } 

    global Database.QueryLocator start(Database.BatchableContext BC){
          System.debug('QUERY LANZADA ---->'+query);
          return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext BC,List<sObject> scope) {
        
        try{
            list<OpportunityTeamMember> oppTeamMembers = new list<OpportunityTeamMember>();

            if(scope.get(0).getSObjectType() == Opportunity.getSObjectType()){
                for(Opportunity opp : (List<Opportunity>) scope){
                    OpportunityTeamMember teamMember = new OpportunityTeamMember();
                    teamMember.OpportunityId = opp.id;
                    teamMember.OpportunityAccessLevel = 'Edit';
                    teamMember.TeamMemberRole = 'Equipo_generado';
                    teamMember.userID = userID;
                    oppTeamMembers.add(teamMember);
                }
            }else{
                for(Linea_de_Proyecto__c PL : (List<Linea_de_Proyecto__c>) scope){
                    OpportunityTeamMember teamMember = new OpportunityTeamMember();
                    teamMember.OpportunityId = pl.Oportunidad__c;
                    teamMember.OpportunityAccessLevel = 'Edit';
                    teamMember.TeamMemberRole = 'Equipo_generado';
                    teamMember.userID = userID;
                    oppTeamMembers.add(teamMember);
                }
            }
       
       

        if(!oppTeamMembers.isEmpty()){
           List<Database.SaveResult> sresultList = Database.insert(oppTeamMembers,false);
           if(!sresultList.isEmpty()){
            for(Database.SaveResult sr : sresultList){
                if(!sr.isSuccess()){
                    system.debug('Error al insertar el registro '+sr.getErrors() + ' / '+sr.getId());
                }
            }
        }
        }

    } catch(Exception ex){
        system.debug(ex.getCause()+'//'+ex.getMessage());
    }

        
    }
    
      global void finish(Database.BatchableContext BC) {
        System.debug(LoggingLevel.WARN,'Batch Job terminado.');
   }

   /**
    * @description creates a dynamic query depending on the parameters the batch received.
    * @author Adrián Bernardo Monedero
    * @date 26/03/2023
    * @return retuns the query ,.................................l´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´ws-dfffffffto use by the batch.
    */
   public String createQuery(String clan,String sede,Boolean hasLP){
        String queryADevolver = hasLP ? 'select Oportunidad__c from Linea_de_Proyecto__c WHERE Oportunidad__c != null AND Oportunidad__r.StageName IN (\'Pendiente Aprobacion\',\'Presentada\',\'Entregada\',\'Preventa\',\'Solicitada\',\'Identificada\') ' : 'select id from Opportunity WHERE StageName IN (\'Pendiente Aprobacion\',\'Presentada\',\'Entregada\',\'Preventa\',\'Solicitada\',\'Identificada\') ';
        if(!String.isBlank(clan) && clan != null){
            queryADevolver += hasLP ? ' AND Gerencia__c =\''+clan+'\'' : ' AND Clan_Principal__c =\''+clan+'\'';
        }
        if(!String.isBlank(sede) && sede != null){
            queryADevolver += hasLP ? ' AND Oportunidad__r.Owner.Sede__c =\''+sede+'\'' : ' AND Owner.Sede__c =\''+sede+'\'';
        }

        return queryADevolver;
   }

}