@Istest
private class Test_reprocesaEvento {
        
    /**
    *@description: Comprueba que se programa el Job que republica los eventos y
                   se aborta al terminar
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/  
    @isTest
    static void test_republicar()
    {
        List<E_Linea_de_Proyecto__e> eventoList = new List<E_Linea_de_Proyecto__e>();
        eventoList.add (
                        new E_Linea_de_Proyecto__e (
                        eoperacion__c ='UPDATE',
                        Codigo_SAP_Ejecucion__c = '11'
                        ) 
                        );
        ReprocesaEvento re = new ReprocesaEvento(eventoList);

        Integer hour = Datetime.now().hour();
        Integer min = Datetime.now().minute() + 30; 
        Integer ss = Datetime.now().second();
        
        if( min >= 60)
        {
            hour++;
            min = min - 60;
        }
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        //recuperamos el ID
        String jobId = System.schedule('Republicar Eventos ' + String.valueOf(Datetime.now()), nextFireTime, re);
        Test.startTest();
        //verificamos que existe el job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        //debería haber 1 job programado
        system.assertEquals(jobId, ct.ID);
        Test.stopTest();
        Integer jobs = [SELECT count() FROM CronTrigger WHERE id = :jobId]; 
        //el job debería haberse ejecutado y abortado
        system.assertEquals(jobs, 0);


    }   
}