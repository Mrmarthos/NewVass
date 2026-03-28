global class WebServiceMockGenerator implements WebServiceMock {
    public WebServiceMockGenerator() {}
    global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

		system.debug('RESQUESRT MOCCK' + request);
				
                //Como solo es para el test, lo unico necesario es el Id, asi que el campo que viene de SAP se queda en blanco
                if(request instanceof ClienteSAP.ZsforSincroCliente_element)//ACCOUNT
                {
                    //DESCOMENTAR PARA SINCRO CUENTAS
                    ClienteSAP.ZsforSincroCliente_element request_x = (ClienteSAP.ZsforSincroCliente_element)request;
                    ClienteSAP.ZsforSincroClienteResponse_element responseElement = new ClienteSAP.ZsforSincroClienteResponse_element();
                    if (request_x.IdSapC.equalsIgnoreCase('FAIL')) //Esta cuenta del test no debe enviarse
                    {
                        System.debug('entra cuentafail');
                        responseElement.MensajeNok = 'Test ERROR';
                        responseElement.MensajeOk = '';
                        responseElement.OIdSapC = request_x.IdSapC == '' ? '' : request_x.IdSapC;
                        responseElement.OIdSfor = request_x.IdSfor;
                        responseElement.Retorno = 'NOK';
                    }
                    else 
                    {
                        responseElement.MensajeNok = '';
                        responseElement.MensajeOk = 'Se creo TEST Account '+request_x.NameSearch;
                        responseElement.OIdSapC = request_x.IdSapC == '' ? String.valueOf( Datetime.now().format('HHmmss.SS') ) : request_x.IdSapC;
                        responseElement.OIdSfor = request_x.IdSfor;
                        responseElement.Retorno = 'OK';                       
                        System.debug('entra cuentaOIdSapC '+responseElement.OIdSapC);
                    }
                response.put('response_x', responseElement);
                }
                //PREVENTAS
                //
                
                
                else if (request instanceof PreventaSAP.ZSFOR_PEPS_PREVENTA_element)
                {
                    //DESCOMENTAR PARA SINCRO PREVENTAS
                    PreventaSAP.ZSFOR_PEPS_PREVENTA_element request_x = (PreventaSAP.ZSFOR_PEPS_PREVENTA_element)request;
                    PreventaSAP.ZSFOR_PEPS_PREVENTAResponse_element responseElement = new PreventaSAP.ZSFOR_PEPS_PREVENTAResponse_element();

                    responseElement.MENSAJE_NOK = '';
                    responseElement.MENSAJE_NOK = 'Se creo TEST PREVENTA '+request_x.I_NAME;
                    responseElement.O_CSAP_PREVENTA = request_x.I_CSAP_PREVENTA == '' ? String.valueOf( Datetime.now().format('HHmmss.SS') ) : request_x.I_CSAP_PREVENTA;
                    responseElement.O_ID_SFOR = request_x.I_ID_SFOR;
                    responseElement.Retorno = 'OK';                       
                    System.debug('entra PREVENTA '+responseElement.O_ID_SFOR);
                    response.put('response_x', responseElement);
                    
                }else if(request instanceof PepsEjecucionCall.ZSFOR_PROYECTOS){
                    
                    
                   
                    PepsEjecucionCall.ZSFOR_PROJECT_MAINTAIN_element request_x = ( PepsEjecucionCall.ZSFOR_PROJECT_MAINTAIN_element)request;
                    PepsEjecucionCall.ZSFOR_PROJECT_MAINTAINResponse_element responseElement = new   PepsEjecucionCall.ZSFOR_PROJECT_MAINTAINResponse_element();

                  
                    responseElement.E_RESULTADO = 'ok';
                    responseElement.E_OBJNR ='22222';
         
                    
                }
                //ActualizarJP
                else if (request instanceof SincroJPSAP.ZsforActualizaJp_element) 
                {
                    SincroJPSAP.ZsforActualizaJpResponse_element responseElement = new SincroJPSAP.ZsforActualizaJpResponse_element();
                    SincroJPSAP.ZsforTabJp listaJPsPresponse = new SincroJPSAP.ZsforTabJp();
                    SincroJPSAP.ZsforListaJp jpResponse1 = new SincroJPSAP.ZsforListaJp();

                        jpResponse1.Pernr = '00001';
                        jpResponse1.Vorna = 'Manu';
                        jpResponse1.Nachn = 'Sanz';
                        jpResponse1.Nach2 = 'G';
                        jpResponse1.Activo = 'X';
                        jpResponse1.Email = 'any@email.com';
                        jpResponse1.Telnr = '666999222';
                        jpResponse1.Kostl = 'ES00E00006';

                    SincroJPSAP.ZsforListaJp jpResponse2 = new SincroJPSAP.ZsforListaJp();

                        jpResponse2.Pernr = '00002';
                        jpResponse2.Vorna = 'Sergio';
                        jpResponse2.Nachn = 'Perez';
                        jpResponse2.Nach2 = 'A';
                        jpResponse2.Activo = 'a';
                        jpResponse2.Email = 'any2@email.com';
                        jpResponse2.Telnr = '666888222';
                        jpResponse2.Kostl = 'ES00E00006';

                    listaJPsPresponse.item = new SincroJPSAP.ZsforListaJp[2];    
                    listaJPsPresponse.item[0] = jpResponse1;
                    listaJPsPresponse.item[1] = jpResponse2;
                    responseElement.OtListaJp = listaJPsPresponse;

                    System.debug('entra ACTUALIZA JP '+responseElement);
                    response.put('response_x', responseElement);
                }
                //Validación NIF (SAPCheckNIFCalloutUtil)
                else if (request instanceof SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBER_element)
                {
                    SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBER_element request_x = (SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBER_element)request;
                    if(request_x.I_NIF.equalsIgnoreCase('FAIL')){
                        Map<String, SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element> response_map_x = new Map<String,SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element>();
                        SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element responseElement = new SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element();
                        
                        responseElement.E_CAMPO_VALIDO='STCD1';
                        responseElement.E_COMUNITARIO='1';
                        responseElement.E_ERROR='0';
                        responseElement.E_MENSAJE='Error NIf comunitario';
                        response.put('response_x', responseElement);


                    }else{
                        Map<String, SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element> response_map_x = new Map<String,SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element>();
                        SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element responseElement = new SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element();
                        
                        responseElement.E_CAMPO_VALIDO='STCD1';
                        responseElement.E_COMUNITARIO='1';
                        responseElement.E_ERROR='1';
                        responseElement.E_MENSAJE='NIF correcto';
                        response.put('response_x', responseElement);
                    }
                    
                } 
                //Crear clientes SAP (SendOpportunityToSAP)
                else if (request instanceof CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTE_element){
                    CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTE_element request_x = (CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTE_element)request;
                    if(request_x.I_DATOS_PREVENTAS != null){
                        if(request_x.I_DATOS_PREVENTAS.KUNNR.equalsIgnoreCase('FAIL')){
                            Map<String, CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element> response_map_x = new Map<String,CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element>();
                            CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element responseElement = new CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element();
                            
        
                            responseElement.E_KUNNR='';
                            responseElement.E_MENSAJE='Mensaje de error';
                            response.put('response_x', responseElement);
                        }else if(!request_x.I_DATOS_PREVENTAS.KUNNR.equalsIgnoreCase('FAIL')){
                            Map<String, CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element> response_map_x = new Map<String,CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element>();
                            CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element responseElement = new CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element();
                        
    
                            responseElement.E_KUNNR='1';
                            responseElement.E_MENSAJE='Datos actualizados';
                            response.put('response_x', responseElement);
                        }
                    }else if(request_x.I_DATOS_FINAL != null){
                        if(request_x.I_DATOS_FINAL.KUNNR.equalsIgnoreCase('FAIL')){
                            Map<String, CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element> response_map_x = new Map<String,CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element>();
                            CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element responseElement = new CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element();
                            
        
                            responseElement.E_KUNNR='';
                            responseElement.E_MENSAJE='Mensaje de error';
                            response.put('response_x', responseElement);
                        }else if(!request_x.I_DATOS_FINAL.KUNNR.equalsIgnoreCase('FAIL')){
                            Map<String, CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element> response_map_x = new Map<String,CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element>();
                            CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element responseElement = new CrearClienteSAPEsquema.ZSFOR_CREAR_CLIENTEResponse_element();
                        
    
                            responseElement.E_KUNNR='1';
                            responseElement.E_MENSAJE='Datos actualizados';
                            response.put('response_x', responseElement);
                        }
                    }
                    

                    

                }
         
    }
}