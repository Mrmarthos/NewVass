/**
* Clase para sincronizar periódicamente las lineas de proyecto
**
* @author: gserrano (2018/11/16)
*/

global class Batch_SincronizarLineasDeProyecto implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts
{
    global String query;

	global Batch_SincronizarLineasDeProyecto()
    {
        //Recupera Lineas de proyectos preventa no sincronizados en SAP con su oportunidad en estado 
        //(preventa, presentada , entregada y ganada)
        //y recupera también lineas de proyecto en ejecución ya sincronizadas como preventa en SAP
        // pero sin sincronizar como ejecución en SAP y que estan validadas y listas para ser enviadas
        query = 'SELECT Id, '
                + 'Name, ' 
                + 'Sincronizado_SAP_Preventa__c, ' 
                + 'Sincronizado_SAP_Ejecucion__c, ' 
                + 'Listo_para_sincronizar__c, ' 
                + 'Validado_para_Sincronizacion__c, ' 
                + 'Codigo_SAP_Preventa__c, ' 
                + 'Codigo_SAP_Ejecucion__c, ' 
                + 'Oportunidad__r.ID_SAP__c, ' 
                + 'Oportunidad__r.StageName, ' 
                + 'Oportunidad__r.Contrato_Firmado__c, '
                + 'Oficina_tecnica__c,'
                + 'Area__c, ' 
                + 'Clave_de_Periodificacion__c, ' 
                + 'Fecha_Fin__c, '
                + 'Fecha_Inicio__c, ' 
                + 'Gerencia__c, ' 
                + 'Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c, ' 
                + 'Margen_real__c, ' 
                + 'Importe_total_2__c, ' 
                + 'Responsable_de_LDP__r.EmployeeNumber, ' 
                + 'Tecnologia__c, ' 
                + 'Oportunidad__r.Proyecto_extraordinario__c, '
            	+ 'Oportunidad__r.Codigo_de_oportunidad__c, '
                + 'RecordType.developername, ' 
                + 'Oportunidad__r.Oficina_tecnica__c, ' 
                + 'Oportunidad__r.Account.ID_SAP__c, ' 
                + 'Oportunidad__r.Offering__r.EmployeeNumber,'
                + 'Oportunidad__r.Offering__r.Profile.Id,'
                + 'CreatedBy.EmployeeNumber, '
                + 'Nombre_SAP__c,'
                + 'LastModifiedBy.EmployeeNumber'
                +' FROM Linea_de_proyecto__c ';
       
        List<Linea_de_Proyecto__c> lps = Database.query(query);
        System.debug('RESULTADO: ' + lps);
    }

    global Database.queryLocator start(Database.BatchableContext BC)
    { 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        List<Linea_de_Proyecto__c> lpsPreventa = new List<Linea_de_Proyecto__c>();
        List<Linea_de_Proyecto__c> lpsEjecucion = new List<Linea_de_Proyecto__c>();
        List<String> estadosValidos  = new List<String>{'Preventa','Presentada','Entregada'};
            
        system.debug('DATOS BATCH __ '+scope);
         
        //Variable que utilizaremos más adelante en for, se declara aquí por optimización
        List<Linea_de_proyecto__c> lpsRelacionadas;
        Linea_de_proyecto__c lpTemporal;
        Map<Id, Opportunity> mapOpsRelacionadas;
        
       	//A continuación se recogerán las oportunidades necesarias y se guardarán en un mapa
       	//para posteriormente recuperarlas donde proceda
        
		Set<Id> idsOpsRelacionadas = new set<Id>();
        for(Linea_de_Proyecto__c lp : (List<Linea_de_Proyecto__c>) scope)  
        {
            if
            (//ESTO PARA LOS EJECUCIÓN
               lp.Sincronizado_SAP_Ejecucion__c == false 
               && lp.Validado_para_Sincronizacion__c == true 
               && String.isNotBlank(lp.Codigo_SAP_Preventa__c) 
               && lp.Listo_para_sincronizar__c == true 
               && String.isBlank(lp.Oportunidad__r.ID_SAP__c)
            )
            {
				idsOpsRelacionadas.add(lp.Oportunidad__c);
            }
        }
        
        if(!idsOpsRelacionadas.isEmpty())
        {//SE RECUPERAN LAS OPORTNIDADES CON LP DE EJECUCIÓN
        mapOpsRelacionadas = new Map<Id, Opportunity>
            (
                [SELECT Id, 
                (
                    SELECT Id, 
                    Sincronizado_SAP_Ejecucion__c, 
                    Validado_para_Sincronizacion__c, 
                    Codigo_SAP_Preventa__c, 
                    RecordType.developername,
                    Listo_para_sincronizar__c,
                    Linea_principal__c
                	   FROM Lineas_de_Proyecto__r 
                    WHERE No_aplica_para_ejecucion__c = false
                ),
                Name,
                ID_SAP__c,
                Codigo_de_oportunidad__c,
                Sede_Venta__r.ID_SAP__c,
                Account.ID_SAP__c,
                Contrato_Firmado__c,
                CurrencyIsoCode,
                Owner.EmployeeNumber,
                LastModifiedBy.EmployeeNumber
                FROM Opportunity 
                WHERE Id in :idsOpsRelacionadas]
            );
        }
        
        for(Linea_de_Proyecto__c lp : (List<Linea_de_Proyecto__c>) scope)  
        {
            /*Una misma lp puede cumplir las dos condiciones siguientes*/
            /*Si no está sincronizado en preventa (y la oportunidad está en un estado correspondiente) => enviar preventa*/
            if(lp.Sincronizado_SAP_Preventa__c == false && estadosValidos.contains(lp.Oportunidad__r.StageName))
            {
                lpsPreventa.add(lp);
            } 
            /*Si no está sincronizado en ejecucion y se ha sincronizado alguna vez en preventa y su oportunidad esta firmada(tiene código preventa) -> enviar ejecución*/
            else if(lp.Oportunidad__r.StageName == Constants.OPPORTUNITY_STAGE_WON)
            {//LP PROYECTO Oportunidad ganada
                // if(
                // lp.Sincronizado_SAP_Ejecucion__c == false 
                // && lp.Validado_para_Sincronizacion__c == true 
                // && String.isNotBlank(lp.Codigo_SAP_Preventa__c) 
                // && lp.Listo_para_sincronizar__c == true
                // )
                // {
                //     //incluir condicion: si la Oportunidad de la LP tiene ID_SAP, se envia la LP a SAP
                //     //si la oportunidad no tiene ID_SAP, se pregunta si la linea_de_proyecto_principal de la oportunidad cumpla las condiciones del if de arriba
                //     //y si es así, primero se envia la op a otro servicio (mirar en quip)                
                // if(String.isNotBlank(lp.Oportunidad__r.ID_SAP__c))
                // {
                //     lpsEjecucion.add(lp);
                // }
                // else
                // {
                //     lpsRelacionadas = (List<Linea_de_proyecto__c>) mapOpsRelacionadas.get(lp.Oportunidad__c).get('Lineas_de_proyecto__c');

                //         System.debug('lpsRelacionadas -- > '+ lpsRelacionadas );
                //     for(Linea_de_proyecto__c lpTemp : lpsRelacionadas)
                //     {
                //         if(lpTemp.Linea_principal__c == true)
                //         {
                //             lpTemporal = lpTemp;
                //             break;
                //         }
                //     }
                    
                //     if(lpTemporal != null )
                //     {
                //         if
                //         (
                //                 lp.Sincronizado_SAP_Ejecucion__c == false 
                //                 && lp.Validado_para_Sincronizacion__c == true 
                //                 && String.isNotBlank(lp.Codigo_SAP_Preventa__c) 
                //                 && lp.Listo_para_sincronizar__c == true
                //         )
                //         {
                //                 //Enviar la Lp a SAP pero no hacer DMLs aún
                //                 OpportunityUtil.serializeAndSendOpportunity(new List<Opportunity>{mapOpsRelacionadas.get(lp.Oportunidad__c)}, Constants.SAP_OPPORTUNITIES_PATH, true); //True es POSPONER
                //         }
                //     }
                // }
                // lpsEjecucion.add(lp);
                // }
            }    
        }

        if(!lpsPreventa.isEmpty()) 
        { 
            SYSTEM.debug(lpsPreventa.size());
            system.debug('AQUI');
            ProjectLineUtil.serializeAndSendProjectLines(lpsPreventa, Constants.SAP_LPS_PREVENTA_PATH, null, false);
        } 
        
        if(!lpsEjecucion.isEmpty()) 
        {
            ProjectLineUtil.serializeAndSendProjectLines(lpsEjecucion, Constants.SAP_LPS_EJECUCION_PATH, null, false);
        }
    }

    public static void SchedulerMethod()
    {
        String timeinterval = '0 0 * * * ?';
        System.schedule('Batch_SincronizarLineasDeProyecto',timeinterval, new Batch_SincronizarLineasDeProyecto());
    }

    global void execute(SchedulableContext SC)
    {
        Database.executeBatch(new Batch_SincronizarLineasDeProyecto ());
    } 

    global void finish(Database.BatchableContext BC){}
}