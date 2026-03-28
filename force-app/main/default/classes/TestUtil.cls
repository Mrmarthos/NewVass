@isTest
public with sharing class TestUtil 
{
	/** 
	* @description: método genérico para crear cualquier sObject.
	* 				1º Se consigue la longitud de la lista de sObjects; será tan larga como el número más grande de posibles variaciones de campo
	* 				2º Se llama a un método que será el encargado de crear la lista de sObject dependiendo del tipo
	* 				3º Se realiza un bucle por cada sObject vacío
	* 						Un segundo bucle recorre los campos a rellenar
	* 							Si la lista de variaciones contiene una, se añadirá al sObject ese campo con esa variación
	* 							Si la lista de variaciones de ese campo no es tan extensa como la más larga, no se insertará el campo
	* 				Queda responsabilidad de la función de Test, que los campos requeridos sean rellenados, no se hacen comprobaciones
	* 				
	**
	* @Autor: Noemi Escudero del Olmo (14/06/2018)
	**
	* @Modificacion: 
	**
	* @Parametro: soType 	es el tipo del sObject que se va a generar la lista (se obtiene haciendo Account.sObjectType)
	* 			  camposMap es el Mapa con todos los campos del sObject que se van a rellenar, y 
	* 						una lista con las variaciones de cada campo	
	**
	* @return: List<sObject> Una lista que contiene los sObjects con sus campos ya rellenos
	**
	*/
    public static List<sObject> rellenarSObject(Schema.sObjectType soType, Map<String, List<Object>> camposMap)
    {
    	///////////////////////////////////////////////////
    	List<sObject> listaSObject 	= new List<sObject>();
    	Integer n 					= 0;
    	Integer i;
    	Set<String> campoSet 		= new Set<String>();
    	//////////////////////////////////////////////////
    	
    	//1º Conseguir el tamaño de la lista más larga.
    	//Por cada lista de valores de cada fields
    	for ( i = 0; i < camposMap.values().size(); i++)
    	{
    		//Si la lista de esa key es más grande, se pisa el valor
    		if(camposMap.values()[i].size() > n)
    		{
    			n = camposMap.values()[i].size();
    		}
    	}
    	
    	//2º Crear la lista del sObject con los sObject vacíos
    	listaSObject = crearSObject(n, soType);
    	
    	//3º Rellenar la lista con el mapa de campos
    	//Se consiguen todas las claves del mapa (Son los nombres de los fields del sObject)
    	campoSet = camposMap.keyset();
    	
    	//Por cada sObject, se va a rellenar cad
    	for(i = 0; i < n ; i++)
    	{
    		//Por cada campo distinto
    		for(String k: campoSet)
    		{	
    			//Si hay lista de valores suficiente para dicho campo
    			if(camposMap.get(k).size() > i) {
    				//Se inserta el valor concreto al campo concreto
    				listaSObject[i].put(k, camposMap.get(k)[i]);
    			}
    		}
    	}
    	
    	//Se devuelve la lista con todo ya creado y rellenado
    	return listaSObject;
    }
    
	/** 
	* @description: el objetivo es devolver una lista que contendrá un número determinado de sObjects
	* 				Por parámetro se consigue el tipo del sObject, el cual siempre se creará vacío
	**
	* @Autor: Noemi Escudero del Olmo (14/06/2018)
	**
	* @Modificacion: 
	**
	* @Parametro: n el número de sObjects que se van a crear vacíos
	* 			  soType es el tipo del sObject que se va a generar la lista (se obtiene haciendo Account.sObjectType)
	**
	* @return: List<sObject> Se devuelve la lista que contendrá N sObject vacíos
	**
	*/
    public static List<sObject> crearSObject(Integer n, Schema.sObjectType soType) //newInstance()
    {
    	///////////////////////////////////////////////////
    	List<sObject> listaSObject 	= new List<sObject>();
    	Integer i;
    	//////////////////////////////////////////////////
    	
    	//Se añadirán a una lista tantos sObject creados vacíos como indique N
    	for (i = 0; i < n; i++)
    	{
    		//Si coincide con el tipo del sObject 
    		if(soType == Account.sObjectType)
    		{
    			//Añadir a la lista el sObject creado vacío
    			listaSObject.add(new Account());
    		}
    		if(soType == Opportunity.sObjectType)
    		{
    			listaSObject.add(new Opportunity());
    		}
            if(soType == Linea_de_Proyecto__c.sObjectType)
            {
                listaSObject.add(new Linea_de_Proyecto__c());
            }   		    	
            if(soType == E_Linea_de_Proyecto__e.sObjectType)
            {
                listaSObject.add(new E_Linea_de_Proyecto__e());
            } 
            if(soType == Contact.sObjectType)
            {
                listaSObject.add(new Contact());
            } 
            if(soType == Hito_de_facturacion__c.sObjectType)
            {
                listaSObject.add(new Hito_de_facturacion__c());
            }
            if(soType == Licencia__c.sObjectType) 
            {
                listaSObject.add(new Licencia__c());               
            } 
            //...
    		//Crear tantos ifs como sObjects se quieren probar en los Tests
    		//...
    	}
    	
    	//Se devuelve la lista que contendrá N sObject vacíos
    	return listaSObject;
    }

	/**
    *@description: Genera datos válidos para las pruebas, creará tres cuentas dentro de Salesforce para
				   realizar los Test, las dos primeras del tipo cuentas externas y una tercera como cuenta interna. 
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Account> generaCuentasTest()
	{
		Map<String, List<Object>> camposMapAcc = new Map<String, List<Object>>
        {
            'Name' 							   => new List<String>{'AccTest1', 'AccTest2', 'VASS', 'AccTestFailSAP'},
            'Regiones__c'                      => new List<String>{'Madrid', 'Madrid', 'Madrid', 'Madrid'},
            'Sectores__c' 					   => new List<String>{'Industria-Industria', 'Industria-Industria', '', 'Industria-Industria'},
            'ID_SAP__c' 					   => new List<String>{'1','', '', 'FAIL'},
            'RecordTypeId' 					   => new List<String>{
											   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).RecordTypeId,
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId} 
        }; 
        
        List<Account> accs = TestUtil.rellenarSObject(Account.SObjectType, camposMapAcc);
        
        insert accs;
		return accs;
	}


    public static List<Account> generaSedeTest()
	{
		Map<String, List<Object>> camposMapAcc = new Map<String, List<Object>>
        {
            'Name' 							   => new List<String>{'test_batch' },
            'Regiones__c'                      => new List<String>{'Madrid'},
            'Sectores__c' 					   => new List<String>{'Banca-banca'},
            'ID_SAP__c' 					   => new List<String>{},
            'sede__c'                          => new List<String>{'1110'},
            'RecordTypeId' 					   => new List<String>{
											   Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).RecordTypeId} 
        }; 
        
        List<Account> accs = TestUtil.rellenarSObject(Account.SObjectType, camposMapAcc);
        
        insert accs;
		return accs;
	}


    

	/**
    *@description: Genera datos válidos para las pruebas, creará tres contactos dentro de Salesforce para
				   realizar los Test, los dos primeras del tipo ordinario y uno tercero como Jefe de proyecto. 
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Contact> generaContactosTest(List<Account> cuentasPadre)
	{
		List<Account> accs = cuentasPadre;
        Map<String, List<Object>> camposMapCont = new Map<String, List<Object>>
        {
            'LastName' 							=> new List<String>{'ContTest1', 'ContTest2', 'JEFEPROYECTO'},
			'Codigo_de_empleado__c'				=> new List<String>{'12312378', '12345698', '11144477'},                
			'Activo__c'         				=> new List<Boolean>{false, false, true},                
            'AccountId' 						=> new List<String>{accs[0].Id, accs[1].Id, accs[2].Id},
            'RecordTypeId' 						=> new List<String>{
                                                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId}

        }; 
         
        List<Contact> conts = TestUtil.rellenarSObject(Contact.SObjectType, camposMapCont);
        
        insert conts; 
		return conts;
	}

	/**
    *@description: Genera datos válidos para las pruebas, creará dos Oportunidades dentro de Salesforce para
				   realizar los Test, la primera tiene identificado ID_SAP (se encuentra en SAP como Proyecto)
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Opportunity> generaOportunidadesPreventaTest(List<Account> cuentaPadre, List<Contact> contactosRelacionados,List<Account> sede)
	{
		List<Account> accs = cuentaPadre;
		List<Contact> conts = contactosRelacionados;
      
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' 							   => new List<String>{'OppTest1Preventa','OppTest2Preventa'},
			'ID_SAP__c'						   => new List<String>{'idsapventa', ''},                
            'CloseDate'						   => new List<Date>{
											   date.newInstance(2018, 10, 10), 
											   date.newInstance(2018, 12, 12)},
            'RecordTypeId' 					   => new List<String>{
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId},
            'StageName' 					   => new List<String>{Constants.OPPORTUNITY_STAGE_IDENTIFIED, Constants.OPPORTUNITY_STAGE_IDENTIFIED},
            'Mercado__c' 					   => new List<String>{'Industria', 'Industria'},
			'Amount'						   => new List<Integer>{2000,3000},
            'AccountId' 					   => new List<String>{accs[0].Id, accs[1].Id},
            'Bid_Manager__c' 				   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Offering__c' 					   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()}, 
            'Contacto_del_cliente__c' 		   => new List<String>{conts[0].Id, conts[1].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c'    => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)},

            'Sede_Venta__c'                     =>new List<id>{accs[0].Id,accs[0].Id,accs[0].Id}
        };
        
        List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
       
        insert opps;

		Map<String, List<Object>> camposHitos = new Map<String, List<Object>>
        {
            'Oportunidad__c' 				   => new List<String>{opps[0].Id, opps[0].Id,opps[1].Id, opps[1].Id},
            'Porcentaje__c'					   => new List<Integer>{20, 80, 75, 25},
            'Fecha__c' 						   => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)}
        };

        List<Hito_de_facturacion__c> hitos = TestUtil.rellenarSObject(Hito_de_facturacion__c.SObjectType, camposHitos);
		insert hitos;
		return opps;
	}	


    public static List<Opportunity> generaOportunidadesPreventaTest(List<Account> cuentaPadre, List<Contact> contactosRelacionados)
	{
		List<Account> accs = cuentaPadre;
		List<Contact> conts = contactosRelacionados;
      
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' 							   => new List<String>{'OppTest1Preventa','OppTest2Preventa'},
			'ID_SAP__c'						   => new List<String>{'idsapventa', ''},                
            'CloseDate'						   => new List<Date>{
											   date.newInstance(2018, 10, 10), 
											   date.newInstance(2018, 12, 12)},
            'RecordTypeId' 					   => new List<String>{
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId},
            'StageName' 					   => new List<String>{Constants.OPPORTUNITY_STAGE_IDENTIFIED, Constants.OPPORTUNITY_STAGE_IDENTIFIED},
            'Mercado__c' 					   => new List<String>{'Industria', 'Industria'},
			'Amount'						   => new List<Integer>{2000,3000},
            'AccountId' 					   => new List<String>{accs[0].Id, accs[1].Id},
            'Bid_Manager__c' 				   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Offering__c' 					   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()}, 
            'Contacto_del_cliente__c' 		   => new List<String>{conts[0].Id, conts[1].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c'    => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)}

       
        };
        
        List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
       
        insert opps;

		Map<String, List<Object>> camposHitos = new Map<String, List<Object>>
        {
            'Oportunidad__c' 				   => new List<String>{opps[0].Id, opps[0].Id,opps[1].Id, opps[1].Id},
            'Porcentaje__c'					   => new List<Integer>{20, 80, 75, 25},
            'Fecha__c' 						   => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)}
        };

        List<Hito_de_facturacion__c> hitos = TestUtil.rellenarSObject(Hito_de_facturacion__c.SObjectType, camposHitos);
		insert hitos;
		return opps;
	}	

	/**
    *@description: Genera datos válidos para las pruebas, creará dos Oportunidades dentro de Salesforce para
				   realizar los Test, (nunca viajan a ejecución, no tendran ID_SAP__c)
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Opportunity> generaOportunidadesConceptualizacionTest(List<Account> cuentaPadre, List<Contact> contactosRelacionados)
	{
		List<Account> accs = cuentaPadre;
		List<Contact> conts = contactosRelacionados;
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' 							   => new List<String>{'OppTest1Conceptualizacion','OppTest2Conceptualizacion'},
            'CloseDate'						   => new List<Date>{
											   date.newInstance(2018, 12, 12), 
											   date.newInstance(2018, 12, 12)},
            'RecordTypeId' 					   => new List<String>{
											   Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_CONCEPTUALIZATION).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_CONCEPTUALIZATION).RecordTypeId},
            'StageName' 					   => new List<String>{'Identificada', 'Identificada'},
            'Mercado__c' 					   => new List<String>{'Industria', 'Industria'},
			'Amount'						   => new List<Integer>{2000,3000},
            'AccountId' 					   => new List<String>{accs[0].Id, accs[1].Id},
            'Bid_Manager__c' 				   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Offering__c' 					   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()}, 
            'Contacto_del_cliente__c' 		   => new List<String>{conts[0].Id, conts[1].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c'    => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)}
        };
        
        List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
       
        insert opps;
		return opps;
	}	

	/**
    *@description: Genera datos válidos para las pruebas, creará dos Oportunidades dentro de Salesforce para
				   realizar los Test, la primera tiene identificado ID_SAP (se encuentra en SAP como Proyecto)
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Opportunity> generaOportunidadesTMTest(List<Account> cuentaPadre, List<Contact> contactosRelacionados)
	{
		List<Account> accs = cuentaPadre;
		List<Contact> conts = contactosRelacionados;
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' 							   => new List<String>{'OppTest1TM','OppTest2TM'},
			'ID_SAP__c'						   => new List<String>{'idsapTM', ''},                
            'CloseDate'						   => new List<Date>{
											   date.newInstance(2018, 12, 12), 
											   date.newInstance(2018, 12, 12)},
            'RecordTypeId' 					   => new List<String>{
											   Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_TM).RecordTypeId},
            'StageName' 					   => new List<String>{'Identificada', 'Identificada'},
            'Mercado__c' 					   => new List<String>{'Industria', 'Industria'},
			'Amount'						   => new List<Integer>{2000,3000},
            'AccountId' 					   => new List<String>{accs[0].Id, accs[1].Id},
            'Bid_Manager__c' 				   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Offering__c' 					   => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()}, 
            'Contacto_del_cliente__c' 		   => new List<String>{conts[0].Id, conts[1].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c'    => new List<Date>{
											   date.newInstance(2018, 11, 11), 
											   date.newInstance(2018, 11, 11)}
        };
        
        List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
        
		insert opps;
		return opps;
	}

	/**
    *@description: Genera datos válidos para las pruebas, creará dos Linea_de_Proyecto__c dentro de Salesforce para
				   realizar los Test
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Linea_de_Proyecto__c> generaLineasLlaveManoTest(List<Opportunity> oportunidadPadre, List<Contact> contactoRelacionado)
	{
		List<Contact> conts = contactoRelacionado;
		List<Opportunity> opps = oportunidadPadre;
        Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
        {
            'Oportunidad__c' 				  => new List<String>{opps[0].Id, opps[1].Id},
            'Oficina_tecnica__c' 				  => new List<String>{'1000', '1000'},
            'Gerencia__c' 					  => new List<String>{'Tailor-Made Solutions', 'Tailor-Made Solutions'},
            'Responsable_de_LDP__c' 		  => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Area__c'						  => new List<String>{'ES00T03003', 'ES00T03003'},
            'Tecnologia__c'					  => new List<String>{'ADO', 'ADO'},
            'Coste_estimado__c'               => new List<Decimal>{100, 100}, 
             'precio_venta__c'               => new List<Decimal>{100, 100}, 
            'Margen_bruto__c'                 => new List<Decimal>{20, 20},           
            'Listo_para_sincronizar__c'		  => new List<Boolean>{true, true},
            'Linea_principal__c'		  	  => new List<Boolean>{false, true},
			'Fecha_Inicio__c'				  => new List<Date>{
											  date.newInstance(2019, 12, 00), 
											  date.newInstance(2019, 12, 00)},	
			'Fecha_Fin__c'					  => new List<Date>{
											  date.newInstance(2019, 12, 01), 
											  date.newInstance(2019, 12, 01)},	
            'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[2].Id, conts[2].Id}, 
            'Jefe_de_Proyecto_de_Ejecucion__c'=> new List<String>{conts[2].Id, conts[2].Id},
            'RecordTypeId' 					  => new List<String>{
											  Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId, 
                                              Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId}
        };
          
        List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP);
        
        insert lps;
        return lps;
	}

	/**
    *@description: Genera datos válidos para las pruebas, creará dos Linea_de_Proyecto__c dentro de Salesforce para
				   realizar los Test
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Linea_de_Proyecto__c> generaLineasAMTest(List<Opportunity> oportunidadPadre, List<Contact> contactoRelacionado, User u1)
	{
		List<Contact> conts = contactoRelacionado;
		List<Opportunity> opps = oportunidadPadre;
        Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
        {
            'Oportunidad__c' 				  => new List<String>{opps[0].Id, opps[1].Id},
            'Oficina_tecnica__c' 				  => new List<String>{'1000', '1000'},
            'Gerencia__c' 					  => new List<String>{'Digital Experience', 'Digital Experience'},
            'Responsable_de_LDP__c'			  => new List<String>{u1.Id, u1.Id},
            'Area__c'						  => new List<String>{'ES00T02003', 'ES00T02003'},
            'Tecnologia__c'					  => new List<String>{'ADO', 'ADO'},
			'Fecha_Fin__c'					  => new List<Date>{
											  date.newInstance(2020, 12, 11), 
											  date.newInstance(2020, 12, 11)},				
            'Listo_para_sincronizar__c'	 	  => new List<Boolean>{true, true},
            'Linea_principal__c'	 	  	  => new List<Boolean>{true, false},
            'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[2].Id, conts[2].Id},
            'Jefe_de_Proyecto_de_Ejecucion__c'=> new List<String>{conts[2].Id, conts[2].Id},
            'Oficina_tecnica__c'           =>new List<String>{'1000', '1100'},
            'Fecha_Inicio__c'                    => new List<Date>{
											  date.newInstance(2019, 12, 11), 
											  date.newInstance(2019, 11, 11)},

            'RecordTypeId'					  => new List<String>{
											  Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_AM).RecordTypeId, 
                                              Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_AM).RecordTypeId}
        };
          
        List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP);
        
        insert lps;
        return lps;
	}	

	/**
    *@description: Genera datos válidos para las pruebas, creará dos Linea_de_Proyecto__c dentro de Salesforce para
				   realizar los Test
    *@param name Description:
    *@author name: rpolvera
    *@date date: 28/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: 
    **/ 
	public static List<Linea_de_Proyecto__c> generaLineasLicenciasTest(List<Opportunity> oportunidadPadre, List<Contact> contactoRelacionado)
	{
		List<Contact> conts = contactoRelacionado;
		List<Opportunity> opps = oportunidadPadre;
        Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
        {
            'Oportunidad__c' 				  => new List<String>{opps[0].Id, opps[1].Id},
            'Oficina_tecnica__c' 				  => new List<String>{'1000','1000'},
            'Gerencia__c' 					  => new List<String>{'Digital Experience', 'Digital Experience'},
            'Responsable_de_LDP__c'			  => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Area__c'						  => new List<String>{'ES00T02002', 'ES00T02002'},
            'Tecnologia__c'					  => new List<String>{'ADO', 'ADO'},
			'Fecha_Fin__c'					  => new List<Date>{
											  date.newInstance(2019, 12, 11), 
											  date.newInstance(2019, 11, 11)},				
            'Listo_para_sincronizar__c'	 	  => new List<Boolean>{true, true},
            'Linea_principal__c'	 	  	  => new List<Boolean>{true, false},
            'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[2].Id, conts[2].Id},
            'Jefe_de_Proyecto_de_Ejecucion__c'=> new List<String>{conts[2].Id, conts[2].Id},
            'Fecha_Inicio__c'                    => new List<Date>{
											  date.newInstance(2019, 12, 11), 
											  date.newInstance(2019, 11, 11)},
    


            'RecordTypeId'					  => new List<String>{
											  Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_LICENSES).RecordTypeId, 
                                              Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_LICENSES).RecordTypeId}
        };        
        List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP); 
        insert lps;

        Map<String, List<Object>> camposLicencias = new Map<String, List<Object>>
        {
            'Linea_de_Proyecto__c' 		          => new List<String>{lps[0].Id, lps[0].Id, lps[1].Id, lps[1].Id},
			'Fecha_de_expiracion__c'			  => new List<Date>{
										          date.newInstance(2019, 11, 11),             
										          date.newInstance(2019, 12, 11),             
										          date.newInstance(2019, 12, 11),             
										          date.newInstance(2019, 12, 11)},     
            'Fecha_de_activacion__c'              =>    new List<Date>{
										          date.newInstance(2020, 11, 11),             
										          date.newInstance(2020, 12, 11),             
										          date.newInstance(2020, 12, 11),             
										          date.newInstance(2020, 12, 11)}    

        };
        List<Linea_de_Proyecto__c> licencias = TestUtil.rellenarSObject(Licencia__c.SObjectType, camposLicencias); 
        insert licencias;

        return lps;
	}	
}