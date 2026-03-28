@isTest
                        
global class  WSMockPreventaSAP implements WebServiceMock{
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
        // start - specify the response you want to send
        
			
               PreventaSAP.ZSFOR_PEPS_PREVENTAResponse_element response2;
               Map<String, PreventaSAP.ZSFOR_PEPS_PREVENTAResponse_element> response_map_x = new Map<String, PreventaSAP.ZSFOR_PEPS_PREVENTAResponse_element>();
				response.put('response_x', response2);
        // end
    
   }
}