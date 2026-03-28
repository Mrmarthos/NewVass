/**jav 
* @description: Clase para hacer test sobre la sincronización
				de las DMLs de Linea_de_proyecto__c (trigger) del Batch_SincronizarLineasDeProyecto

**
* @Autor: gserrano (20/11/2018)
**
* @Modificacion: 
**
*/

@isTest
public class Test_SincronizacionesProyectLine 
{
	private static void test_scenario_DMLs() //afterUpdate
    {

        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        list<Account >Sedes=TestUtil.generaSedeTest();
        List<Linea_de_proyecto__c> lps= TestUtil.generaLineasLlaveManoTest(opps, conts);
		opps[1].Proyecto_Padre__c='233';
        opps[0].StageName = 'Solicitada'; 
        opps[1].StageName = 'Solicitada'; 
        opps[0].Mercado__c = 'Banca-Banca';
        opps[1].Mercado__c = 'Banca-Banca';
        opps[1].Sede_Venta__c=Sedes[0].id;
        opps[0].Sede_Venta__c=Sedes[0].id;
        update opps;
            Eppm__mdt config = new Eppm__mdt(
            DeveloperName = 'Eppm',
            Endpoint__c = 'https://test.endpoint.com',
            Username__c = 'testuser',
            Password__c = 'testpass'
        );


    }
    
    
    private static void test_scenario_Batch()
    {

        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        List<Linea_de_Proyecto__c> ls = TestUtil.generaLineasLlaveManoTest(opps, conts);
		system.debug('ls2222222222222'+ls);
        opps[0].StageName = 'Solicitada'; 
        opps[1].StageName = 'Solicitada'; 
        update opps;
        //HASTA este momento tenemos:
        //3 Cuentas (2 Externas 1 Interna)
        //3 Contactos (2 Ordinarios 1 Jefe de Proyecto)
        //2 Oportunidades del tipo Preventa con 2 hitos cada una, las dos en estado Solicitada
        //2 Lineas de Proyecto del tipo Llave en Mano y con el check listo para sincronizar = true
        opps[0].StageName = 'Preventa';
        opps[1].StageName = 'Preventa';
        
        //Al modificar la oportnida a preventa, se deberían enviar aquellas Lineas 
        //marcadas como válidas para preventa = true
        //El metodo encargado de realizar esta taréa es  OpportunityUtil.serializeAndSendProjectLinesPreventa()
        //TestUtil.generaLineasAMTest(opps, conts); 
        opps[0].StageName = 'Entregada';
        opps[1].StageName = 'Entregada';
  
        opps[0].StageName = 'Presentada';
        opps[1].StageName = 'Presentada';
   

        List<Linea_de_Proyecto__c> preventassincro = [ SELECT 
                                                       Id,
                                                       Oportunidad__r.Account.ID_SAP__c, 
                                                       Validado_para_Preventa__c,
                                                       Validado_para_Sincronizacion__c, 
                                                       Sincronizado_SAP_Preventa__c,
                                                       Sincronizado_SAP_Ejecucion__c,
                                                       Codigo_SAP_Preventa__c,
                                                       Codigo_SAP_Ejecucion__c,
                                                       Listo_para_sincronizar__c,
                                                       Gerencia__c,
                                                       Area__c,
                                                       Tecnologia__c,
                                                       Coste_estimado__c,
                                                       Fecha_Fin__c,
                                                       Fecha_Inicio__c,
                                                       Margen_bruto__c ,  
                                                       Responsable_de_LDP__c
                                                       FROM Linea_de_proyecto__c ];
        preventassincro[0].Sincronizado_SAP_Preventa__c = false; 
        preventassincro[1].Sincronizado_SAP_Preventa__c = false; 
        preventassincro[0].Codigo_SAP_Preventa__c = '2'; 
        preventassincro[1].Codigo_SAP_Preventa__c = '3'; 
       // update preventassincro;
        // opps[0].StageName = 'Ganada';
        // opps[1].StageName = 'Ganada';
        // update opps; 
                                            
    }

