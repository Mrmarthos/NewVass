public class AccountUtil 
{
    /**
     * Este método recoge las cuentas a sincronizar 
       Se llama en el afterinsert de account y en un batch
     *
     * @author: gserrano (16/11/2018)
     */
    public static void serializeAndSendAccounts(list<SObject> accounts)
    {      
        String serializedAccounts;
        String idRecordTypeCuentaExterna = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(Constants.ACCOUNT_RECORDTYPE_EXTERNAL).RecordTypeId;
        /*Si se ha llamado desde un trigger*/
        if(Trigger.IsExecuting)
        {   
            Set<String> Ids = new Set<String>();

            for(SObject acc : accounts)
            { 
                Ids.add(acc.Id);
            }

        System.debug('Cuentas con ID SAP: ' + Ids);
            List<Account> accs = [SELECT 
                                  Id, 
                                  Name,
                                  Razon_Social__c,
                                  ID_SAP__c,
                                  NIF_CIF__c, 
                                  Parent.ID_SAP__c, 
                                  BillingAddress, 
                                  BillingStreet, 
                                  BillingCity, 
                                  BillingCountryCode, 
                                  BillingPostalCode,
                                  Phone, 
                                  Fax, 
                                  Mercado__c, 
                                  Sectores__c, 
                                  Owner.EmployeeNumber
                                  FROM Account
                                  WHERE Id in :Ids 
                                  AND ID_SAP__c != '' 
                                  AND ID_SAP__c != null
                                  AND RecordTypeId = :idRecordTypeCuentaExterna
                                  AND  Regiones__c in  :Constants.REGION_CUENTA_SINCRO_SAP  ];

            System.debug('Cuentas con ID SAP: ' + accs);

            if(!accs.isEmpty())
            {
                serializedAccounts = JSON.serialize(accs);
 
                CalloutUtil.sendObjsToSAPFromTrigger(serializedAccounts, Constants.SAP_ACCOUNTS_PATH, 'Account'); 
            }    
        } 
        /*Si viene del batch el proceso será distinto*/
        else
        {   
            serializedAccounts = JSON.serialize(accounts); 

            System.debug('Cuentas sin ID SAP: ' + serializedAccounts);  
    
            CalloutUtil.sendObjsToSAPFromTrigger(serializedAccounts,  Constants.SAP_ACCOUNTS_PATH, 'Account');
        }
    } 

    /**
     * Este método recoge las cuentas a sincronizar 
       Se llama en el afterupdate de account
       Se comprueba si se ha cambiado un campo relevante 
       En caso de no ser así, no se sincroniza
     *
     * @author: gserrano (16/11/2018)
     */

}