/** 
* @description: Clase para hacer test a OpportunityCrearCarpetaSPBatchTest
**
* @Autor: Noemi Escudero del Olmo (07/11/2018)
**
* @Modificacion:
**
*/
@isTest (SeeAllData = false)
public with sharing class OpportunityCrearCarpetaSPBatchTest 
{
   
   	private static void test_scenario()
    {		        
        Opportunity_code_counter__c code =  new Opportunity_code_counter__c
		(
			Year__c = '	2018;2019',
			Number__c = '38;3'
		);
        insert code;         
        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        List<linea_de_proyecto__c> lps = TestUtil.generaLineasLlaveManoTest(opps, conts);
		
		
		//Modificar Opp
		for(Integer i = 0; i < 2; i++) //total
		{
	        opps[i].StageName = 'Solicitada'; //oportunidadList
		}
		update opps;

		//Modificar Opp
		for(Integer i = 0; i < 2; i++) //total
		{
	        opps[i].StageName = 'Preventa';  //oportunidadList
		}
		update opps;
        //OBJECTS-----------------------------------------------------------------------------------
        
    }
    
    /** 
	* @description: Pruebas a OpportunityCrearCarpetaSPBatchTest
	**
	* @Autor: Noemi Escudero del Olmo (07/11/2018)
	**
	* @Modificacion: 
	**
	*/
	@isTest
	public static void test_OpportunityCrearCarpetaSharePointBatch()
	{       
        //TEST--------------------------------------------------------------------------------------

        test_scenario();

        Test.startTest();
        
        	//Si la creación de datos provocara que algún trigger realizara un Callout, esta línea debería ponerse antes 
        	//de la creación de los datos, lo cual no estaría permitido hacer en el @testSetup,
			//porque el @testSetup solo conserva el estado de la Database, no el Mock,
        	//por lo que el método encargado de crear los datos deberia ser static y llamarse en la línea siguiente al Test.setMock()
			Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
			Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        


			Set<String> stageName = new Set<String>{'Preventa','Entregada','Presentada','Ganada'};
			String urlSharepoint_c = '';
			String name = '';
			String accName = '';
			String mercado = '';
			String codigo = '';
			String query = 'Select Id, Name, Account.Name, Mercado__c, StageName, URL_Sharepoint__c, Codigo_de_oportunidad__c From Opportunity Where '+ 
					+'StageName IN :stageName AND '+
					+'URL_Sharepoint__c = \''+urlSharepoint_c+'\' AND '+
					+'Name != \''+name+'\' AND '+
					+'Account.Name != \''+accName+'\' AND '+
					+'Codigo_de_oportunidad__c != \''+codigo+'\' AND '+
					+'Mercado__c != \''+mercado+'\' LIMIT 1';

			        
			//La siguiente línea daria el error "You have uncommited work pending", 
			//por eso ejecutamos el batch "por partes"
			
			//Database.executeBatch(new OpportunityCrearCarpetaSharePointBatch(query), 1);
		
			//Esta es la forma de testear un Batch que llame a un Callout desde un test
				
	        Database.BatchableContext BC;
        	OpportunityCrearCarpetaSharePointBatch p = new OpportunityCrearCarpetaSharePointBatch(query);
		    //String sch = '0 0 0 13 12 ? 2030';
		    //system.schedule('OpportunityCrearCarpetaSharePointBatch Started At ' + String.valueOf(Datetime.now()), sch, p);
		    Database.queryLocator dbql = p.start(BC); 			  
		    Database.QueryLocatorIterator  iterator = dbql.iterator(); 
			List<sObject> aScopeList = new List<sObject> ();  
            while (iterator.hasNext())  
            {
                aScopeList.add(iterator.next());
            }
            p.execute(BC, aScopeList);
            p.finish(bc);
	        		    
		Test.stopTest();
			List<Opportunity_code_counter__c> oppCfgs = [SELECT Year__c, Number__c FROM Opportunity_code_counter__c LIMIT 1];
			System.debug(oppCfgs);
        //TEST--------------------------------------------------------------------------------------- 
        	
        List<Opportunity> listaOportunidadesDespuesBatch = [SELECT URL_Sharepoint__c, Codigo_de_oportunidad__c FROM Opportunity];
        System.debug(listaOportunidadesDespuesBatch);
        //ASSERTS------------------------------------------------------------------------------------

        	System.assertNotEquals('', listaOportunidadesDespuesBatch[0].URL_Sharepoint__c, 'Opp : La URL de SharePoint debería estar rellena, no vacío.');
            System.assertNotEquals(null, listaOportunidadesDespuesBatch[0].URL_Sharepoint__c, 'Opp : La URL de SharePoint debería estar rellena, no null.');
            System.assertEquals('https://grupovass.sharepoint.com/es-es/businessvalue/offering/Biblioteca de Ofertas/Industria/AccTest1/'+System.now().year() + '-0001/', listaOportunidadesDespuesBatch[0].URL_Sharepoint__c , 'Opp: La URL de SharePoint no se ha formado bien.');
			//Se pasan dos opps a preventa entonces el contador autoincremental debería sumar +2, para el año 2019  (EDIT:ANDRES MARTOS TEEEEELAAA NTS....EN EL 2020 NO FUNCIONA REVISAR)el valor será 38;5
        	System.assertEquals('38;3;2', oppCfgs[0].Number__c, 'El código autonumérico no se incrementó correctamente.');
	    //ASSERTS------------------------------------------------------------------------------------
	}
}