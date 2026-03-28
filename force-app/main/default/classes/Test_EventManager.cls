/**versión v1
*@description: Clase de test para EventManager.
*@author name: rpolvera
*@date date: 12/11/2018
*@change name date description: Clase nueva.
*@see class/method: EventManager
**/
@IsTest
public with sharing class Test_EventManager {
    
    /**
    *@description: Comprueba que se parsea correctamente un evento en un sObject
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/    
    @isTest
    static void test_parseaEventoCorrecto()
    { 
        EventManager em = new EventManager();
        List<E_Linea_de_Proyecto__e> eventosPlatadormaTrigger = new List<E_Linea_de_Proyecto__e>();
        Map<sObject,sObject> result = new Map<sObject,sObject>(); 
        
        //variables de entrada, se introduce un evento y se crea una linea vacía
        Map<sObject,sObject> resultEsperado = new Map<sObject,sObject>(); 
        E_Linea_de_Proyecto__e evento = new E_Linea_de_Proyecto__e
								            (
                                                eoperacion__c = 'UPDATE',
                                                id_std__c = '0061j00000238O',
                                                Codigo_SAP_Ejecucion__c = '1'
								            );
		
		Linea_de_Proyecto__c lineaProyecto = new Linea_de_Proyecto__c();	
        lineaProyecto.put('Id','0061j00000238O');                           
        lineaProyecto.put('Codigo_SAP_Ejecucion__c','1');                           
        resultEsperado.put(evento,lineaProyecto);
         
        eventosPlatadormaTrigger.add(evento);
        result = em.parseaEvento(eventosPlatadormaTrigger, Linea_de_Proyecto__c.getSObjectType());
        system.assertEquals(result,resultEsperado);
    }
    
        /**
    *@description: Comprueba que no parsea porque el tipo de Object a parsear 
                   y el evento no tienen los mismos campos definidos.
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/    
    @isTest
    static void test_parseaEventoError()
    {
        try
        { 
	        EventManager em = new EventManager();
	        List<E_Linea_de_Proyecto__e> eventosPlatadormaTrigger = new List<E_Linea_de_Proyecto__e>();
	        Map<sObject,sObject> result = new Map<sObject,sObject>(); 
	        
	        //variables de entrada, se introduce un evento y se crea una linea vacía
	        Map<sObject,sObject> resultEsperado = new Map<sObject,sObject>(); 
	        E_Linea_de_Proyecto__e evento = new E_Linea_de_Proyecto__e
	                                            (
	                                                eoperacion__c = 'UPDATE',
	                                                id_std__c = '0061j00000238O',
	                                                Codigo_SAP_Ejecucion__c = '1'
	                                            );
	        
	        eventosPlatadormaTrigger.add(evento);
	        result = em.parseaEvento(eventosPlatadormaTrigger, Account.getSObjectType());
        }
        catch(TypeException e)
        {
            system.assertEquals(e.getMessage().contains('Invalid'),true);
        }
    }
    
    /**
    *@description: Comprueba que se clasifica por operaciones
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/    
    @isTest
    static void test_clasificaEventoDMLCorrecto()
    { 
        EventManager em = new EventManager();
        //contiene el resultado del metodo
        Map<String,Map<sObject,sObject>> resultOp = new Map<String,Map<sObject,sObject>>();
        
        //variables de entrada, se introduce un mapa con evento = sObjecto clasificado por OP
        Map<sObject,sObject> resultEsperado = new Map<sObject,sObject>(); 
        //Contiene el resultado esperado por la ejecución del método
        Map<String,Map<sObject,sObject>> resultEsperadoOp = new Map<String,Map<sObject,sObject>>();
        
        E_Linea_de_Proyecto__e evento = new E_Linea_de_Proyecto__e
                                            (
                                                eoperacion__c = 'UPDATE',
                                                id_std__c = '0061j00000238O',
                                                Codigo_SAP_Ejecucion__c = '1'
                                            );
         E_Linea_de_Proyecto__e eventoError = new E_Linea_de_Proyecto__e
                                            (
                                                eoperacion__c = 'invali',
                                                id_std__c = '0061j00000238O',
                                                Codigo_SAP_Ejecucion__c = '2'
                                            );       
        Linea_de_Proyecto__c lineaProyecto = new Linea_de_Proyecto__c();    
        lineaProyecto.put('Id','0061j00000238O');                           
        lineaProyecto.put('Codigo_SAP_Ejecucion__c','2');                           
        resultEsperado.put(evento,lineaProyecto);      
        //este registro debe ser descartado       
        resultEsperado.put(eventoError,lineaProyecto);
        resultOp = em.clasificaEventoDML(resultEsperado);
        
        //se espera un mapa con clave UPDATE y como valor otro Mapa con clave
        //evento y valor como su sObject a procesar relacionado
        //se retira el registro que no debería ser devuelto, operación inválida
        resultEsperado.remove(eventoError);
        resultEsperadoOp.put('UPDATE',resultEsperado);
        
        system.assertEquals(resultOp, resultEsperadoOp);
    }
    /**
    *@description: Comprueba que se realiza correctamente el update
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/    
    @isTest
    static void test_doUpdateCorrecto()
    { 
        Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
        EventManager em = new EventManager();
        List<E_Linea_de_Proyecto__e> eventosRepublicar = new List<E_Linea_de_Proyecto__e>();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //variables de entrada, se introduce un evento y se crea una linea vacía
        Map<sObject,sObject> resultEsperado = new Map<sObject,sObject>();  
        
        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        //Inserta 2 Oportunidades preventa
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        
         
        //Se comprueba una actualización correcta        
        E_Linea_de_Proyecto__e evento = new E_Linea_de_Proyecto__e
                                            (
                                                eoperacion__c = 'UPDATE',
                                                Codigo_SAP_Ejecucion__c = '1',
                                                Oportunidad__c = opps[0].Id

                                            );
        
        Linea_de_Proyecto__c lineaProyecto = new Linea_de_Proyecto__c();    
        lineaProyecto.put('Codigo_SAP_Ejecucion__c','1');    
        lineaProyecto.put('Oportunidad__c', opps[0].Id);  
        lineaProyecto.put('Oficina_tecnica__c', '1000');  
        Test.startTest();  
        //Insertamos los datos de prueba.
        insert lineaProyecto;   
        Test.stopTest();
        
        //modificames estos datos para realizar el test
        evento.put('id_std__c', lineaProyecto.Id);
        lineaProyecto.put('id', lineaProyecto.Id);
        evento.put('Codigo_SAP_Ejecucion__c', '2');
        lineaProyecto.put('Codigo_SAP_Ejecucion__c', '2');
        //**EL RESULTADO ESPERADO ES EL CAMBIO DE   Codigo_SAP_Ejecucion__c a 2                          
        resultEsperado.put(evento,lineaProyecto);
        
        //Se comprueba unerror en la DML con evento sin soobrepasar el max de reintentos
         E_Linea_de_Proyecto__e evento2 = new E_Linea_de_Proyecto__e
                                            (
                                                eoperacion__c = 'UPDATE',
                                                Codigo_SAP_Ejecucion__c = '1',
                                                Oportunidad__c = opps[0].Id,
                                                id_std__c = '0061j00000238O',
                                                Reintento__c = 2
                                            );       
        Linea_de_Proyecto__c lineaProyecto2 = new Linea_de_Proyecto__c();    
        lineaProyecto2.put('Codigo_SAP_Ejecucion__c','1');    
        lineaProyecto2.put('Oportunidad__c', opps[0].Id);  
        lineaProyecto2.put('Id','0061j00000238O');
      
        resultEsperado.put(evento2,lineaProyecto2);
        
         //Se comprueba unerror en la DML con evento sin soobrepasar el max de reintentos
         E_Linea_de_Proyecto__e evento3 = new E_Linea_de_Proyecto__e
                                            (
                                                eoperacion__c = 'UPDATE',
                                                Codigo_SAP_Ejecucion__c = '3',
                                                Oportunidad__c = opps[0].Id,
                                                id_std__c = '0061j000002387',
                                                Reintento__c = 4
                                            );       
        Linea_de_Proyecto__c lineaProyecto3 = new Linea_de_Proyecto__c();    
        lineaProyecto3.put('Codigo_SAP_Ejecucion__c','3');    
        lineaProyecto3.put('Oportunidad__c', opps[0].Id);  
        lineaProyecto3.put('Id','0061j000002387');
        lineaProyecto3.put('Oficina_tecnica__c','1000');
        resultEsperado.put(evento3,lineaProyecto3);  
        System.debug('debug result '+resultEsperado);      
        eventosRepublicar = em.doUpdate(resultEsperado);
        Linea_de_Proyecto__c lpActualizada = [select id, Oportunidad__c, Codigo_SAP_Ejecucion__c, Oficina_tecnica__c
                                              from Linea_de_Proyecto__c where Id =:lineaProyecto.Id];
        system.assertEquals(lineaProyecto,lpActualizada);
        System.debug(lpActualizada);       
    } 
}