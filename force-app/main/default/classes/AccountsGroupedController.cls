public with sharing class AccountsGroupedController {
    private String username ;
    private String password ; 
    private String instanceURL;
    private String endPoint;
    private String registroMetadata;
    private String searchPhrase;
    public AccountsGroupedController(String registroMetadata,String accName) {
        this.registroMetadata = registroMetadata;
        this.searchPhrase = accName;
        getTokenInfo(registroMetadata);
    }


    /**
     * @author Adrián Bernardo
     * @descripción obtendrá las cuentas de SAP para poder hacer las operaciones más adelante.
     * @param accName será el nombre por el que se filtrará en el buscador.
     */
    @AuraEnabled
    public static  List<Account> getAccs(String accName){
        AccountsGroupedController cuentaSAP = new AccountsGroupedController('TokenSAP',accName);
        list<Account> ListAccs=new List<Account>();
        Http h2 = new Http();
        HttpRequest req1 = new HttpRequest();
        if(accName != '' || accName != null){
            ListAccs = AccountsGroupedController.obtenerCuentas(cuentaSAP);
            
        }
        return ListAccs;
    }

    /**
     * @author Adrián Bernardo
     * @descripción añadirá la Id_grupo del registro seleccionado en la tabla de cuentas de SAP.
     * @param Identificador el ID del registro actual en el que estamos de Account
     * @param accs el registro seleccionado.
     */
    @AuraEnabled
    public static void aniadirIdExterna(String Identificador,List<Account> accs){
        /**Do something  */
        system.debug('Cuentas:-------------'+accs);
        system.debug('Grupo ID:-------------'+accs[0].SAP_Grupo_ID__c);
        system.debug('Grupo Nombre:-------------'+accs[0].Name);
        
        List<Account> currentRecord = [SELECT id,SAP_Grupo_ID__c,NIF_CIF__c,SAP_Group_Name__c FROM Account WHERE id =:Identificador];
        currentRecord[0].SAP_Grupo_ID__c = accs[0].SAP_Grupo_ID__c;
        currentRecord[0].SAP_Group_Name__c = accs[0].Name;

        update currentRecord;
    }

    /**
     * @author Adrián Bernardo
     * @descripción obtiene los metadatos para la posterior llamada al servicio web
     * @param recordLabel el nombre del registro de metadatos
     */
    public void getTokenInfo(String recordLabel){
        List<Get_Token__mdt> tokenList = [SELECT EndPoint__c,Password__c,User__c FROM Get_Token__mdt WHERE label =:recordLabel];
        username = tokenList.get(0).User__c;
        password = tokenList.get(0).Password__c;
        endPoint = tokenList.get(0).EndPoint__c;
    }


    /**
     * @author Adrián Bernardo
     * @descripción realiza el servicio web para obtener las cuentas de SAP
     * @param cuentaSAP obtiene la clase que contiene variables con los datos del registro de metadatos
     */
    public static List<Account> obtenerCuentas(AccountsGroupedController cuentaSAP){
        Blob headerValue = Blob.valueOf(cuentaSAP.username + ':' + cuentaSAP.password);
        String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        List<Account> cuentasProvisionales = new List<Account>();
        if(cuentaSAP.searchPhrase == '' || cuentaSAP.searchPhrase == null){
            return cuentasProvisionales;  
        }
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/atom+xml');    
        req.setHeader('x-csrf-token', 'fetch');
        req.setHeader('Authorization', authorizationHeader);
        req.setMethod('GET');
        req.setEndpoint(cuentaSAP.endPoint);
        HttpResponse res = h.send(req);
        
        if(res.getStatusCode() == 200){
            Dom.Document doc = new Dom.Document();
            doc.load(res.getBody());
            Dom.XMLNode address = doc.getRootElement();
            for(Dom.XMLNode child : address.getChildElements()) {
                if(child.getName() == 'entry'){
                    for(Dom.XMLNode content : child.getChildElements()) {
                        if(content.getName() == 'content'){
                            for(Dom.XMLNode properties : content.getChildElements()) {
                                if(properties.getChildElement('descripcion', address.getNamespaceFor('d')).getText().containsIgnoreCase(CuentaSAP.searchPhrase)){
                                    Account cuenta = new Account();
                                    cuenta.SAP_Grupo_ID__c = properties.getChildElement('id_grupo', address.getNamespaceFor('d')).getText();
                                    cuenta.name = properties.getChildElement('descripcion', address.getNamespaceFor('d')).getText();
                                    cuentasProvisionales.add(cuenta); 
                                }
                                
                            }
                        }
                        
                    }
                }
            }
        }
        return cuentasProvisionales;

    }


    
}