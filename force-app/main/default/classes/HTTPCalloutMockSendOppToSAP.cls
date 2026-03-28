@isTest
global class HTTPCalloutMockSendOppToSAP implements HttpCalloutMock {
    protected String body;
    protected Integer code;

    public HTTPCalloutMockSendOppToSAP(String body,Integer code){
        this.body = body;
        this.code = code;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(code);
        return res;
    }
  }