@isTest
public class TestBotonSincro {

      @isTest
    static void CallWS()
    {
        
          Test.setMock(WebServiceMock.class, new WSMockPreventaSAP());

        Test.startTest();
        CallSAPSincro.SendPreventa('12212',false);
        //salida=srv.buscarSiniestrosCliente(entrada);
        Test.stopTest();
        
    }
    
          @isTest
    static void CallWSEjecucion()
    {
        
          Test.setMock(WebServiceMock.class, new WSMockEjecucionSAP());

        Test.startTest();
        CallSAPSincro.SendPreventa('12212',true);
        //salida=srv.buscarSiniestrosCliente(entrada);
        Test.stopTest();
        
    }

       
}