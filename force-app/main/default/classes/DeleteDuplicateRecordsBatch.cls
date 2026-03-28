public class DeleteDuplicateRecordsBatch implements Database.Batchable<SObject>, Database.Stateful , Schedulable{

    // Variable que guardará el campo por el que quieres detectar duplicados
    private String duplicateField;

    // Constructor para pasar el campo a la clase batch
    public DeleteDuplicateRecordsBatch(String duplicateField) {
        this.duplicateField = duplicateField;
    }

    // Método que hace la consulta de los registros duplicados
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Consulta todos los registros de Analitica__c con el campo duplicado y ordenados por Duplicatefield__c
        return Database.getQueryLocator([
            SELECT Id, Duplicatefield__c 
            FROM Analitica__c 
            WHERE RecordType.Name = 'Forecastdelinea'
            ORDER BY Duplicatefield__c
        ]);
    }

    // Método que procesa los registros en lotes
    public void execute(Database.BatchableContext bc, List<Analitica__c> scope) {
        // Mapa para identificar los duplicados
        Map<String, Analitica__c> uniqueRecords = new Map<String, Analitica__c>();
        List<Analitica__c> recordsToDelete = new List<Analitica__c>();

        for (Analitica__c record : scope) {
            if (uniqueRecords.containsKey(record.Duplicatefield__c)) {
                // Si ya existe un registro con el mismo valor de Duplicatefield__c, lo marcamos para eliminar
                recordsToDelete.add(record);
            } else {
                // Si es el primer registro con este valor, lo agregamos al mapa
                uniqueRecords.put(record.Duplicatefield__c, record);
            }
        }

        // Eliminamos los registros duplicados
        if (!recordsToDelete.isEmpty()) {
            // Debug para mostrar los registros a eliminar
            System.debug('Número de duplicados encontrados en este lote: ' + recordsToDelete.size());
            System.debug('Registros duplicados: ' + recordsToDelete);
            
            // Eliminar los registros duplicados (comentado por ahora)
             delete recordsToDelete;
        }
    }

    // Método que finaliza el batch
    public void finish(Database.BatchableContext bc) {
        System.debug('Proceso de eliminación de duplicados completado.');
    }
    
     // Método Schedulable para programar el batch
    public void execute(SchedulableContext sc) {
        // Ejecutar el batch usando la misma instancia actual y el campo de duplicados ya proporcionado
        Database.executeBatch(this);
    }
    
    
    
    
    
    
}