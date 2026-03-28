/** 
* @description: Clase para hacer test a OpportunityUtil
**
* @Autor: Noemi Escudero del Olmo (06/11/2018)
**
* @Modificacion: 
**
*/
@isTest (SeeAllData = false)
public with sharing class OpportunityUtilTest 
{
	private static void insertaOppIdetificada()
	{        
		//OBJECTS-----------------------------------------------------------------------------------
        //Crear Account que debe tener relleno Name y Mercado__c
       Map<String, List<Object>> camposMapAcc = new Map<String, List<Object>>
        {
            'Name' => new List<String>{'AccTest1', 'AccTest2', 'VASS'},
            'Mercado__c' => new List<String>{'Industria', 'Industria', ''},
            'ID_SAP__c' => new List<String>{'IDSAPTEST1','IDSAPTEST2', 'IDSAPVASS'},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).RecordTypeId}
    
        }; 
        
        List<Account> accs = TestUtil.rellenarSObject(Account.SObjectType, camposMapAcc);
        
        insert accs;
 
        Map<String, List<Object>> camposMapCont = new Map<String, List<Object>>
        {
            'LastName' 				=> new List<String>{'ContTest1', 'ContTest2', 'JEFEPROYECTO'},
			'Codigo_de_empleado__c'	=> new List<String>{'12312378', '12345698', '11144477'},                
            'AccountId' => new List<String>{accs[0].Id, accs[1].Id, accs[2].Id},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                               Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                               Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId}
        }; 
         
        List<Contact> conts = TestUtil.rellenarSObject(Contact.SObjectType, camposMapCont);
        
        insert conts; 
 
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' => new List<String>{'Opp101234','OppTest2'},
			'ID_SAP__c'	=> new List<String>{'oprtunidadidsap1234', ''},    // una Opp con ID sap, ya en SAP, la otra para prueba enviar SAP            
            'CloseDate' => new List<Date>{date.newInstance(2018, 12, 12), date.newInstance(2018, 12, 12)},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId},
            'StageName' => new List<String>{'Identificada', 'Identificada'},
            'Mercado__c' => new List<String>{'Industria', 'Industria'},
            'AccountId' => new List<String>{accs[0].Id, accs[1].Id},
            'Bid_Manager__c' => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Offering__c' => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()}, 
            'Contacto_del_cliente__c' => new List<String>{conts[0].Id, conts[1].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c' => new List<Date>{date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11)},
            'Codigo_de_oportunidad__c' => new List<String>{'VASS20180123456701', 'VASS20180123456702'}
        };
        
        List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
       
        insert opps;

        Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
        {
            'Oportunidad__c' => new List<String>{opps[0].Id, opps[1].Id},
            'Gerencia__c' => new List<String>{'Tailor-Made Solutions', 'Tailor-Made Solutions'},
            'Responsable_de_LDP__c' => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Area__c' => new List<String>{'ES00T03003', 'ES00T03003'},
            'Tecnologia__c' => new List<String>{'ADO', 'ADO'},
            'Listo_para_sincronizar__c' => new List<Boolean>{true, true},
            'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[2].Id, conts[2].Id},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId, 
                                               Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId}
        };
          
        List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP);
        
        insert lps;

	}  
	
	/** 
	* @description: Pruebas de OpportunityUtil:
	* 					- getOppWithAcc (bulk before y bulk after)
	* 					- checkCreateFolderSharePoint (before update)
	* 					- createFolderSharePoint (after update)
	* 				Y de IntegracionSharePoint:
	* 					- autenticarSharePoint
    *              		- limpiezaPaths
    *               	- formarURLBodyCrearCarpeta
    *               	- hacerRequest
	* 				Y de IntegracionSharePointVass:
	* 					- crearCarpeta
    *               	- actualizarOpp
	* 						
	**
	* @Autor: Noemi Escudero del Olmo (06/11/2018)
	**
	* @Modificacion: 
	**
	*/
    // @isTest 
    // static void testCallout() 
    // {
    //     Test.startTest();
    //     // Set mock callout class
    //     Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());  
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    //     insertaOppIdetificada();
    //     List<Opportunity> listaOportunidadesActualizadas = new List<Opportunity>();
	// 	//Conseguir Id de Admin
    //     Database.SaveResult[] saveResultsUpdate;        
    //     //SELECT Name FROM User WHERE ProfileId IN (SELECT Id FROM Profile WHERE Name='Administrador del sistema')

	// 	//Modificar a Solicitada antes de entrar a Preventa
	// 	List<Opportunity> oportunidadTest = [ SELECT (select Id, Validado_para_Preventa__c from Lineas_de_Proyecto__r), Id, StageName, Codigo_de_oportunidad__c  FROM Opportunity WHERE NAME = 'Opp101234' ];
	// 	system.debug('test--'+oportunidadTest);
		
    //     oportunidadTest[0].StageName = 'Solicitada';
	// 	oportunidadTest[0].amount = 2000;
	// 	update oportunidadTest;
    //     //OBJECTS-----------------------------------------------------------------------------------
	// 	System.debug(oportunidadTest);
    //     //TEST--------------------------------------------------------------------------------------
    //     //Modificar Opp
    //     oportunidadTest[0].StageName = 'Preventa';
    //     //No se puede updatear más de 1 a la vez porque sino no entra al método y se hace con Batch
    //     Test.stopTest();
    //     saveResultsUpdate = Database.Update(oportunidadTest, false);            

    //     //TEST---------------------------------------------------------------------------------------
    //     //ASSERTS------------------------------------------------------------------------------------
    //     for(Database.SaveResult dbsr : saveResultsUpdate)
    //     {
    //     	System.assert(dbsr.isSuccess(), 'Oportunidad mal actualizada: '+dbsr.getErrors());
    //     }
        
    //     //Conseguir las Oportunidades fuera del Test.startTest() para que de tiempo al @future
    //     listaOportunidadesActualizadas = [SELECT Name, StageName, URL_Sharepoint__c FROM Opportunity];
                
    //     //Update (excepted, actual, msg)
    //     System.assertNotEquals('', listaOportunidadesActualizadas[0].URL_Sharepoint__c, 'La URL de SharePoint debería estar rellena, no vacío.');
    //     System.assertNotEquals(null, listaOportunidadesActualizadas[0].URL_Sharepoint__c, 'La URL de SharePoint debería estar rellena, no null.');
    //     //PITT DESCOMENTAR System.assertEquals('https://grupovass.sharepoint.com/sites/salesforce/Documentos compartidos/Industria/AccTest1/'+System.now().year()+'-1/', listaOportunidadesActualizadas[0].URL_Sharepoint__c , 'La URL de SharePoint no se ha formado bien.');
        
	// 	//ASSERTS------------------------------------------------------------------------------------
        
    // }

    // @isTest
	// static void Test_serializeAndSendProjectLinesPreventa()
	// {
    //     // Set mock callout class
    //     Test.startTest();
    //     Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
    //     Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    //     insertaOppIdetificada();
    //     List<Opportunity> listaOportunidadesActualizadas = new List<Opportunity>();
    //     Database.SaveResult[] saveResultsUpdate;        
	// 	List<Opportunity> oportunidadTest = [ SELECT Id, StageName FROM Opportunity WHERE NAME = 'Opp101234' ];
	// 	system.debug(oportunidadTest);
	// 	oportunidadTest[0].StageName = 'Solicitada';
	// 	oportunidadTest[0].amount = 2000;
	// 	update oportunidadTest;        
    //     //Modificar Opp
    //     oportunidadTest[0].StageName = 'Preventa';
    //     //No se puede updatear más de 1 a la vez porque sino no entra al método y se hace con Batch
  
    //     Test.stopTest();
  	//     saveResultsUpdate = Database.Update(oportunidadTest, false);            
	// }
  
}