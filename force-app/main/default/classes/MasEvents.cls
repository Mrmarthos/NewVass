/**versión v1
*@description: Gestor de pubicación de eventos de manera masiva mediante
               API de REST.
*@author name: rpolvera
*@date date: 22/10/2018
*@change name date description: Clase nueva.
*@see class/method:
**/
@RestResource(urlMapping='/v1/sobjects/events')
global with sharing class MasEvents {
    
    /**
    *@description: Recibe dentro del requestBody la estructura de datos y su
                   valor en formato JSON de todos los eventos que queremos
                   publicar.
                   El nombre del evento hace referencia al sObject que vamos
                   a sincronizar dentro de Salesforce. 
                   El Evento deberá incluir la clave OPERACION (operación DML)
                   junto con su valor: INSERT | UPSERT | UPDATE | DELETE.
    *@param name Description:
    *@author name: rpolvera
    *@date date: 22/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: Se ejecuta mediante una petición del tipo POST mediante
                         la API de REST de SalesForce.
    *@see class/method:
    **/    
    @HttpPost
    global static void publicaEventos()
    {   
	        //VARIABLES
	        List<sObject> eventos;
	        List<sObject> descartar = new List<sObject>();
	        List<sObject> procesar = new List<sObject>();
            List<Map<String,Object>> listaErroneos = new List<Map<String,Object>>();
            Map<String,Object> infoObjectoFallido;
	        List<Database.SaveResult> results;
	
	        //se recupera la request y response 
	        RestRequest request = RestContext.request; 
	        RestResponse response = RestContext.response;
	        
        try
        { 	        
	        //se deserializan los eventos de la llamada en una lista de sObjects                
	        eventos = (List<sObject>)JSON.deserialize(
	                                      request.requestBody.toString(),
	                                      List<sObject>.class
	                                                 );
	        
	        //se filtran y se extren solo los eventos
	        for( sObject evento : eventos )
	        {	            
	            //el nombre del tipo de objeto termina en __e 
	            if (String.valueOf(evento.getSObjectType()).endsWith('__e'))
	            {
	                procesar.add(evento);
	            }
	            //no es un evento y se descarta
	            else
	            {
	                descartar.add(evento);
	            }
	        }
	        
	        //se procede a publicar los eventos
	        results = EventBus.publish(procesar);
	        
	        //se registra la respuesta del SaveResult
			for (Integer i = 0; i < results.size(); i++)
			{
			    if (!results.get(i).isSuccess())
			    { 
			        //se inicializa un nuevo mapa de resultados
			        infoObjectoFallido = new Map<String,Object>();
                    //Se registran los errores
                    infoObjectoFallido.put('Event',procesar.get(i));
                    infoObjectoFallido.put('Error',String.valueOf(
                                                   results.get(i).getErrors()));
                    
                    listaErroneos.add(infoObjectoFallido);

			    }       
			}
			
			//se añaden los registros descartados
			for (sObject descartado : descartar)
	        {
                //se inicializa un nuevo mapa de resultados
                infoObjectoFallido = new Map<String,Object>();
                //Se registran los errores
                infoObjectoFallido.put('Event',descartado);
                infoObjectoFallido.put('Error','Tipo no soportado.');
	            listaErroneos.add(infoObjectoFallido);
	        }   
	
			//Si ha fallado alguno devuelve error
			if( listaErroneos.size() > 0 )
			{
	            response.addHeader('RESULTADO','KO');
	            response.responseBody = Blob.valueOf(JSON.serialize(listaErroneos));
	            response.statusCode = 500;   
			}
			else
			{
			    response.addHeader('RESULTADO','OK');
                response.statusCode = 201;  
			}
		}
		catch(Exception ex)
		{
            response.addHeader('RESULTADO','KO');
            response.statusCode = 400;  
            response.responseBody = Blob.valueOf(String.valueOf(ex.getMessage()));
        }
    }
}