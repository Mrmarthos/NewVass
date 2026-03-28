@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock 
{    
    global MockHttpResponseGenerator(){}
    Integer statusCode;
    String responseBody;
	//Hacer un constructor si quiero, por ejemplo, cambiar el statusCode que se devuelve
	static final String site_realm = 'b716c11f-16a3-4d15-8dbc-f11f7fdefe5a'; 
	    public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

	// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) 
    {       
        // Optionally, only send a mock response for a specific endpoint and method.
        //System.assertEquals('https://grupovass.sharepoint.com/teams/PruebasCRMSalesforce/_api/web/folders', req.getEndpoint());
     
        
        // Create a fake response
        HttpResponse res = new HttpResponse();

        if(req.getEndpoint() == 'https://test.salesforce.com/services/oauth2/token')
        {
            res.setHeader('Content-Type', 'application/text');
            res.setBody('Token Success');
            res.setStatusCode(201);
            return res; 
        }
        else if(req.getEndpoint() == 'https://accounts.accesscontrol.windows.net/'+site_realm+'/tokens/OAuth/2')
        {
            res.setHeader('Content-Type', 'application/text');
            res.setBody('{"token_type":"Bearer","expires_in":"28800","not_before":"1542543335","expires_on":"1542572435","resource":"00000003-0000-0ff1-ce00-000000000000/grupovass.sharepoint.com@b716c11f-16a3-4d15-8dbc-f11f7fdefe5a","access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IndVTG1ZZnNxZFF1V3RWXy1oeFZ0REpKWk00USIsImtpZCI6IndVTG1ZZnNxZFF1V3RWXy1oeFZ0REpKWk00USJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvZ3J1cG92YXNzLnNoYXJlcG9pbnQuY29tQGI3MTZjMTFmLTE2YTMtNGQxNS04ZGJjLWYxMWY3ZmRlZmU1YSIsImlzcyI6IjAwMDAwMDAxLTAwMDAtMDAwMC1jMDAwLTAwMDAwMDAwMDAwMEBiNzE2YzExZi0xNmEzLTRkMTUtOGRiYy1mMTFmN2ZkZWZlNWEiLCJpYXQiOjE1NDI1NDMzMzUsIm5iZiI6MTU0MjU0MzMzNSwiZXhwIjoxNTQyNTcyNDM1LCJpZGVudGl0eXByb3ZpZGVyIjoiMDAwMDAwMDEtMDAwMC0wMDAwLWMwMDAtMDAwMDAwMDAwMDAwQGI3MTZjMTFmLTE2YTMtNGQxNS04ZGJjLWYxMWY3ZmRlZmU1YSIsIm5hbWVpZCI6IjA1MDA4Nzk3LTU4NDItNDYyZC1iYWViLWQxYzZiN2FkMTU5Y0BiNzE2YzExZi0xNmEzLTRkMTUtOGRiYy1mMTFmN2ZkZWZlNWEiLCJvaWQiOiI0M2FjOTdiMC1kNWFmLTQ2NDMtYWFlNC00ZjkxODllNTQwZGYiLCJzdWIiOiI0M2FjOTdiMC1kNWFmLTQ2NDMtYWFlNC00ZjkxODllNTQwZGYiLCJ0cnVzdGVkZm9yZGVsZWdhdGlvbiI6ImZhbHNlIn0.TRZ3WEnQudG33hM1zHBJcq7zPYWnmN6DkcWKNGQT2KB8jwcQLHmL52UPM50mBivffOYTOrreiQig3VJJLTE_giz8z7qHK6NgbpyqyhKn2ZQYxzOxVeusljV5TicRoP-RTJpBjjfCpgohkqgDpKvRFgi6Acx2rMWEn5NLdNMc6OZitzi6jvtMUCrsnCYO9tmWimnXBlMRnZ5A2-EADKGl0nliWFvn73yNJihHcw2DK-P_Yga3tMKTMw9NiKwVP-TykenKZkisYZJS_QpUe3uKDQDQIAGhkajgzIMmbZjNtOQ295_SjO9qdGueWqLPAFD16NgMDi8L6RYnj6IYL1iDWg"}');
            res.setStatusCode(200);
            return res;
        }
        else if(req.getEndpoint() == 'https://grupovass.sharepoint.com/sites/salesforce/_api/web/folders')
        {
            res.setHeader('Content-Type', 'application/text');
            res.setBody('Token Success');
            res.setStatusCode(201);
            return res;
        }          
        else
        {	             
            res.setStatusCode(201);
            res.setStatus('OK');
            return res;
        }
    }
}