@isTest
public class Test_QueueableDMLSObjects 
{

    @isTest
    public static void pruebaInsert()
    {
        User us = [SELECT Id FROM User LIMIT 1];

        List<Task> tareasEjemplo = new List<Task>();
        for (Integer i = 0; i < 151; i++) 
        {
            tareasEjemplo.add(new Task(
                Subject = 'prueba'+i,
                OwnerId = us.Id
            ));
        }

        //COMPRUEBA INSERTS
        System.debug(tareasEjemplo.size());
        Test.startTest();
        System.enqueueJob(new Queueable_DMLSObjects(tareasEjemplo, Queueable_DMLSObjects.Operation.INSERTA));
        Test.stopTest();

        List<Task> tareasEjemploInsertadas =  [SELECT id FROM TASK];
        System.AssertEquals(tareasEjemploInsertadas.size(), tareasEjemplo.size()-1);
        //FIN COMPRUEBA INSERT
    }
}