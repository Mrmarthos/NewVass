public class ActualizadorJP {
/**
*@description: Realiza la petición a SAP y actualiza JP en Salesforce
*@param name Description:
*@author name: rpolvera
*@date date: 21/12/2018
*@throws Exception: 
*@where description: TEST.
*@see class/method:
**/    
    @future(callout=true)
    public static void actualizadorJP()
    {

        SincroJPSAP.ZsforTabJp jps = new SincroJPSAP.ZsforTabJp();
        SincroJPSAP.zws_act_jpbinding request = new SincroJPSAP.zws_act_jpbinding();
        List<Contact> jpsActualizar = new List<Contact>();
        try 
        {
            jps = request.ZsforActualizaJp();
            for (SincroJPSAP.ZsforListaJp jp : jps.item) 
            {
               jpsActualizar.add( new Contact(
                    RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(Constants.CONTACT_RECORDTYPE_PROJECTMANAGER).RecordTypeId,
                    Codigo_de_empleado__c   = jp.Pernr,
                    FirstName               = jp.Vorna,
                    LastName                = jp.Nachn + ' ' + jp.Nach2,
                    Activo__c               = jp.Activo == '' ? false : true,
                    Email                   = jp.Email,
                    Phone                   = jp.Telnr,
                    Department              = jp.Name1
                  //Es necesario una gerencia que no se envía desde Salesforce para aplicar el área = Kostl
                  //   Gerencia__c             = jp.Kostl,
                  //   Area__c                 = jp.Kostl
               ));
            }
            List<Database.UpsertResult> result = Database.upsert(jpsActualizar, Contact.Codigo_de_empleado__c,false);
                                    
            LogUtil.addLog('Job_ActualizaJP.actualizadorJP() ',System.now()+'\nresult: '+result);
        } 
        catch (Exception e) 
        {
           System.debug(e.getMessage());
           LogUtil.addLog('Job_ActualizaJP.actualizadorJP() ','Exception: '+e.getMessage());
        }
        finally
        {
           LogUtil.insertLog();
        }
    }
}