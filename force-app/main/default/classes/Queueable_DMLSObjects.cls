/**
 *@description: Queueable que realiza operaciones DML de manera masiva encolandolas
 *@param name Description:
 *@author name: rpolvera
 *@date date: 09/04/2019
 *@throws Exception:
 *@where description:
 *@see class/method:
 **/
public class Queueable_DMLSObjects implements Queueable
{
    public enum Operation
    {
        INSERTA,
        ACTUALIZA,
        BORRA
    }

    Set<sObject> listSObject {get; set;}
    Operation op;

    public Queueable_DMLSObjects(List<sObject> listSObject, Operation op)
    {
        this.listSObject = new Set<sObject>(listSObject);
        this.op = op;
    }

    /**
     * comprueba los límites de Salesforce y realiza DML o las encola en un nuevo trabajo.
     **
     * @author: rpolvera (09/04/2019)
     */
    public void execute(QueueableContext context)
    {
        for (SObject myObject : listSObject)
        {
            if (Limits.getDmlStatements() < Limits.getLimitDmlStatements())
            {
                listSObject.remove(myObject);
                doTransaction( myObject );
            }
            else
                break;
        }

        if (listSObject.size() > 0 && !Test.isRunningTest())
        {
            System.enqueueJob(new Queueable_DMLSObjects(new List<SObject>(listSObject), op));
        }
    }

    /**
     * Identifica la DML a realizar
     **
     * @author: rpolvera (09/04/2019)
     */
    public void doTransaction(SObject myObject)
    {
        switch on op
        {
            when INSERTA
            {
                insert myObject;
            }
            when ACTUALIZA
            {
                update myObject;
            }
            when BORRA
            {
                delete myObject;
            }
        }
    }
}