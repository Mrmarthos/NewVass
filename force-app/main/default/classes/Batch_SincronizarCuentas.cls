/**
* Clase para sincronizar periódicamente las cuentas
**
* @author: gserrano (2018/11/16)
*/
global class Batch_SincronizarCuentas implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        String idRecordTypeCuentaExterna = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId;
    	String query;
        query = 'SELECT' 
                        +'(SELECT stageName '
                        +'FROM Opportunities where stageName != \'identificada\' AND stageName != \'Solicitada\'), ' 
                        +'Id, ' 
                        +'Name, ' 
                        +'Razon_Social__c, ' 
                        +'ID_SAP__c, ' 
                        +'NIF_CIF__c, ' 
                        +'Parent.ID_SAP__c, ' 
                        +'BillingAddress, ' 
                        +'BillingStreet, ' 
                        +'BillingCity, '
                        +'BillingCountryCode, ' 
                        +'BillingPostalCode, ' 
                        +'Phone, '
                        +'Fax, '
                        +'Mercado__c, ' 
                        +'Sectores__c, '
                        +'Owner.EmployeeNumber '
                +'FROM Account ' 
                +'WHERE (ID_SAP__c = null OR ID_SAP__c = \'\' OR Sincronizado_SAP__c = false) AND ' 
                +'Regiones__c in(\'Madrid\',\'Barcelona\',\'Sedes España\') '
                +'AND RecordTypeId = \''+idRecordTypeCuentaExterna+'\' LIMIT 25';

        List<Account> accs = Database.query(query);
        Set<Account> accsSet = new Set<Account>();

        System.debug('RESULTADO: ' + accs);

        for(Account acc : accs)  
        {
            for(Opportunity opp : acc.Opportunities) 
            { 
                if(opp.StageName == Constants.OPPORTUNITY_STAGE_PRESALE
                  || opp.StageName == Constants.OPPORTUNITY_STAGE_SUBMITTED 
                  || opp.StageName == Constants.OPPORTUNITY_STAGE_DISPLAYED 
                  || opp.StageName == Constants.OPPORTUNITY_STAGE_WON) 
                { 
                    accsSet.add(acc);
                    break;
                }  
            }
        }
        List<Account> accsEnviar = new List<Account>(accsSet);
        if(!accsEnviar.isEmpty()) 
        {
            AccountUtil.serializeAndSendAccounts(accsEnviar);
        }

    }
    public static void SchedulerMethod()
    {
        String timeinterval = '0 0 * * * ?';
        System.schedule('Batch_SincronizarCuentas',timeinterval, new Batch_SincronizarCuentas());
    }
}