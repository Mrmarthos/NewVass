/** 
    * @description: Clase específica para el proyecto Vass que utiliza métodos para comunicarse a través de un API REST con SharePoint.
    *               Está formada por métodos útiles para Vass:
    *               - crearCarpeta
    *               - actualizarOpp
    **
    * @Autor: Noemi Escudero del Olmo (29/10/2018)
    **
    * @Modificacion: 
    **
    */
public with sharing class IntegracionSharePointVass {

	  //*******************************//
	  //Me falta pasar esto a metadatos//
	  //*******************************//
	  //static final String endpointSP = 'https://grupovass.sharepoint.com/teams/businessvalue/offering/Biblioteca de Ofertas/_api/web/folders';
	  
    	static final IntegracionSharePoint__mdt config = [SELECT audiencePrincipalId__c, client_id__c, client_secret__c, 
		grant_type__c, site_realm__c,endpointSP__C,	baseURL__c,base_url__c,urlSP__c  FROM IntegracionSharePoint__mdt LIMIT 1];
    
	/*  static final String endpointSP = 'https://grupodesvass.sharepoint.com/sites/Salesforce_UAT/_api/web/folders';
    	
	  static final String urlSP = 'https://grupodesvass.sharepoint.com';
	  //static final String baseURL = '/teams/PruebasCRMSalesforce/myDocs/'; //importante la / final
	  static final String baseURL = '/sites/salesforce_UAT/Documentos compartidos/'; //importante la / final
	  static final Boolean debug = true; //Modo debug ACTIVADO!	  
	  static final String site_realm = '542fba7d-522d-49a7-b659-b5b7100ad97b';
	  static final String client_id = '81ab8168-3169-4cc4-acc4-30c72fb5c34d@'+site_realm;
	  static final String client_secret = 'GQGl9UXSEGaNwnvxvsH88Esjo2yGnWZgC3wDc0sQdrg=';
	  static final String grant_type = 'client_credentials';
	  static final String audiencePrincipalId = '00000003-0000-0ff1-ce00-000000000000';
	  static final String base_url = 'grupodesvass.sharepoint.com';
	  static final String resource = audiencePrincipalId+'/'+base_url+'@'+site_realm; //usar {0}.format()	  
	  static final String request_OAuth = 'https://accounts.accesscontrol.windows.net/'+site_realm+'/tokens/OAuth/2';*/

	

		static final String endpointSP = config.endpointSP__C;	
		static final String urlSP = 	config.urlSP__c;
		//static final String baseURL = '/teams/PruebasCRMSalesforce/myDocs/'; //importante la / final
		static final String baseURL = config.baseURL__c; //importante la / final
		static final Boolean debug = true; //Modo debug ACTIVADO!	  
		static final String site_realm = config.site_realm__c;
		static final String client_id = config.client_id__c +'@'+site_realm;
		static final String client_secret = config.client_secret__c;
		static final String grant_type = config.grant_type__c;
		static final String audiencePrincipalId = config.audiencePrincipalId__c;
		static final String base_url = config.base_url__c;
		static final String resource = audiencePrincipalId+'/'+base_url+'@'+site_realm; //usar {0}.format()	  
		static final String request_OAuth = 'https://accounts.accesscontrol.windows.net/'+site_realm+'/tokens/OAuth/2'; 
	

	
	  /** 
	  * @description: método asíncrono que gestiona por completo la creación de todas las carpetas que requiera 1 trigger de Opp
	  * 				Llama a:
	  * 					- crearCarpeta()
	  * 			  Útil para que se llame desde un trigger
	  **
	  * @Autor: Noemi Escudero del Olmo (05/11/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - paths: 	lista de todos los paths de carpetas a crear
	  * 			- method:	en este caso siempre será POST
	  * 			- listIds:	lista de Ids de Opp que se corresponde cada uno a un path de carpetas a crear
	  **
	  */	  
	  @future (callout=true)
	  public static void crearCarpetaFuturo(List<String> paths, String method, List<ID> listIds)
	  {
		  crearCarpeta(paths, method, listIds);
	  }
	  
	  
	  /** 
	  * @description: método síncrono que gestiona por completo la creación de todas las carpetas que requiera 1 trigger de Opp
	  * 				Llama a:
	  * 					- IntegracionSharePoint.limpiezaPaths()
	  * 					- IntegracionSharePoint.formarURLBodyCrearCarpeta()
	  * 					- IntegracionSharePoint.hacerRequest()
	  * 					- IntegracionSharePoint.enviarEmailError()
	  * 					- actualizarOpp()
	  * 			 Útil para llamarse desde un Batch
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - paths: 	lista de todos los paths de carpetas a crear
	  * 			- method:	en este caso siempre será POST
	  * 			- listIds:	lista de Ids de Opp que se corresponde cada uno a un path de carpetas a crear
	  **
	  */	  
	  public static void crearCarpeta(List<String> paths, String method, List<ID> listIds)
	  {


		  String jsonBody;
		  String carpeta;
		  List<String> carpetas;
		  String baseURLextendida = baseURL;
		  HttpResponse response = new HttpResponse();
		  List<ID> selectIds = new List<ID>();
		  List<String> selectPaths = new List<String>();
		  String accessToken = '';
		  String urlencoded = '';

		  //REQUEST CONSEGUIR ACCESS TOKEN----------------------------------------------------
		  urlencoded = IntegracionSharePoint.formarURLBodyAutenticar(client_id, client_secret, grant_type, resource);
		  System.debug('[crearCarpeta] urlencoded:'+urlencoded);

		  accessToken = IntegracionSharePoint.autenticarSharePoint('POST', urlencoded, request_OAuth); //Poner un try catch
		  System.debug('[crearCarpeta] accessToken:'+accessToken);		  

		  //REQUEST CREAR CARPETA-----------------------------
		  //SharePoint no permite " * : > < ? / \ |
		  paths = IntegracionSharePoint.limpiezaPaths(paths);
		  
		  if (paths != null || !paths.isEmpty())
		  {
			  //Recorro el listado de paths por cada Opp
			  for (Integer i = 0; i < paths.size(); i++)
			  {
				  //Consigo el listado de carpetas a crear dentro de una misma Opp
				  carpetas = paths[i].split('/');
				  
				  //Recorro el listado de subcarpetas a crear (la baseUrl debe ir siendo cada vez mayor, ya que no he encontrado una función del api rest para hacer nested folders)
				  for (Integer j = 0; j < carpetas.size(); j++)
				  {
					  //Consigo la carpeta a crear
					  carpeta = carpetas[j];
					  
					  jsonBody = IntegracionSharePoint.formarURLBodyCrearCarpeta(baseURLextendida, carpeta);
					  
					  if (jsonBody != '-1') //Error por venir vacío? Dudo mucho que ocurra pero bueh
					  {
						  try
						  {
							  response = IntegracionSharePoint.hacerRequest(method, jsonBody, endpointSP, accessToken);
							  if(response == null)
							  {
								 break; //mmm seguramente si es null debería haber salido por el catch...
							  }
							  if (response.getStatusCode() != 201) //Ha fallado la creación
							  {
								  System.debug('['+i+']['+j+'] Al intentar crear la carpeta:\n'+carpeta+'\nen el path:\n'+carpetas+'\nha saltado la siguiente Exception:\n'+response.getBody()+'\ncon el código de error:\n'+String.valueOf(response.getStatusCode()));
								  //IntegracionSharePoint.enviarEmailError(response.getBody(), String.valueOf(response.getStatusCode()), carpetas, carpeta);
							      //LogUtil.addLog('IntegracionSharePointVass.crearCarpeta -- Código != 201', 'Al intentar crear la carpeta:\n'+carpeta+'\nen el path:\n'+carpetas+'\nha saltado la siguiente Exception:\n'+response.getBody()+'\ncon el código de error:\n'+String.valueOf(response.getStatusCode()));
								  //LogUtil.insertLog();
								  break;
							  }
							  if (response.getStatusCode() == 201) //Solo si sale bien, se actualiza el campo en la Opp
							  {
								  //Nótese el i
								  selectIds.add(listIds[i]);					//Añadir Id al listado
								  selectPaths.add(urlSP + baseURLextendida);	//Añadir path a otro listado (No se añade carpeta al final del path porque se quiere la url raíz)
							  }
							  
						  }
						  catch (Exception ex)
						  {
							  System.debug('['+i+']['+j+'] Al intentar crear la carpeta:\n'+carpeta+'\nen el path:\n'+carpetas+'\nha saltado la siguiente Exception:\n'+ex.getMessage()+'\ncon el código de error:\n-1');
							  //LogUtil.sendEmailError('IntegracionSharePointVass.crearCarpeta -- Exception', 'Al intentar crear la carpeta:\n'+carpeta+'\nen el path:\n'+carpetas+'\nha saltado la siguiente Exception:\n'+ex.getMessage()+'\ncon el código de error:\n-1');
							  //LogUtil.addLog('IntegracionSharePointVass.crearCarpeta -- Exception', 'Al intentar crear la carpeta:\n'+carpeta+'\nen el path:\n'+carpetas+'\nha saltado la siguiente Exception:\n'+ex.getMessage()+'\ncon el código de error:\n-1');
						      //LogUtil.insertLog();
							  //IntegracionSharePoint.enviarEmailError(ex.getMessage(),'-1', carpetas, carpeta);
							  break;							 						  	
                          }
					  }
					  
					  //Añado la carpeta al path para que las siguientes tengan el path actualizado
					  baseURLextendida = baseURLextendida + carpeta +'/';  
				  }
						  
				  //resetear
				  carpetas = null;
				  baseURLextendida = baseURL;
			  }
			 
			  //Hacer update de la Opp
			  actualizarOpp(selectIds,selectPaths);
			  LogUtil.insertLog();
		  
		  }
		  else
		  {
			  System.debug('Ha llegado vacío el listado de paths a crear'); 
		  }

	  }
	  
	  /** 
	  * @description: recoge una lista de Ids y de Paths correspondientes a cada Id
	  * 				Ambas listas son del mismo tamaño
	  * 				Se hace un Map para cerciorarse que NO haya varios Ids repetidos
	  * 				se hace Update de las Opps con su nueva URL (se quedará la última url "raíz" creada
	  **
	  * @Autor: Noemi Escudero del Olmo (29/10/2018)
	  **
	  * @Modificacion: 
	  **
	  * @Parametro: - listIds	
	  * 			- listPaths
	  **
	  */
	  public static void actualizarOpp(List<ID> listIds, List<String> listPaths)
	  {
		  List<Opportunity> listOpp = new List<Opportunity>();
		  Set<ID> setIds = new Set<ID>(listIds);  //Crear un Set para utilizarlo como Key del Map de Opps a updatear
		  Map<ID,String> mapPathUnico = new Map<ID,String>();
		  String path;		 
		  
		  //Por si acaso hay varios paths de 1 solo Id, nos quedamos con el último puesto
		  for(Integer i = 0 ; i<listPaths.size(); i++) //listPaths y listIds se presuponen mismo tamaño
		  {	
			  mapPathUnico.put(listIds[i],listPaths[i]);
		  }
		  
		  //Query recogiendo Opps que tengan el mismo ID que en el =:setIds y devolver en un Map<Id,Opportunity>
		  listOpp = [SELECT Id, URL_Sharepoint__c FROM Opportunity WHERE Id IN :setIds];
		  
		  if (listOpp.size()>0)
		  {
			  //for each , opp.URL_Sharepoint__c = Map.get(Opp.ID) (no hace falta limpiar el último /carpeta!!! porque se quiere la raiz porque se envía sin esto)
			  for(Opportunity opp: listOpp)
			  {
				  path = mapPathUnico.get(opp.Id);
				  opp.URL_Sharepoint__c = path;
			  }
			  System.debug('OPPS: '+listOpp);
			  update listOpp;	 
		  }
		  
	  }
	  

	  // run IntegracionSharePointVass.testMe(); from Execute Anonymous to test
	   public static void testMe() 
	   {
		 //La estructura de paths debe ser por ejemplo {'a1/b2','c3/c4'}
 	  	  List<String> paths = new List<String> {'a*1/a\\22','test?123/test<2/ajj'}; 
	 	  List<ID> listIds = new List<ID> {'0061j000002ZH0xAAG','0061j000002ZH0xAAG'};
		  crearCarpeta(paths , 'POST', listIds);
	   }
	  
}