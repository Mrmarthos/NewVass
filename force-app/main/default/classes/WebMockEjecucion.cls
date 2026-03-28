global class WebMockEjecucion implements WebServiceMock {
    public WebMockEjecucion() {}
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
            
            

                
                
                
                PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAIN_element request_x = ( PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAIN_element)request;
                PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAINResponse_element  responseElement = new   PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAINResponse_element ();
                
                
                responseElement.E_RESULTADO = '';
                responseElement.E_OBJNR ='22222';
                responseElement.E_WBS_ELEMENT='LL/1';
                responseElement.E_PROYECTO_PADRE='LL/1';
                response.put('response_x', responseElement);
                
            
            
        }
    
}