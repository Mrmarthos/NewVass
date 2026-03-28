@Istest
public class Test_ActualizarJP {

        /**
    *@description: Comprueba que el job que actualiza los JPs funciona
    *@param name Description:
    *@author name: rpolvera
    *@date date: 21/12/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/  
    @isTest
    static void test_actualizaJP()
    {
        Job_Actualizajp job = new Job_Actualizajp();
        Integer hour = Datetime.now().hour();
        Integer min = Datetime.now().minute() + 30; 
        Integer ss = Datetime.now().second();
        
        if( min >= 60)
        {
            hour++;
            min = min - 60;
        }

        //parse to cron expression
        Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
        Test.startTest();
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId = System.schedule('Actualizar JP ' + String.valueOf(Datetime.now()), nextFireTime, job);
        //verificamos que existe el job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        //debería haber 1 job programado
        system.assertEquals(jobId, ct.ID);
        Test.stopTest();
    }   

}