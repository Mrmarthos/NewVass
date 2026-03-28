public class EPPM_HTTPService {

    public static void sendPayload(String jsonPayload, Set<Id> opportunityIds) {
        System.debug('*** sendPayload START ***');
        System.debug('Payload: ' + jsonPayload);
        System.debug('Opportunity IDs: ' + opportunityIds);

        for(Id oppId : opportunityIds) {
            System.debug('Processing Opportunity: ' + oppId);
            if(Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
                System.debug('Queueable Jobs Available: ' + Limits.getQueueableJobs() + '/' + Limits.getLimitQueueableJobs());
                System.enqueueJob(new EPPM_QueueableService(jsonPayload, oppId));
            } else {
                System.debug('No Queueable Jobs available for Opportunity: ' + oppId);
            }
        }
        System.debug('*** sendPayload END ***');
    }

    public class EPPM_QueueableService implements Queueable, Database.AllowsCallouts {
        private final String payload;
        private final Id opportunityId;
        private Integer retryCount = 0;

        public EPPM_QueueableService(String payload, Id opportunityId) {
            this.payload = payload;
            this.opportunityId = opportunityId;
            System.debug('EPPM_QueueableService Initialized with OpportunityId: ' + opportunityId);
        }

        public void execute(QueueableContext context) {
            System.debug('*** Queueable Execute START ***');
            System.debug('Payload: ' + payload);
            System.debug('OpportunityId: ' + opportunityId);

            // Buscar log existente o crear nuevo
            Log__c log = getOrCreateLog();
            System.debug('Log Found or Created: ' + log);

            log.XML_Request__c = payload;
            log.Synched_with_EPPM__c = false;

            HttpRequest req = createRequest();
            System.debug('HTTP Request Created: ' + req);

            try { 
                System.debug('Sending HTTP Request...');
                HttpResponse res = new Http().send(req);
                System.debug('HTTP Response Status: ' + res.getStatus());
                System.debug('HTTP Response Status Code: ' + res.getStatusCode());
                System.debug('HTTP Response Body: ' + res.getBody());
                
                // Manejar respuesta
                EPPM_HTTPService.handleResponse(res, log);
            } catch(Exception e) {
                System.debug('Exception during HTTP callout: ' + e.getMessage());
                System.debug('Stack Trace: ' + e.getStackTraceString());
            }

            updateLog(log);
            System.debug('Log Updated: ' + log);
            System.debug('*** Queueable Execute END ***');
        }

        private Log__c getOrCreateLog() {
            System.debug('Fetching existing Log for Opportunity: ' + opportunityId);
            List<Log__c> existingLogs = [SELECT Id, XML_Request__c, XML_Response__c, 
                                               Synched_with_EPPM__c ,Opportunity__c 
                                        FROM Log__c 
                                        WHERE Opportunity__c = :opportunityId 
                                        ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('Existing Logs Found: ' + existingLogs.size());
            return !existingLogs.isEmpty() ? existingLogs[0] : 
                new Log__c(
                    Opportunity__c = opportunityId,
                    XML_Response__c = ''
                );
        }

        private void updateLog(Log__c log) {
            System.debug('Updating or Inserting Log...');
            if(log.Id == null) {
                insert log;
                System.debug('Inserted Log: ' + log);
            } else {
                update log;
                System.debug('Updated Log: ' + log);
            }
        }

        private HttpRequest createRequest() {
            System.debug('Creating HTTP Request...');
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EPPM_Config.ENDPOINT);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', getAuthHeader());
            req.setBody(payload);
            req.setTimeout(120000);
            return req;
        }

        private String getAuthHeader() {
            String authHeader = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(EPPM_Config.USERNAME + ':' + EPPM_Config.PASSWORD));
            System.debug('Generated Auth Header: ' + authHeader);
            return authHeader;
        }
    }

    public static void handleResponse(HttpResponse res, Log__c log) {
        System.debug('*** handleResponse START ***');
        System.debug('Response Status Code: ' + res.getStatusCode());
        System.debug('Response Body: ' + res.getBody());

        log.XML_Response__c = res.getBody();
        String errorMessage = null;

        if(res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
            errorMessage = EPPM_HTTPService.extractErrorMessage(res.getBody());
            System.debug('Extracted Error Message: ' + errorMessage);
        }

        if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
            log.Synched_with_EPPM__c = true;
            log.Response_Code__c = res.getStatusCode();
            System.debug('Success Response - Updating Opportunity');
            Opportunity opp = new Opportunity(
                Id = log.Opportunity__c,
                SyncEppm__c = true,
                Eppm_Error__c=null
            );
            update opp;
        } else {
            log.Synched_with_EPPM__c = false;
            log.Response_Code__c = res.getStatusCode();
            System.debug('Error Response - Updating Opportunity');
            Opportunity opp = new Opportunity(
                Id = log.Opportunity__c,
                SyncEppm__c = false,
                Eppm_Error__c = errorMessage
            );
            update opp;
        }
        System.debug('*** handleResponse END ***');
    }

    public static String extractErrorMessage(String responseBody) {
        System.debug('Extracting error message from response...');
        try {
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            System.debug('Parsed Body: ' + body);
            if (body.containsKey('error')) {
                Map<String, Object> error = (Map<String, Object>) body.get('error');
                if (error.containsKey('innererror')) {
                    Map<String, Object> innerError = (Map<String, Object>) error.get('innererror');
                    if (innerError.containsKey('errordetails')) {
                        Map<String, Object> errorDetails = (Map<String, Object>) innerError.get('errordetails');
                        if (errorDetails.containsKey('errordetail')) {
                            Object errDetailObj = errorDetails.get('errordetail');
                            List<Object> errDetailList = new List<Object>();

                            if (errDetailObj instanceof List<Object>) {
                                errDetailList = (List<Object>) errDetailObj;
                            } else if (errDetailObj instanceof Map<String, Object>) {
                                errDetailList.add(errDetailObj);
                            }

                            List<String> messages = new List<String>();
                            for (Object detailObj : errDetailList) {
                                Map<String, Object> detail = (Map<String, Object>)detailObj;
                                if (detail.containsKey('message')) {
                                    String msg = (String) detail.get('message');
                                    messages.add(msg.trim());
                                }
                            }

                            System.debug('Error Messages Extracted: ' + messages);
                            return String.join(messages, '; ');
                        }
                    }
                }
            }
            return null;
        } catch(Exception e) {
            System.debug('Exception extracting error message: ' + e.getMessage());
            return null;
        }
    }
}