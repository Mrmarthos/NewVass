/**
*@description: trigger Util que procesa los eventos Linea_de_Proyecto__c e invoca 
               el manager para realizar operaciones DML 
*@author name: rpolvera
*@date date: 22/10/2018
*@change name date description: Nueva clase.
*@see class/method:
**/
     
public class LineaProyectoEventTriggerUtil {
    
    /**
    *@description: procesa la lógica para actualizar Lineas de Preventa y Ejecución
    *@param name Description:
    *@author name: rpolvera
    *@date date: 12/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: TEST.
    *@see class/method:
    **/ 
    public void process(List<E_Linea_de_Proyecto__e> eventos)
    {
        //Se invoca el manager y se recuperan los objetos clasificados por operaciones DML
        EventManager manager = new EventManager();
        Map<String,List<Linea_de_Proyecto__c>> registrosPorOperacion = new Map<String,List<Linea_de_Proyecto__c>>();
    
        //variables comunes
        Map<sObject,sObject> dmlList = new Map<sobject,sObject>();
        Map<sObject,sObject> descartar = new Map<sObject,sObject>();
        List<sObject> noExiste = new List<sObject>();

        //Procesa los eventos y los parsea a sObject manteniendo la relación con su evento 
        Map<sObject,sObject> eventosParseados = manager.parseaEvento(eventos, Linea_de_Proyecto__c.getSObjectType());
        
        //Clasificamos los eventos por operción DML
        Map<String,Map<sObject,sObject>> eventosClasificados = manager.clasificaEventoDML(eventosParseados);
        
        //Recuperamos los evnetos que vamos a actualizar
        Map<sObject,sObject> updates = eventosClasificados.get('UPDATE');

        //Variables para Preventa
        List<String> idsExternosPreventa = new List<String>();
        Map<sObject,sObject> procesarPreventa = new Map<sObject,sObject>();

        //Variables para Ejecución
        List<String> idsExternosEjecucion = new List<String>();
        Map<sObject,sObject> procesarEjecucion = new Map<sObject,sObject>();

        Map<String,List<String>> parIdExtIdSalesfrce;
        for(sObject lineaProyecto : updates.keySet())
        {
            //si se informa solo Codigo_SAP_Ejecucion__c hacemos el update por este campo
            if(lineaProyecto.get('Codigo_SAP_Preventa__c') != null && 
            !lineaProyecto.get('Codigo_SAP_Preventa__c').equals('') && 
            (lineaProyecto.get('Codigo_SAP_Ejecucion__c') == null || 
                lineaProyecto.get('Codigo_SAP_Ejecucion__c').equals('')))
            {
            idsExternosPreventa.add(String.valueOf(lineaProyecto.get('Codigo_SAP_Preventa__c')));
            procesarPreventa.put(lineaProyecto, updates.get(lineaProyecto)); 
            }
            //si se informa solo Codigo_SAP_Preventa__c hacemos el update por este campo
            else if (lineaProyecto.get('Codigo_SAP_Ejecucion__c') != null && 
                    !lineaProyecto.get('Codigo_SAP_Ejecucion__c').equals('') &&
                    (lineaProyecto.get('Codigo_SAP_Preventa__c') == null || 
                    lineaProyecto.get('Codigo_SAP_Preventa__c').equals('')))
            {
            idsExternosEjecucion.add(String.valueOf(lineaProyecto.get('Codigo_SAP_Ejecucion__c')));
            procesarEjecucion.put(lineaProyecto, updates.get(lineaProyecto));             
            }
            //si se informan los dos campos devolvemos error
            else
            { 
                descartar.put(lineaProyecto, updates.get(lineaProyecto));
            }
        }
        //recuperamos los IDS de Salesforce y su oportunidad
        List<Linea_de_Proyecto__c> idPreventa = [select id, Codigo_SAP_Preventa__c, Oportunidad__C from Linea_de_Proyecto__c where Codigo_SAP_Preventa__c IN : idsExternosPreventa ];
        List<Linea_de_Proyecto__c> idEjecucion = [select id, Codigo_SAP_Ejecucion__c, Oportunidad__C from Linea_de_Proyecto__c where Codigo_SAP_Ejecucion__c IN : idsExternosEjecucion ];
        //Mapa contenedor de la relación entre los ids externos y el Id sObject + Id de master
        //para relación master detail
        parIdExtIdSalesfrce = new Map<String,List<String>>();
        
        //se guardan Ids y master Id en un mapa donde la clave será el id externo, ya sea PREVENTA O EJEUCUCIÓN
        for(Linea_de_Proyecto__c lp : idPreventa)
        {
            List<String> lpPreventa = new List<String>();
            lpPreventa.add(String.valueOf(lp.get('id')));
            lpPreventa.add(String.valueOf(lp.get('Oportunidad__C')));
            parIdExtIdSalesfrce.put(String.valueOf(lp.get('Codigo_SAP_Preventa__c')), lpPreventa);
        }
        for(Linea_de_Proyecto__c lp : idEjecucion)
        {
            List<String> lpPreventa = new List<String>();
            lpPreventa.add(String.valueOf(lp.get('id')));
            lpPreventa.add(String.valueOf(lp.get('Oportunidad__C')));
            parIdExtIdSalesfrce.put(String.valueOf(lp.get('Codigo_SAP_Ejecucion__c')), lpPreventa);
        }

        //se incluyen los ids a los objetos a procesar en preventa
        for(sObject eventoLP : procesarPreventa.keySet())
        {
            if (parIdExtIdSalesfrce.containsKey(String.valueOf(eventoLP.get('Codigo_SAP_Preventa__c'))))
            {
            //comprobamos que existe el codigo sap, es decir que está en salesforce como id Externo en algún registro
            String Id = parIdExtIdSalesfrce.get(String.valueOf(eventoLP.get('Codigo_SAP_Preventa__c'))).get(0);
                String IdOpp = parIdExtIdSalesfrce.get(String.valueOf(eventoLP.get('Codigo_SAP_Preventa__c'))).get(1);
                procesarPreventa.get(eventoLP).put('Id',Id);
                procesarPreventa.get(eventoLP).put('Oportunidad__C',IdOpp);
                procesarPreventa.get(eventoLP).put('Sincronizado_SAP_Preventa__c',true);
                //se añade la linea a la lista a procesar
                dmlList.put(eventoLP, procesarPreventa.get(eventoLP));
            }
            else
            {
                noExiste.add(eventoLP);
            }
        }
        //se incluyen los ids a los objetos a procesar en ejecución    
        for(sObject eventoLP : procesarEjecucion.keySet())
        {
            //comprobamos que existe el codigo sap, es decir que está en salesforce como id Externo en algún registro
            if (parIdExtIdSalesfrce.containsKey(String.valueOf(eventoLP.get('Codigo_SAP_Ejecucion__c')))) 
            {
                String Id = parIdExtIdSalesfrce.get(String.valueOf(eventoLP.get('Codigo_SAP_Ejecucion__c'))).get(0);
                String IdOpp = parIdExtIdSalesfrce.get(String.valueOf(eventoLP.get('Codigo_SAP_Ejecucion__c'))).get(1);
                procesarEjecucion.get(eventoLP).put('Id',Id);
                procesarEjecucion.get(eventoLP).put('Oportunidad__C',IdOpp);
                procesarEjecucion.get(eventoLP).put('Sincronizado_SAP_Ejecucion__c',true);
               //se añade la linea a la lista a procesar
                dmlList.put(eventoLP, procesarEjecucion.get(eventoLP));
            }
            else
            {
                noExiste.add(eventoLP);
            }
        }

        //si descartar contiene errores los notificamos
        if(descartar.size()>0)
        {
            LogUtil.addLog('LineaProyectoEventTrigger -- Error '+
                        'Codigo_SAP_Preventa__c y Codigo_SAP_Ejecucion__c informados',
                            'Registros Erroneos\n'+descartar);
        }
        LogUtil.insertLog();      
        //se realiza el update
        manager.doUpdate(dmlList);            
    }
}