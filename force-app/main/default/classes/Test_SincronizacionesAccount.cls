/**
* @description: Clase para hacer test sobre la sincronización
				de las DMLs de Account (trigger) del Batch_SincronizarCuentas
**
* @Autor: gserrano (20/11/2018)
**
* @Modificacion:
**
*/

@isTest
public class Test_SincronizacionesAccount
{
    private static void test_scenario_DMLs()
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

    private static void test_scenario_Batch()
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
        Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());

        Test.startTest();

            test_scenario_DMLs();

        Test.stopTest();

        //TEST--------------------------------------------------------------------------------------

        List<Account> accs = [SELECT ID, Id_SAP__c, Sincronizado_SAP__c FROM ACCOUNT WHERE ID_SAP__c != null OR ID_SAP__c != ''];
        List<Account> accsFail = [SELECT ID, Id_SAP__c, Sincronizado_SAP__c FROM ACCOUNT WHERE ID_SAP__c = 'FAIL'];

        System.debug(accs);

        //ASSERTS------------------------------------------------------------------------------------
        //Las cuentas con idSAP se han modificado o creado correctamente
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        //Las cuentas que tiene como ID = FAIL Está preparada para que no se puede sincronizar
        System.assert(accsFail[0].Sincronizado_SAP__c == false);

        //ASSERTS------------------------------------------------------------------------------------
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
    static void testSincronizarCuentasBatch()
    {
        //TEST--------------------------------------------------------------------------------------
        Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());
        test_scenario_Batch();

        Test.startTest();

            //Si la creación de datos provocara que algún trigger realizara un Callout, esta línea debería ponerse antes
        	//de la creación de los datos, lo cual no estaría permitido hacer en el @testSetup,
			//porque el @testSetup solo conserva el estado de la Database, no el Mock,
        	//por lo que el método encargado de crear los datos deberia ser static y llamarse en la línea siguiente al Test.setMock()


        	//La siguiente línea daria el error "You have uncommited work pending",
        	//por eso ejecutamos el batch "por partes"

            //Database.executeBatch(new Batch_SincronizarCuentas());

            //Esta es la forma de testear un Batch que llame a un Callout desde un test

            SchedulableContext sc;
            Batch_SincronizarCuentas bClass = new Batch_SincronizarCuentas();

            //Database.QueryLocator queryLocator = bClass.start(bc);

            //Database.QueryLocatorIterator  iterator = queryLocator.iterator();

            bClass.execute(sc);


        Test.stopTest();

        //TEST--------------------------------------------------------------------------------------
        //Las cuentras procesadas son sincronizadas con exito y su ID_SAP es informado, salvo para la cuenta con ID_SAP = FAIL, para mas detalle mirar la clase WebServiceMockGenerator
        List<Account> accs  = [SELECT ID, Sincronizado_SAP__c FROM ACCOUNT WHERE ID_SAP__c != null OR ID_SAP__c != '' OR ID_SAP__c != 'FAIL'];
        List<Account> accs2 = [SELECT ID, Sincronizado_SAP__c FROM ACCOUNT WHERE ID_SAP__c = 'FAIL'];

        //ASSERTS------------------------------------------------------------------------------------
        //PITT COMENTAR
        // System.assert(accs[0].Sincronizado_SAP__c == true);
        // System.assert(accs[1].Sincronizado_SAP__c == true);
        // System.assert(accs2[0].Sincronizado_SAP__c == false);

        //ASSERTS------------------------------------------------------------------------------------
    }
}