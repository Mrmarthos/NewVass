/**
*@description: Gestiona inserciones, actualizaciones y borrado de registros a 
               través de eventos plataforma.
*@author name: rpolvera
*@date date: 22/10/2018
*@change name date description: Nueva clase.
*@see class/method:
**/
public with sharing class EventManager {
    
    /**
    *@description: recibe una lista de sObjects y reliza el UPDATE.
    *@param name Description: List<sObject> con los eventos capturados por el 
                              trigger.
    *@author name: rpolvera
    *@date date: 22/10/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: Se debe invocar desde el trigger correspondiente a cada
                         evento de plataforma.
    *@see class/method:
    **/  
    public List<sObject> doUpdate(Map<sObject,sObject> eventosSObject)
    {
        final String OPERACION = 'UPDATE';
        final String metodo = 'EventManager.doUpdate()';
        List<Database.SaveResult> result;
        List<sObject> eventos = new List<sObject>();
        List<sObject> objetos = new List<sObject>();
        List<sObject> erroneos = new List<sObject>();
        List<sObject> reintentar = new List<sObject>();
        List<sObject> noReintentar = new List<sObject>();
        try
        {
            for(sObject evento : eventosSObject.keySet())
            {
            eventos.add(evento);
            objetos.add(eventosSObject.get(evento));
            }
            result = Database.update(objetos, false);
            //Recupera los registros erroneos, inserta el log de errores
            for ( Integer i = 0 ; i < result.size() ; i++ )
            {
                if(!result.get(i).isSuccess())
		        {
		           LogUtil.addLog(metodo+' -- ERROR '+OPERACION, 
		                          eventos.get(i) + '\n'+ result.get(i).getErrors());
		           erroneos.add(eventos.get(i));                
		        }    
            }
            //si la lista de errores contine almenos algún error se reprocesará en un futuro
            if(erroneos.size()>0)
            {
                //se recorren los errores
                for(sObject error : erroneos)
                {
                    Decimal reintento =  (Decimal) error.get('reintento__c');
                    //si no ha superado el numero de reintentos máximos
                    if( reintento < 3)
                    {
                        sObject sObj = error.clone(false,false,false,false);
                        reintento++;
                        sObj.put('reintento__c', reintento);
                        reintentar.add(sObj); 
                    }
                    //si los ha superado se notifica
                    else
                    {
                        noReintentar.add(error);
                    } 
                }
                if (reintentar.size()>0){
                    
                    reprocesar(reintentar);
                    LogUtil.addLog(metodo+' -- REINTENTAR '+OPERACION, 
                               '\nRegistros de Entrada: \n' +
                               String.join(reintentar,' \n '));   
                }
                if (noReintentar.size()>0)
                {
                    
                    LogUtil.addLog(metodo+' -- NUM REINTENTOS SUPERADOS '+OPERACION, 
                               '\nRegistros de Entrada: \n' +
                               String.join(noReintentar,' \n '));   
                }            
            }
        }
        catch(Exception ex)
        {
            LogUtil.addLog('EventManager.doUpdate() -- Exception',
                          ex.getMessage() + '\nRegistros de Entrada: \n' +
                           String.join(eventos,' \n '));       
        }
        finally
        {
            LogUtil.insertLog();  
        }
        return erroneos;  
        
    }
    
    public void reprocesar(List<sObject> eventosRepublicar)
    {
        Integer hour = Datetime.now().hour();
		Integer min = Datetime.now().minute() + 1; 
		Integer ss = Datetime.now().second();
		
		if( min > 60)
		{
		    hour++;
		    min = min - 60;
		}
		
		//parse to cron expression
		String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
		
		ReprocesaEvento s = new ReprocesaEvento(eventosRepublicar); 
		System.schedule('Republicar Eventos ' + String.valueOf(Datetime.now()), nextFireTime, s);
    }    

    public Map<sObject,sObject> parseaEvento(List<sObject> triggerEventos,
                                             Schema.SObjectType tipoObjetoAParsear)
    {
        Map<sObject,sObject> result = new Map<sObject,sObject>();
        final String metodo = 'EventManager.parseaEvento()';
        sObject sObj;
        try
        {
            for (Integer i=0; i < triggerEventos.size(); i++)
            {
                sObj = Schema.getGlobalDescribe().get(String.valueOf(tipoObjetoAParsear)).newSObject();
                Map<String,Schema.SObjectField> campos = triggerEventos.get(i).getSObjectType().getDescribe().fields.getMap();
                
	            //se recorren los campos del evento para mapearlos contra los campos del sObject correspondiente
	            for(string campo: campos.keySet())
	            {
	                //si el campo es nulo no se incluye
	                if(triggerEventos.get(i).get(campo) != null)
	                {
		                if (campo.endsWith('__c') && !campo.equals('eoperacion__c') && !campo.equals('reintento__c') )
		                {
		                    if (campo.endsWith('_std__c'))
		                    {
		                        sObj.put(campo.replace('_std__c',''), triggerEventos.get(i).get(campo));    
		                    }
		                    else
		                    {
		                        sObj.put(campo, triggerEventos.get(i).get(campo));    
		                    }
		                }
	                }
	            } 
	            result.put(triggerEventos.get(i),sObj);
            }
        }
        catch(SObjectException ex)
        {
            LogUtil.addLog(metodo + ' -- Exception',
                           ex.getMessage() + '\nsObject: ' + tipoObjetoAParsear +
                           '\nRegistros de Entrada: \n' + String.join(triggerEventos,' \n '));
        }
        finally
        {
            LogUtil.insertLog();
        }
        
        return result;
    }
    
    public Map<String,Map<sObject,sObject>> clasificaEventoDML(Map<sObject,sObject> eventosVSobjects)
    {
        final String metodo = 'EventManager.clasificaEventoDML()';
        Map<String,Map<sObject,sObject>> result = new Map<String,Map<sObject,sObject>>();
        //Listas que almacenarán los objetos a procesar    
        Map<sObject, sObject> updates = new Map<sObject, sObject>();
        Map<sObject, sObject> erroneos = new Map<sObject, sObject>();
        
        try
        {
            for(sObject evento : eventosVSobjects.keySet())
            {

                if (evento.get('eOperacion__c').equals('UPDATE'))
                {
                    updates.put(evento, eventosVSobjects.get(evento));
                }
                else
                {
                    erroneos.put(evento, eventosVSobjects.get(evento));
                }
            }

            result.put('UPDATE',updates);
            //Notifica error
            if(erroneos.size()>0)
            {
                LogUtil.addLog(metodo + ' -- Operación DML Inválida',
                               'Registros Erroneos: \n' + erroneos);            
            }
        }
        catch(Exception ex)
        {
            LogUtil.addLog(metodo + ' -- Exception',
                           ex.getMessage() + '\n' +
                           '\nRegistros de Entrada: \n' +
                           eventosVSobjects);   
        }
        return result;
    }
    

    
}