    /** 
	* @description: Pruebas a Batch_SincronizarCuentas
	**
	* @Autor: gserrano (20/11/2018)
	**
	* @Modificacion: 
	**
	*/

    @isTest
    static void testSincronizarLineasProyectoTrigger()
    {
        //TEST--------------------------------------------------------------------------------------
        
        

            //Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
        	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            test_scenario_DMLs();
			
        
        
        //TEST--------------------------------------------------------------------------------------
            Test.startTest();
        List<Linea_de_Proyecto__c> preventassincro = [ SELECT 
                                                       Id,
                                                       Oportunidad__r.Account.ID_SAP__c, 
                                                       Validado_para_Preventa__c,
                                                       Validado_para_Sincronizacion__c, 
                                                       Sincronizado_SAP_Preventa__c,
                                                       Sincronizado_SAP_Ejecucion__c,
                                                       Codigo_SAP_Preventa__c,
                                                       Codigo_SAP_Ejecucion__c,
                                                       Listo_para_sincronizar__c,
                                                       Gerencia__c,
                                                       Area__c,
                                                       Tecnologia__c,
                                                       Coste_estimado__c,
                                                       Fecha_Fin__c,
                                                       Fecha_Inicio__c,
                                                       Margen_bruto__c ,  
                                                       Responsable_de_LDP__c
                                                       FROM Linea_de_proyecto__c  ];
        
    
         Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
         ProjectLineUtil.serializeAndSendProjectLines(preventassincro, Constants.SAP_LPS_PREVENTA_PATH, null, false);
        
        
        Test.stopTest();
        //System.assertEquals(preventassincro.get(0).Sincronizado_SAP_Preventa__c, true);
        System.debug('-> '+preventassincro);

        //ASSERTS------------------------------------------------------------------------------------
        
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        
        //ASSERTS------------------------------------------------------------------------------------
    }
    
