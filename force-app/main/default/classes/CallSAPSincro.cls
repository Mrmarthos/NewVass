public with sharing class CallSAPSincro {

       @AuraEnabled
     public static string  SendPreventa(id Identificador,boolean ejecucion)
    {
        
            if (Identificador.getSObjectType() == Log__c.SObjectType ||Identificador.getSObjectType() == Opportunity.SObjectType  ) {
                // Llamar a test() si es un Log__c
                Log__c logRecord = null;
                Id oppid=null;
                if (Identificador.getSObjectType() == Log__c.SObjectType){                
                     logRecord = [SELECT Opportunity__c FROM Log__c WHERE Id = :Identificador LIMIT 1];
                    oppid=logRecord.Opportunity__c;
        
                }else{
                    oppid=Identificador;
                }
                
                if(oppid != null) {
                    Opportunity opp =null;
                    // 2. Obtener datos completos de la oportunidad
  List<Opportunity> oppList = [SELECT Id, Name, StageName, CloseDate 
                                 FROM Opportunity 
                                 WHERE Id = :oppid 
                                 LIMIT 1];
                    if (!oppList.isEmpty()) {
                         opp = oppList[0];
                    
                    // 3. Generar payload usando el Set<Id> requerido
                    Set<Id> opportunityIds = new Set<Id>{opp.Id};
                        String payload = EPPM_PayloadBuilder.generatePayload(opportunityIds);
                    
                    // 4. Enviar usando el ID de oportunidad
                    EPPM_HTTPService.sendPayload(payload, opportunityIds);
                    
                    return 'Proceso completado para Opportunity: ' + opp.Name;
                }
                }
            }else{
        
         List<Linea_de_Proyecto__c> preventas = [SELECT
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
                                                        PEP_Interco__c,
                                                        Responsable_de_LDP__r.EmployeeNumber,
                                                        Tecnologia__c,
                                                        Coste_Estimado_Intercompany__c,
                                                 Oportunidad__r.Fecha_Inicio_Preventa__c,
                                                        Oportunidad__r.Proyecto_extraordinario__c,
                                                        Oportunidad__r.Codigo_de_oportunidad__c,
                                                 		Oportunidad__r.proyecto_Padre__c,
                                                 		Id_PepEspejo__c,
                                                 		Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c,
                                                 		Oportunidad__r.CreatedDate,
                                                         EsIntercompany__c,
                                                         Margen_Intercompany__c,
                                                         Importe_Total_Intercompany__c,
                                                        Oportunidad__r.Account.ID_SAP__c,
                                                 		Oportunidad__r.Margen_bruto__c,
                                                        Oportunidad__r.Owner.EmployeeNumber,
                                                 		Oportunidad__r.owner.Sede__c,
                                                        Oportunidad__r.Offering__r.EmployeeNumber,
                                                        Oportunidad__r.Offering__r.Profile.Id,
                                                        Oportunidad__r.GPM__r.Codigo_de_empleado__c,
                                                        CreatedById,
                                                 		Fabricantes__c,
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
                                                        CreatedBy.EmployeeNumber
                                                        FROM Linea_de_Proyecto__c
                                                        WHERE Id  =:Identificador];
                    String serializedPreventa;
                    serializedPreventa = JSON.serialize(preventas);
                  
                    if(ejecucion==true){
                        
               				return calloututil.sendObjsToSAPFromComponent(serializedPreventa, null, 'Linea_de_Proyecto__c',true);
                        
                    }else{
                            
                         system.debug('AQUI'+ejecucion);
                      		 calloututil.sendObjsToSAPFromTrigger(serializedPreventa, null, 'Linea_de_Proyecto__c');
                        	return null;
                    }
          				
                  

    		}
        return null;
    }  
    
    /*@AuraEnabled
     public static string SendPreventaOpor(String Identificador,list<Linea_de_Proyecto__c> lps,boolean ejecucion)
    {
                set<id> ids = new set<id>();
        if(lps!=null){       
            for(Linea_de_Proyecto__c lp:lps){
                
                ids.add(lp.id);
            }
        }
        
        		id idlp=Identificador;
        if(idlp.getSObjectType().getDescribe().getName()=='Linea_de_Proyecto__c'){
                                ids.add(idlp);
        }
        
                    system.debug ('LPPPS'+lps);
                    List<Linea_de_Proyecto__c> pepsEje = [SELECT  Codigo_SAP_Preventa__c,
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
                                                          Comercial_Intercompany__r.EmployeeNumber,
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


                    FROM Linea_de_Proyecto__c 
                    WHERE Id  in :ids and No_aplica_para_ejecucion__c=false];

                system.debug('LPS'+pepsEje);

                SendEmailPepsEjecucion.enviarCorreo(pepsEje);
          		return 'Se ha generado la plantilla correctamente y se han enviado los correos';		
                  
                  

    }*/
    
    
    @InvocableMethod(label='SendPreventaOpor')
     public static void SendPreventaOporFlow(list<Linea_de_Proyecto__c> lps)
    {
    set<id> ids = new set<id>();
        if(lps!=null){       
            for(Linea_de_Proyecto__c lp:lps){
                
                ids.add(lp.id);
            }
            SendPreventaOpor(ids);
        }

       
         
    }
    
    @future(callout=true)
     public static void SendPreventaOpor(Set<ID> ids)
    {
            
                    List<Linea_de_Proyecto__c> pepsEje = [SELECT  Codigo_SAP_Preventa__c,
                                                          Name,
                                                          Nombre_SAP__c,
                                                          Area__c,
                                                          Oficina_tecnica__c,
                                                          Fecha_Fin__c, 
                                                          Fecha_Inicio__c,
                                                          Gerencia__c,
                                                          RecordType.Name,
                                                          Oportunidad__r.Owner.Email,
                                                          Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                                          Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c,
                                                          Margen_real__c,
                                                          Importe_total_2__c,
                                                          Responsable_de_LDP__r.EmployeeNumber,
                                                          Responsable_de_LDP__r.Name,
                                                          Tecnologia__c,
                                                          Margen_Intercompany__c,
                                                          Oportunidad__r.Proyecto_Padre__c,
                                                          Oportunidad__r.Oportunidad_Relacionada__r.Proyecto_Padre__c,
                                                          Oportunidad__r.Proyecto_extraordinario__c,
                                                          Oportunidad__r.Codigo_de_oportunidad__c,
                                                          Oportunidad__r.CreatedDate,
                                                          Oportunidad__r.Account.ID_SAP__c,
                                                          Oportunidad__r.Margen_bruto__c,
                                                          Oportunidad__r.Owner.EmployeeNumber,
                                                          Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c,  
                                                          Oportunidad__r.GPM__r.Codigo_de_empleado__c,
                                                          Oportunidad__r.Offering__r.EmployeeNumber,
                                                          Oportunidad__r.Offering__r.Profile.Id,
                                                          Comercial_Intercompany__r.EmployeeNumber,
                                                          Coste_Estimado_Intercompany__c,
                                                          Oportunidad__r.owner.Sede__c,
                                                          CreatedById,
                                                          Fabricantes__c,
                                                          Importe_Total_Intercompany__c,
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
                                                          PEP_Interco__c,
                                                          Venta_Extraordinaria__c,
                                                          oportunidad__r.Proyecto_estrategico__c,
                                                          Sin_Controlling__c,
                                                          Id_PepEspejo__c,
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
                                                          Oportunidad__r.Sede_Venta__r.ID_SAP__C,
                                                          Coste_real__c,
                                                          EsIntercompany__c,
                                                          CodigoPepInterco__c,      
                                                          Oportunidad__r.New_Form_PEPS__c,
                                                          Importe_a_elevar__c
                    FROM Linea_de_Proyecto__c 
                    WHERE Id  in :ids and No_aplica_para_ejecucion__c=false];
        	
        			String serializedLP;
                    serializedLP = JSON.serialize(pepsEje);

                system.debug('LPS--->'+pepsEje.size());
        		system.debug('SerializedLP-->'+serializedLP);

        		//capturar la respuesta y comprobar que sea 200 ok.
                String mensajeResultado = calloututil.sendObjsToSAPFromComponent(serializedLP, null, 'Linea_de_Proyecto__c',true);	
                if (!mensajeResultado.containsIgnoreCase('correctamente')){
                    //Error
                    SendEmailPepsEjecucion.enviarCorreo(pepsEje[0],mensajeResultado);
                }else{
                    //Éxito
                    SendEmailPepsEjecucion.enviarCorreo(pepsEje[0]);
                }
        
        
        		
        		
    }
    
       @AuraEnabled
    public static list<Linea_de_Proyecto__c>  getLps(String Identificador){
                 List<Linea_de_Proyecto__c> lps = [SELECT
                                                        Id,
                                                        Codigo_SAP_Preventa__c,
                                                        Name,
                                                       Listo_para_sincronizar__c,
                                                  		Nombre_Tipo_Registro__c,
                                                        Nombre_SAP__c,
                                                        toLabel(Area__c),
                                                        Oficina_tecnica__c,
                                                        Fecha_Fin__c, 
                                                        Fecha_Inicio__c,
                                                     Tipo_de_ingreso__c,
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
                                                        Oportunidad__r.GPM__r.Codigo_de_empleado__c,
                                                  		Oportunidad__r.Fecha_Inicio_Preventa__c,
                                                          Coste_Estimado_Intercompany__c,
                                                   Oportunidad__r.owner.Sede__c,
                                                          PEP_Interco__c,
                                                        CreatedById,
                                                 		Fabricantes__c,
                                                         Execution_SAP_Name__c,
                                                        Sede__c,
                                                        Margen_Intercompany__c,
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
                                                    Importe_a_elevar__c,
                                                         Ejecutado_en_cliente__c,
                                                         Direccion_cliente__c,
                                                         Clave_Periodificacion__c,
                                                         Importe_Total_Intercompany__c,
                                                         Agile__c,
                                                         Cambio_Alcance__c,
                                                         Sin_Contrato__c,
                                                         Inducido__c,
                                                   Id_PepEspejo__c,
                                                        CreatedBy.EmployeeNumber
                                                        FROM Linea_de_Proyecto__c
                                                        WHERE oportunidad__c  =:Identificador and No_aplica_para_ejecucion__c=false and  Codigo_SAP_Ejecucion__c=null ];
        
        return lps;
        
    }
    
    
          @AuraEnabled
    public static string  sendall(String Identificador){
        
                 List<Linea_de_Proyecto__c> lps = [SELECT
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
                                                   		Comercial_Intercompany__r.EmployeeNumber,
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
                                                   		Oportunidad__r.owner.Sede__c,
                                                        Oportunidad__r.Offering__r.Profile.Id,
                                                        Oportunidad__r.GPM__r.Codigo_de_empleado__c,
                                                   Oportunidad__r.Fecha_Inicio_Preventa__c,
                                                   Coste_Estimado_Intercompany__c,
                                                        CreatedById,
                                                        PEP_Interco__c,
                                                    Importe_a_elevar__c,
                                                 		Fabricantes__c,
                                                        Sede__c,
                                                        Margen_Intercompany__c,
                                                 		Coste_Bruto__c,
                                                         Importe_Total_Intercompany__c,
                                                 		Margen_Real_Economico__c,
                                                        Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c,
                                                        Oportunidad__r.mercado__c,
                                                        Org_Ventas__c,
                                                   Id_PepEspejo__c,
                                                 		Clase_PEP__c,
                                                             EsIntercompany__c,
                                                         Codigo_SAP_Ejecucion__c,
                                                   		Execution_SAP_Name__c,
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
                                                        FROM Linea_de_Proyecto__c
                                                        WHERE oportunidad__c  =:Identificador];
        String serializedPreventa;
        serializedPreventa = JSON.serialize(lps);
        system.debug('serializedPreventa'+serializedPreventa);
        return calloututil.sendObjsToSAPFromComponent(serializedPreventa, null, 'Linea_de_Proyecto__c',true);
        
        
    }
    
     @AuraEnabled
    public static void SendCorreoForm(String Identificador,list<Linea_de_Proyecto__c> lps,boolean ejecucion){
		set<id> ids = new set<id>();
        String []destinatarios = new String[]{};
        id idlp=Identificador;
        if(lps!=null){       
            for(Linea_de_Proyecto__c lp:lps){
                ids.add(lp.id);
            } 
        }
        if(idlp.getSObjectType().getDescribe().getName()=='Linea_de_Proyecto__c'){
        	ids.add(idlp);
        }
        
        system.debug ('LPPPS'+lps);
        //Saca todos los correos de las lineas de proyecto seleccionadas.
        List<Linea_de_Proyecto__c> pepsEje =
        [SELECT  Jefe_de_Proyecto_de_Ejecucion__r.Email,
        Responsable_de_LDP__r.Email,
        Responsable_de_SW__r.Email, 
        Execution_SAP_Name__c,
        UrlForm__c,
        Oportunidad__r.Codigo_de_oportunidad__c
        FROM Linea_de_Proyecto__c 
        WHERE Id  in :ids];
        
        for(Linea_de_Proyecto__c lproy : pepsEje){
            system.debug('Linea de proyecto------------->'+lproy);
            system.debug('lproy.Jefe_de_Proyecto_de_Ejecucion__r.Email------------->'+lproy.Jefe_de_Proyecto_de_Ejecucion__r.Email);
            system.debug('lproy.Responsable_de_LDP__r.Email------------->'+lproy.Responsable_de_LDP__r.Email);
           	if(lproy.Jefe_de_Proyecto_de_Ejecucion__r.Email != null){
                destinatarios.add(lproy.Jefe_de_Proyecto_de_Ejecucion__r.Email);
            }
            if(lproy.Responsable_de_LDP__r.Email != null){
                destinatarios.add(lproy.Responsable_de_LDP__r.Email);
            }
            
            if(lproy.Responsable_de_SW__r.Email != null){
                destinatarios.add(lproy.Responsable_de_SW__r.Email);
            }

     
            destinatarios.add('cristina.leal@vasscompany.com');
            destinatarios.add('crminterno.salesforce@vass.es');
            system.debug('Destinatarios:++++Z'+destinatarios);
            SendEmailPepsEjecucion.enviarCorreoAltaPEP(lproy,destinatarios); 
            destinatarios.clear();
        }
        
    }
    
}