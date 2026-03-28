global  class ScheludablehistoricoActionPlan implements Schedulable {

    global void execute(SchedulableContext sc) {

        
          BatchHistoricoActionPlan uca = new BatchHistoricoActionPlan();
        
        Id batchId = Database.executeBatch(uca,50);          
    }

}