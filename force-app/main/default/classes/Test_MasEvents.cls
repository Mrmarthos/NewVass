/**versión v1
*@description: Clase de test para MasEvents.
*@author name: rpolvera
*@date date: 12/11/2018
*@change name date description: Clase nueva.
*@see class/method: MasEvents
**/
@IsTest
private class Test_MasEvents {
    
    /**
    *@description: Prueba el flujo correcto del WS
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/    
    @isTest
    static void test_publicaEventosCorrecto()
    {
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/v1/sobjects/events';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('['
                                    +'{'
                                    +'"attributes": {'
                                    +'    "type": "E_Linea_de_Proyecto__e"'
                                    +'    },'
                                    +'"eOperacion__c":"update"'
                                    +'}'
                            +']');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        MasEvents.publicaEventos();
        system.assertEquals(RestContext.response.statusCode, 201);
    }
    
    /**
    *@description: Prueba el flujo con errores del servidor como un error de tipo de evento
                   o un error en campos obligatorios
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/    
    @isTest
    static void test_publicaEventosError()
    {
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/v1/sobjects/events';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('['
                                    +'{'
                                    +'"attributes": {'
                                    +'    "type": "Linea_de_Proyecto__c"'
                                    +'    },'
                                    +'"name":"prueba"'
                                    +'},'
                                    +'{'
                                    +'"attributes": {'
                                    +'    "type": "E_Linea_de_Proyecto__e"'
                                    +'    },'
                                    +'"eOperacion__c":""'
                                    +'}'
                            +']');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        MasEvents.publicaEventos();

        system.assertEquals(RestContext.response.statusCode, 500);
    }

    /**
    *@description: Prueba el flujo con errores del cliente como una mala estructura
                   en el JSON de entrada
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/  
    @isTest
    static void test_publicaEventosErrorJSON()
    {
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/v1/sobjects/events';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('['
                                    +'{'
                                    +'attributes": {'
                                    +'    "_de_Proyecto__e"'
                                    +'    },'
                                    +'"eOperacion__c":""'
                                    +'}'
                            +']');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        // Call the method to test
        MasEvents.publicaEventos();

        system.assertEquals(RestContext.response.statusCode, 400);
    }    
}