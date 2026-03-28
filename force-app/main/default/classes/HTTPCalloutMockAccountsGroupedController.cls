@isTest
global class HTTPCalloutMockAccountsGroupedController implements HttpCalloutMock {
    protected String body;
    protected Integer code;

    public HTTPCalloutMockAccountsGroupedController(String body,Integer code){
        this.body = body;
        this.code = code;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/atom+xml');
        res.setBody(body);
        res.setStatusCode(code);
        return res;
    }
}