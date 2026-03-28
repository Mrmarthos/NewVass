/**
* Clase de test encargada de probar el funcionamiento de la clase "ControladorDivisas.apxc"
* @author adiaz
* @date 28/08/2018 
*/
@isTest
public class Test_ActualizadorDivisas implements HttpCalloutMock 
{
    
    // Importante: ver como se puede modificar el método respond para simular dos respuestas desde el servidor Mock.
    public Integer contadorRespuestasMock = 0;
    
    /**
* Método encargado de simular la respuesta del servidor
* @author adiaz
* @date 28/08/2018 
*/
    public HTTPResponse respond(HTTPRequest req) 
    {  
        if (contadorRespuestasMock == 0)
        {
            // Se genera una respuesta falsa desde el servidor con el contenido del XML de las divisas
          HttpResponse res = new HttpResponse();
          res.setHeader('Content-Type', 'application/text');
          String body = '<gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01" xmlns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref"><gesmes:subject>Reference rates</gesmes:subject><gesmes:Sender><gesmes:name>European Central Bank</gesmes:name></gesmes:Sender><Cube><Cube time="2018-08-27"><Cube currency="USD" rate="1.1633"/><Cube currency="JPY" rate="129.16"/><Cube currency="BGN" rate="1.9558"/><Cube currency="CZK" rate="25.744"/><Cube currency="DKK" rate="7.4582"/><Cube currency="GBP" rate="0.90365"/><Cube currency="HUF" rate="323.87"/><Cube currency="PLN" rate="4.2710"/><Cube currency="RON" rate="4.6423"/><Cube currency="SEK" rate="10.6095"/><Cube currency="CHF" rate="1.1428"/><Cube currency="ISK" rate="124.60"/><Cube currency="NOK" rate="9.6988"/><Cube currency="HRK" rate="7.4375"/><Cube currency="RUB" rate="78.2795"/><Cube currency="TRY" rate="7.2082"/><Cube currency="AUD" rate="1.5886"/><Cube currency="BRL" rate="4.7606"/><Cube currency="CAD" rate="1.5182"/><Cube currency="CNY" rate="7.9396"/><Cube currency="HKD" rate="9.1318"/><Cube currency="IDR" rate="17015.88"/><Cube currency="ILS" rate="4.2281"/><Cube currency="INR" rate="81.6230"/><Cube currency="KRW" rate="1294.41"/><Cube currency="MXN" rate="21.8104"/><Cube currency="MYR" rate="4.7777"/><Cube currency="NZD" rate="1.7415"/><Cube currency="PHP" rate="61.997"/><Cube currency="SGD" rate="1.5884"/><Cube currency="THB" rate="37.929"/><Cube currency="ZAR" rate="16.6464"/></Cube></Cube></gesmes:Envelope>';  
          res.setBody(body);             
          res.setStatusCode(200);
          contadorRespuestasMock++;
          return res;
        }
        else 
        {
            // Se genera una respuesta falsa desde el servidor con el contenido del JSON del access token
          HttpResponse res = new HttpResponse();
          res.setHeader('Content-Type', 'application/json');
          String body = '{"access_token":"SESSION_ID_REMOVED","instance_url":"https://eu16.salesforce.com","id":"https://login.salesforce.com/id/00D1t000000FPd1EAG/0051t000000VXxmAAG","token_type":"Bearer","issued_at":"1538637060949","signature":"7kPWer9MgLB5gzKChUWXVaZiSmp446enstscZSxBwB0="}';  
          res.setBody(body);             
          res.setStatusCode(200);
          return res;
        }
        
    }
    
        /**
* Método de test encargado de probar el funcionamiento del método cargarDivisas() sin haber recibido una respuesta del servidor
* @author adiaz
* @date 28/08/2018 
*/
    @isTest public static void testFallo_cargarDivisas() 
    {
        // Este test da fallo porque no se ha hecho la llamada falsa al servidor
        Test.startTest();
        try 
        {
            ActualizadorDivisas.cargarDivisas();
        }
        catch(Exception e)
        {
            System.debug('TEST Mensaje de error -> ' + e.getMessage());
            System.debug('TEST Lugar del error -> ' + e.getStackTraceString());
            System.debug('TEST Tipo de error -> ' + e.getTypeName());
        }
        //System.assertEquals(false, ControladorDivisas.cargarDivisas(''));
        Test.stopTest();
    }
    
            /**
* Método de test encargado de probar el funcionamiento del método cargarDivisas() habiendo recibido una respuesta del servidor
* @author adiaz
* @date 28/08/2018 
*/
    @isTest(SeeAllData=false) public static void testFuncionaBien_cargarDivisas() 
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_ActualizadorDivisas());
        
        ActualizadorDivisas.cargarDivisas();
        
        List<CurrencyType> listaDivisasAntes = [SELECT Id, IsoCode, ConversionRate FROM CurrencyType];        
        System.assertEquals(true, listaDivisasAntes.size() > 0);
        Test.stopTest();
    }
}