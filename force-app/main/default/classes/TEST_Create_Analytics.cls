@isTest
public class TEST_Create_Analytics {

    @testSetup
    static void test_setup(){
        
        Account acc = new Account();
        acc.name = 'Setup1';
        acc.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        acc.sede__c = '1000';
        acc.NIF_CIF__c = '3';
        acc.ID_SAP__c = '2';
        
        insert acc;

        Account acc2 = new Account();
        acc2.name = 'Setup1';
        acc2.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).getRecordTypeId();
        acc2.sede__c = '1410';
        acc2.NIF_CIF__c = '4';
        acc2.ID_SAP__c = '5';
        insert acc2;

        List<CodMercado__c> codigosMercado = new List<CodMercado__c>();
        codigosMercado.add(new codMercado__c(
            Codigo__c = '20',
            Name = 'Banca-Banca'
                ));
        insert codigosMercado;
    }
    
    /**
     * @description comprueba que se han creado registros de analítica si se envia bien formado el JSON y contiene ID o NIF.
     * @author Adrián Bernardo
     * @date 16/02/2023
     */
  @isTest
    static void test_createAnalyticsIdSAP(){
        

        String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":1,"febrero":2,"marzo":3,"abril":4,"mayo":5,"junio":6,"julio":7,"agosto":8,"septiembre":9,"octubre":10,"noviembre":11,"diciembre":12,"cebe":"ES00T02004","idcliente":"2","nifcliente":"3","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(body);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        CreateAnalytics.CreateAnalytics();
        Test.stopTest();

        List<Analitica__c> analytics = [SELECT id,importe__c,fecha__c FROM Analitica__c];
        List<Log__c> logsError = [SELECT id,error__c FROM Log__C];
        system.debug('Error'+ logsError);
        for(Analitica__c an : analytics ){
              System.debug('Analitica-->'+an.fecha__c + an.importe__c);
        }
      
        system.assertEquals(analytics.isEMpty(),false);
        system.assertEquals(logsError.isEMpty(),true);
    


        }

        /**
     * @description comprueba que se han creado registros de analítica si se envia bien formado el JSON 
     * y no contiene ID pero si NIF.
     * @author Adrián Bernardo
     * @date 16/02/2023
     */
        @isTest
    static void test_createAnalyticsNIF(){
        

        String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"","nifcliente":"3","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(body);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        CreateAnalytics.CreateAnalytics();
        Test.stopTest();

        List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
        List<Log__c> logsError = [SELECT id,error__c FROM Log__C];
        system.debug('lgsError'+logsError);
        system.assertEquals(analytics.isEMpty(),false);
        system.assertEquals(logsError.isEMpty(),true);
    


        }

        /**
        * @description comprueba que se han creado registros de log tras no existir registro de cuenta con id sap y NIf
        * que se envían
        * @author Adrián Bernardo
        * @date 16/02/2023
        */
        @isTest
        static void test_createAnalyticsKONoConcuerda(){
            
    
            String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"8","nifcliente":"5","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response= response;
            Test.startTest();
            CreateAnalytics.CreateAnalytics();
            Test.stopTest();
    
            List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
            List<Log__c> logsError = [SELECT id FROM Log__C];
            system.assertEquals(analytics.isEMpty(),true);
            system.assertEquals(logsError.isEMpty(),false);
    
    
            }

            /**
        * @description comprueba que se han creado registros de log tras no pasarle ni ID ni NIF
        * @author Adrián Bernardo
        * @date 16/02/2023
        */
            @isTest
        static void test_createAnalyticsKONoIdNoNif(){
            
    
            String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"","nifcliente":"","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response= response;
            Test.startTest();
            CreateAnalytics.CreateAnalytics();
            Test.stopTest();
    
            List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
            List<Log__c> logsError = [SELECT id FROM Log__C];
            system.assertEquals(analytics.isEMpty(),true);
            system.assertEquals(logsError.isEMpty(),false);
    
    
            }



        /**
        * @description comprueba que se han creado registros de log tras estar el JSON malformado
        * @author Adrián Bernardo
        * @date 16/02/2023
        */
            @isTest
        static void test_createAnalyticsJSONMalformado(){
            
    
            String body = '{"data" : ["anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"","nifcliente":"","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response= response;
            Test.startTest();
            CreateAnalytics.CreateAnalytics();
            Test.stopTest();
    
            List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
            List<Log__c> logsError = [SELECT id,error__c FROM Log__C];
            system.assertEquals(analytics.isEMpty(),true);
            system.assertEquals(logsError.isEMpty(),false);
    
    
            }

            /**
        * @description comprueba que se han creado registros de log no encontrar una sede existente.
        * @author Adrián Bernardo
        * @date 13/03/2023
        */
            @isTest
    static void test_createAnalyticsNoExisteSede(){
        

        String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"2","nifcliente":"3","orgventas":"5123","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(body);
        RestContext.request = request;
        RestContext.response= response;
        Test.startTest();
        CreateAnalytics.CreateAnalytics();
        Test.stopTest();

        List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
        List<Log__c> logsError = [SELECT id FROM Log__C];
        system.assertEquals(analytics.isEMpty(),true);
        system.assertEquals(logsError.isEMpty(),false);
    


        }


         /**
        * @description comprueba que se han creado registros de log al no encontrar un sector que no existe
        * @author Adrián Bernardo
        * @date 13/03/2023
        */
        @isTest
        static void test_createAnalyticsNoExisteSector(){
            
    
            String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"2","nifcliente":"3","orgventas":"1000","sector":"50","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(body);
            RestContext.request = request;
            RestContext.response= response;
            Test.startTest();
            CreateAnalytics.CreateAnalytics();
           
            Test.stopTest();
    		
            List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
            List<Log__c> logsError = [SELECT id FROM Log__C];
            system.assertEquals(analytics.isEMpty(),true);
            system.assertEquals(logsError.isEMpty(),false);
        
    
    
            }

            /**
        * @description comprueba que se han creado registros de log al introducirse un valor de picklist erroneo.
        * @author Adrián Bernardo
        * @date 13/03/2023
        */
            @isTest
            static void test_createAnalyticsInvalidPicklistValue(){
                
        
                String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"PE00T18002","idcliente":"2","nifcliente":"3","orgventas":"1000","sector":"50","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
                RestRequest request = new RestRequest();
                RestResponse response = new RestResponse();
                request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
                request.httpMethod = 'POST';
                request.requestBody = Blob.valueof(body);
                RestContext.request = request;
                RestContext.response= response;
                Test.startTest();
                CreateAnalytics.CreateAnalytics();
                Test.stopTest();
        
                List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
                List<Log__c> logsError = [SELECT id FROM Log__C];
                system.assertEquals(analytics.isEMpty(),true);
                system.assertEquals(logsError.isEMpty(),false);
            
        
        
                }




                @isTest
                static void test_createAnalyticsSubSede(){
                    
            
                    String body = '{"data" : [{"anio":"2024", "elemento_pep":"EC/000014-001-003","denominacion":"Digital - Elastic Search","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"julio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"diciembre":0.0,"cebe":"ES00T02004","idcliente":"5","nifcliente":"4","orgventas":"1420","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
                    RestRequest request = new RestRequest();
                    RestResponse response = new RestResponse();
                    request.requestUri =URL.getOrgDomainUrl()+'/services/apexrest/CreateAnalytics';
                    request.httpMethod = 'POST';
                    request.requestBody = Blob.valueof(body);
                    RestContext.request = request;
                    RestContext.response= response;
                    Test.startTest();
                    CreateAnalytics.CreateAnalytics();
                    Test.stopTest();
            
                    List<Analitica__c> analytics = [SELECT id FROM Analitica__c];
                    List<Log__c> logsError = [SELECT id,error__c FROM Log__C];
                    system.assertEquals(analytics.isEMpty(),false);
                    system.assertEquals(logsError.isEMpty(),true);
                    system.debug(logsError);
                
            
            
                }

                
            @isTest
        static void test_createAnalyticWrapper(){
                AnalyticWrapper wrapper = new AnalyticWrapper();
                String body = '{"data":[{"anio":"2024", "elemento_pep":"EC/000014-001-001-001","denominacion":"Nueva Web W1","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"cebe":"ES00T02002","idcliente":"","nifcliente":"","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""},{"elemento_pep":"EC/000014-001-001-002","denominacion":"eComm. Benchmark W1","moneda":"","clvper":"ZVAWIP","enero":0.0,"febrero":0.0,"marzo":0.0,"abril":0.0,"mayo":0.0,"junio":0.0,"agosto":0.0,"septiembre":0.0,"octubre":0.0,"noviembre":0.0,"cebe":"ES00T02002","idcliente":"","nifcliente":"","orgventas":"1000","sector":"20","clan":"V002","idcomercial":"00000000","oficina":"1000","ve":"","pres":"","cluster":"","tecnologia":""}]}';
                wrapper = AnalyticWrapper.parse(body);
    
            }
}