public with sharing class SendOpportunityToSAP {

    /**
     * @author Adrián Bernardo
     * @descripcion asigna los valores al objeto auxiliar y ejecuta una función para enviar los valores.
     * @invocableMethod es llamado desde el flow Confirmar información Oportunidad
     * @param ids ids de las oportunidades que se pasan como parámetro desde el flow
     * @return List<Response> clase interna que simulará la respuesta del servicio SAP.
     * 
     */
    @InvocableMethod(label='Get Opportunity From SAP')
    public static List<Response> getOpporInfoFromSAP (List<String> ids) {
        List<Response> responses = new List<Response>();
        List<String> valoresFlow = ids[0].split(',');

        
        if(!valoresFlow.contains('envio')){
            Map<String,String> valores = SendOpportunityToSAP.obtenerOporDeSAP(ids);
                Response response = new Response();
                response.codigoClienteSAP = valores.get('kunnr');
                response.sociedad = valores.get('bukrs');
                response.areaDeVentas = valores.get('vkorg');
                response.mercado = valores.get('spart');
                response.direccion = valores.get('stras');
                response.ciudad = valores.get('ort01');
                response.codigoPostal = valores.get('pstlz');
                response.grupoDeClientes = valores.get('KDGRP'); // Account__r.SAP_Grupo_ID__c
                //response.grupoImputacionCliente = valores.get('ktgrd');
                response.viasDePago = valores.get('zwels');
                response.condicionDePagoSociedad =  valores.get('zterm');
                response.condicionDePagoCliente = valores.get('ztermvv');

                responses.add(response);
                
           
           
        }else if(valoresFlow.contains('envio')){
            system.debug('Se ha enviado.');
            system.debug('Valores FLow ---------------->'+valoresFlow);
            Response respuesta =  devolverRespuesta(valoresFlow);
            responses.add(respuesta);
            return sendOppToSAPFinal(responses);
        }
        return responses;
    } 


    /*@author Adrián Bernardo
    * @descripcion asigna los valores de la respuesta del servicio web a un mapa.
    * @param ids ids de las oportunidades que se pasan como parámetro desde el flow
    * @return Map<String,String> mapa que recoge la clave(etiqueta XML) y el valor(valor de etiqueta) del servicio SAP.
    */
    public static Map<String,String> obtenerOporDeSAP(List<String> ids){
        Http h2 = new Http();   
        List<Opportunity> opps = [SELECT id,
        ID_SAP__c,
        Account.Sede__c,
        sede_Venta__r.oficina_tecnica_SAP__c,
        Account.ID_SAP__c,
        Mercado__c 
        FROM Opportunity 
        WHERE id = :ids.get(0)];
        String mercado = CodMercado__c.getinstance(opps[0].Mercado__c).Codigo__c;    
        HttpRequest req1 = new HttpRequest();   
            req1.setHeader('Content-Type','application/xml');
            req1.setHeader('accept','application/xml');
            req1.setMethod('GET');
            req1.setEndpoint('callout:GetClientSAP/opu/odata/sap/ZWSSALESFORCE_SRV/data_customerSet(kunnr=\''
            +opps[0].Account.ID_SAP__c+'\',bukrs=\''+opps[0].Account.Sede__c+'\',vkorg=\''+opps[0].sede_Venta__r.oficina_tecnica_SAP__c+'\',spart=\''+mercado+'\')');
            
            HttpResponse res1 = h2.send(req1);
            Map<String,String> valoresRespuesta = new Map<String,String>();
            system.debug(res1.getStatusCode() == 200);
            if(res1.getStatusCode() == 200){
                Dom.Document doc = new Dom.Document();
                doc.load(res1.getBody());
                Dom.XMLNode address = doc.getRootElement();
                for(Dom.XMLNode addressChild : address.getChildElements()) {
                    if(addressChild.getName().equalsIgnoreCase('content')){
                        for(Dom.XMLNode content : addressChild.getChildElements()) {
                            if(content.getName().equalsIgnoreCase('properties')){
                                for(Dom.XMLNode properties : content.getChildElements()) {
                                    valoresRespuesta.put(properties.getName(), properties.getText());
                                }
                            }
                        }   
                    }
                }
            }
            return valoresRespuesta;
    }

    /**
     * @author Adrián Bernardo
     * @descripción clase auxiliar utilizada para contener los valores del flow y mandar valores al flow.
     */
    public class Response{
        
        @invocablevariable public String condicionDePagoSociedad;
        @invocablevariable public String condicionDePagoCliente;
        @invocablevariable public String viasDePago;
        @invocablevariable public String grupoImputacionCliente;
        @invocablevariable public String sociedad;
        @invocablevariable public String areaDeVentas;
        @invocablevariable public String mercado;
        @invocablevariable public String codigoClienteSAP;
        @invocablevariable public String grupoDeClientes;
        @invocablevariable public String codigoPostal;
        @invocablevariable public String direccion;
        @invocablevariable public String ciudad; //poblacion
        @invocablevariable public String numCalle;
        @invocablevariable public String areaDeVentasCodigo;
        @invocablevariable public String sociedadCodigo;
        @invocablevariable public String accountid;
        @invocablevariable public String opportunityId;
        @invocablevariable public String currencyIsoCode;
        @invocablevariable public String mensjaeError;
        @invocablevariable public Integer mostrarScreenError;

        }
        /*@author Adrián Bernardo
        * @descripcion asigna los valores a un mapa, siendo los pares la clave y los impares el valor.
        * @param valores contiene los valores que se obtienen a través del flow.
        * @return List<Response> clase interna utilizada para comunicarse con el flow.
        */
    public static Response devolverRespuesta(List<String> valores){
        Map<String,String> mapaValores = new Map<String,String>();
        system.debug(valores);
        String clave = '';
        String valor = '';
        for (Integer i = 0; i < valores.size(); i++) {
            if(math.mod(i, 2)==0){
                //Es par,será la clave para el mapa
                 clave = valores.get(i);
                 system.debug('Clave+------->'+valores.get(i));
            }else{
                //Es impar, será el valor para el mapa
                mapaValores.put(clave, valores.get(i));
                system.debug('Valor------->'+valores.get(i));
            }
        }
        Response respuesta = generarRespuestaMapa(mapaValores);
        return respuesta;
    }
    /*@author Adrián Bernardo
    * @descripcion genera una respuesta utilizando los valores del mapa pasado por parámetro.
    * @param valores mapa con los valores del flow para asignarlos al objeto auxiliar Response
    * @return Response objeto auxiliar con toods los valores del flow.
    */
    public static Response generarRespuestaMapa(Map<String,String> valores){
        Response respuesta = new Response();
        respuesta.areaDeVentas = valores.get('areaDeVentas');
        respuesta.ciudad = valores.get('poblacion');
        respuesta.codigoClienteSAP = valores.get('codigoClienteSAP');
        respuesta.codigoPostal = valores.get('codigoPostal');
        respuesta.condicionDePagoSociedad = valores.get('condicionDePagoSociedad');
        respuesta.direccion = valores.get('calle');
        //respuesta.grupoImputacionCliente = valores.get('grupoImputacionCliente');
        respuesta.mercado = valores.get('mercado');
        respuesta.sociedad = valores.get('sociedad');
        respuesta.opportunityId = valores.get('opportunityId');
        return respuesta;
    }
    
    

    /**
     * @author Adrián Bernardo
     * @descripcion envia la oportunidad con los datos modificados a SAP a través del servicio Web.
     * @param idOpp id de la oportunidad a mandar a través del WS.
     * @date 19-09-2022
     */
    @future(callout=true)
    public static void sendOppToSAPPreventa(id idOpp){
        Boolean haOcurridoError = false;
            //ESTO SE PUEDE HACER EN 1 QUERY CON LOS Account__r.CurrencyIsoCode,Account__r.NIF_CIF__c...
            List<Opportunity> opps = [SELECT id,OwnerID,
            Account.CurrencyIsoCode,mercado__c,
            Owner.EmployeeNumber,
            sede_Venta__r.Sede__c,
            sede_Venta__r.Oficina_tecnica_SAP__c,
            Account.NIF_CIF__c,
            Account.Name,
            Account.Razon_social__c,
            Account.Sede__c,
            Account.Sectores__c ,
            Account.SAP_Grupo_ID__c,
            Account.BillingCountryCode, 
            Account.ID_SAP__c,
            AccountId 
            FROM Opportunity 
            WHERE id = :idOpp ];

            List<Account> accs = 
            [SELECT id,
            ID_SAP__c 
            FROM Account 
            WHERE id =:opps[0].AccountId];
            system.debug('Opps---->'+opps); 
            List < CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element   > response = new List < CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element  > ();
            CrearClienteSAPEsquema.clientes request = new CrearClienteSAPEsquema.clientes();
            CrearClienteSAPEsquema.ZSFOR_CUSTOMER_PREVENTAS datosPreventa = new CrearClienteSAPEsquema.ZSFOR_CUSTOMER_PREVENTAS();
                 
            //datos preventa                                                                            //CAMPOS
            //datosPreventa.BUKRS = accs[0]. ;
            datosPreventa.LAND1 = opps[0].Account.BillingCountryCode == null ? '' : String.valueOf(opps[0].Account.BillingCountryCode);     //codigo ISO del pais
            datosPreventa.SORT1 = opps[0].Account.Name == null ? '' : String.valueOf(opps[0].Account.Name);                                 //concepto de búsqueda
            datosPreventa.STCD1 = opps[0].Account.NIF_CIF__c == null ? '' : String.valueOf(opps[0].Account.NIF_CIF__c);       
            datosPreventa.NAME1 = opps[0].Account.Razon_social__c == null ? '' : String.valueOf(opps[0].Account.Razon_social__c);                                                                     //sociedad ||| CAMPO EN SF??
            datosPreventa.KUNNR = opps[0].Account.ID_SAP__c == null ? '' : String.valueOf(opps[0].Account.ID_SAP__c); 
            datosPreventa.BUKRS = opps[0].sede_Venta__r.Oficina_tecnica_SAP__c == null ? '' : String.valueOf(opps[0].sede_Venta__r.Oficina_tecnica_SAP__c);                    //Codigo cliente de sap
            datosPreventa.VKORG = opps[0].sede_Venta__r.Sede__c == null ? '' : String.valueOf(opps[0].sede_Venta__r.Sede__c);                       //area de ventas
            datosPreventa.SPART = opps[0].mercado__c == null ? '' : CodMercado__c.getinstance(opps[0].mercado__c).Codigo__c;              //Mercado
            datosPreventa.KDGRP = opps[0].Account.SAP_Grupo_ID__c == null ? '' : String.valueOf(opps[0].Account.SAP_Grupo_ID__c);       //grupo de clientes
            datosPreventa.WAERS = opps[0].Account.CurrencyIsoCode == null ? '' : String.valueOf(opps[0].Account.CurrencyIsoCode);       //moneda
            datosPreventa.PARNR = opps[0].Owner.EmployeeNumber == null ? '' : String.valueOf(opps[0].Owner.EmployeeNumber);                 //id del comercial |||| CAMPO EN SF?
            
          
            response.add(request.ZSFOR_CREAR_CLIENTE(
                null,
                datosPreventa
            ));

            system.debug('Servicio creacion cuentas-->'+response);
            //Si da error, crear Log__c
            if(response[0].E_KUNNR == '' || response[0].E_KUNNR == null){
                Log__c nuevoLog = new Log__c();
                nuevoLog.Account__c = opps[0].AccountId;
                nuevoLog.CurrencyIsoCode = opps[0].Account.CurrencyIsoCode;
                nuevoLog.Error__c = 'Error en la oportunidad '+opps[0].id+': '+response[0].E_MENSAJE;
                nuevoLog.Propietario_de_PEP__c = UserInfo.getUserId();
                insert nuevoLog;
                
                
            }else{
                accs[0].ID_SAP__c = response[0].E_KUNNR;
                accs[0].Sincronizado_SAP__c = true;
                accs[0].GenerateFromWS__c=true;
                update accs;
            }
    }

    /**
     * @author Adrián Bernardo
     * @descripción Comprueba que la oportunidad haya cambiado a estado Preventa o haya sufrido una modificación a ciertos campos.
     * @param newList lista con la oportunidad modificada
     * @param oldMap mapa con la oportunidad a ser reemplazada
     * @return devuelve booleano para comprobar en el trigger si es necesario lanzar el método de preventa.
     */
    public static boolean comprobarCambios(List<Opportunity> newList,Map<Id,Opportunity> oldMap){
        //Falta por comprobar la sociedad.  
        Boolean enviaraSAP = false;
        List<Account> accs = [SELECT Razon_social__c,
        Name,
        NIF_CIF__c,
        ID_SAP__c,
        Sede__c,
        Sectores__c,
        SAP_Grupo_ID__c,
        CurrencyIsoCode,
        RecordType.DeveloperName,
        Validacion_NIF__c 
        FROM Account 
        WHERE id = :newList[0].AccountId];
        if(accs!=null && accs.size()!=0){
        if(accs[0].RecordType.DeveloperName=='Cuenta_externa' && newList[0].StageName == 'Solicitada' && oldMap.get(newList[0].id).StageName != 'Solicitada' && newList[0].ID_SAP__c==null && newList[0].Sede_de_Venta__c.contains('España')  ){
            enviaraSAP = true;
            system.debug('Ha cambiado a preventa.');
        }
        
        /*if(newList[0].StageName == 'Preventa'){
            if(accs[0].Razon_social__c != oldMap.get(newList[0].id).Account.Razon_social__c
            || newList[0].Account.Name != oldMap.get(newList[0].id).Account.Name
            ||newList[0].Account.NIF_CIF__c != oldMap.get(newList[0].id).Account.NIF_CIF__c
            ||newList[0].Account.ID_SAP__c != oldMap.get(newList[0].id).Account.ID_SAP__c
            ||newList[0].Account.Sede__c != oldMap.get(newList[0].id).Account.Sede__c
            ||newList[0].Account.Sectores__c != oldMap.get(newList[0].id).Account.Sectores__c
            ||newList[0].Account.SAP_Grupo_ID__c != oldMap.get(newList[0].id).Account.SAP_Grupo_ID__c
            ||newList[0].Account.CurrencyIsoCode != oldMap.get(newList[0].id).Account.CurrencyIsoCode
            ||newList[0].OwnerId != oldMap.get(newList[0].id).OwnerId){
                enviaraSAP = true;
                system.debug('Ha cambiado alguno de los datos que se mandan a SAP.');
            }
        }*/
        if(!accs[0].Validacion_NIF__c){
            enviaraSAP = false;
            system.debug('Validación mal.');
        }

        
        system.debug(enviaraSAP);
    }
        return enviaraSAP;
    }

    /**
     * @author Adrián Bernardo
     * @descripción hará la llamada al WS una vez la oportundiad esté ganada.
     * @param valores objeto auxiliar que contiene los datos a mostrar en el screen flow.
     */
    public static List<Response> sendOppToSAPFinal(List<Response> valores){
        system.debug(valores[0].opportunityId);
        List<Opportunity> opps = [SELECT ID,
        Cliente_Enviado_a_SAP__c,
        StageName 
        FROM Opportunity 
        WHERE id = :valores[0].opportunityId];
        List < CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element   > response = new List < CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element  > ();
        CrearClienteSAPEsquema.clientes request = new CrearClienteSAPEsquema.clientes();
        CrearClienteSAPEsquema.ZSFOR_CUSTOMER_FINAL datosFinal = new CrearClienteSAPEsquema.ZSFOR_CUSTOMER_FINAL();
        //datos final
        datosFinal.BUKRS = valores[0].sociedad == null ? '' : String.valueOf( valores[0].sociedad); //Sede__c
        datosFinal.VKORG = valores[0].areaDeVentas== null ? '' : String.valueOf( valores[0].areaDeVentas); // Account.oficina_tecnica_SAP__c
        datosFinal.SPART = valores[0].mercado ==null ? '' : String.valueOf( valores[0].mercado); // CodMercado__c.getinstance(Oportunidad.mercado__c).Codigo__c; 
        datosFinal.KUNNR = valores[0].codigoClienteSAP==null ? '' : String.valueOf( valores[0].codigoClienteSAP); //Account.ID_SAP__c
        datosFinal.DZTERM =valores[0].condicionDePagoSociedad ==null ? '' : String.valueOf( valores[0].condicionDePagoSociedad);
        //datosFinal.KTGRD =valores[0].grupoImputacionCliente ==null ? '' : String.valueOf( valores[0].grupoImputacionCliente); 
        datosFinal.ORT01 =valores[0].ciudad ==null ? '' : String.valueOf( valores[0].ciudad);
        datosFinal.STREET =valores[0].direccion ==null ? '' : String.valueOf( valores[0].direccion);
        datosFinal.PSTLZ =valores[0].codigoPostal ==null ? '' : String.valueOf( valores[0].codigoPostal);
        datosFinal.STREET_NO = '';
        datosFinal.KVERM = '';
         response.add(request.ZSFOR_CREAR_CLIENTE(
            datosFinal,
            null
        ));


        if(!response[0].E_MENSAJE.containsIgnoreCase('actualizados')){
            valores[0].mostrarScreenError=1;
            valores[0].mensjaeError= response[0].E_MENSAJE;
            Log__c nuevoLog = new Log__c();
            nuevoLog.Account__c = valores[0].accountId;
            nuevoLog.CurrencyIsoCode = valores[0].currencyIsoCode;
            nuevoLog.Error__c = 'Error en la oportunidad '+valores[0].opportunityId +': '+response[0].E_MENSAJE;
            nuevoLog.Propietario_de_PEP__c = UserInfo.getUserId();
            insert nuevoLog;
            
        }else{
            
            opps[0].Cliente_Enviado_a_SAP__c = true;
            update opps;
        }
        return valores;
       
    }

    
}