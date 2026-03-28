@istest
public class Test_generacion_Hitos_Controller {
    	private static void test_scenario_DMLs() //afterUpdate
    {

        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        TestUtil.generaLineasLlaveManoTest(opps, conts);

        opps[0].StageName = 'Solicitada'; 
        opps[1].StageName = 'Solicitada'; 
        opps[0].Mercado__c = 'Banca-Banca';
        opps[1].Mercado__c = 'Banca-Banca';
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

        List<Account> cuentas = [SELECT Name, ID_SAP__c FROM Account];
        System.debug('Cuentas para TEST '+cuentas);
        System.assertEquals(Cuentas.get(0).ID_SAP__c, '1');
        System.assertEquals(Cuentas.get(1).ID_SAP__c, null);
        //SE habrán creado dos cuentas, la que contiene -ID_SAP distinto de null tiene una LP y será la que se enviará aSAP

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
        preventassincro[0].Fecha_Inicio__c = date.newInstance(2019, 12, 01); 
        preventassincro[1].Fecha_Inicio__c = date.newInstance(2019, 12, 01); 
       	

        opps[0].StageName = 'Ganada';
        opps[1].StageName = 'Ganada';
      

    }
    
              @isTest
    static void testEnvioCorreoEjecucion()
    {


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
        
    
	
        Generacion_Hitos_Controller.guardarHitos(preventassincro[0].oportunidad__c,	Generacion_Hitos_Controller.CalculateHitos(preventassincro[0].oportunidad__c,2));
        Generacion_Hitos_Controller.guardarHitos(preventassincro[0].id,	Generacion_Hitos_Controller.CalculateHitos(preventassincro[0].oportunidad__c,2));
        Generacion_Hitos_Controller.ActualizarHitosTabla(preventassincro[0].oportunidad__c,Generacion_Hitos_Controller.CalculateHitos(preventassincro[0].oportunidad__c,2),	Generacion_Hitos_Controller.CalculateHitos(preventassincro[0].oportunidad__c,2));
        system.assertequals([select id from Hito_de_facturacion__c where Linea_de_Proyecto__c=:preventassincro[0].id].size(),2);
    }

}