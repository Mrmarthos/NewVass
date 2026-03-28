global class ScheludableHsitoricoAnaliticas implements Schedulable{



    global void execute(SchedulableContext sc) {

        BatchHistoricoAnaliticas Batch = new BatchHistoricoAnaliticas();
        ID batchprocessid = Database.executeBatch(Batch);           
    }
}