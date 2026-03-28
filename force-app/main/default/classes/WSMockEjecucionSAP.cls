@isTest
global class WSMockEjecucionSAP implements WebServiceMock {

    
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
        
		
              		PepsEjecucionCall.ZSFOR_PROJECT_MAINTAINResponse_element response2;
               Map<String, PepsEjecucionCall.ZSFOR_PROJECT_MAINTAINResponse_element> response_map_x = new Map<String,PepsEjecucionCall.ZSFOR_PROJECT_MAINTAINResponse_element>();
				response.put('response_x', response2);
        // end
    
   }
}