    /** 
	* @description: Pruebas a Batch_SincronizarCuentas
	**
	* @Autor: gserrano (20/11/2018)
	**
	* @Modificacion: 
	**
	*/
    
    
    @isTest
    static void testSincronizarLineasProyectoBatch()
    {
        //TEST--------------------------------------------------------------------------------------
               
        test_scenario_Batch();
        
        Test.startTest();

            //Si la creación de datos provocara que algún trigger realizara un Callout, esta línea debería ponerse antes 
        	//de la creación de los datos, lo cual no estaría permitido hacer en el @testSetup,
			//porque el @testSetup solo conserva el estado de la Database, no el Mock,
        	//por lo que el método encargado de crear los datos deberia ser static y llamarse en la línea siguiente al Test.setMock()
			        
            Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        	//La siguiente línea daria el error "You have uncommited work pending", 
        	//por eso ejecutamos el batch "por partes"
            
            //Database.executeBatch(new Batch_SincronizarCuentas());

            //Esta es la forma de testear un Batch que llame a un Callout desde un test

            Database.BatchableContext bc; 
            Batch_SincronizarLineasDeProyecto bClass = new Batch_SincronizarLineasDeProyecto();

            Database.QueryLocator queryLocator = bClass.start(bc); 

            Database.QueryLocatorIterator  iterator = queryLocator.iterator(); 

            List<sObject> aScopeList = new List<sObject> ();   

            while (iterator.hasNext()) 
            {
                aScopeList.add(iterator.next());
            }

            bClass.execute(bc, aScopeList);

            bClass.finish(bc);

        Test.stopTest();
        
        //TEST--------------------------------------------------------------------------------------
        
        List<Account> accs = [SELECT ID, Sincronizado_SAP__c FROM ACCOUNT];

        System.debug(accs);

        //ASSERTS------------------------------------------------------------------------------------

        //PITT DESCOMENTAR
        // System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);

        //ASSERTS------------------------------------------------------------------------------------
    }
    
    
    
    
        @isTest
    static void testSincronizarLineasProyectoEjecucion()
    {
        //TEST--------------------------------------------------------------------------------------
        
        

            //Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
        	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            test_scenario_DMLs();
		
        
        CodMercado__c setting = new CodMercado__c();
        setting.Name = 'Banca-Banca';
        setting.Codigo__c = '20';
        insert setting;
        
        
        //TEST--------------------------------------------------------------------------------------
            Test.startTest();
        List<Linea_de_Proyecto__c> preventassincro = [ SELECT
                                                        Id,
                                                        Codigo_SAP_Preventa__c,
                                                        Name,
                                                       Listo_para_sincronizar__c,
                                                  		Nombre_Tipo_Registro__c,
                                                        Nombre_SAP__c,
                                                       	Area__c,
                                                        Oficina_tecnica__c,
                                                        Fecha_Fin__c, 
                                                        Fecha_Inicio__c,
                                                        Gerencia__c,
                                                        Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                                        Margen_real__c,
                                                        Importe_total_2__c,
                                                        Responsable_de_LDP__r.EmployeeNumber,
                                                        Tecnologia__c,
                                                        Oportunidad__r.Proyecto_extraordinario__c,
                                                        Oportunidad__r.Codigo_de_oportunidad__c,
                                                 		Oportunidad__r.CreatedDate,
                                                        Oportunidad__r.Account.ID_SAP__c,
                                                 		Oportunidad__r.Margen_bruto__c,
                                                        Oportunidad__r.Owner.EmployeeNumber,
                                                        Oportunidad__r.Offering__r.EmployeeNumber,
                                                        Oportunidad__r.Offering__r.Profile.Id,
                                                        CreatedById,
                                                 		Fabricantes__c,
                                                        Sede__c,
                                                 		Coste_Bruto__c,
                                                 		Margen_Real_Economico__c,
                                                        Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c,
                                                        Oportunidad__r.mercado__c,
                                                        Comercial_Intercompany__r.EmployeeNumber,
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
                                                         Sin_Contrato__c,
                                                         Inducido__c,
                                                        CreatedBy.EmployeeNumber
                                                        FROM Linea_de_Proyecto__c ];
        
  
            Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
            CallSAPSincro.SendPreventa(preventassincro[0].id, true);
            log__c logtest= new log__c();
            logtest.Opportunity__c=preventassincro[0].oportunidad__c;
        	system.debug('oportunidad'+logtest.Opportunity__c);
            insert logtest;
            CallSAPSincro.SendPreventa(logtest.id, true);
            Test.stopTest();
        
        
        
        //System.assertEquals(preventassincro.get(0).Sincronizado_SAP_Preventa__c, true);
        System.debug('-> '+preventassincro);

        //ASSERTS------------------------------------------------------------------------------------
        
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        
        //ASSERTS------------------------------------------------------------------------------------
    }
    
