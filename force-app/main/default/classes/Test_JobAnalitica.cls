@Istest
public class Test_JobAnalitica {

    private static void test_scenario_DMLs()
    {
        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        //Inserta 2 Oportunidades preventa
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        //Inserta 2 Lineas con 2 Licencias cada una (dentro de la Opp anteior)
        List<Linea_de_Proyecto__c> lpsL = TestUtil.generaLineasLicenciasTest(opps, conts);

        lpsL[0].Fecha_Inicio__c = date.newInstance(2018, 03, 01);
        lpsL[0].Linea_principal__c = TRUE;
        lpsL[0].Fecha_Fin__c = date.newInstance(2018, 03, 11);
        lpsL[1].Fecha_Inicio__c = date.newInstance(2018, 03, 01);
        lpsL[1].Linea_principal__c = TRUE;
        lpsL[1].Fecha_Fin__c = date.newInstance(2018, 03, 11);

        lpsL[0].No_aplica_para_ejecucion__c = FALSE;
        lpsL[1].No_aplica_para_ejecucion__c = FALSE;
		system.debug('lpSSSSSSSSss' + lpsL);
        //Update lpsL;
    }
    /**
    *@description: Comprueba que el job que actualiza las analíticas
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/03/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description:
    *@see class/method:
    **/  
    @isTest
    static void jobAnaliticaTest()
    {
        Job_Analitica job = new Job_Analitica();
        Integer hour = Datetime.now().hour();
        Integer min = Datetime.now().minute() + 30; 
        Integer ss = Datetime.now().second();
        
        if( min >= 60)
        {
            hour++;
            min = min - 60;
        }
        test_scenario_DMLs();
        //parse to cron expression
        Test.startTest();
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        String jobId = System.schedule('Actualizar Analitica ' + String.valueOf(Datetime.now()), nextFireTime, job);
        //verificamos que existe el job
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        //debería haber 1 job programado
        system.assertEquals(jobId, ct.ID);
        Test.stopTest();

    }   

}