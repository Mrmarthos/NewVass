@isTest
private class LogUtilTest
{

        @isTest
        static void debug_testOnlyMessage()
        {
                    // Given
                    // Log Mode is ALL

                    // When
                    Test.startTest();

                    LogUtil.debug('Hello World!');

                    Test.stopTest();

                    // Then
                    //String log = LogUtil.debugLogger.getLog();
                    //System.assert(true, log.contains('Hello World!') );
        }



        //#region Test Error Log Methods
        @isTest
        static void addLog_testNullParams()
        {
                // Given
                // Log Mode is ALL
                String message = null;
                String method = null;
                LogUtil.debug('Hello World!');

                // When
                Test.startTest();

                LogUtil.addLog(message, method);

                Test.stopTest();

                // Then
                Log__c log = LogUtil.exceptionList.get(LogUtil.exceptionList.size() - 1);

                System.assertEquals(log.Descripcion__c, null, 'The message is not null.');
                //System.assert(LogUtil.debugLogger.getLog().contains('Hello World!'), 'The log does not contain the debug.');
        }

        @isTest
        static void addLog_testNoDebug()
        {
                // Given
                // Log Mode is ALL
                String message = 'Hello World!';
                String method = null;

                // When
                Test.startTest();

                LogUtil.addLog(method, message);

                Test.stopTest();

                // Then
                Log__c log = LogUtil.exceptionList.get(LogUtil.exceptionList.size() - 1);

                System.assertEquals(null, log.Descripcion__c, 'The message is null.');
                //System.assert(LogUtil.debugLogger.getLog() != '', 'Debug Log is empty');
        }

        @isTest
        static void addLog_testAllParams()
        {
                // Given
                // Log Mode is ALL
                String message = 'Hello World!';
                String method = 'addLog_testAllParams';
                String debug = 'Bye!';
                
                //Añadido por Gabriel Serrano 27/06/2018 para mejorar cobertura
                Database.Error[] errores = new List<Database.Error>();
            
                Account[] accts = new List<Account>{
                                        new Account(Name='Account1'),
                                        new Account()};
                Database.SaveResult[] srList = Database.insert(accts, false);
                                                                
                for (Database.SaveResult sr : srList)
                {
                    if (!sr.isSuccess()) 
                    {
                        errores = sr.getErrors();
                    }
                }
                //Hasta aquí
                Test.startTest();
                    LogUtil.addLog('Errores');           //Añadido por Gabriel
                    LogUtil.addLog(errores);             //Añadido por Gabriel
                    LogUtil.addLog('Errores', errores);  //Añadido por Gabriel
                    addDebugLog(message, method, debug);
                Test.stopTest();

                // Then
                Log__c log = LogUtil.exceptionList.get(LogUtil.exceptionList.size() - 1);

                
                System.assertEquals(log.Descripcion__c, null, 'The message is not equal.');
                System.assertEquals(log.Metodo__c, 'addLog_testAllParams', 'The method is not setted.');
                //System.assert(LogUtil.debugLogger.getLog().contains('Bye!'), 'The log does not contain the debug.');
        }

        @isTest
        static void addLog_testException()
        {
                // Given

                // When
                String stackString;

                Test.startTest();

                stackString = addExceptionLog('Hello World!');

                Test.stopTest();

                // Then
                Log__c log = LogUtil.exceptionList.get(LogUtil.exceptionList.size() - 1);

                System.assertEquals(log.Descripcion__c, 'Hello World!', 'The message is not null.');
                //System.assert(LogUtil.debugLogger.getLog().contains(stackString) );
        }
        
        //Método añadido por Gabriel Serrano 28/06/2018 para mejorar la cobertura 
        @isTest
        static void addLog_testExceptionTwo()
        {
        
            Test.startTest();
            
                try
                {
                    Account acct = new Account();
                    insert acct;
                }
                catch(DmlException e)
                {
                    LogUtil.addLog(e);
                    LogUtil.addLog('error', e);
                }
                
            Test.stopTest();  
        }
        
