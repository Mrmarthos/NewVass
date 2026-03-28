/**
*@description: job que realiza la creación de analíticas para el forecast
*@param name Description:
*@author name: arodriguez
*@date date: 12/03/2019
*@throws Exception: 
*@where description: 
*@see class/method:
**/  
global class Job_Analitica implements Schedulable
{
    global void execute(SchedulableContext ctx) 
    {
        System.debug('Ejecutando actualización de Analitica__c a día y hora: ' + System.now());
        List<Analitica__c> analist = new List<Analitica__c>(); 

        List<Analitica__c> anadelete = [SELECT Id FROM Analitica__c WHERE Tipo__c = 'Forecast'];

        System.enqueueJob(new Queueable_DMLSObjects(anadelete, Queueable_DMLSObjects.Operation.BORRA));

        For(Linea_de_Proyecto__c LP:[SELECT Id, Gerencia__c, Area__c, CurrencyISOCode, Oportunidad__r.OwnerId, RecordType.Name, Oportunidad__r.AccountId, Duracion_de_Linea__c, Importe_prorrateado_x_prob__c, Fecha_Inicio__c FROM Linea_de_Proyecto__c WHERE No_aplica_para_ejecucion__c = FALSE])
        {
            For(Integer i = 0 ; i<LP.Duracion_de_linea__c ; i++)
            {
                Analitica__c analitica = new Analitica__c();
                analitica.Clan__c = LP.Gerencia__c;
                analitica.Consejo__c = LP.Area__c;
                analitica.Cuenta__c = LP.Oportunidad__r.AccountId;
                analitica.CurrencyISOCode = LP.CurrencyISOCode;
                analitica.Linea_de_Proyecto__c = LP.Id;
                analitica.Propietario__c = LP.Oportunidad__r.OwnerId;
                analitica.Tipo__c = 'Forecast';
                analitica.Tipo_de_Proyecto__c = LP.RecordType.Name;
                analitica.Fecha__c = LP.Fecha_Inicio__c.addMonths(i);
                system.debug(i + ' ' + analitica);
                analist.add(analitica);
            }
        }

        For(Opportunity Opp:[SELECT Id, OwnerId, AccountId, CurrencyISOCode, Duracion_del_proyecto__c, Fecha_de_inicio__c FROM Opportunity])
        {
            For(Integer i = 0 ; i<Opp.Duracion_del_proyecto__c ; i++)
            {
                Analitica__c analitica = new Analitica__c();
                analitica.Cuenta__c = Opp.AccountId;
                analitica.CurrencyISOCode = Opp.CurrencyISOCode;
                analitica.Oportunidad__c = Opp.Id;
                analitica.Propietario__c = Opp.OwnerId;
                analitica.Tipo__c = 'Forecast';
                analitica.Fecha__c = Opp.Fecha_de_inicio__c.addMonths(i);
                system.debug(i + ' ' + analitica);
                analist.add(analitica);
            }
        }
        
        System.enqueueJob(new Queueable_DMLSObjects(analist, Queueable_DMLSObjects.Operation.INSERTA));

    }
}