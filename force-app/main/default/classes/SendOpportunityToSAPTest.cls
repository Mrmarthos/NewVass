@IsTest private class SendOpportunityToSAPTest {

    @TestSetup
    static void testSetup(){
        insert new CodMercado__c(Codigo__c = '20',Name = 'Industria-Industria');

        Map<String, List<Object>> camposMapAcc = new Map<String, List<Object>>
        {
            'Name' => new List<String>{'AccTest1', 'AccTest2', 'AccTest3'},
            'Sede__c' => new List<String>{'2110', '2110', '2110'},
            'oficina_tecnica_SAP__c' => new List<String>{'1000', '1000', '1000'},
            'Mercado__c' => new List<String>{'Industria-Industria', 'Industria-Industria', 'Industria-Industria'},
            'ID_SAP__c' => new List<String>{'IDSAPTEST1','IDSAPTEST2', 'IDSAPTEST3'},
            'NIF_CIF__c' => new List<String>{'NIFCIF1','NIFCIF2', 'NIFCIF3'},
            'Razon_social__c' => new List<String>{'CUENTATEST1','CUENTATEST2', 'CUENTATEST3'},
            'BillingCountryCode' => new List<String>{'ES','ES', 'ES'},
            'SAP_Grupo_ID__c' => new List<String>{'IDSAPTEST1','IDSAPTEST2', 'IDSAPTEST3'},
            'CurrencyIsoCode' => new List<String>{'EUR','EUR', 'EUR'},
            'Validacion_NIF__c' => new List<Boolean>{true,true,true},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId, 
                                               Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_INTERNAL).RecordTypeId}
    
        }; 
        
        
        List<Account> accs = TestUtil.rellenarSObject(Account.SObjectType, camposMapAcc);
        
        insert accs;
 
        Map<String, List<Object>> camposMapCont = new Map<String, List<Object>>
        {
            'LastName' 				=> new List<String>{'ContTest1', 'ContTest2', 'JEFEPROYECTO'},
			'Codigo_de_empleado__c'	=> new List<String>{'12312378', '12345698', '11144477'},                
            'AccountId' => new List<String>{accs[0].Id, accs[1].Id, accs[2].Id},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                               Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId, 
                                               Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId}
        }; 
         
        List<Contact> conts = TestUtil.rellenarSObject(Contact.SObjectType, camposMapCont);
        
        insert conts; 
 
        Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
        {
            'Name' => new List<String>{'Opp101234','OppTest2'},
            'Amount' => new List<Integer>{10000,10000},
			'ID_SAP__c'	=> new List<String>{'oprtunidadidsap1234', ''},    // una Opp con ID sap, ya en SAP, la otra para prueba enviar SAP            
            'CloseDate' => new List<Date>{date.newInstance(2018, 12, 12), date.newInstance(2018, 12, 12)},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId, 
                                               Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId},
            'StageName' => new List<String>{'Identificada', 'Identificada'},
            'Mercado__c' => new List<String>{'Industria-Industria', 'Industria-Industria'},
            'AccountId' => new List<String>{accs[0].Id, accs[1].Id},
            'Bid_Manager__c' => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Offering__c' => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()}, 
            'Contacto_del_cliente__c' => new List<String>{conts[0].Id, conts[1].Id},
            'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11)},
            'Fecha_de_propuesta_general__c' => new List<Date>{date.newInstance(2018, 11, 11), date.newInstance(2018, 11, 11)},
            'Codigo_de_oportunidad__c' => new List<String>{'VASS20180123456701', 'VASS20180123456702'}
        };
       
        
        List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);
       
        insert opps;

        Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
        {
            'Oportunidad__c' => new List<String>{opps[0].Id, opps[1].Id},
            'Gerencia__c' => new List<String>{'Digital Experience', 'Digital Experience'},
            'Responsable_de_LDP__c' => new List<String>{UserInfo.getUserId(), UserInfo.getUserId()},
            'Area__c' => new List<String>{'ES00T02002', 'ES00T02002'},
            'Tecnologia__c' => new List<String>{'ADO', 'ADO'},
            'Listo_para_sincronizar__c' => new List<Boolean>{true, true},
            'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[2].Id, conts[2].Id},
            'RecordTypeId' => new List<String>{Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId, 
                                               Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId}
        };
          
        List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP);
        
        insert lps;

        Hito_de_facturacion__c hito1;
        hito1=new  Hito_de_facturacion__c (

            Fecha__c=Date.newInstance(2019, 12, 16),
            //Name='test',
            Oportunidad__c=opps[0].id,
            Porcentaje__c=100
        );
        insert hito1;

    }
    


    @isTest
    private static void comprobarEnvioDeDatosASAPPreventaOK() {
        List<Opportunity> opps = [SELECT id,StageName,Sede_venta__r.sede__c,Lineas_validadas_Preventa__c,Lineas_validadas_Entregada__c,Gerencias_involucradas__c,Contador_Lineas_validadas_Preventa__c,Contador_Lineas_validadas_Entregada__c FROM Opportunity Limit 1];
        
        WebServiceMockGenerator mock = new WebServiceMockGenerator();
       

        Test.startTest();
        
        
        Test.setMock(WebServiceMock.class, mock);
        opps.get(0).StageName = 'Preventa';
        update opps;

        
            
       
            
        Test.stopTest();
        
        
    }

    
    @isTest
    private static void comprobarEnvioDeDatosASAPPreventaKO() {
        List<Opportunity> opps = [SELECT id,StageName,AccountID,Sede_venta__r.sede__c,Account.ID_Sap__c,Lineas_validadas_Preventa__c,Lineas_validadas_Entregada__c,Gerencias_involucradas__c,Contador_Lineas_validadas_Preventa__c,Contador_Lineas_validadas_Entregada__c FROM Opportunity Limit 1];
        List<Account> accs = [SELECT ID_Sap__c FROM Account WHERE id =:opps[0].AccountId]; 
        
        WebServiceMockGenerator mock = new WebServiceMockGenerator();
        

        Test.startTest();
        accs.get(0).ID_Sap__c = 'FAIL';
        update accs;
        
        Test.setMock(WebServiceMock.class, mock);
        opps.get(0).StageName = 'Preventa';
        update opps;

        
            
       
            
        Test.stopTest();
        
        
    }

    @isTest
    private static void comprobarEnvioDeDatosASAPFinalOK() {
        List<Opportunity> opps = [SELECT id,StageName,Lineas_validadas_Preventa__c,Gerencias_involucradas__c,Contador_Lineas_validadas_Preventa__c,Contador_Lineas_validadas_Entregada__c FROM Opportunity Limit 1];
        List<String> valores = new List<String>();
        WebServiceMockGenerator mock = new WebServiceMockGenerator();
        valores.add('sociedad,2110,envio,envio,areaDeVentas,1100,mercado,20,codigoClienteSAP,0000000391,condicionDePagoSociedad,NT00,grupoImputacionCliente,01,poblacion,Madrid,calle,Hospitalet,codigoPostal,00990,opportunityId,'+opps[0].id);

        
        Test.setMock(WebServiceMock.class, mock);
        
        //Hacerlo como lo haría normalmente el flujo.
        
        Test.startTest();
        SendOpportunityToSAP.getOpporInfoFromSAP(valores);
            
    
    
        Test.stopTest();
        
        
    }
    @isTest
    private static void comprobarEnvioDeDatosASAPFinalNIFNoValido() {
        List<Opportunity> opps = [SELECT id,AccountId,StageName,Lineas_validadas_Preventa__c,Gerencias_involucradas__c,Contador_Lineas_validadas_Preventa__c,Contador_Lineas_validadas_Entregada__c FROM Opportunity Limit 1];
        List<String> valores = new List<String>();
        List<Account> accs = [SELECT NIF_CIF__c,Validacion_NIF__c FROM Account WHERE ID = :opps[0].accountId];
        WebServiceMockGenerator mock = new WebServiceMockGenerator();

        valores.add('sociedad,2110,envio,envio,areaDeVentas,1100,mercado,20,codigoClienteSAP,0000000391,condicionDePagoSociedad,NT00,grupoImputacionCliente,01,poblacion,Madrid,calle,Hospitalet,codigoPostal,00990,opportunityId,'+opps[0].id);
        accs[0].validacion_nif__c = false;
        update accs;

        Test.setMock(WebServiceMock.class, mock);
        Test.startTest();
        SendOpportunityToSAP.getOpporInfoFromSAP(valores);
        Test.stopTest();
    }


    @isTest
    private static void comprobarEnvioDeDatosASAPFinalKO() {
        List<Opportunity> opps = [SELECT id,AccountId,StageName,Lineas_validadas_Preventa__c,Gerencias_involucradas__c,Contador_Lineas_validadas_Preventa__c,Contador_Lineas_validadas_Entregada__c FROM Opportunity Limit 1];
        List<String> valores = new List<String>();
        List<Account> accs = [SELECT NIF_CIF__c,Validacion_NIF__c,ID_SAP__c FROM Account WHERE ID = :opps[0].AccountId];
        WebServiceMockGenerator mock = new WebServiceMockGenerator();
        valores.add('sociedad,2110,envio,envio,areaDeVentas,1100,mercado,20,codigoClienteSAP,FAIL,condicionDePagoSociedad,NT00,grupoImputacionCliente,01,poblacion,Madrid,calle,Hospitalet,codigoPostal,00990,opportunityId,'+opps[0].id);

        Test.setMock(WebServiceMock.class, mock);
        Test.startTest();
        SendOpportunityToSAP.getOpporInfoFromSAP(valores);
        Test.stopTest();
    }

    @isTest
    private static void comprobarMostrarDatosEnFlow() {
        List<Opportunity> opps = [SELECT id,AccountId,StageName,Lineas_validadas_Preventa__c,Gerencias_involucradas__c,Contador_Lineas_validadas_Preventa__c,Contador_Lineas_validadas_Entregada__c FROM Opportunity Limit 1];
        List<String> valores = new List<String>();
        List<Account> accs = [SELECT NIF_CIF__c,Validacion_NIF__c,ID_SAP__c FROM Account WHERE ID = :opps[0].AccountId];
        String bodyXML = '<?xml version="1.0" encoding="utf-8"?><entry xml:base="https://salesforceintegrationsaptest.vass.es:8441/sap/opu/odata/sap/ZWSSALESFORCE_SRV/" xmlns="http://www.w3.org/2005/Atom" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices"><id>https://salesforceintegrationsaptest.vass.es:8441/sap/opu/odata/sap/ZWSSALESFORCE_SRV/data_customerSet(kunnr=\''+318+'\',bukrs=\''+1000+'\',vkorg=\''+1100+'\',spart=\''+20+'\')</id><title type="text">data_customerSet(kunnr=\''+318+'\',bukrs=\''+1000+'\',vkorg=\''+1100+'\',spart=\''+20+'\')</title><updated>2022-09-26T11:10:53Z</updated><category term="ZWSSALESFORCE_SRV.get_data_customer" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme"/><link href="data_customerSet(kunnr=\''+318+'\',bukrs=\''+1000+'\',vkorg=\''+1100+'\',spart=\''+20+'\')" rel="self" title="get_data_customer"/><content type="application/xml"><m:properties><d:kunnr>318</d:kunnr><d:bukrs>1000</d:bukrs><d:vkorg>1100</d:vkorg><d:spart>20</d:spart><d:stras>calle</d:stras><d:ort01>Madrid</d:ort01><d:pstlz>09900</d:pstlz><d:KDGRP>92</d:KDGRP><d:ktgrd>01</d:ktgrd><d:zwels>TU</d:zwels><d:zterm>60D</d:zterm><d:ztermvv>NT00</d:ztermvv></m:properties></content></entry>';
        Integer code= 200;
        HTTPCalloutMockSendOppToSAP mock = new HTTPCalloutMockSendOppToSAP(bodyXML,code);
        valores.add(opps[0].id);

        Test.setMock(HTTPCalloutMock.class, mock);
        Test.startTest();
        SendOpportunityToSAP.getOpporInfoFromSAP(valores);
        Test.stopTest();
    }

    
}