        @isTest
        static void insertLog_testNoRows()
        {
                // Given

                // When
                Test.startTest();

                LogUtil.insertLog();

                Test.stopTest();

                // Then
                List<Log__c> errorLog = [SELECT Id FROM Log__c];

                System.assert(errorLog.isEmpty(), 'insertLog_testWithRows: The error list is not empty.');
        }

        @isTest
        static void insertLog_testWithRows()
        {
                // Given
                //addLog_testNullParams();
                LogUtil.addLog(null, (String) null);

                //addLog_testNoDebug();
                addDebugLog('message', 'method', null);


                //addLog_testAllParams();
                addDebugLog('message', 'method', 'Bye bye!');

                // When
                Test.startTest();

                LogUtil.insertLog();

                Test.stopTest();

                // Then
                List<Log__c> errorLog = [SELECT Id, name FROM Log__c];
                List<ContentVersion> contentVersionLog = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :errorLog[0].name];

                System.assert(!errorLog.isEmpty(), 'insertLog_testWithRows: The error list is empty.');
                System.assertEquals(errorLog.size(), 3, 'insertLog_testWithRows: The list size must be 3');
                System.assertEquals(true, contentVersionLog.isEmpty(), 'insertLog_testWithRows: There is no log.');
                //System.assert(contentVersionLog[0].VersionData.toString().contains('Bye bye!'), 'insertLog_testWithRows: There is no log.');
        }

        @isTest
        static void insertLog_debugDisabled()
        {
                // Given
                //addLog_testNullParams();
                LogUtil.addLog(null, (String) null);

                //addLog_testNoDebug();
                addDebugLog('message', 'method', null);


                //addLog_testAllParams();
                addDebugLog('message', 'method', 'debug');

                // When
                Test.startTest();

                LogUtil.insertLog();

                Test.stopTest();

                // Then
                List<Log__c> errorLog = [SELECT Id, name FROM Log__c];
                List<ContentVersion> contentVersionLog = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :errorLog[0].name];

                System.assert(!errorLog.isEmpty(), 'insertLog_debugDisabled: The error list is empty.');
                System.assertEquals(true, contentVersionLog.isEmpty(), 'insertLog_debugDisabled: There is log created.');
                System.assertEquals(errorLog.size(), 3, 'insertLog_debugDisabled: The list size must be 3');

        }

        @isTest
        static void insertLog_testLogger()
        {
                // Given
                String longMessageDebug = 'ABC';
                LogUtil.debug(longMessageDebug.leftPad(400000));

                LogUtil.addLog('Hello World!', 'Test');

                // When
                Test.startTest();

                LogUtil.insertLog();

                Test.stopTest();

                // Then
                List<Log__c> errorLog = [SELECT Id FROM Log__c];

                System.assert(!errorLog.isEmpty(), 'insertLog_testWithRows: The error list is empty.');
                System.assertEquals(errorLog.size(), 1, 'insertLog_testWithRows: The list size must be 1');
        }

        @isTest
        static void insertLog_testEffort()
        {
                // Given
                String debugMessage = 'ABC';

                // When
                Test.startTest();

                LogUtil.debug(debugMessage);

                debugMessage = debugMessage.leftPad(250);

                for(Integer i = 0; i < 1000; i++)
                {
                    LogUtil.addLog('Hello World!', 'Test '+ i);

                    for(Integer j = 0; j < 5; j++)
                    {
                        LogUtil.debug(debugMessage);
                    }

                }

                LogUtil.insertLog();

                Test.stopTest();

                // Then
                List<Log__c> errorLog = [SELECT Id FROM Log__c];

                System.assert(!errorLog.isEmpty(), 'insertLog_testWithRows: The error list is empty.');
                System.assertEquals(errorLog.size(), 1000, 'insertLog_testWithRows: The list size must be 1000');

        }
        //#endregion

        //#region Util Test Methods
        static void addDebugLog(String message, String method, String debug)
        {
                if(String.isNotEmpty(debug))
                {
                    LogUtil.debug(debug);
                }

                LogUtil.addLog(method, message);
        }

        static String addExceptionLog(String text)
        {
                String stackString;
                
                try
                {
                    throw new DmlException(text);
                }
                catch(Exception e)
                {
                    LogUtil.addLog(e);
                    stackString = e.getStackTraceString();
                }

                return stackString;

        }
        //#endregion
}