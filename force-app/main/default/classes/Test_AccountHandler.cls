/** 
* @description: Clase para hacer test sobre las DML de Account
**
* @Autor: gserrano (20/11/2018)
**
* @Modificacion: 
**
*/

@isTest
public class Test_AccountHandler 
{
    private static void test_scenario()
    {
        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        //Inserta 2 Oportunidades preventa
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        //Inserta 2 Lineas con 2 Licencias cada una (dentro de la Opp anteior)  
        List<Linea_de_Proyecto__c> lpsL = TestUtil.generaLineasLicenciasTest(opps, conts);

        opps[0].StageName = 'Solicitada'; 
        opps[0].amount = 200;
        opps[1].StageName = 'Solicitada'; 
        opps[1].amount = 200;

        update opps;

        opps[0].StageName = 'Preventa';
        opps[1].StageName = 'Preventa';

        update opps; 

        accs[0].Phone = '666666666';
        accs[1].Phone = '666666667';

        update accs;

    }

    /** 
	* @description: Pruebas a Batch_SincronizarCuentas
	**
	* @Autor: gserrano (20/11/2018)
	**
	* @Modificacion: 
	**
	*/

    @isTest
    static void testSincronizarCuentasProcesadas()
    {
        //TEST--------------------------------------------------------------------------------------
        
        Test.startTest();

            Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());     

            test_scenario();
			
        Test.stopTest();
        
        //TEST--------------------------------------------------------------------------------------
        
        //ASSERTS------------------------------------------------------------------------------------
        
        /*Aquí irían los asserts correspondiente a comprobar si se ha procesado correctamente la respuesta del servicio web al que llamamos
        En este caso esa respuesta es la falseada en el mock
        Habra que hacer q devuelve un ID SAP y comprobar si en la cuenta se ha establecido ese valor para su campo ID_SAP__c*/
        
        //ASSERTS------------------------------------------------------------------------------------
    }
}