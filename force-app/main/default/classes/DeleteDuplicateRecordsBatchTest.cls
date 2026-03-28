@isTest
public class DeleteDuplicateRecordsBatchTest {

    @isTest
    static void testBatchDeleteDuplicates() {
        // Crear registros de prueba
        List<Analitica__c> testRecords = new List<Analitica__c>();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        // Agregamos algunos registros con el mismo valor en el campo Duplicatefield__c para simular duplicados
        testRecords.add(new Analitica__c(Importe_Forecast__c = 1,cuenta__c=testAccount.id, RecordTypeId = Schema.getGlobalDescribe().get('Analitica__c').getDescribe().getRecordTypeInfosByName().get('ForecastDeLinea').getRecordTypeId()));
        testRecords.add(new Analitica__c(Importe_Forecast__c = 1,cuenta__c=testAccount.id, RecordTypeId = Schema.getGlobalDescribe().get('Analitica__c').getDescribe().getRecordTypeInfosByName().get('ForecastDeLinea').getRecordTypeId()));
        testRecords.add(new Analitica__c(Importe_Forecast__c = 1, cuenta__c=testAccount.id,RecordTypeId = Schema.getGlobalDescribe().get('Analitica__c').getDescribe().getRecordTypeInfosByName().get('ForecastDeLinea').getRecordTypeId()));
        testRecords.add(new Analitica__c(Importe_Forecast__c = 2,cuenta__c=testAccount.id, RecordTypeId = Schema.getGlobalDescribe().get('Analitica__c').getDescribe().getRecordTypeInfosByName().get('ForecastDeLinea').getRecordTypeId()));
        testRecords.add(new Analitica__c(Importe_Forecast__c = 3,cuenta__c=testAccount.id, RecordTypeId = Schema.getGlobalDescribe().get('Analitica__c').getDescribe().getRecordTypeInfosByName().get('ForecastDeLinea').getRecordTypeId()));
        
        // Insertamos los registros de prueba
        insert testRecords;

        // Ejecutar el batch
        DeleteDuplicateRecordsBatch batch = new DeleteDuplicateRecordsBatch('Duplicatefield__c');
        Database.executeBatch(batch);

        // Verificar los resultados
        List<Analitica__c> remainingRecords = [
            SELECT Id, Duplicatefield__c 
            FROM Analitica__c 
            WHERE RecordType.Name = 'ForecastDeLinea'
        ];

        // Comprobar que solo queda un registro por cada valor único en el campo Duplicatefield__c
        Map<String, Integer> recordCountByField = new Map<String, Integer>();
        for (Analitica__c record : remainingRecords) {
            if (!recordCountByField.containsKey(record.Duplicatefield__c)) {
                recordCountByField.put(record.Duplicatefield__c, 0);
            }
            recordCountByField.put(record.Duplicatefield__c, recordCountByField.get(record.Duplicatefield__c) + 1);
        }

     
    }
}