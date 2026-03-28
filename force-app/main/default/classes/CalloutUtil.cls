public class CalloutUtil {

  private static Map<String, String> dataMap = new Map<String,String>();
  public static boolean intercompanyFlag = true;

  public static void setResult(String nombreData,String data){
      dataMap.put(nombreData,data);
  }

  public static String getResult(String nombreData){
      return dataMap.get(nombreData);
}

    /**
     * Este método llama al siguiente pero de forma asíncrona porque se utiliza en un trigger
       El método no va a poder devolver la HttpResponse así su procesamiento tendrá q ser en el propio método,
       por lo tanto, para hacerlo genérico, le pasamos el tipo de objeto como argumento
     * @author: gserrano (2018/11/16)
     */
    @future(callout = true)
    public static void sendObjsToSAPFromTrigger(String serializedObjs, String path, String tipoObjeto) {
     
      sendObjsToSAP(serializedObjs, path, tipoObjeto, null);
    }

  	
    public static string sendObjsToSAPFromComponent(String serializedObjs, String path, String tipoObjeto,Boolean Ejecucion) {

     return SendPepEjecucion(serializedObjs, path, tipoObjeto,ejecucion);
    }
  

    /** 
     * Este método se encarga de realizar la llamada al WS (se utiliza en un batch)
     **
     * @author: gserrano (2018/11/16)
     */
    public static void sendObjsToSAP(String serializedObjs, String path, String tipoObjeto, Boolean posponer) {
      String METODO = 'CalloutUtil.sendOnjsToSAP ';
  
      try {
        if (tipoObjeto == 'Account') { 
            /*
          System.debug('ENVÍO DE CUENTAS');
          //Si se trata de cuentas, llamamos a las clases de ws de ClienteSAP
          List < Account > accs = (List < Account > ) JSON.deserialize(serializedObjs, List < Account > .class);
          List < Account > cuentas = new List < Account > ();
          List < Account > cuentasErroneas = new List < Account > ();
          ClienteSAP.zws_sincro_clientesbinding request = new ClienteSAP.zws_sincro_clientesbinding();
          List < ClienteSAP.ZsforSincroClienteResponse_element > response = new List < ClienteSAP.ZsforSincroClienteResponse_element > ();
          for (Account acc: accs) {
            String BillingAddress = '';
            String BillingCity = acc.BillingCity == null ? '' : String.valueOf(acc.BillingCity);
            String BillingCountry = acc.BillingCountryCode == null ? '' : String.valueOf(acc.BillingCountryCode);
            String BillingPostalCode = acc.BillingPostalCode == null ? '' : String.valueOf(acc.BillingPostalCode);
            String BillingStreet = acc.BillingStreet == null ? '' : String.valueOf(acc.BillingStreet);
            String Fax = acc.Fax == null ? '' : String.valueOf(acc.Fax);
            String IdSapC = acc.ID_SAP__C == null ? '' : String.valueOf(acc.ID_SAP__C);
            String IdSfor = acc.Id == null ? '' : String.valueOf(acc.Id);
            String Name = acc.Razon_Social__c == null ? '' : String.valueOf(acc.Razon_Social__c);
            String NameSearch = acc.Name == null ? '' : String.valueOf(acc.Name);
            String NifC = acc.NIF_CIF__c == null ? '' : String.valueOf(acc.NIF_CIF__c);
            String OwnerIdCod = acc.Owner.EmployeeNumber == null ? '' : String.valueOf(acc.Owner.EmployeeNumber);
            String ParentidIdSapC = acc.Parent.ID_SAP__c == null ? '' : String.valueOf(acc.Parent.ID_SAP__c);
            String Phone = acc.Phone == null ? '' : String.valueOf(acc.Phone);
            List < String > sectores = acc.Sectores__c == null ? null : acc.Sectores__c.split(';');
            String SectorC = sectores == null ? '' : Constants.SECTORESSAP.get(sectores.get(0));
            String MercadoC = sectores == null ? '' : Constants.MERCADOSSAP.get(sectores.get(0));
          
            response.add(request.ZsforSincroCliente(
              BillingAddress,
              BillingCity,
              BillingCountry,
              BillingPostalCode,
              BillingStreet,
              Fax,
              IdSapC,
              IdSfor,
              MercadoC,
              Name,
              NameSearch,
              NifC,
              OwnerIdCod,
              ParentidIdSapC,
              Phone,
              SectorC
            ));
          }

          if (response.size() > 0) {
            //comprobamos todas las respuestas del servicio
            for (ClienteSAP.ZsforSincroClienteResponse_element res: response) {
              //respuesta OK
              if (res.Retorno.equalsIgnoreCase('OK')) {
         
                cuentas.add(new Account(
                  ID = res.OIdSfor == null ? '' : res.OIdSfor,
                  ID_SAP__c = res.OIdSapC == null ? '' : res.OIdSapC,
                  Sincronizado_SAP__c = true
                ));
              } else {
                cuentasErroneas.add(new Account(
                  ID = res.OIdSfor == null ? '' : res.OIdSfor,
                  Sincronizado_SAP__c = false
                ));
                LogUtil.addLog(METODO, 'Account - error al enviar a SAP: ' + res.OIdSfor + ' -> Detalle: ' + res.MensajeNok);
              }
            }
  
          }
          if (cuentas.size() > 0) update cuentas;
          if (cuentasErroneas.size() > 0) update cuentasErroneas;
	*/
        } else if (tipoObjeto == 'Linea_de_Proyecto__c' ) {
  			system.debug('AQQQI');
          List < Linea_de_Proyecto__c > lps = (List < Linea_de_Proyecto__c > ) JSON.deserialize(serializedObjs, List < Linea_de_Proyecto__c > .class);
          List < Linea_de_Proyecto__c > lineas = new List < Linea_de_Proyecto__c > ();
          List < Linea_de_Proyecto__c > lineasErrorres = new List < Linea_de_Proyecto__c > ();
          PreventaSAP.crearpepbind request = new PreventaSAP.crearpepbind();
          PreventaSAP.ZSFOR_PEPS_PREVENTAResponse_element response;
          for (Linea_de_Proyecto__c lp: lps) {
  
            system.debug('IAccountIdSapC 	: ' + lp.Oportunidad__r.Account.ID_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Account.ID_SAP__c));
  
            String IAccountIdSapC = lp.Oportunidad__r.Account.ID_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Account.ID_SAP__c);
            String IAreaCebe = lp.Area__c == null ? '' : String.valueOf(lp.Area__c);
            String ICsapPreventa = lp.Codigo_SAP_Preventa__c == null ? '' : String.valueOf(lp.Codigo_SAP_Preventa__c);
            String IFechaFin = lp.Oportunidad__r.CreatedDate == null ? '' : String.valueOf(lp.Oportunidad__r.CreatedDate.addmonths(6).format('yyy-MM-dd'));
                String IFechaIni;
             if(lp.Oportunidad__r.Fecha_Inicio_Preventa__c!=null){
                   IFechaIni = String.valueOf(lp.Oportunidad__r.Fecha_Inicio_Preventa__c.format('yyy-MM-dd'));
                   IFechaFin=String.valueOf(lp.Oportunidad__r.Fecha_Inicio_Preventa__c.addmonths(6).format('yyy-MM-dd'));
             }else{ 
             IFechaIni = lp.Oportunidad__r.CreatedDate == null ? '' : String.valueOf(lp.Oportunidad__r.CreatedDate.format('yyy-MM-dd'));
             }
            
                String IIdSfor = lp.Id == null ? '' : String.valueOf(lp.Id);
            String IImporteTotalC = lp.Importe_total_2__c == null ? '' : ((Decimal) lp.Importe_total_2__c).toPlainString();
            String IJpPreventaC = lp.Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c == null ? '' : String.valueOf(lp.Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c);
            String IMargenRealC = lp.Margen_real__c == null ? '' : String.valueOf(lp.Margen_real__c);
            String IName = lp.Nombre_SAP__c == null ? '' : String.valueOf(lp.Nombre_SAP__c);
            String IOporCidSapC = ''; //lp.IOporCidSaps                                           == null ? '' : String.valueOf(lp.);
            String IOwnerIdCod = lp.Oportunidad__r.Owner.EmployeeNumber == null ? '' : String.valueOf(lp.Oportunidad__r.Owner.EmployeeNumber);
            String IProyEstra = '';
            String IGerenteC = lp.Responsable_de_LDP__r.EmployeeNumber == null ? '' : String.valueOf(lp.Responsable_de_LDP__r.EmployeeNumber);
            String ITecnoC = lp.Tecnologia__c == null ? '' : String.valueOf(lp.Tecnologia__c);
            String ICodOferta = lp.Oportunidad__r.Codigo_de_oportunidad__c == null ? '' : String.valueOf(lp.Oportunidad__r.Codigo_de_oportunidad__c);
            String IdOwner = lp.CreatedById == null ? '' : String.valueOf(lp.CreatedById);
            String Id = lp.Id == null ? '' : String.valueOf(lp.Id);
            String IJpPreventaAdicC = '';
            String IOficinaTec = lp.Oficina_tecnica__c == null ? '' : String.valueOf(lp.Oficina_tecnica__c);
            String Sede = lp.Sede__c == null ? '' : String.valueOf(lp.Sede__c);
            String OrgVentas = lp.Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c);
            String OrgVentasLinea = lp.Org_Ventas__c == null ? '' : String.valueOf(lp.Org_Ventas__c);
            String Sociedad = Sede;
            String Mercado = lp.Oportunidad__r.mercado__c == null ? '' : CodMercado__c.getinstance(lp.Oportunidad__r.mercado__c).Codigo__c;
            String ComercialVass = lp.Comercial_Intercompany__r.EmployeeNumber == null ? '' : String.valueOf(lp.Comercial_Intercompany__r.EmployeeNumber);
            String Fabricante = lp.Fabricantes__c;
  			  String cluster= lp.oportunidad__r.cluster__c==null ? '':  '1';
			
             
              
            if (lp.Oportunidad__r.Offering__r.Profile.Id == '00e0N000000i4KfQAI' || lp.Oportunidad__r.Offering__r.Profile.Id == '00e0N000000i4KcQAI') {
  
              IJpPreventaAdicC = lp.Oportunidad__r.Offering__r.EmployeeNumber == null ? '' : String.valueOf(lp.Oportunidad__r.Offering__r.EmployeeNumber);
            }
              
              system.debug('Seede ' +sede);
              system.debug('OrgVentas ' +OrgVentas);
               if(sede != OrgVentas){
           
                  IOwnerIdCod = lp.Comercial_Intercompany__r.EmployeeNumber== null ? lp.Oportunidad__r.Owner.EmployeeNumber : String.valueOf(lp.Comercial_Intercompany__r.EmployeeNumber);
                  IJpPreventaAdicC=null;
                 
              }  
  
            if (sede != OrgVentas) {
  
              list < Tabla_PEPS_LP__mdt > meta = [select id, Org_Ventas__c, Sede_venta__c from Tabla_PEPS_LP__mdt where MasterLabel =: OrgVentas];
              Sociedad = Sede;
  
              if (meta.size() != 0 && OrgVentasLinea == '') {
  
              OrgVentas = meta.get(0).Org_Ventas__c;
  
              } else {
                OrgVentas = OrgVentasLinea;
  
              }
  
            }
  
            if (OrgVentasLinea == '1120') {
              OrgVentas = '1120';
            }
              
              if (OrgVentasLinea == '1420') {
              OrgVentas = '1420';
            }
  
  
            if (sede == '1110') {
              if (IOficinaTec == '1110') {
                OrgVentas = '1110';
                IOficinaTec = '1110';
  
              } else if (IOficinaTec == '1120') {
  
                IOficinaTec = '1120';
              } else {
                IOficinaTec = '1000';
              }
  
            }
  
            if (sede == '1100') {
  
              OrgVentas = '1100';
  
              Sociedad = '1000';
  
            }
  
            if (sede == '1800') {
  
              OrgVentas = '1800';
  
              Sociedad = '1000';
  
            }
  
            if (sede == OrgVentas) {
  
              OrgVentas = sede;
  
            }
  
            if (OrgVentasLinea == '1120') {
              OrgVentas = '1120';
            }
            if( sede=='1410'){
             // IOwnerIdCod='6996';
          }
               if( sede=='1120'){
                    Sociedad='1110';
                }
  
            system.debug('COD_OFERTA 	: ' + lp.Oportunidad__r.Codigo_de_oportunidad__c == null ? '' : String.valueOf(lp.Oportunidad__r.Codigo_de_oportunidad__c));
            system.debug('--------------------------------------------');
            response = request.ZSFOR_PEPS_PREVENTA(
              IAccountIdSapC,
              IAreaCebe,
              ICodOferta,
              ComercialVass,
              ICsapPreventa,
              IFechaFin,
              IFechaIni,
              IGerenteC,
              OrgVentas,
              IIdSfor,
              IImporteTotalC,
              IJpPreventaAdicC,
              IJpPreventaC,
              IMargenRealC,
              Mercado,
              IName,
              IOficinaTec,
              IOporCidSapC,
              IOwnerIdCod,
              IProyEstra,
              Sociedad,
              ITecnoC,
              Fabricante,
                cluster
  
            );
  
            system.debug('--------------------------------------');
  
            if (response.Retorno.equalsIgnoreCase('OK')) {
              System.debug('RES Preventa ID: ' + response.O_ID_SFOR + ' --- Codigo_SAP_Preventa__c: ' + response.O_CSAP_PREVENTA);
              lineas.add(new Linea_de_Proyecto__c(
                ID = response.O_ID_SFOR == null ? '' : response.O_ID_SFOR,
                Codigo_SAP_Preventa__c = response.O_CSAP_PREVENTA == null ? '' : response.O_CSAP_PREVENTA,
                Sincronizado_SAP_Preventa__c = true
              ));
              System.debug(lineas);
            } else {
              lineasErrorres.add(new Linea_de_Proyecto__c(
                ID = response.O_ID_SFOR == null ? '' : response.O_ID_SFOR,
                Sincronizado_SAP_Preventa__c = false
              ));
              //LogUtil.addLog( METODO , 'PREVENTA - error al enviar a SAP: '+response.OIdSfor + ' -> Detalle: ' +response.MensajeNok ); 
              system.debug('Metodo---> ' + METODO);
              system.debug('LpID---->' + lp.Id);
              system.debug('Owner---->' + lp.CreatedById);
              system.debug('Error---->' + response.MENSAJE_NOK);
  
              LogUtil.addLog(METODO, Id, response.MENSAJE_NOK, IdOwner, null, null, IAreaCebe, null);
  
            }
  
            System.debug('RESPONSE Preventa: ' + response);
  
          }
          if (lineas.size() > 0) update lineas;
          if (lineasErrorres.size() > 0) update lineasErrorres;
        } 
      } catch (Exception ex) {
          system.debug('Error llamando a SAP');
       LogUtil.addLog(METODO, null, ex.getmessage(),  userinfo.getUserId(), null, null, null, null);
          
      } finally {
  		LogUtil.insertLog();
      }
    }
    
        
    public static string SendPepEjecucion (String serializedObjs, String path, String tipoObjeto,Boolean Ejecucion) {
   
        String METODO = 'CalloutUtil.sendOnjsToSAP ';
        List < Linea_de_Proyecto__c > lineas = new List < Linea_de_Proyecto__c > ();
        List < Opportunity > opors = new List < Opportunity > ();
        List < String > Responsemsg = new List < String > ();
        list<PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAINResponse_element> response = new list<PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAINResponse_element> () ;
        PepsEjecucionNewSAP.salesforce_binding request2 = new PepsEjecucionNewSAP.salesforce_binding();
        PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAINResponse_element response2;
        PepsEjecucionNewSAP.ZSFOR_PROYECTOS pr = new PepsEjecucionNewSAP.ZSFOR_PROYECTOS();
        PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T lsthitos = new PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T();

        try { 
            List < Linea_de_Proyecto__c > lps = (List < Linea_de_Proyecto__c > ) JSON.deserialize(serializedObjs, List < Linea_de_Proyecto__c > .class);
     
            List < Linea_de_Proyecto__c > lineasErrorres = new List < Linea_de_Proyecto__c > ();
            PreventaSAP.crearpepbind request = new PreventaSAP.crearpepbind();
            for (Linea_de_Proyecto__c lp: lps) {
                string printerco='';
                String IAccountIdSapC = lp.Oportunidad__r.Account.ID_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Account.ID_SAP__c);
                String IAreaCebe = lp.Area__c == null ? '' : String.valueOf(lp.Area__c);
                String ICsapPreventa = lp.Codigo_SAP_Preventa__c == null ? '' : String.valueOf(lp.Codigo_SAP_Preventa__c);
                String IFechaFin = lp.Fecha_Fin__c == null ? '' : String.valueOf(lp.Fecha_Fin__c);
                String IFechaIni = lp.Fecha_Inicio__c == null ? '' : String.valueOf(lp.Fecha_Inicio__c);
                String IIdSfor = lp.Id == null ? '' : String.valueOf(lp.Id);
                String IImporteTotalC = lp.Importe_total_2__c == null ? '' : ((Decimal) lp.Importe_total_2__c).toPlainString();
                String margen = lp.Margen_Real_Economico__c == null ? '' : ((Decimal) lp.Margen_Real_Economico__c).toPlainString();
                String coste = lp.Coste_Bruto__c == null ? '' : ((Decimal) lp.Coste_Bruto__c).toPlainString();
                String IJpEjecucionC = lp.Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c == null ? '' : String.valueOf(lp.Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c);
                String IMargenRealC = lp.Margen_real__c == null ? '' : String.valueOf(lp.Margen_real__c);
                String IName = lp.Execution_SAP_Name__c == null ? '' : String.valueOf(lp.Execution_SAP_Name__c);
                String IOporCidSapC = ''; //lp.IOporCidSaps                                           == null ? '' : String.valueOf(lp.);
                String IOwnerIdCod = lp.Oportunidad__r.Owner.EmployeeNumber == null ? '' : String.valueOf(lp.Oportunidad__r.Owner.EmployeeNumber);
                String IProyEstra = '';
                String IGerenteC = lp.Responsable_de_LDP__r.EmployeeNumber == null ? '' : String.valueOf(lp.Responsable_de_LDP__r.EmployeeNumber);
                String ITecnoC = lp.Tecnologia__c == null ? '' : String.valueOf(lp.Tecnologia__c);
                String ICodOferta = lp.Oportunidad__r.Codigo_de_oportunidad__c == null ? '' : String.valueOf(lp.Oportunidad__r.Codigo_de_oportunidad__c);
                String IdOwner = lp.CreatedById == null ? '' : String.valueOf(lp.CreatedById);
                String Id = lp.Id == null ? '' : String.valueOf(lp.Id);
                String IJpEjecucionAdicC =lp.Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c == null ? '' : String.valueOf(lp.Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c);
                String IOficinaTec = lp.Oficina_tecnica__c == null ? '' : String.valueOf(lp.Oficina_tecnica__c);
                String Sede = lp.Sede__c == null ? '' : String.valueOf(lp.Sede__c);
                String OrgVentas = lp.Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c);
                String OrgVentasLinea = lp.Org_Ventas__c == null ? '' : String.valueOf(lp.Org_Ventas__c);
                String Sociedad = Sede;
                String Mercado = lp.Oportunidad__r.mercado__c == null ? '' : CodMercado__c.getinstance(lp.Oportunidad__r.mercado__c).Codigo__c;
                String ComercialVass=lp.Oportunidad__r.Owner.EmployeeNumber;
                String Fabricante = lp.Fabricantes__c;
                String clasepep = lp.Clase_PEP__c;
                String CodigoEjecucion;    
                String Moneda =lp.CurrencyIsoCode; 
                String ventaExtra=lp.Venta_Extraordinaria__c ==true ? 'True': 'False';
                string estrategico=lp.oportunidad__r.Proyecto_estrategico__c ==true ? 'True': 'False';
                string sincontrolling= lp.Sin_Controlling__c ==true ? 'True': 'False';
                string checkCliente= lp.Ejecutado_en_cliente__c ==true ? 'True': 'False';
                string direccionCliente= lp.Direccion_cliente__c==null ? '':lp.Direccion_cliente__c;
                String gpm=lp.Oportunidad__r.GPM__r.Codigo_de_empleado__c ==null? '' :lp.Oportunidad__r.GPM__r.Codigo_de_empleado__c;
                string clave= lp.Clave_Periodificacion__c;
                string proyectoPadre;
                Boolean newpep= lp.oportunidad__r.New_Form_PEPS__c;
                string agile= lp.Agile__c ==true ? 'True': 'False';
                string alcance = lp.Cambio_Alcance__c ==true ? 'True': 'False';
                string contrato=lp.Sin_Contrato__c ==true ? 'True': 'False';
                string inducido=lp.Inducido__c ==null ? '': lp.Inducido__c;
                String cluster= lp.oportunidad__r.cluster__c==null ? '':  String.valueOf(lp.oportunidad__r.cluster__c);
				String sedeowner= lp.Oportunidad__r.owner.Sede__c==null ? '':  String.valueOf(lp.Oportunidad__r.owner.Sede__c);
                
                if(lp.Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c == null && lp.Oportunidad__r.Proyecto_Padre__c == null){
                      proyectoPadre='';
                }else if(lp.Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c != null){
                      proyectoPadre=lp.Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c;
                }else if(lp.Oportunidad__r.Proyecto_Padre__c != null){
                      proyectoPadre=lp.Oportunidad__r.Proyecto_Padre__c;
                }
                if(sede=='1100'){
                      sede='1000';
                }
            
                system.debug('Esinterco?'+lp.EsIntercompany__c);
                Printerco=null;
                if(lp.Id_PepEspejo__c!=null){
                Printerco=lp.Id_PepEspejo__c;
                IAccountIdSapC=lp.Oportunidad__r.Sede_Venta__r.ID_SAP__C;   
                }
                if(lp.EsIntercompany__c==true && Printerco==null){

                  Printerco=CalloutUtil.generarPEPEspejo(lp.PEP_Interco__c,String.valueOf(lp.Margen_Intercompany__c),String.valueOf(lp.Importe_Total_Intercompany__c),String.valueOf(lp.Coste_Estimado_Intercompany__c));
                  if(Printerco==null){
                    Responsemsg.add( 'Error during the creation of WBS Interco element, please contact Admin');
                    return null ;
                  }
                  IAccountIdSapC=lp.Oportunidad__r.Sede_Venta__r.ID_SAP__C;
                    
                    if(sede=='1410'){
                        IOwnerIdCod='6996';
                    } else if(sede=='1110'){
                        IOwnerIdCod='3506';
                    }else if(sede=='1210'){
                        IOwnerIdCod='3400';
                        
                    }else if(sede=='1000'){
                        IOwnerIdCod='1271';
                        
                    } 
              

           
               
                }

                if(clave=='ZTMWIP'){
                  IImporteTotalC='0';
                  coste='0';
                }
                
                
                if(sede!=sedeowner){  
                 if(sede=='1410'){
                        IOwnerIdCod='6996';
                    } else if(sede=='1110'){
                        IOwnerIdCod='3506';
                    }else if(sede=='1210'){
                        IOwnerIdCod='3400';
                        
                    }else if(sede=='1000'){
                        IOwnerIdCod='1271';
                        
                    } 
                }
                
                if( sede=='1120'){
                    sede='1110';
                }
                pr.PROYECTO_PADRE = proyectoPadre;
                pr.ID_PEP = CodigoEjecucion;
                pr.DESCRIPTION = IName;
                pr.GERENTE = IGerenteC;
                pr.GPM=gpm;
                pr.JP_PRINCIPAL = IJpEjecucionC;
                pr.SOLICITANTE = IAccountIdSapC;
                pr.COMERCIAL = IOwnerIdCod;
                pr.GESTOR_PROYECTO = IJpEjecucionAdicC;
                pr.SOCIEDAD = Sede;
                pr.MONEDA = Moneda;
                pr.FECHA_INI = IFechaIni;
                pr.FECHA_FIN = IFechaFin;
                pr.COD_OFERTA =ICodOferta ;
                pr.PRACTICA = ITecnoC;
                pr.FABRICANTE = Fabricante;
                pr.VTA_EXTRA = ventaExtra; //venta extra??
                pr.PEP_ESTRATEGICO = estrategico;
                pr.SIN_CONTROLLING = sincontrolling;
                pr.CHECK_CLIENTE = checkCliente; //si se va ejecutar en cliente??
                pr.DIRECCION_CLIENTE =direccionCliente; //direccion??
                pr.ORG_VENTAS = OrgVentasLinea;
                pr.MERCADO = Mercado;
                pr.OFICINA_TECNICA = IOficinaTec;
                pr.ID_SFOR = Id;
                pr.CLASE_PEP = clasepep;
                pr.CLAVE_PERIODIFICACION = clave;
                pr.AREA_CEBE = IAreaCebe;
                pr.IMPORTE_TOTAL_C = IImporteTotalC;
                pr.AGILE=agile;
                pr.ALCANCE=alcance;
                pr.SIN_CONTRATO= contrato;
                pr.INDUCIDO= inducido;
                pr.MARGEN_TEORICO=margen;
                pr.COSTE_BRUTO= coste;
                pr.CLUSTER=cluster;
                pr.FACTURA_CLIENTE='';
                pr.CONTRATO_ESPECIFICO='';
                pr.CONTROL_HORAS='';
                pr.ZWBS_REL_INTERCO=Printerco;
                pr.COMERCIAL_VASS=ComercialVass;

                

                system.debug('pr.PROYECTO_PADRE: ' +pr.PROYECTO_PADRE);
                system.debug(' pr.ID_PEP: ' +   pr.ID_PEP );
                system.debug('pr.DESCRIPTION: ' +pr.DESCRIPTION);
                system.debug('pr.GERENTE: ' +pr.GERENTE);
                system.debug('pr.JP_PRINCIPAL--: ' +pr.JP_PRINCIPAL);
                system.debug('pr.SOLICITANTE: ' +pr.SOLICITANTE);
                system.debug('pr.COMERCIAL: ' +pr.COMERCIAL);
                system.debug('pr.GESTOR_PROYECTO: ' +pr.GESTOR_PROYECTO);
                system.debug('pr.COMERCIAL_VASS: ' +pr.COMERCIAL_VASS);
                system.debug('pr.SOCIEDAD: ' +pr.SOCIEDAD);
                system.debug('pr.MONEDA: ' +pr.MONEDA);
                system.debug('pr.FECHA_INI: ' +pr.FECHA_INI);
                system.debug('pr.FECHA_FIN: ' +pr.FECHA_FIN);
                system.debug('pr.COD_OFERTA: ' +pr.COD_OFERTA);
                system.debug('pr.PRACTICA: ' +pr.PRACTICA);
                system.debug('pr.FABRICANTE: ' +pr.FABRICANTE);
                system.debug('pr.VTA_EXTRA: ' +pr.VTA_EXTRA);
                system.debug('pr.PEP_ESTRATEGICO: ' +pr.PEP_ESTRATEGICO);
                system.debug('pr.SIN_CONTROLLING: ' +pr.SIN_CONTROLLING);
                system.debug('pr.CHECK_CLIENTE: ' +pr.CHECK_CLIENTE);
                system.debug('pr.DIRECCION_CLIENTE: ' +pr.DIRECCION_CLIENTE);
                system.debug('pr.ORG_VENTAS: ' +pr.ORG_VENTAS);
                system.debug('pr.MERCADO: ' +pr.MERCADO);
                system.debug('pr.OFICINA_TECNICA: ' +pr.OFICINA_TECNICA);
                system.debug('pr.ID_SFOR: ' +pr.ID_SFOR);
                system.debug('pr.CLASE_PEP: ' +pr.CLASE_PEP);
                system.debug('pr.CLAVE_PERIODIFICACION: ' +pr.CLAVE_PERIODIFICACION);
                system.debug('pr.AREA_CEBE: ' +pr.AREA_CEBE);
                system.debug('pr.IMPORTE_TOTAL_C: ' +pr.IMPORTE_TOTAL_C);
                system.debug('pr.AGILE: ' +pr.AGILE);
                system.debug('pr.ALCANCE: ' +pr.ALCANCE);
                system.debug('pr.SIN_CONTRATO: ' +pr.SIN_CONTRATO);
                system.debug('pr.INDUCIDO: ' +pr.INDUCIDO);
                system.debug('pr.MARGEN: ' +pr.MARGEN_TEORICO);
                system.debug('pr.COSTE: ' +pr.COSTE_BRUTO);
                system.debug('pr.Cluster: ' +pr.Cluster);
                system.debug('pr.GPM' +pr.GPM);
                system.debug('pr.ZWBS_REL_INTERCO' +pr.ZWBS_REL_INTERCO);
                system.debug('ppr.FACTURA_CLIENTE' +pr.FACTURA_CLIENTE);
                system.debug('pr.CONTRATO_ESPECIFICO' +pr.CONTRATO_ESPECIFICO);
                system.debug('pr' + JSON.serialize(pr) );

                list < Hito_de_facturacion__c > hitosLP = [Select Descripcion__c, Fecha__c, Importe__c from Hito_de_facturacion__c where Linea_de_Proyecto__c =: id];

                pr.IMPORTE_TOTAL_C=String.valueof(CalloutUtil.sumadeimporte(hitosLP));
                if(clasepep=='ZM' || clasepep=='ZC' ){
                   pr.IMPORTE_TOTAL_C= IImporteTotalC;
                }
               
                if(label.SwitchPepEje=='True'){
             
                    if(request2!=null){
                      system.debug('NEW PEP'+newpep);
                        if(newpep==true){             
                          response2 = request2.ZSFOR_PROJECT_MAINTAIN('1',CalloutUtil.generarhitos(hitosLP), pr);
                        }else{
                          response2 = request2.ZSFOR_PROJECT_MAINTAIN('1',CalloutUtil.generarhitos(hitosLP), pr);
                        }

                    }
              
                }
                system.debug('Respuesta antes de   ---->'+request2);
                system.debug('Resultado-------------> '+response2.E_RESULTADO);
                if(response2.E_RESULTADO!=''){
                  string error;
                    for( PepsEjecucionNewSAP.BAPI_METH_MESSAGE msg : response2.ET_LOG_ERRORES.item ){
                      error=msg.MESSAGE_TEXT +';';
                        system.debug('ERROR:'+error);
                    }
                    
                    LogUtil.addLog('PepsEjecucion', Id, error, IdOwner, null, null, IAreaCebe, null);         
                    Responsemsg.add( response2.E_RESULTADO);
                    
                    Linea_de_Proyecto__c LPactu = new Linea_de_Proyecto__c();
                      if(lp.PEP_Interco__c!=null){
                      Linea_de_Proyecto__c LPactu2 = new Linea_de_Proyecto__c();
                      LPactu2.id=lp.PEP_Interco__c;
                      LPactu2.Id_PepEspejo__c=pr.ZWBS_REL_INTERCO;
                      lineas.add(LPactu2);
                    }
                    
                }else {
                    Linea_de_Proyecto__c LPactu = new Linea_de_Proyecto__c();
                   
                    system.debug('Respuesta Servicio -----------'+response2);
                    system.debug('Codigo Ejecucion SAP------------'+response2.E_WBS_ELEMENT);
         
                    LPactu.id=lp.id;
                    LPactu.Codigo_SAP_Ejecucion__c=response2.E_WBS_ELEMENT;
                    lpactu.Sincronizado_SAP_Ejecucion__c=true;
                    if(lp.PEP_Interco__c!=null){
                      Linea_de_Proyecto__c LPactu2 = new Linea_de_Proyecto__c();
                      LPactu2.id=lp.PEP_Interco__c;
                      LPactu2.Id_PepEspejo__c=pr.ZWBS_REL_INTERCO;
                      lineas.add(LPactu2);
                    }
                 
                    lineas.add(LPactu);
                   


                    Opportunity op = new Opportunity ();
                    op.id=lps.get(0).oportunidad__c;
                    op.Proyecto_Padre__c=response2.E_PROYECTO_PADRE;
                    op.Sincronizado_SAP__c=true;
                    if(opors.size()==0){
                          opors.add(op);
                    }
                  
                	  Responsemsg.add ('La línea:' + lp.name + 'se ha sincronizado correctamente con id:' + response2.E_WBS_ELEMENT+'/n');

                }
                
            }
            } catch (Exception ex) {
                system.debug('Error llamando a SAP'+ex.getmessage());
                LogUtil.addLog(METODO, null,  ex.getmessage(), userinfo.getUserId(), null, null, null, null);
                logUtil.insertLog();
                return 'No se ha podido sincronizar con SAP:' + ex.getmessage();
            }

            logUtil.insertLog();
            update lineas;
            update opors;

          
            system.debug('String.valueof(Responsemsg) ---> '+String.valueof(Responsemsg));
            return String.valueof(Responsemsg);

        }

  public static PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T   generarhitos(list < Hito_de_facturacion__c > hitosLP){

    PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T lsthitos = new PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T();
    lsthitos.item = NEW list < PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION > ();
              
                for (Hito_de_facturacion__c h: hitosLP) {
                    
                  PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION hito = new PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION();
                    hito.DESCRIPCION = h.Descripcion__c;
                    hito.FECHA_HITO = String.valueof(h.Fecha__c);
                    hito.IMPORTE = String.valueof(h.Importe__c.setScale(2));
                    lsthitos.item.add(hito);
                    
                }
        return lsthitos;
      }


      public static PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T   generarhitosEspejo(string Importe, Date Fecha){

        PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T lsthitos = new PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION_T();
        lsthitos.item = NEW list < PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION > ();
                  
         PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION hito = new PepsEjecucionNewSAP.ZPS_PLAN_FACTURACION();
                        hito.DESCRIPCION = 'Hito 1';
                        hito.FECHA_HITO = String.valueof(Fecha);
                        hito.IMPORTE = Importe;
                        lsthitos.item.add(hito);
             
            return lsthitos;
          }

  public static decimal sumadeimporte( list < Hito_de_facturacion__c > hitosLP){

    Double ImporteSumado=0;
    for (Hito_de_facturacion__c h: hitosLP) {
                    
      ImporteSumado=ImporteSumado+h.Importe__c.setScale(2);
        
    }

    return ImporteSumado;
  }


    public static string generarPEPEspejo(String IdentificadorInterco,String margeninterco,String importeInterco,string costeInterco )
    {
      PepsEjecucionNewSAP.ZSFOR_PROYECTOS prespejo = new PepsEjecucionNewSAP.ZSFOR_PROYECTOS();
      PepsEjecucionNewSAP.salesforce_binding requestespejo = new PepsEjecucionNewSAP.salesforce_binding();
        PepsEjecucionNewSAP.ZSFOR_PROJECT_MAINTAINResponse_element responseespejo;
      
        List<Linea_de_Proyecto__c> LpPadre = [SELECT
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
                  FROM Linea_de_Proyecto__c
                  WHERE Id  =:IdentificadorInterco];

      String serializedObjs;
      serializedObjs = JSON.serialize(LpPadre);
      List < Linea_de_Proyecto__c > lps = (List < Linea_de_Proyecto__c > ) JSON.deserialize(serializedObjs, List < Linea_de_Proyecto__c > .class);
   if(lps!=null){
      Linea_de_Proyecto__c lp=lps.get(0);
                  string printerco='';
                  String IAccountIdSapC = lp.Oportunidad__r.Account.ID_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Account.ID_SAP__c);
                  String IAreaCebe = lp.Area__c == null ? '' : String.valueOf(lp.Area__c);
                  String ICsapPreventa = lp.Codigo_SAP_Preventa__c == null ? '' : String.valueOf(lp.Codigo_SAP_Preventa__c);
                  String IFechaFin = lp.Fecha_Fin__c == null ? '' : String.valueOf(lp.Fecha_Fin__c);
                  String IFechaIni = lp.Fecha_Inicio__c == null ? '' : String.valueOf(lp.Fecha_Inicio__c);
                  String IIdSfor = lp.Id == null ? '' : String.valueOf(lp.Id);
                  String IImporteTotalC = importeInterco;
                  String margen = margeninterco;
                  String coste = costeInterco;
                  String IJpEjecucionC = lp.Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c == null ? '' : String.valueOf(lp.Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c);
                  String IMargenRealC = lp.Margen_real__c == null ? '' : String.valueOf(lp.Margen_real__c);
                  String IName = lp.Execution_SAP_Name__c == null ? '' : String.valueOf(lp.Execution_SAP_Name__c);
                  String IOporCidSapC = ''; //lp.IOporCidSaps                                           == null ? '' : String.valueOf(lp.);
                  String IOwnerIdCod = lp.Oportunidad__r.Owner.EmployeeNumber == null ? '' : String.valueOf(lp.Oportunidad__r.Owner.EmployeeNumber);
                  String IProyEstra = '';
                  String IGerenteC = lp.Responsable_de_LDP__r.EmployeeNumber == null ? '' : String.valueOf(lp.Responsable_de_LDP__r.EmployeeNumber);
                  String ITecnoC = lp.Tecnologia__c == null ? '' : String.valueOf(lp.Tecnologia__c);
                  String ICodOferta = lp.Oportunidad__r.Codigo_de_oportunidad__c == null ? '' : String.valueOf(lp.Oportunidad__r.Codigo_de_oportunidad__c);
                  String IdOwner = lp.CreatedById == null ? '' : String.valueOf(lp.CreatedById);
                  String Id = lp.Id == null ? '' : String.valueOf(lp.Id);
                  String IJpEjecucionAdicC =lp.Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c == null ? '' : String.valueOf(lp.Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c);
                  String IOficinaTec = lp.Oficina_tecnica__c == null ? '' : String.valueOf(lp.Oficina_tecnica__c);
                  String Sede = lp.Sede__c == null ? '' : String.valueOf(lp.Sede__c);
                  String OrgVentas = lp.Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c == null ? '' : String.valueOf(lp.Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c);
                  String OrgVentasLinea = lp.Org_Ventas__c == null ? '' : String.valueOf(lp.Org_Ventas__c);
                  String Sociedad = Sede;
                  String Mercado = lp.Oportunidad__r.mercado__c == null ? '' : CodMercado__c.getinstance(lp.Oportunidad__r.mercado__c).Codigo__c;
                  String ComercialVass=IOwnerIdCod;
                  String Fabricante = lp.Fabricantes__c;
                  String clasepep = lp.Clase_PEP__c;
                  String CodigoEjecucion;
                  String Moneda =lp.CurrencyIsoCode;
                  String ventaExtra=lp.Venta_Extraordinaria__c ==true ? 'True': 'False';
                  string estrategico=lp.oportunidad__r.Proyecto_estrategico__c ==true ? 'True': 'False';
                  string sincontrolling= lp.Sin_Controlling__c ==true ? 'True': 'False';
                  string checkCliente= lp.Ejecutado_en_cliente__c ==true ? 'True': 'False';
                  string direccionCliente= lp.Direccion_cliente__c==null ? '':lp.Direccion_cliente__c;
                  String gpm=lp.Oportunidad__r.GPM__r.Codigo_de_empleado__c ==null? '' :lp.Oportunidad__r.GPM__r.Codigo_de_empleado__c;
                  string clave= lp.Clave_Periodificacion__c;
                  string proyectoPadre;
                  string agile= lp.Agile__c ==true ? 'True': 'False';
                  string alcance = lp.Cambio_Alcance__c ==true ? 'True': 'False';
                  string contrato=lp.Sin_Contrato__c ==true ? 'True': 'False';
                  string inducido=lp.Inducido__c ==null ? '': lp.Inducido__c;
                  String cluster= lp.oportunidad__r.cluster__c==null ? '':  String.valueOf(lp.oportunidad__r.cluster__c);
                  String idpep=lp.Id_PepEspejo__c==null ?'':  lp.Id_PepEspejo__c;
                  if(lp.Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c == null && lp.Oportunidad__r.Proyecto_Padre__c == null){
                    proyectoPadre='';
                  }else if(lp.Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c != null){
                    proyectoPadre=lp.Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c;
                  }else if(lp.Oportunidad__r.Proyecto_Padre__c != null){
                    proyectoPadre=lp.Oportunidad__r.Proyecto_Padre__c;
                  }


                prespejo.PROYECTO_PADRE = proyectoPadre;
                prespejo.ID_PEP = idpep;
                prespejo.DESCRIPTION = lp.Nombre_Pep_Espejo__c;
                prespejo.GERENTE = IGerenteC;
                prespejo.GPM=gpm;
                prespejo.JP_PRINCIPAL = IJpEjecucionC;
                prespejo.SOLICITANTE = IAccountIdSapC;
                prespejo.COMERCIAL = IOwnerIdCod;
                prespejo.GESTOR_PROYECTO = IJpEjecucionAdicC;
                prespejo.SOCIEDAD = Sede;
                prespejo.MONEDA = Moneda;
                prespejo.FECHA_INI = IFechaIni;
                prespejo.FECHA_FIN = IFechaFin;
                prespejo.COD_OFERTA =ICodOferta ;
                prespejo.PRACTICA = ITecnoC;
                prespejo.FABRICANTE = Fabricante;
                prespejo.VTA_EXTRA = ventaExtra; //venta extra??
                prespejo.PEP_ESTRATEGICO = estrategico;
                prespejo.SIN_CONTROLLING = sincontrolling;
                prespejo.CHECK_CLIENTE = checkCliente; //si se va ejecutar en cliente??
                prespejo.DIRECCION_CLIENTE =direccionCliente; //direccion??
                prespejo.ORG_VENTAS = OrgVentasLinea;
                prespejo.MERCADO = Mercado;
                prespejo.OFICINA_TECNICA = IOficinaTec;
                prespejo.ID_SFOR = lp.name;
                prespejo.CLASE_PEP = clasepep;
                prespejo.CLAVE_PERIODIFICACION = clave;
                prespejo.AREA_CEBE = IAreaCebe;
                prespejo.IMPORTE_TOTAL_C = IImporteTotalC;
                prespejo.AGILE=agile;
                prespejo.ALCANCE=alcance;
                prespejo.SIN_CONTRATO= contrato;
                prespejo.INDUCIDO= inducido;
                prespejo.MARGEN_TEORICO=margen;
                prespejo.COSTE_BRUTO= coste;
                prespejo.CLUSTER=cluster;
                prespejo.FACTURA_CLIENTE='';
                prespejo.CONTRATO_ESPECIFICO='';
                prespejo.CONTROL_HORAS='';
                prespejo.ZWBS_REL_INTERCO='';
                prespejo.COMERCIAL_VASS=ComercialVass;

                if(clave=='ZTMWIP'){
                  IImporteTotalC='0';
                  coste='0';
                }
                

                system.debug('prespejo.PROYECTO_PADRE: ' +prespejo.PROYECTO_PADRE);
                system.debug('prespejo.ID_PEP: ' +   prespejo.ID_PEP );
                system.debug('prespejo.DESCRIPTION: ' +prespejo.DESCRIPTION);
                system.debug('prespejo.GERENTE: ' +prespejo.GERENTE);
                system.debug('prespejo.JP_PRINCIPAL--: ' +prespejo.JP_PRINCIPAL);
                system.debug('prespejo.SOLICITANTE: ' +prespejo.SOLICITANTE);
                system.debug('prespejo.COMERCIAL: ' +prespejo.COMERCIAL);
                system.debug('prespejo.GESTOR_PROYECTO: ' +prespejo.GESTOR_PROYECTO);
                system.debug('prespejo.COMERCIAL_VASS: ' +prespejo.COMERCIAL_VASS);
                system.debug('prespejo.SOCIEDAD: ' +prespejo.SOCIEDAD);
                system.debug('prespejo.MONEDA: ' +prespejo.MONEDA);
                system.debug('prespejo.FECHA_INI: ' +prespejo.FECHA_INI);
                system.debug('prespejo.FECHA_FIN: ' +prespejo.FECHA_FIN);
                system.debug('prespejo.COD_OFERTA: ' +prespejo.COD_OFERTA);
                system.debug('prespejo.PRACTICA: ' +prespejo.PRACTICA);
                system.debug('prespejo.FABRICANTE: ' +prespejo.FABRICANTE);
                system.debug('prespejo.VTA_EXTRA: ' +prespejo.VTA_EXTRA);
                system.debug('prespejo.PEP_ESTRATEGICO: ' +prespejo.PEP_ESTRATEGICO);
                system.debug('prespejo.SIN_CONTROLLING: ' +prespejo.SIN_CONTROLLING);
                system.debug('prespejo.CHECK_CLIENTE: ' +prespejo.CHECK_CLIENTE);
                system.debug('prespejo.DIRECCION_CLIENTE: ' +prespejo.DIRECCION_CLIENTE);
                system.debug('prespejo.ORG_VENTAS: ' +prespejo.ORG_VENTAS);
                system.debug('prespejo.MERCADO: ' +prespejo.MERCADO);
                system.debug('prespejo.OFICINA_TECNICA: ' +prespejo.OFICINA_TECNICA);
                system.debug('prespejo.ID_SFOR: ' +prespejo.ID_SFOR);
                system.debug('prespejo.CLASE_PEP: ' +prespejo.CLASE_PEP);
                system.debug('prespejo.CLAVE_PERIODIFICACION: ' +prespejo.CLAVE_PERIODIFICACION);
                system.debug('prespejo.AREA_CEBE: ' +prespejo.AREA_CEBE);
                system.debug('prespejo.IMPORTE_TOTAL_C: ' +prespejo.IMPORTE_TOTAL_C);
                system.debug('prespejo.AGILE: ' +prespejo.AGILE);
                system.debug('prespejo.ALCANCE: ' +prespejo.ALCANCE);
                system.debug('prespejo.SIN_CONTRATO: ' +prespejo.SIN_CONTRATO);
                system.debug('prespejo.INDUCIDO: ' +prespejo.INDUCIDO);
                system.debug('prespejo.MARGEN: ' +prespejo.MARGEN_TEORICO);
                system.debug('prespejo.COSTE: ' +prespejo.COSTE_BRUTO);
                system.debug('prespejo.Cluster: ' +prespejo.Cluster);
                system.debug('prespejo.GPM' +prespejo.GPM);
                system.debug('prespejo.ZWBS_REL_INTERCO' +prespejo.ZWBS_REL_INTERCO);
                system.debug('prespejo.FACTURA_CLIENTE' +prespejo.FACTURA_CLIENTE);
                system.debug('prespejo.CONTRATO_ESPECIFICO' +prespejo.CONTRATO_ESPECIFICO);
                system.debug('prespejo' + JSON.serialize(prespejo) );
                if(label.SwitchPepEje=='True'){

                            responseespejo = requestespejo.ZSFOR_PROJECT_MAINTAIN('1',CalloutUtil.generarhitosEspejo(importeInterco,lp.Fecha_Fin__c), prespejo);
                    system.debug('EN TESTTT' +responseespejo );
                            if(responseespejo.E_RESULTADO!=''){
                              string error;
                                for( PepsEjecucionNewSAP.BAPI_METH_MESSAGE msg : responseespejo.ET_LOG_ERRORES.item ){
                                  error=msg.MESSAGE_TEXT +';';
                                    system.debug('ERROR:'+error);
                                }
                                
                                LogUtil.addLog('PepsEjecucion', Id, error, IdOwner, null, null, IAreaCebe, null);         
                                
                            }else {
                                Linea_de_Proyecto__c LPactu = new Linea_de_Proyecto__c();
                                
                                system.debug('Respuesta Servicio -----------'+responseespejo);
                                system.debug('Codigo Ejecucion SAP ESPEJO------------'+responseespejo.E_WBS_ELEMENT);

                          
                              
                                return responseespejo.E_WBS_ELEMENT;

                            }

              }
      }

    return null;  
      }
  
    }