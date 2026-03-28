/**
 * Class with all the utilities for the debug of the code and the log generation.
 *
 * @author Asier Rodríguez
 * @date 08/08/2016
 **/
global virtual class LogUtil
{
        //#endregion

        //#region Attributes
        @TestVisible private static List<Log__c> exceptionList = new List<Log__c>(); //All the debug logs saved by the user.

        //#endregion

        //#region (\(O.O)/) Client Log Class Definition(\(O.O)/)

         /**
         * Debug writer overload with only a String.
         *
         * @author Asier Rodríguez
         * @date 08/08/2016
         */
        global static void debug(String message)
        {
                //LogUtil.debugLogger.log();
        }
        //#endregion


        //#region (\(O.O)/) Error Log Functions (\(O.O)/)

        /**
         * It adds one Error log built from a list of Database.Error to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         *
         * @author Javier Martínez de Pissón
         * @date 09/08/2017
         * @param errors Database.Errors[] to be logged
         */
        global static void addLog(Database.Error[] errors)
        {
            addLog('Database.Error[]', errors);
        }

        /**
         * It adds one Error log built from a list of Database.Error to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         *
         * @author Javier Martínez de Pissón
         * @date 09/08/2017
         * @param method Method where the Database.error[] is processed
         * @param errors Database.Errors[] to be logged
         */
        global static void addLog(String method, Database.Error[] errors)
        {
            if(errors != null && !errors.isEmpty())
            {
                Integer errorIndex = errors.size();
                String message = '';

                while(errorIndex-- > 0)
                {
                    message += 'Got error ' + errors[errorIndex].getStatusCode()
                                + ': ' + errors[errorIndex].getMessage()
                                + 'on field(s) ' + String.join(errors[errorIndex].getFields(), ',');
                }

                debug(message);

                exceptionList.add(
                    new Log__c (
                            Metodo__c = String.isEmpty(method) ? null : method.left(255),
                            Descripcion__c = String.isEmpty(message) ? null : message.left(131072)
                            )
                    );
            }
        }


        /**
         * It adds one Error log built from an DmlException to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         * Facade for the addLog(method, dmlEx)
         **
         * @author Javier Martínez de Pissón
         * @date 19/10/2016
         * @param e DmlException to be logged
         */
        global static void addLog(DmlException dmlEx)
        {
            if(dmLEx != null)
            {
                addLog('DmlException:' + dmlEx.getLineNumber(), dmlEx);
            }
        }

        /**
         * It adds one Error log built from an DmlException to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         **
         * @author Javier Martínez de Pissón
         * @date 08/08/2018
         * @param method Method where the exception is catched
         * @param dmlEx DmlException to be logged
         */
        global static void addLog(String method, DmlException dmlEx)
        {
            if(dmLEx != null)
            {
                Integer rowsFailed = dmlEx.getNumDml();
                String[] errors = new String[]{};

                while(rowsFailed-- > 0)
                {
                    errors.add(
                        '\r\n\t\tRow ' + rowsFailed
                        + ' exception: ' + dmlEx.getDmlMessage(rowsFailed)
                        + '\r\n\t\tFields: ' + String.join(dmlEx.getDmlFieldNames(rowsFailed), ', ')
                        + '\r\n\t\tId: ' + dmlEx.getDmlId(rowsFailed)
                    );
                }

                debug('NTS1 EXCEPTION:\r\n\tType: DmlException'
                    + '\r\n\tMessage: ' + dmlEx.getMessage()
                    + '\r\n\tRows failed: ' + dmlEx.getNumDml()
                    + String.join(errors, '\r\n\t')
                );

                exceptionList.add(
                        new Log__c (
                                Metodo__c = String.isEmpty(method) ? null : method.left(255),
                                Descripcion__c = dmlEx.getMessage().substringBefore(':').left(131072)
                                )
                        );
            }
        }

        /**
         * It adds one Error log built from an Exception to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         * Facade for the addLog(method, e)
         * @author Javier Martínez de Pissón
         * @date 19/10/2016
         * @param e Exception to be logged
         */
        global static void addLog(Exception e)
        {
            if(e != null)
            {
                addLog(e.getTypeName() + ':' + e.getLineNumber(), e);
            }
        }

        /**
         * It adds one Error log built from an Exception to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         *
         * @author Javier Martínez de Pissón
         * @date 08/08/2017
         * @param method Method where the exception is catched
         * @param e (Exception) Exception to be logged
         */
        global static void addLog(String method, Exception e)
        {
            if(e != null)
            {
                debug('NTS1 EXCEPTION:\r\n\tType:' + e.getTypeName() 
                    + '\r\n\tMessage: ' + e.getMessage() 
                    + '\r\n\tStack String:' + e.getStackTraceString()
                );

                exceptionList.add(
                        new Log__c (
                                Metodo__c = String.isEmpty(method) ? null : method.left(255),
                                Descripcion__c = e.getMessage().substringBefore(':').left(131072)
                                )
                        );
            }
        }

        /**
         * It adds one Error log to the list of error logs. Facade for the addLog(method, message).
         * It also add all the system debugs saved until the moment of the log save.
         **
         * @author Javier Martínez de Pissón
         * @date 08/08/2017
         */
        global static void addLog(String message)
        {
                addLog(null, message);
        }

        /**
         * It adds one Error log to the list of error logs. It also add all the system debugs saved until the moment of the log save.
         *
         * @author Asier Rodríguez
         * @date 08/08/2016
         * @change Javier Martínez de Pissón (19/10/2016) Refactored for create the Log in a single line of code using String.join, to improve perfomance.
         * @change Javier Martínez de Pissón (28/08/2017) Doesn't save the Log field in the method. Imporves heap performance.
         */
        global static void addLog(String method, String message)
        {
                debug('NTS1 LOG: \n Method: '+ method + '\n Message: ' + message);
                exceptionList.add(
                        new Log__c (
                                Metodo__c = String.isEmpty(method) ? null : method.left(255),
                                Error__c = String.isEmpty(message) ? null : message.left(131072)
                                )
                        );
                
        }

           global static void addLog(String Metodo,String LP, String Error,String PropietarioPEP, String XMLRequest,String XMLResponse,String Area , String Gerencia)
        {
               
                exceptionList.add(
                        new Log__c (
                                Metodo__c = String.isEmpty(Metodo) ? null : Metodo.left(255),
                                L_nea_de_Proyecto__c=String.isEmpty(LP) ? null : LP.left(255),
                                Error__c=String.isEmpty(Error) ? null : Error.left(255),
                                OwnerId=String.isEmpty(PropietarioPEP) ? null : PropietarioPEP.left(255),
                                XML_Request__c=String.isEmpty(XMLRequest) ? null : XMLRequest.left(255),
                                XML_Response__c=String.isEmpty(XMLResponse) ? null : XMLResponse.left(255),
                                Area__c=String.isEmpty(Area) ? null : Area.left(255),
                                Gerencia__c=String.isEmpty(Gerencia) ? null : Gerencia.left(255)
                                )
                        );
        }

        /**
         * Inserts the previously added error logs into the database, with a complete log file attached.
         * WARNING - Consumes 2 DML if the Log or Debug Mode is Enabled
         **
         * @author Asier Rodríguez
         * @date 08/08/2016
         * @change Javier Martínez de Pissón (15/03/2017) Change the clearing of the log. Moved the log to an external file
         * @change Javier Martínez de Pissón (08/08/2017) Rewrited the logger. Create a log file attached to all the errors created
         */
        global static void insertLog()
        {
                if(!exceptionList.isEmpty())
                {

                        // 2 - Inserts the log list
                        Integer eIndex = exceptionList.size();

                        while(eIndex-- > 0)
                        {
                            //exceptionList[eIndex].LogFileId__c = logContentDocumentId;
                        }

                        insert exceptionList;
                        exceptionList.clear();
                }
        }

	     /** 
	   * @description: send Email with Error Log
	   **
	   * @Autor: Noemi Escudero del Olmo (05/11/2018)
	   **
	   * @Modificacion: 
	   **
	   * @Parametro: - method   
	   * - message  
	   **
	   *//*
	   public static void sendEmailError(String method, String log) 
	   {
		   Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
		   message.toAddresses = new String[] { 'nescudero@nts-solutions.com', 'rpolvera@nts-solutions.com' , 'jquintana@nts-solutions.com' };
		   message.optOutPolicy = 'FILTER';
		   message.subject = '[VASS] Error Log';
		   message.plainTextBody = 'Método que ha fallado:\n'+method+'\nMensaje:\n'+log+'\n';
		   Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
		   Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
		
	   if (results[0].success) 
	   {
	       System.debug('EMAIL: El email se ha enviado a '+ message.getToAddresses() +'.');
	   } 
	   else 
	   {
	       System.debug('EMAIL: El email ha fallado al enviarse: ' + results[0].errors[0].message); 
	   }
	   }*/
}