public class SAPCheckNIFCalloutUtil {
    
    
    /**
     * @author Adrián Bernardo
     * @future callout true debido a que hace una llamda a un servicio web
     * @param ids set que contiene las IDS que les pasarán desde el flow llamado ControlCheckNIF
     * @descripcion hace la llamada al servicio Web con la ayuda del esquema SAPCheckNIFEsquema para simular una archivo XML.
     */
    @future(callout=true)
    public static void calloutFuture (Set<id> ids){
        List<Account> accs = [SELECT id,NIF_CIF__c,BillingCountryCode FROM Account WHERE id IN :ids];
        List < SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element > response = new List < SAPCheckNIFEsquema.ZSFOR_CHECK_FISCAL_NUMBERResponse_element > ();
        SAPCheckNIFEsquema.check_nif request = new SAPCheckNIFEsquema.check_nif();

        response.add(request.ZSFOR_CHECK_FISCAL_NUMBER(
            accs[0].BillingCountryCode,
            accs[0].NIF_CIF__c
        ));

        system.debug('Respuesta------->'+response);

        system.debug('Error----->'+response[0].E_ERROR);
        if(response[0].E_ERROR == '1'){
            //hacer update
            accs[0].Validacion_NIF__c = true;
            update accs;
        }else if(response[0].E_ERROR == '0'){
            //no hacer update
        }
        
    }

    /**
     * @author Adrián Bernardo
     * @invocableMethod método invocado desde flow.
     * @param accs cuentas o cuenta en la que ocurre el cambio al registro que se pasa como parámetro desde el flow
     * @descripcion llama al un método para que haga la llamada al servicio de manera asíncrona.
     * 
     */
    @InvocableMethod(label='checkNif')
        public static void hacerCalloutDesdeFlow(List<Account> accs){
            Set<ID> ids = new Set<ID>();
            for (Account acc : accs) {
                ids.add(acc.id);
            }
            SAPCheckNIFCalloutUtil.calloutFuture(ids);
        }

        /**
         * @author Adrián Bernardo
         * @AuraEnabled llamado desde un componente aura
         * @param accID ID por el que filtra las cuentas.
         * @descripcion devuelve las cuentas al componente aura .
         */
    @AuraEnabled
    public static List<Account> getCurrentAccount(Id accId){
        
        List<Account> accs = [SELECT id,Validacion_NIF__c FROM Account WHERE id =:accId];
        System.debug(accs);

        return accs;
    }    

    
}