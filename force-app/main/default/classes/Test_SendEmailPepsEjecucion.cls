@isTest
private class Test_SendEmailPepsEjecucion {
    
    
    @TestSetup
    static void setupData(){
        //Crear Account
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
           'LastName' 				=> new List<String>{'ContTest1','ContTest2','ContTest3'},
           'Codigo_de_empleado__c'	=> new List<String>{'12312378','12312379','12312370'},                
           'AccountId' => new List<String>{accs[0].Id,accs[1].Id,accs[2].Id},
           'Email' => new List<String>{'test.test1@test.com','test.test2@test.com','test.test3@test.com'},
           'RecordTypeId' => new List<String>{Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId,
                                                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_STANDAR).RecordTypeId,
                                                Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId}
       }; 
        
       List<Contact> conts = TestUtil.rellenarSObject(Contact.SObjectType, camposMapCont);
       
       insert conts; 

       Map<String, List<Object>> camposMapOpp = new Map<String, List<Object>>
       {
           'Name' => new List<String>{'Opp101234','Opp1012345'},
           'ID_SAP__c'	=> new List<String>{'oprtunidadidsap1234','oprtunidadidsap12345'},    // una Opp con ID sap, ya en SAP, la otra para prueba enviar SAP            
           'CloseDate' => new List<Date>{date.newInstance(2024, 12, 12),date.newInstance(2023, 12, 12)},
           'RecordTypeId' => new List<String>{Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId,
                                              Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).RecordTypeId},
           'StageName' => new List<String>{'Identificada','Identificada'},
           'Mercado__c' => new List<String>{'Industria-Retail','Industria-Retail'},
           'AccountId' => new List<String>{accs[0].Id,accs[0].Id},
           'Bid_Manager__c' => new List<String>{UserInfo.getUserId(),UserInfo.getUserId()},
           'Offering__c' => new List<String>{UserInfo.getUserId(),UserInfo.getUserId()}, 
           'Contacto_del_cliente__c' => new List<String>{conts[0].Id,conts[0].Id},
           'Fecha_de_propuesta_economica_tecnica__c' => new List<Date>{date.newInstance(2023, 11, 11),date.newInstance(2024, 11, 11)},
           'Fecha_de_propuesta_general__c' => new List<Date>{date.newInstance(2024, 11, 11),date.newInstance(2023, 11, 11)},
           'Codigo_de_oportunidad__c' => new List<String>{'VASS20180123456701','VASS20180123456702'}
       };
       System.debug('Campos mapa opp'+camposMapOpp);
       List<Opportunity> opps = TestUtil.rellenarSObject(Opportunity.SObjectType, camposMapOpp);

      
       insert opps;
       /*Map<String, List<Object>> camposMapLP = new Map<String, List<Object>>
       {
           'Oportunidad__c' => new List<String>{opps[0].Id},
           'Area__c' => new List<String>{'ES00T04006'},
           'Gerencia__c' => new List<String>{'Customer Centric'},
           'Responsable_de_LDP__c' => new List<String>{UserInfo.getUserId()},
           'Tecnologia__c' => new List<String>{'JAV', 'JAV'},
           'Listo_para_sincronizar__c' => new List<Boolean>{true, true},
           'Jefe_de_Proyecto_de_Preventa__c' => new List<String>{conts[0].Id},
           'Jefe_de_Proyecto_de_Ejecucion__c' => new List<String>{conts[0].Id},
           'Jefe_de_Proyecto_de_Ejecucion__c' => new List<String>{conts[0].Id},
           'Sede__c' => new List<String>{'1110'},
           'Oficina_tecnica__c' => new List<String>{'1000'},
           'Org_Ventas__c' => new List<String>{'1000'},
           'Coste_estimado__c' => new List<Decimal>{100},           
            'Margen_bruto__c' => new List<Decimal>{20}, 
            'Fecha_Inicio__c' => new List<Date>{date.newInstance(2022, 12, 00)}, 	
            'Fecha_Fin__c'=> new List<Date>{date.newInstance(2023, 12, 01)},
           'Responsable_de_LDP__c' => new List<String>{UserInfo.getUserId()},
           'Jefe_Proyecto_Ejecucion_Adicional__c' => new List<String>{conts[0].Id},
           'NEW_Nombre_SAP__c' => new List<String>{'Nuevo nombre sap 1'},
           'Linea_principal__c' => new List<Boolean>{true},
           'RecordTypeId' => new List<String>{Schema.SObjectType.Linea_de_proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_TURNKEY).RecordTypeId}
       };
       
       System.debug('Campos mapa LP'+camposMapLP);
       List<Linea_de_Proyecto__c> lps = TestUtil.rellenarSObject(Linea_de_Proyecto__c.SObjectType, camposMapLP);
       
       insert lps;*/
       system.debug(conts[2]);
       List<Linea_de_Proyecto__c> lps = TestUtil.generaLineasLlaveManoTest(opps,conts);
       lps[0].Sede__c = '1100';
       lps[0].Linea_principal__c = true;
       update lps;

    }

    @isTest private static void enviarCorreoOKTest(){
        
        List<Linea_de_Proyecto__c> lps = [Select id,
        Nombre_SAP__c,
        Sede__c,
       Execution_SAP_Name__c,
        Oportunidad__r.Codigo_de_oportunidad__c 
        from Linea_de_Proyecto__c];

        SendEmailPepsEjecucion.enviarCorreo(lps[0]);
    }

    @isTest private static void enviarCorreoKOTest(){
        List<Linea_de_Proyecto__c> lps = [Select id,
        Nombre_SAP__c,
        Sede__c,
        Execution_SAP_Name__c,
        Oportunidad__r.Codigo_de_oportunidad__c 
        from Linea_de_Proyecto__c];

        SendEmailPepsEjecucion.enviarCorreo(lps[0],'Error');
    }

    @isTest private static void enviarCorreoAltaPEPTest(){
        List<Linea_de_Proyecto__c> lps = [Select id,
        Nombre_SAP__c,
        Sede__c,
        Execution_SAP_Name__c,
         urlForm__c,                                 
        Oportunidad__r.Codigo_de_oportunidad__c 
        from Linea_de_Proyecto__c];
        String []destinatarios = new String[]{'test.test23@test.com'};
        SendEmailPepsEjecucion.enviarCorreoAltaPEP(lps[0],destinatarios);
    }

    @isTest private static void generarPlantillaHTML(){
        List<Linea_de_Proyecto__c> lps = [Select id,
        Codigo_SAP_Preventa__c,
        Name,
        Nombre_SAP__c,
        urlForm__c,
        Area__c,
        Oficina_tecnica__c,
        Fecha_Fin__c, 
        Fecha_Inicio__c,
        Gerencia__c,
        RecordType.Name,
        RecordTypeId,
        Oportunidad__r.Owner.Email,
        Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
        Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c,
        Margen_real__c,
        Importe_total_2__c,
        Responsable_de_LDP__r.EmployeeNumber,
        Responsable_de_LDP__r.Name,
        Tecnologia__c,
        Oportunidad__r.Proyecto_Padre__c,
        Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c,
        Oportunidad__r.Proyecto_extraordinario__c,
        Oportunidad__r.Codigo_de_oportunidad__c,
        Oportunidad__r.CreatedDate,
        Oportunidad__r.Account.ID_SAP__c,
        Oportunidad__r.Margen_bruto__c,
        Oportunidad__r.Owner.EmployeeNumber,
        Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c,  
        Oportunidad__r.Offering__r.EmployeeNumber,
        Oportunidad__r.Offering__r.Profile.Id,
        Comercial_Intercompany__r.EmployeeNumber,
        CreatedById,
        Fabricantes__c,
        Sede__c,
        Coste_Bruto__c,
        Execution_SAP_Name__c,
        Margen_Real_Economico__c,
        Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c,
        Oportunidad__r.mercado__c,
        Org_Ventas__c,
        Clase_PEP__c,
        Codigo_SAP_Ejecucion__c,
        CurrencyIsoCode,
        Venta_Extraordinaria__c,
        oportunidad__r.Proyecto_estrategico__c,
        Sin_Controlling__c,
        Ejecutado_en_cliente__c,
        Direccion_cliente__c,
        Clave_Periodificacion__c,
        Agile__c,
        Cambio_Alcance__c,
        Jefe_de_Proyecto_de_Ejecucion__r.Email,
        Sin_Contrato__c,
        ToLabel(Inducido__c),
        CreatedBy.EmployeeNumber,
        Jefe_Proyecto_Ejecucion_Adicional__r.name,
        Jefe_de_Proyecto_de_Ejecucion__r.Name,
        Oportunidad__r.Owner.Name,
        Oportunidad__r.Account.Name,
        Coste_real__c,
        Importe_a_elevar__c
        from Linea_de_Proyecto__c];
        SendEmailPepsEjecucion.generarPlantillaHTML(lps[0]);
    }

    @isTest private static void generarPlantillaOKTest(){
        List<Linea_de_Proyecto__c> lps = [Select id,
        Nombre_SAP__c,
        Sede__c,
        Execution_SAP_Name__c,
        Oportunidad__r.Codigo_de_oportunidad__c 
        from Linea_de_Proyecto__c];
        SendEmailPepsEjecucion.generarPlantillaOK(lps[0]);
    }

    @isTest private static void generarPlantillaKOTest(){
        List<Linea_de_Proyecto__c> lps = [Select id,
        Nombre_SAP__c,
        Sede__c,
        Execution_SAP_Name__c,
        Oportunidad__r.Codigo_de_oportunidad__c 
        from Linea_de_Proyecto__c];
        SendEmailPepsEjecucion.generarPlantillaKO(lps[0],'Error al mandar el correo.');
    }
}