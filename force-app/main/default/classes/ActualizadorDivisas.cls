/**
* Clase encargada de efectuar el control de las divisas de la instancia de Salesforce en que es ejecutada
* @author adiaz
* @date 28/08/2018 
*/
public with sharing class ActualizadorDivisas 
{

    /**
* Método que efectúa tanto la carga como la actualización de las divisas en la instancia de Salesforce en que es ejecutada
* @author adiaz
* @date 28/08/2018 
*/
    @future(callout=true)
    public static void cargarDivisas() 
    {
                
        try 
        {
            Configuracion_actualizacion_divisas__mdt config = [SELECT MasterLabel, Clave_publica_cliente__c, Clave_secreta_cliente__c, 
                                                               	Usuario__c, Contrasena__c, DireccionURL__c, DireccionURLTokenAccess__c, Token_seguridad__c 
                                                           		FROM Configuracion_actualizacion_divisas__mdt LIMIT 1];
            
            
            // Se trae desde la URL externa el documento XML        
            Http httpXML = new Http();
            HttpRequest peticionXML = new HttpRequest();
            peticionXML.setEndpoint(config.DireccionURL__c);
            peticionXML.setMethod('GET');
            HttpResponse respuestaXML = httpXML.send(peticionXML);
           // system.debug('resouesto'+respuestaXML.getbody());
            // Se muestra el contenido del XML (opcional)        
          System.debug('response'+respuestaXML.getBody()); 
            
            // Se genera un lector para el XML        
            XmlStreamReader reader = respuestaXML.getXmlStreamReader();
            Dom.Document doc  = respuestaXML.getBodyDocument();
            Dom.XMLNode address = doc.getRootElement();

            // Obtenemos token de acceso
            HttpRequest reqTokenAccess = new HttpRequest();
            reqTokenAccess.setMethod('POST'); 
            reqTokenAccess.setHeader('Content-Type','application/x-www-form-urlencoded'); 
            reqTokenAccess.setEndpoint(config.DireccionURLTokenAccess__c); 
                        
            String CLIENT_ID = config.Clave_publica_cliente__c; 
            String CLIENT_SECRET = config.Clave_secreta_cliente__c; 
            String USERNAME = config.Usuario__c; 
            String PASSWORD = config.Contrasena__c; 
            //String TOKENSEGURIDAD = config.Token_seguridad__c;
            
            reqTokenAccess.setBody('grant_type=password' + '&client_id='+CLIENT_ID + '&client_secret='+CLIENT_SECRET + '&username='+USERNAME + '&password='+PASSWORD); 
            Http httpTokenAccess = new Http(); 
            HTTPResponse responseTokenAccess = httpTokenAccess.send(reqTokenAccess); 
            System.debug('Respuesta TokenAccess = ' + responseTokenAccess.getBody()); 
            System.debug('Status Token Access = ' + responseTokenAccess.getStatus()); 
            System.debug('Status code TokenAccess = ' + responseTokenAccess.getStatusCode());
            
            // En cada lista se guardará, por cada divisa, su IsoCode y su ConversionRate
            List<String> valoresIsoCode = new List<String>();
            List<Decimal> valoresConversionRate = new List<Decimal>();
            String fechaDivisaAplicada = '';
            

            for(Dom.XMLNode child : address.getChildElements()) {
               
                for(Dom.XMLNode child2 : child.getChildElements()){
                    
                    if (child2.getName() == 'pubDate') {
                       // system.debug('Fecha' + child2.getText());
                        fechaDivisaAplicada=child2.getText();
                    }

                    if(child2.getName() == 'targetCurrency' ){

                        if(Constants.DIVISAS_CRM.contains(string.valueof(child2.getText()))){
                            
                            
                            valoresIsoCode.add(child2.getText()); // 'USD', 'GBP', ...
                            for(Dom.XMLNode child3 : child.getChildElements()){
                                if(child3.getName() == 'exchangeRate' ){
                                   
                                    system.debug('Iso='+child2.getText() + '    Valor =' + child3.getText().replace(',', ''));

                                    valoresConversionRate.add(double.valueof(child3.getText().replace(',', '')));
                                
        
        
                            }

                            }
                            continue;
                        }


                    }

            
                    
                    
                }
            }

            system.debug('valoresIsoCode'+ valoresIsoCode);
            system.debug('valoresConversionRate'+valoresConversionRate);
            // Se lee todo el XML      
      /*      while(reader.hasNext()) 
            {
                // Si se está leyendo un tag de apertura de elemento
                if (reader.getEventType() == XmlTag.START_ELEMENT) 
                { 
                    system.debug('eventtype'  +reader.getAttributeCount() );
                    system.debug('feeecha'  +reader.getLocalName());
                    system.debug('feeecha'  +reader.getLocalName());
                    
                    // se verifica que es de tipo "Cube" y que tiene sólo un atributo (este elemento contiene un atributo para la fecha en que se están aplicando los cambios de divisa)
                    if (reader.getLocalName() == 'PubDate')
                    {   
                        if (reader.getEventType() == XmlTag.characters) {
                            system.debug('Numero' + reader.getText());
                        }
                        
                        fechaDivisaAplicada = reader.getAttributeValueAt(0);
                    }
                    // se verifica que es de tipo "Cube" y que tiene dos atributos (ya que estos elementos son los que tienen un atributo para el tipo de divisa y otro para el valor de la divisa)
                    else if (reader.getLocalName() == 'Cube' && reader.getAttributeCount() == 2) 
                    { 
                        system.debug('Codiiifo'  +reader.getAttributeValueAt(0) );
                        // Se introduce cada valor en la lista correspondiente
                        if(Constants.DIVISAS_CRM.contains(string.valueof(reader.getAttributeValueAt(0)))){
                            system.debug('codigoo'+reader.getAttributeValueAt(0));
                            valoresIsoCode.add(reader.getAttributeValueAt(0)); // 'USD', 'GBP', ...
                            valoresConversionRate.add(Decimal.valueOf(reader.getAttributeValueAt(1))); 
                        }
                        // el valor de cambio asociado a cada moneda
                    }
                }            
                reader.next();
            }
            */
            
            // Se prepara la peticion HTTP para cargar los tipos de divisa dentro del Salesforce de la organización 
            Http httpCargar = new Http();
            HttpRequest peticionCargar = new HttpRequest();
            
            String urlDestino = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v42.0/composite/tree/CurrencyType/';
            peticionCargar.setEndpoint(urlDestino);
            peticionCargar.setMethod('POST');            
            
            // Como hay que cargar muchos objetos iguales, se va a generar un JSON con los datos de las listas anteriores
            
            String cuerpoPeticion = '{ "records" : [ { "attributes" : { "type" : "CurrencyType", "referenceId" : "ref0" }, "IsoCode" : "' + valoresIsoCode.get(0) + '", "ConversionRate" : ' + valoresConversionRate.get(0) + ', "DecimalPlaces" : 2, "IsActive" : "true" }';
            
            String referencias = 'ref'; // cada elemento debe tener un id de referencia
            for (Integer cursor = 1; cursor < valoresIsoCode.size(); cursor++) 
            {
                cuerpoPeticion += ', { "attributes" : { "type" : "CurrencyType", "referenceId" : "'+referencias+cursor+'" }, "IsoCode" : "' + valoresIsoCode.get(cursor) + '", "ConversionRate" : ' + valoresConversionRate.get(cursor) + ', "DecimalPlaces" : 2, "IsActive" : "true" }';
            }
            
            cuerpoPeticion += '] }';
            
            // Se muestra todo el JSON resultante (útil para copiarlo y pegarlo en un validador de JSON, para saber si está bien formado)
            System.debug('Peticion = ' + cuerpoPeticion);
            
            peticionCargar.setBody(cuerpoPeticion);  
            Map<String,Object> respuestaJSON = (Map<String,Object>) JSON.deserializeUntyped(responseTokenAccess.getBody());
            peticionCargar.setHeader('Authorization', 'Bearer ' + respuestaJSON.get('access_token'));
            peticionCargar.setHeader('Content-Type', 'application/json');
            
            // Se obtiene la respuesta resultante de mandar la petición
            HttpResponse respuestaPeticionCargar = httpCargar.send(peticionCargar);
            
            // Se verifica si todo ha funcionado bien o no
            System.debug('Respuesta CurrencyType -> ' + respuestaPeticionCargar);
            System.debug(respuestaPeticionCargar.getStatus());
            System.debug(respuestaPeticionCargar.getStatusCode());
            System.debug(respuestaPeticionCargar.getBody());
            
            // Ahora se procede a actualizar el metadato DatedConversionRate, que guarda el histórico de valores de cambio decada divisa
            Http httpCargarDCR = new Http();
            HttpRequest peticionCargarDCR = new HttpRequest();      
            
			// Obtenemos la fecha actual (usado para falsear fechas con el fin de hacer pruebas)           
            /*Date fecha = System.today();
            Integer anno = fecha.year();
            Integer mes = fecha.month();
            Integer dia = fecha.day();            
            System.debug('FECHA = ' + String.valueOf(Date.newInstance(anno,mes,dia)));*/
            
            // Para cada tipo de divisa almacenada en las listas anteriormente creadas
            for (Integer contador = 0; contador < valoresIsoCode.size(); contador++) 
            {
                String urlDestinoDCR = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v42.0/sobjects/DatedConversionRate/'; 
            	peticionCargarDCR.setEndpoint(urlDestinoDCR);
                
                String cuerpoPeticionDCR = '{ "IsoCode" : "' + valoresIsoCode.get(contador) + 
                    						'", "ConversionRate" : ' + valoresConversionRate.get(contador) +
                    						', "StartDate" : "' + fechaDivisaAplicada + '" }';
                
                peticionCargarDCR.setBody(cuerpoPeticionDCR);
                peticionCargarDCR.setHeader('Authorization', 'Bearer ' + respuestaJSON.get('access_token'));
            	peticionCargarDCR.setHeader('Content-Type', 'application/json'); 
                peticionCargarDCR.setMethod('POST');
                
                // Obtenemos la respuesta resultante de mandar la petición
                HttpResponse respuestaPeticionCargarDCR = httpCargarDCR.send(peticionCargarDCR); 
                
                // Verificamos si todo ha funcionado bien o no
                System.debug('Para la divisa ' + valoresIsoCode.get(contador) + ' con valor de cambio ' + valoresConversionRate.get(contador));
                System.debug('Respuesta DatedConversionRate -> ' + respuestaPeticionCargarDCR);
                System.debug(respuestaPeticionCargarDCR.getStatus());
                System.debug(respuestaPeticionCargarDCR.getStatusCode());
                System.debug(respuestaPeticionCargarDCR.getBody());
            }
        }
        catch (Exception e) 
        {
            System.debug('Mensaje de error -> ' + e.getMessage());
            System.debug('Lugar del error -> ' + e.getStackTraceString());
            System.debug('Tipo de error -> ' + e.getTypeName());
        }
        
    }
}