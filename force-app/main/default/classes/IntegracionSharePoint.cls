/** 
    * @description: Clase genérica para comunicarse a través de un API REST con SharePoint.
    *               Está formada por métodos útiles:
    *               - autenticarSharePoint
    *               - limpiezaPaths
    *               - formarURLBodyCrearCarpeta
    *               - hacerRequest
    *               - enviarEmailError
    **
    * @Autor: Noemi Escudero del Olmo (29/10/2018)
    **
    * @Modificacion: 
    **
    */
public with sharing class IntegracionSharePoint {
	
	  //static final String rtFa = 'rtFa=RqGpGQHW9O6ggf3SnnWkk7A5aeAfzQQOPIx+Iu5vfi8mQjcxNkMxMUYtMTZBMy00RDE1LThEQkMtRjExRjdGREVGRTVBKtnhsGq1GTiI84qgvbZK384Lv7yo5+PKksavobCFth9k4QkYoynP2MlUNWyAkfCGV6Hc9nrhpo7dkwZDA8AdYAbKCIFSTyC1jKLshAar9BgNf3kMBFOWNhk3wkoqdktUMnUnnurznnUvJoup8FCAs4dAoGj29LVUxtMi89AjpxfFGYFqV6ZBQYKBOzOzthiWUXNggZ56lMFOyMEXBeOxrKaJeWKvvNXO0DfKC013VIoFQpI+KIcBBQS9SxXgp1Ou2JtvE/3IG4Zh1QjvEORRs0tyKI2WG1aMt6NY9T7MR1l/LKvsVoPSlsUwCiF7L86eSyXcnwBjs8zEWOQ+Af7VmEUAAAA=';
	  //static final String FedAuth = 'FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjQsMGguZnxtZW1iZXJzaGlwfDEwMDNiZmZkYWRiMGE0YjBAbGl2ZS5jb20sMCMuZnxtZW1iZXJzaGlwfGNybXNhbGVzZm9yY2VAdmFzcy5lcywxMzE4NDEwNTc1NzAwMDAwMDAsMTMxODA1MzE2NzUwMDAwMDAwLDEzMTg1Mjc2NjgzNzkyMDkxNCwwLjAuMC4wLDMsYjcxNmMxMWYtMTZhMy00ZDE1LThkYmMtZjExZjdmZGVmZTVhLCxWMiExMDAzQkZGREFEQjBBNEIwITEzMTg0MTA1NzU3LDk4ZjI5ODllLTAwY2YtNzAwMC1jZmE4LTBmNzlhZTliNWQyMiwyNDc3OWI5ZS0zMDk3LTcwMDAtNGE5MC03MTI3ZWNiYTU5MDIsLDAsMTMxODQ4NDgyODM3NzY0NjU1LDEzMTg1MTAzODgzNzc2NDY1NSxUR1lhOXhQZytuVXZsTU1yL3drc2czR1UzeTlxSU5XN2Voc2kyTXJ1cnJuVW4zK241WTBtRzJIRkt1eTR2blRKVjdPU0xLTHMxYWt0N2tYTEhKVWRoNGRQcVlCSjg4NlNjdTh0SXZOL0ZDalhmWnlPR3JBRlk0c2pTanQrMCtTSVhzbkpDQUZlVndYaTZCYnR3dFVhaWpWbHZSaFZGeEIxTEw4MnhiS1R5a0xxcFY0OExadEFCUFpIZTRoa0t6aWNUcVg1Q1dZeTcxQlNNaXNBT2I1Nm0wNWRSZXpUeVM5QTl6WGNGY1VEZGtoTnEyNFNhbFRva2VPMEJmY0xFRmc4elJXcnBpcGV1aDc2cDlPb1R2YTYwMkNVLzhDTEhPUmx4TUthRkd2am1Cd0JvM242S08zS3JZb294VE1pNVcvT09JbGRZVWxscm13VGlFbmNOVHNlenc9PTwvU1A+; path=/; domain=.grupovass.sharepoint.com; Secure; HttpOnly';
	  //static final Boolean debug = true; //Modo debug ACTIVADO!
	  //static final String rtFa = 'rtFa=RqGpGQHW9O6ggf3SnnWkk7A5aeAfzQQOPIx+Iu5vfi8mQjcxNkMxMUYtMTZBMy00RDE1LThEQkMtRjExRjdGREVGRTVBKtnhsGq1GTiI84qgvbZK384Lv7yo5+PKksavobCFth9k4QkYoynP2MlUNWyAkfCGV6Hc9nrhpo7dkwZDA8AdYAbKCIFSTyC1jKLshAar9BgNf3kMBFOWNhk3wkoqdktUMnUnnurznnUvJoup8FCAs4dAoGj29LVUxtMi89AjpxfFGYFqV6ZBQYKBOzOzthiWUXNggZ56lMFOyMEXBeOxrKaJeWKvvNXO0DfKC013VIoFQpI+KIcBBQS9SxXgp1Ou2JtvE/3IG4Zh1QjvEORRs0tyKI2WG1aMt6NY9T7MR1l/LKvsVoPSlsUwCiF7L86eSyXcnwBjs8zEWOQ+Af7VmEUAAAA=';//; domain=sharepoint.com; expires=Sat, 03-Nov-2018 09:01:38 GMT; path=/; secure; HttpOnly
	  //static final String FedAuth = 'FedAuth=77u/PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz48U1A+VjUsMGguZnxtZW1iZXJzaGlwfDEwMDNiZmZkYWRiMGE0YjBAbGl2ZS5jb20sMCMuZnxtZW1iZXJzaGlwfGNybXNhbGVzZm9yY2VAdmFzcy5lcywxMzE4NDEwNTc1NzAwMDAwMDAsMTMxODA1MzE2NzUwMDAwMDAwLDEzMTg2NDAzNzA0NzE4NDI4NywwLjAuMC4wLDMsYjcxNmMxMWYtMTZhMy00ZDE1LThkYmMtZjExZjdmZGVmZTVhLCxWMiExMDAzQkZGREFEQjBBNEIwITEzMTg0MTA1NzU3LGY0YTk5ZjllLTUwMjYtNzAwMC00ZDBlLTkxNzgwZDdmZTExZixmNGE5OWY5ZS01MDI2LTcwMDAtNGQwZS05MTc4MGQ3ZmUxMWYsLDAsMTMxODU5NzUzMDQ1NjIxNTIxLDEzMTg2MjMwOTA0NTYyMTUyMSwsc2QzMDZURDc5ak5WWkdzVU5sbHVMYTNMV3BTWXltUG10bU9aejZvcy9jd0xvT05uQzRVRkV0SXkybVJMZVVvTFNKR2lPRkpKNXVhTWNtRy9abGtPY1JMY0dXdzFaVFh0aVZsOERiQ016Mmc0M0hqUTIyNEVlaS9JeldBVkxYQ29IcnRVenJobFUzK2o1cnQ5QTFYd2x6SklCRDYxUVcyTnN5RWxmUnBhWm9DVjN0aW9UazR5QUtROFZUc1ZiZ2pNcEZCUlNYOGp0Nm1CblhhOHlqdGFEQXJmTFQwV2ROQnJSM2E5bmhTVHFSV3Irdm83a2tRbU40SUpBUU1RM1lldSszQ3puT0NUalcyQ3BqRnJHbm9mZEpRYTB6Z1V3SXQzSEZsSzFuWXM3RUY1NFVHU3VWRy94MTM1VmhXelkxN3NEY1RuUDJWeVlsSisyRFRCRUNrQ2NnPT08L1NQPg==; path=/; domain=.grupovass.sharepoint.com; Secure; HttpOnly'; //expires=Sat, 03-Nov-2018 09:01:38 GMT; 
	  //static final String requestdigest = '0x6505A5536BC485B14584D1E5ABFD3C07F10B7734D579AFE0D7A0C88D435FDB21C52684FED8D49E41091CE3AF62796847EB81E43DB145D2C159AA626159E96568,07 Nov 2018 13:10:57 -0000';
 
	public static String urlEncode(Map<String, String> vals) 
	{
		String result = '';
		for(String thisKey : vals.keySet()) 
		{
			result += EncodingUtil.urlEncode(thisKey, 'UTF-8') + '=' + EncodingUtil.urlEncode(vals.get(thisKey), 'UTF-8') + '&';
		}
		return result.removeEnd('&');    
	}

	public static String formarURLBodyAutenticar(String client_id, String client_secret, String grant_type, String resource)
	{
		String urlencoded = '';
		  
		Map<String,String> bodyMap = new Map<String,String>();
		bodyMap.put('client_id',client_id);
		bodyMap.put('client_secret',client_secret);
		bodyMap.put('grant_type',grant_type);
		bodyMap.put('resource',resource);

		urlencoded = urlEncode(bodyMap);

		return urlencoded;
	}


	  /** 
	  * @description: Se necesita un clientId y un clientSecret y se recoge un Token
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018) 
	  **
	  * @Modificacion: 
	  **
	  * @Parametro:    
	  **
	  */
	  public static String autenticarSharePoint(String method, String urlencoded, String request_OAuth)
	  {
		   HttpRequest req = new HttpRequest();
		   HttpResponse res = new HttpResponse();
		   Http http = new Http();
		   String accessToken = '';
		   		   
		   //METHOD
		   req.setMethod(method);//POST	

		   //ENDPOINT
		   req.setEndpoint(request_OAuth);	 //Cambiar esto a integración Vass y enviarlo por param
		  
		   //HEADERS
		   req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		   req.setHeader('Content-Length', String.valueOf(urlencoded.length()));//Tamaño del body
		   
		   //BODY
		   req.setBody(urlencoded);
		   
		   try 
		   {
			    System.debug('OAUTH REQUEST: '+req);
			    
			    //SEND
			    res = http.send(req);
			    			    
			    if (res != null) 
			    {
					System.debug('OAUTH RESPONSE: '+res.toString());
					System.debug('OAUTH STATUS:'+res.getStatus()); //Created es chachi
					System.debug('OAUTH STATUS_CODE:'+res.getStatusCode()); //201 es chachi
					System.debug('OAUTH BODY: '+res.getBody());
					//System.debug('BODY DESERIALIZE: '+(((Map<Object, Object>)JSON.deserializeUntyped(res.getBody()))));  

					//DEBUG HEADERS
					string[] headerkeys = res.getHeaderKeys();
					Map<string, string> headers = new map<string, string>();
					for(string s : headerkeys)
					{
					   headers.put(s,res.getHeader(s));
					   system.debug('OAUTH HEADER: ' + s + ' VALUE: ' + res.getHeader(s));
					}
			    }	

			    //RESPONSE
				JSONParser parser = JSON.createParser(res.getBody());
				while (parser.nextToken() != null) 
				{
					if (parser.getText() == 'access_token') 
					{
						// Get the value.
						parser.nextToken();
						// Compute the grand total price for all invoices.
                		accessToken = parser.getText();
            		}
        		}
			    return accessToken;

		   } 
		   catch(Exception ex)  //System.CalloutException
		   {
				System.debug('OAUTH ERROR: '+ ex);
				if (res != null)
				{
					if (res.getStatus()!='OK') system.debug('Exception ERROR OAUTH RESPONSE: '+res.toString());
					if (res.getStatus()=='OK') system.debug('Exception OK OAUTH RESPONSE: '+res.toString()); 
				} 	
		 		throw ex;
		   }
	  }
	  
	  /** 
	  * @description: SharePoint no permite la creación de carpetas que contengan " * : > < ? / \ |
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - paths: 	lista con todas las Strings a limpiar de caracteres extraños
	  **
	  * @return: la misma lista pero limpia
	  **
	  */
	  public static List<String> limpiezaPaths(List<String> paths)
	  {
		  List<String> pathsMal = new List<String> {'-1'}; 
		  String carpetaLimpia;
		  
		  if (paths == null || paths.isEmpty()) return pathsMal; 

		  for (Integer i = 0 ; i<paths.size(); i++)
		  {
			  paths[i] = paths[i].replace('"', '_').replace('*', '_').replace(':', '_').replace('>', '_').replace('<', '_').replace('?', '_').replace('\\', '_').replace('|', '_');
		  }
		  
		  System.debug('FOLDERS: '+paths);
		  return paths;
	  }

	  /** 
	  * @description: Construcción del Body de la Request para crear una Carpeta usando el API REST de SharePoint
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - urlRelativa: 	ejemplo '/teams/PruebasCRMSalesforce/myDocs/'
	  * 			- nombreCarpeta
	  **	
	  * @return: el Body de la Request en formato JSON
	  **
	  */
	  public static String formarURLBodyCrearCarpeta(String urlRelativa, String nombreCarpeta)
	  {
		  String jsonBody = '-1';
		  
		  if (urlRelativa == null || nombreCarpeta == null) return jsonBody; 

		  jsonBody = '{ "__metadata": { "type": "SP.Folder" }, "ServerRelativeUrl":"'+ urlRelativa + nombreCarpeta +'"}';
		  
		  return jsonBody;
	  }
	  
	  /** 
	  * @description: Gestiona la Request contra el API REST de SharePoint
	  * 			  - Method
	  * 			  - Endpoint
	  * 			  - Headers
	  * 				- x-requestdigest	el churro que se consigue en la autenticacion
	  * 				- content-type		application/json;odata=verbose
	  * 				- accept: 			application/json
	  * 				- content-length: 	body.length()
	  * 			  - Body
	  * 			  - Send
	  * 			  - Response
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - method:		Puede ser POST, GET....
	  * 			- jsonBody:		El json formado en 	formarURLBody<InserteAquiFunctionEndPoint>
	  * 			- endpointSP:	la url del endpoint
	  **
	  * @return: - la Response que ha generado el Http.send()
	  * 		 - throw Exception de la Request si hubiera
	  **
	  */
	  public static HttpResponse hacerRequest(String method, String jsonBody, String endpointSP, String accessToken)
	  {
		   HttpRequest req = new HttpRequest();
		   HttpResponse res = new HttpResponse();
		   Http http = new Http();
		   
		   //METHOD
		   req.setMethod(method);
		   
		   //ENDPOINT
		   req.setEndpoint(endpointSP); //req.setEndpoint('https://grupovass.sharepoint.com/teams/PruebasCRMSalesforce/_api/web/folders/AddUsingPath(DecodedUrl=@a1,overwrite=@a2)?@a1=%27%2Fteams%2FPruebasCRMSalesforce%2FmyDocs%2Ftest33%27&@a2=false');

		   //HEADERS
		   //req.setHeader('Cookie', rtFa +';'+ FedAuth);
		   //req.setHeader('x-requestdigest', requestdigest);
		   req.setHeader('Authorization', 'Bearer ' + accessToken);
		   req.setHeader('Content-Type', 'application/json;odata=verbose');
		   req.setHeader('Accept', 'application/json');
		   req.setHeader('Content-Length', String.valueOf(jsonBody.length()));
		   
		   //BODY
		   req.setBody(jsonBody);
		   
		   try 
		   {
			    System.debug('REQUEST: '+req);
			    
			    //SEND
			    res = http.send(req);
			    			    
			    if (res != null) 
			    {
					System.debug('RESPONSE: '+res.toString());
					System.debug('STATUS:'+res.getStatus()); //Created es chachi
					System.debug('STATUS_CODE:'+res.getStatusCode()); //201 es chachi
					System.debug('BODY: '+res.getBody());
					//System.debug('BODY DESERIALIZE: '+(((Map<Object, Object>)JSON.deserializeUntyped(res.getBody()))));  

					//DEBUG HEADERS
					string[] headerkeys = res.getHeaderKeys();
					Map<string, string> headers = new map<string, string>();
					for(string s : headerkeys)
					{
					   headers.put(s,res.getHeader(s));
					   system.debug('HEADER: ' + s + ' VALUE: ' + res.getHeader(s));
					}
			    }
			    
			    //RESPONSE
			    return res;
			    
		   } 
		   catch(Exception ex)  //System.CalloutException
		   {
				System.debug('ERROR: '+ ex);
				if (res != null)
				{
					if (res.getStatus()!='OK') system.debug('Exception ERROR RESPONSE: '+res.toString());
					if (res.getStatus()=='OK') system.debug('Exception OK RESPONSE: '+res.toString()); 
				}
			   	throw ex;
		   }  
	  }
	  
	  /** 
	  * @description: método para enviarme un correo cuando algo falla
	  * 				Esto es para DEBUG... ¿Quitar de la versión final?
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - ex:			Exception.getMessage()
	  * 			- codigo:		response.getStatusCode()
	  * 			- pathCarpetas	
	  * 			- carpeta
	  **
	  */
	  /*public static void enviarEmailError(String ex, String codigo, List<String> pathCarpetas, String carpeta) 
	  {
		  Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		  message.toAddresses = new String[] { 'nescudero@nts-solutions.com' };
		  message.optOutPolicy = 'FILTER';
		  message.subject = '[VASS] Integracion Sharepoint Exception';
		  message.plainTextBody = 'Al intentar crear la carpeta:\n'+carpeta+'\nen el path:\n'+pathCarpetas+'\nha saltado la siguiente Exception:\n'+ex+'\ncon el código de error:\n'+codigo;
		  Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
		  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

		  if (results[0].success) 
		  {
		      if (debug) System.debug('EMAIL: El email se ha enviado a '+ message.getToAddresses() +'.');
		  } else 
		  {
			  if (debug) System.debug('EMAIL: El email ha fallado al enviarse: ' + results[0].errors[0].message);
		  }
	  }*/
  
}