            @isTest
    static void testEnvioCorreoEjecucion()
    {
        //TEST--------------------------------------------------------------------------------------
        
        

            //Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
        	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            test_scenario_DMLs();
		
        
        CodMercado__c setting = new CodMercado__c();
        setting.Name = 'Banca-Banca';
        setting.Codigo__c = '20';
        insert setting;
        
        
        //TEST--------------------------------------------------------------------------------------
            Test.startTest();
        List<Linea_de_Proyecto__c> preventassincro = [ SELECT
                                                        Codigo_SAP_Preventa__c,
                                                          Name,
                                                          Nombre_SAP__c,
                                                          tolabel(Area__c),
                                                          tolabel(Oficina_tecnica__c),
                                                          Fecha_Fin__c, 
                                                          Fecha_Inicio__c,
                                                        Execution_SAP_Name__c,
                                                          Gerencia__c,
                                                          RecordType.Name,
                                                          Oportunidad__r.Owner.Email,
                                                          Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                                          Margen_real__c,
                                                          Importe_total_2__c,
                                                          Responsable_de_LDP__r.EmployeeNumber,
                                                          Responsable_de_LDP__r.Name,
                                                          Tecnologia__c,
                                                          Oportunidad__r.Proyecto_Padre__c,
                                                          Oportunidad__r.Proyecto_extraordinario__c,
                                                          Oportunidad__r.Codigo_de_oportunidad__c,
                                                          Oportunidad__r.CreatedDate,
                                                          Oportunidad__r.Account.ID_SAP__c,
                                                          Oportunidad__r.Margen_bruto__c,
                                                          Oportunidad__r.Owner.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.Profile.Id,
                                                          CreatedById,
                                                          Fabricantes__c,
                                                          Sede__c,
                                                          Coste_Bruto__c,
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
                                                          Sin_Contrato__c,
                                                          ToLabel(Inducido__c),
                                                          CreatedBy.EmployeeNumber,
                                                          Jefe_Proyecto_Ejecucion_Adicional__r.name,
                                                          Jefe_de_Proyecto_de_Ejecucion__r.Name,
                                                          Oportunidad__r.Owner.Name,
                                                          Oportunidad__r.Account.Name,
                                                          Coste_real__c,
                                                          Importe_a_elevar__c
                                                        
                                                        FROM Linea_de_Proyecto__c ];
        
        	Hito_de_facturacion__c hito= new Hito_de_facturacion__c();
        hito.Linea_de_Proyecto__c= preventassincro[0].id;
        hito.Importe__c=300;
        hito.Fecha__c=date.newInstance(2019, 12, 01); 
        hito.Oportunidad__c=preventassincro[0].oportunidad__c;
        insert hito;
        
    	 Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());        
      	SendEmailPepsEjecucion.enviarCorreo(preventassincro[0]);
       // SendEmailPepsEjecucion.enviarCorreo(preventassincro[0],true,'error');
        
        Test.stopTest();
        //System.assertEquals(preventassincro.get(0).Sincronizado_SAP_Preventa__c, true);
        System.debug('-> '+preventassincro);

        //ASSERTS------------------------------------------------------------------------------------
        
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        
        //ASSERTS------------------------------------------------------------------------------------
    }
    
    
               @isTest
    static void testCallSapSincro()
    {
        //TEST--------------------------------------------------------------------------------------
        
        

            //Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
        	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            test_scenario_DMLs();
		
        
        CodMercado__c setting = new CodMercado__c();
        setting.Name = 'Banca-Banca';
        setting.Codigo__c = '20';
        insert setting;
        
        
        //TEST--------------------------------------------------------------------------------------
            Test.startTest();
        List<Linea_de_Proyecto__c> preventassincro = [ SELECT
                                                        Codigo_SAP_Preventa__c,
                                                          Name,
                                                          Nombre_SAP__c,
                                                          tolabel(Area__c),
                                                          tolabel(Oficina_tecnica__c),
                                                          Fecha_Fin__c, 
                                                          Fecha_Inicio__c,
                                                        Execution_SAP_Name__c,
                                                          Gerencia__c,
                                                          RecordType.Name,
                                                          Oportunidad__r.Owner.Email,
                                                          Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                                          Margen_real__c,
                                                          Importe_total_2__c,
                                                          Responsable_de_LDP__r.EmployeeNumber,
                                                          Responsable_de_LDP__r.Name,
                                                          Tecnologia__c,
                                                          Oportunidad__r.Proyecto_Padre__c,
                                                          Oportunidad__r.Proyecto_extraordinario__c,
                                                          Oportunidad__r.Codigo_de_oportunidad__c,
                                                          Oportunidad__r.CreatedDate,
                                                          Oportunidad__r.Account.ID_SAP__c,
                                                          Oportunidad__r.Margen_bruto__c,
                                                          Oportunidad__r.Owner.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.Profile.Id,
                                                          CreatedById,
                                                          Fabricantes__c,
                                                          Sede__c,
                                                          Coste_Bruto__c,
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
                                                          Sin_Contrato__c,
                                                          ToLabel(Inducido__c),
                                                          CreatedBy.EmployeeNumber,
                                                          Jefe_Proyecto_Ejecucion_Adicional__r.name,
                                                          Jefe_de_Proyecto_de_Ejecucion__r.Name,
                                                          Oportunidad__r.Owner.Name,
                                                          Oportunidad__r.Account.Name,
                                                          Coste_real__c,
                                                          Importe_a_elevar__c
                                                        
                                                        FROM Linea_de_Proyecto__c ];
        
        	Hito_de_facturacion__c hito= new Hito_de_facturacion__c();
        hito.Linea_de_Proyecto__c= preventassincro[0].id;
        hito.Importe__c=300;
        hito.Fecha__c=date.newInstance(2019, 12, 01); 
        hito.Oportunidad__c=preventassincro[0].oportunidad__c;
        insert hito;
        
    	Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());   
        String ide=preventassincro[0].id;
        Boolean var=true;
  		list<Linea_de_Proyecto__c> lista=preventassincro;
      	CallSAPSincro.SendCorreoForm(ide,lista, true);
        
           CallSAPSincro.sendall(ide);

       // SendEmailPepsEjecucion.enviarCorreo(preventassincro[0],true,'error');
        
        Test.stopTest();
        //System.assertEquals(preventassincro.get(0).Sincronizado_SAP_Preventa__c, true);
        System.debug('-> '+preventassincro);

        //ASSERTS------------------------------------------------------------------------------------
        
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        
        //ASSERTS------------------------------------------------------------------------------------
    }
    
                   @isTest
    static void testCallSapSincro2()
    {
        //TEST--------------------------------------------------------------------------------------
        
        

            //Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
        	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 

            test_scenario_DMLs();
		
        
        CodMercado__c setting = new CodMercado__c();
        setting.Name = 'Banca-Banca';
        setting.Codigo__c = '20';
        insert setting;
        
        
        //TEST--------------------------------------------------------------------------------------
            Test.startTest();
        List<Linea_de_Proyecto__c> preventassincro = [ SELECT
                                                        Codigo_SAP_Preventa__c,
                                                          Name,
                                                          Nombre_SAP__c,
                                                          tolabel(Area__c),
                                                          tolabel(Oficina_tecnica__c),
                                                          Fecha_Fin__c, 
                                                          Fecha_Inicio__c,
                                                        Execution_SAP_Name__c,
                                                          Gerencia__c,
                                                          RecordType.Name,
                                                          Oportunidad__r.Owner.Email,
                                                          Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                                          Margen_real__c,
                                                          Importe_total_2__c,
                                                          Responsable_de_LDP__r.EmployeeNumber,
                                                          Responsable_de_LDP__r.Name,
                                                          Tecnologia__c,
                                                          Oportunidad__r.Proyecto_Padre__c,
                                                          Oportunidad__r.Proyecto_extraordinario__c,
                                                          Oportunidad__r.Codigo_de_oportunidad__c,
                                                          Oportunidad__r.CreatedDate,
                                                          Oportunidad__r.Account.ID_SAP__c,
                                                          Oportunidad__r.Margen_bruto__c,
                                                          Oportunidad__r.Owner.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.Profile.Id,
                                                          CreatedById,
                                                          Fabricantes__c,
                                                          Sede__c,
                                                          Coste_Bruto__c,
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
                                                          Sin_Contrato__c,
                                                          ToLabel(Inducido__c),
                                                          CreatedBy.EmployeeNumber,
                                                          Jefe_Proyecto_Ejecucion_Adicional__r.name,
                                                          Jefe_de_Proyecto_de_Ejecucion__r.Name,
                                                          Oportunidad__r.Owner.Name,
                                                          Oportunidad__r.Account.Name,
                                                          Coste_real__c,
                                                          Importe_a_elevar__c
                                                        
                                                        FROM Linea_de_Proyecto__c ];
        
        Hito_de_facturacion__c hito= new Hito_de_facturacion__c();
        hito.Linea_de_Proyecto__c= preventassincro[0].id;
        hito.Importe__c=300;
        hito.Fecha__c=date.newInstance(2019, 12, 01); 
        hito.Oportunidad__c=preventassincro[0].oportunidad__c;
        insert hito;
        
    	Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());   
        String ide=preventassincro[0].id;
        Boolean var=true;
  		list<Linea_de_Proyecto__c> lista=preventassincro;
      	CallSAPSincro.SendPreventaOporFlow(lista);
        
        

       // SendEmailPepsEjecucion.enviarCorreo(preventassincro[0],true,'error');
        
        Test.stopTest();
        //System.assertEquals(preventassincro.get(0).Sincronizado_SAP_Preventa__c, true);
        System.debug('-> '+preventassincro);

        //ASSERTS------------------------------------------------------------------------------------
        
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        
        //ASSERTS------------------------------------------------------------------------------------
    }


    @isTest
    static void testCallSapSincroInterco()
    {
        //TEST--------------------------------------------------------------------------------------
        
        

            //Test.setMock(WebServiceMock.class, new WebServiceMockGenerator());         
        	//Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator()); 
          
            test_scenario_DMLs();
		
            Test.startTest();
        CodMercado__c setting = new CodMercado__c();
        setting.Name = 'Banca-Banca';
        setting.Codigo__c = '20';
        insert setting;
        
        list<Linea_de_Proyecto__c> lps =[select id from Linea_de_Proyecto__c];
        Linea_de_Proyecto__c  pl= new Linea_de_Proyecto__c();
        pl.id=lps[0].id;
        pl.PEP_Interco__c=lps[1].id;
        update pl;


        //TEST--------------------------------------------------------------------------------------
         
        List<Linea_de_Proyecto__c> preventassincro = [ SELECT
                                            Id,
                                            Codigo_SAP_Preventa__c,
                                            Name,
                                            Nombre_SAP__c,
                                            Area__c,
                                            Oficina_tecnica__c,
                                            Fecha_Fin__c, 
                                            Fecha_Inicio__c,
                                            Gerencia__c,
                                            Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                            Margen_real__c,
                                            Importe_total_2__c,
                                            Responsable_de_LDP__r.EmployeeNumber,
                                            Tecnologia__c,
                                            Oportunidad__r.Fecha_Inicio_Preventa__c,
                                            Oportunidad__r.Proyecto_extraordinario__c,
                                            Oportunidad__r.Codigo_de_oportunidad__c,
                                            Oportunidad__r.proyecto_Padre__c,
                                            Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c,
                                            Oportunidad__r.CreatedDate,
                                            EsIntercompany__c,
                                            Oportunidad__r.Account.ID_SAP__c,
                                            Oportunidad__r.Margen_bruto__c,
                                            Oportunidad__r.Owner.EmployeeNumber,
                                            Oportunidad__r.Offering__r.EmployeeNumber,
                                            Oportunidad__r.Offering__r.Profile.Id,
                                            Oportunidad__r.GPM__r.Codigo_de_empleado__c,
                                            CreatedById,
                                            Fabricantes__c,
                                            Importe_Total_Intercompany__c,
                                            Comercial_Intercompany__r.EmployeeNumber,
                                            Sede__c,
                                            Execution_SAP_Name__c,
                                            Coste_Bruto__c,
                                            Margen_Real_Economico__c,
                                            Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c,
                                            Oportunidad__r.mercado__c,
                                            Org_Ventas__c,
                                            Clase_PEP__c,
                                            Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c,
                                            Codigo_SAP_Ejecucion__c,
                                            Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c,
                                            oportunidad__r.cluster__c,
                                            CurrencyIsoCode,
                                            Venta_Extraordinaria__c,
                                            oportunidad__r.Proyecto_estrategico__c,
                                            Sin_Controlling__c,
                                            Ejecutado_en_cliente__c,
                                            Direccion_cliente__c,
                                            Clave_Periodificacion__c,
                                            Oportunidad__r.Sede_Venta__r.ID_SAP__c,
                                            PEP_Interco__r.Codigo_SAP_Ejecucion__c,
                                            Agile__c,
                                            Cambio_Alcance__c,
                                            Sin_Contrato__c,
                                            Importe_a_elevar__c,
                                            Inducido__c,
                                            Nombre_Pep_Espejo__c,
                                            Id_PepEspejo__c,
                                            CreatedBy.EmployeeNumber        
                                                        FROM Linea_de_Proyecto__c ];
        
        	Hito_de_facturacion__c hito= new Hito_de_facturacion__c();
        hito.Linea_de_Proyecto__c= preventassincro[0].id;
        hito.Importe__c=300;
        hito.Fecha__c=date.newInstance(2019, 12, 01); 
        hito.Oportunidad__c=preventassincro[0].oportunidad__c;
        insert hito;
        
    	Test.setMock(WebServiceMock.class, new WebMockEjecucion());   
         
        String ide=preventassincro[0].id;
        Boolean var=true;
  		list<Linea_de_Proyecto__c> lista=preventassincro;
      	CallSAPSincro.SendPreventaOporFlow(lista);
        
        

       // SendEmailPepsEjecucion.enviarCorreo(preventassincro[0],true,'error');
        
        Test.stopTest();
        //System.assertEquals(preventassincro.get(0).Sincronizado_SAP_Preventa__c, true);
        System.debug('-> '+preventassincro);

        //ASSERTS------------------------------------------------------------------------------------
        
        //System.assert(accs[0].Sincronizado_SAP__c == true);
        //System.assert(accs[1].Sincronizado_SAP__c == true);
        
        //ASSERTS------------------------------------------------------------------------------------
    }

        // TEST PARA EPPM_Service
    @isTest
    static void testServiceCheckChanges() {
         test_scenario_DMLs();
        Opportunity oldOpp = [SELECT Id,isclosed,StageName, N_Cargas_Excel__c FROM Opportunity LIMIT 1];
          Account Acc= [SELECT Id FROM Account LIMIT 1];
         Linea_de_Proyecto__c lp= [SELECT Id FROM Linea_de_Proyecto__c LIMIT 1];
        Acc.Name='T4S';
        acc.sede__c='1410';
        acc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_interna').getRecordTypeId();
        update acc;
        Opportunity newOpp= new Opportunity();
        newOpp.StageName = 'Identificada';
        newOpp.Sede_Venta__c=acc.id;
        newOpp.Amount=10;
        newopp.CloseDate=system.today();
        newopp.AccountId=acc.id;
        newopp.Name='test';
        newopp.Oficina_tecnica__c=null;
        insert newopp;
        string test2=[select GSO_Sede__c from Opportunity where id=:newOpp.id ].GSO_Sede__c;
        system.debug('GSO'+test2);
        
        
     Test.startTest();
        lp.oportunidad__c=newopp.id;
        lp.sede__c='1410';
        update lp;
        Hito_de_facturacion__c hito= new Hito_de_facturacion__c();
        hito.Linea_de_Proyecto__c= lp.id;
        hito.Importe__c=300;
        hito.Fecha__c=date.newInstance(2019, 12, 01); 
        hito.Oportunidad__c=lp.oportunidad__c;
        insert hito;
        newOpp.StageName = 'Solicitada';
       update newopp;
        Boolean result = EPPM_Service.checkChanges(oldOpp, newOpp);
        set<id> opportunityIds = new set<id>();
        opportunityIds.add(newopp.id);
        String payload = EPPM_PayloadBuilder.generatePayload(opportunityIds);
          Test.setMock(WebServiceMock.class, new WebMockEjecucion()); 
          EPPM_HTTPService.sendPayload(payload, opportunityIds);
  	 Test.stopTest();
    }
      // TEST PARA EPPM_HTTPService
    @isTest
    static void testHTTPCallout() { 
         test_scenario_DMLs();
        Test.setMock(WebServiceMock.class, new WebMockEjecucion()); 
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        EPPM_HTTPService.sendPayload('testPayload', new Set<Id>{opp.Id});
  	
             log__c logtest= new log__c();
        logtest.Opportunity__c=opp.id;
        insert logtest;
      
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(200, '<response>OK</response>');
       HttpResponse res = mock.respond(new HttpRequest());

       
         EPPM_HTTPService.handleResponse(res, logtest);
              Test.stopTest();
    }
     // TEST PARA EPPM_Selector
    @isTest
    static void testSelectorQueries() {
         test_scenario_DMLs();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        List<Opportunity> opps = EPPM_Selector.getOpportunitiesWithDetails(new Set<Id>{opp.Id});
        Map<Id, List<Hito_de_facturacion__c>> hitos = EPPM_Selector.getHitosPorLinea(new Set<Id>{opp.Id});
        
       
        Test.stopTest();
    }
        @IsTest
    static void testExtractErrorMessageMultipleDetails() {
        String jsonResponse = '{'+
            '"error": {'+
                '"code":"/IWBEP/CM_MGW_RT/022",'+
                '"message":{"@lang":"en","$":"Exception raised without specific error"},'+
                '"innererror": {'+
                    '"application": {},'+
                    '"transactionid":"b2844dbe11cb47428bca6298cae556ff",'+
                    '"timestamp":"",'+
                    '"Error_Resolution": {},'+
                    '"errordetails": {'+
                        '"errordetail": ['+
                            '{'+
                                '"ContentID":"",'+
                                '"code":"RPM_UTILITIES/000",'+
                                '"message":"Planning element OF/101073-001 already exists",'+
                                '"propertyref":"",'+
                                '"severity":"error",'+
                                '"target":"",'+
                                '"transition":"false"'+
                            '},{'+
                                '"ContentID":"",'+
                                '"code":"/IWBEP/CX_MGW_BUSI_EXCEPTION",'+
                                '"message":"Exception raised without specific error",'+
                                '"propertyref":"",'+
                                '"severity":"error",'+
                                '"target":"",'+
                                '"transition":"false"'+
                            '}'+
                        ']'+
                    '}'+
                '}'+
            '}'+
        '}';

        String result = EPPM_HTTPService.extractErrorMessage(jsonResponse);

        System.assertEquals('Planning element OF/101073-001 already exists; Exception raised without specific error', result);
    }

    @IsTest
    static void testExtractErrorMessageSingleDetail() {
        String jsonResponse = '{'+
            '"error": {'+
                '"innererror": {'+
                    '"errordetails": {'+
                        '"errordetail": {'+
                            '"message":"Single error message here"'+
                        '}'+
                    '}'+
                '}'+
            '}'+
        '}';

        String result = EPPM_HTTPService.extractErrorMessage(jsonResponse);
	
        System.assertEquals('Single error message here', result);
    }

    @IsTest
    static void testExtractErrorMessageNoErrorDetails() {
        String jsonResponse = '{'+
            '"error": {'+
                '"message":{"$":"Some error message"}'+
            '}'+
        '}';

        String result = EPPM_HTTPService.extractErrorMessage(jsonResponse);

        System.assertEquals(null, result);
    }

    @IsTest
    static void testExtractErrorMessageInvalidJson() {
        String invalidJson = 'Not a json string';

        String result = EPPM_HTTPService.extractErrorMessage(invalidJson);

        System.assertEquals(null, result);
    }
    
      @IsTest
    static void testhandlerespomnse() {
        String invalidJson = 'Not a json string';

        String result = EPPM_HTTPService.extractErrorMessage(invalidJson);

        System.assertEquals(null, result);
    }
    
    
    

  
    
}