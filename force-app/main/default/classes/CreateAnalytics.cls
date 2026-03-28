@RestResource(urlMapping='/CreateAnalytics/*')

global with sharing class CreateAnalytics

{
    /**
     * @author Adrián Bernardo
     * @description Recorre los registros que le llegan desde el servicio y crea analíticas o Logs en caso de error.
     */
 @HttpPost
 global static void CreateAnalytics()
 {
    
    List< Analitica__c > analyticsToCreate = new List< Analitica__c >();
    List<Decimal> mesesImporte = new List<Decimal>();
    List<Log__c> errorLogs = new List<Log__c>();
   Integer analiticasTotales;

// Verificar si existe una etiqueta personalizada "mesesforecast2025" y si su valor es distinto de 0
String mesesForecastLabel = Label.mesesforecast2025;

if (mesesForecastLabel != null) {
    // Intentar convertir el valor de la etiqueta a un número entero
    try {
        Integer mesesForecastValue = Integer.valueOf(mesesForecastLabel);

        if (mesesForecastValue != 13) {
            analiticasTotales = mesesForecastValue;
        } else {
            analiticasTotales = CreateAnalytics.calculoAnalyticas();
        }
    } catch (Exception e) {
        // Manejar errores de conversión (si la etiqueta no tiene un valor numérico válido)
        analiticasTotales = CreateAnalytics.calculoAnalyticas();
    }
} else {
    analiticasTotales = CreateAnalytics.calculoAnalyticas();
}
    RestRequest     request    = RestContext.request;
    AnalyticWrapper wrapperAnalytics = new AnalyticWrapper();
    String errorMessage = '';
    String idCliente = '';
    String idComercial = '';
    try {
    if(request.requestBody != null){
        system.debug('REQUEST ----->'+request.requestBody.toString());
        wrapperAnalytics = (AnalyticWrapper ) JSON.deserialize(request.requestBody.toString(), AnalyticWrapper.class);
        system.debug('wrapperAnalytics-->'+wrapperAnalytics);
        //Hacer las queries para obtener los usuarios, cuentas y nifs
        Map<String,String> idsCliente = new Map<String,String>(); //IdSap,id
        Map<String,String> nifCliente = new Map<String,String>(); //Nif,id
        Map<String,String> users = new Map<String,String>(); //employeeNumber,idUser
        Map<String,String> sedes = new Map<String,String>(); //codSede, valor
        Map<String,String> sectores = new Map<String,String>(); //codSede, valor
        Map<String,String> consejos = new Map<String,String>(); //value,label
        Map<String,String> clanes = new Map<String,String>(); //ApiName,Name
        for (Account accSAP : [SELECT ID_SAP_Formatted__c,id FROM Account WHERE ID_SAP__c != null FOR UPDATE]) {
            idsCliente.put(accSAP.ID_SAP_Formatted__c, accSAP.id);
        }
        for (Account accNIF : [SELECT NIF_CIF__c,id  FROM Account WHERE NIF_CIF__c  != null FOR UPDATE]) {
            nifCliente.put(accNIF.NIF_CIF__c, accNIF.id);
        }
        for (User usuario : [SELECT EmployeeNumber,id  FROM User WHERE isActive = true]) {
            users.put(usuario.EmployeeNumber, usuario.id);
        }
        for (Account sede : [SELECT id,sede__c FROM Account WHERE sede__c !=null AND RecordType.Name= 'Cuenta interna' FOR UPDATE]) {
            sedes.put(sede.sede__c, sede.id);
        }
        for(CodMercado__c codigoMercado : [SELECT codigo__c,name FROM CodMercado__c FOR UPDATE]){
            sectores.put(codigoMercado.codigo__c, codigoMercado.name);
        }
		for( Schema.PicklistEntry pickListVal : Analitica__c.Consejo__c.getDescribe().getPicklistValues()){
			consejos.put(pickListVal.getValue(),picklistVal.getLabel());
		}  
        for( Schema.PicklistEntry pickListVal : Analitica__c.clan__c.getDescribe().getPicklistValues()){
			clanes.put(pickListVal.getValue(),picklistVal.getLabel());
		}
        CreateAnalytics.sumSedes(sedes);
        for(Integer i = 0; i < wrapperAnalytics.data.size(); i++){
            if(!String.isBlank(wrapperAnalytics.data[i].idcliente)){
                idCliente = String.ValueOf(Integer.valueOf(wrapperAnalytics.data[i].idcliente));
            }else {
                idCliente = '';
            }
            if(!String.isBlank(wrapperAnalytics.data[i].idcomercial)){
                idcomercial = String.ValueOf(Integer.valueOf(wrapperAnalytics.data[i].idcomercial));
            }else {
                idcomercial = '';
            }
        errorMessage = idsCliente.containsKey(idCliente) || nifCliente.containsKey(wrapperAnalytics.data[i].nifcliente) ? '': 'No existe la cuenta con id SAP '+wrapperAnalytics.data[i].idcliente+' o NIF '+wrapperAnalytics.data[i].nifcliente+'. ';
        errorMessage += sedes.containsKey(wrapperAnalytics.data[i].orgventas) ? '' :'No existe la sede '+wrapperAnalytics.data[i].orgventas+'. ';
        errorMessage += sectores.containsKey(wrapperAnalytics.data[i].sector)  ? '' :'No existe el sector '+wrapperAnalytics.data[i].sector+'. ';
        errorMessage += consejos.containsKey(wrapperAnalytics.data[i].cebe)  ? '' :'No existe el consejo '+wrapperAnalytics.data[i].cebe+'. ';
        if((idsCliente.containsKey(idcliente) || nifCliente.containsKey(wrapperAnalytics.data[i].nifcliente)) 
        && sedes.containsKey(wrapperAnalytics.data[i].orgventas) && sectores.containsKey(wrapperAnalytics.data[i].sector) 
        && consejos.containsKey(wrapperAnalytics.data[i].cebe)){
            
            mesesImporte.clear();
            //Lista con los meses introducidos con index 0 hasta 11 y su importe.
            mesesImporte.add(wrapperAnalytics.data[i].enero);
            mesesImporte.add(wrapperAnalytics.data[i].febrero);
            mesesImporte.add(wrapperAnalytics.data[i].marzo);
            mesesImporte.add(wrapperAnalytics.data[i].abril);
            mesesImporte.add(wrapperAnalytics.data[i].mayo);
            mesesImporte.add(wrapperAnalytics.data[i].junio);
            mesesImporte.add(wrapperAnalytics.data[i].julio);
            mesesImporte.add(wrapperAnalytics.data[i].agosto);
            mesesImporte.add(wrapperAnalytics.data[i].septiembre);
            mesesImporte.add(wrapperAnalytics.data[i].octubre);
            mesesImporte.add(wrapperAnalytics.data[i].noviembre);
            mesesImporte.add(wrapperAnalytics.data[i].diciembre);
             String fecha;
            for(Integer y = analiticasTotales ; y <=11 ; y++){
                Analitica__c analytic = new Analitica__c();
                analytic.recordTypeId = Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get('Backlog').RecordTypeId;
                analytic.Elemento_PEP__c = String.isBlank(wrapperAnalytics.data[i].denominacion) ? '' : wrapperAnalytics.data[i].denominacion;
                analytic.Tipo_Proyecto__c =  String.isBlank(wrapperAnalytics.data[i].clvper) ? '' : wrapperAnalytics.data[i].clvper;
                  if(y<10 && y!=0){
                    fecha='0'+String.valueof(y+1);
                }else {
                    fecha =String.valueof(y+1);
                }
                analytic.Fecha__c = Date.parse('01/'+fecha+'/'+wrapperAnalytics.data[i].anio);
                analytic.importe__c = mesesImporte[y];
                analytic.CurrencyIsoCode = String.isBlank(wrapperAnalytics.data[i].moneda) ? '' : wrapperAnalytics.data[i].moneda;
                analytic.Consejo__c =consejos.containsKey( wrapperAnalytics.data[i].cebe) == true ? wrapperAnalytics.data[i].cebe : '';
                analytic.Clan__c = clan__mdt.getInstance(wrapperAnalytics.data[i].clan) == null ? 'Sin Asignar': clan__mdt.getInstance(wrapperAnalytics.data[i].clan).nombre__c; 
                analytic.CodigoPEP__c = String.isBlank(wrapperAnalytics.data[i].elemento_pep) ? '' :  wrapperAnalytics.data[i].elemento_pep;
                analytic.Cuenta__c = idsCliente.containsKey(idcliente) ?  idsCliente.get(idcliente) : nifCliente.get(wrapperAnalytics.data[i].nifcliente);
                //analytic.Oficina_Tecnica__c =  wrapperAnalytics.data[i].oficina == null ? '' :  wrapperAnalytics.data[i].oficina; //Puede ser un problema también.
                analytic.mercado__c = sectores.containsKey(wrapperAnalytics.data[i].sector) == true ? sectores.get(wrapperAnalytics.data[i].sector) : '';
                analytic.Propietario__c = users.containsKey(idcomercial)? users.get(idcomercial) : UserInfo.getUserId(); 
                analytic.Venta_Extra__c = String.isBlank(wrapperAnalytics.data[i].ve) ? false : true;
                analytic.Sede_Venta__c = sedes.get(wrapperAnalytics.data[i].orgventas);
                analytic.Proyecto_Estrategico__c = String.isBlank(wrapperAnalytics.data[i].pres) ? false : true;
               analyticsToCreate.add(analytic);
               
            }
            } else{
                Log__c errorLog = new Log__c();
                errorLog.Error__c = errorMessage+' : '+wrapperAnalytics.data[i];
                errorlog.Type__C = 'Backlog';
                errorlog.Metodo__c = 'Crea  Analytics';
                errorLogs.add(errorLog);
            }
        }
    }
    
    if(!analyticsToCreate.isEmpty()){
        //System.enqueueJob(new Queueable_Analytics(analyticsToCreate));
       List<Database.SaveResult> sresultList =  Database.insert(analyticsToCreate,false);
        system.debug('FREE'+sresultList );
       for (Database.SaveResult sr : sresultList) {
        if (!sr.isSuccess()) {
            for(Database.Error err : sr.getErrors()) {
                Log__c errorLog = new Log__c();
                errorLog.Error__c = 'Error creando analíticas '+err.getStatusCode() + ': ' + err.getMessage()+': '+err.getFields();
                errorlog.Type__C = 'Backlog';
                errorlog.Metodo__c = 'CreateAnalytics';
                errorLogs.add(errorLog);
            }
        }
    }
    }

}catch (Exception exc) {
        Log__c errorLog = new Log__c();
        errorLog.Error__c = 'Se ha producido un error inesperado al intentar crear las analíticas: '+exc.getCause()+'/'+exc.getMessage();
        errorlog.Type__C = 'Backlog';
        errorlog.Metodo__c = 'CreateAnalytics';
        errorLogs.add(errorLog);
    }finally{
        if(!errorLogs.isEmpty()){
            //System.enqueueJob(new Queueable_Analytics(errorLogs));
            insert errorLogs;
        }
    }
}

/**
 * @author Adrián Bernardo
 * @description calcula el mes actual y las analíticas que habrá que crear.
 * @return devuelve el mes actual en número
 */
public static Integer calculoAnalyticas(){
    return Date.today().month() -2 ;
    //Enero 1 - 1;
    //Febrero 2 - 1;
    //Diciembre 12 - 1;
}

/**
 * @author Adrián Bernardo
 * description: añade las sedes descendientes de las marcadas como valor en el mapa al mapa
 * que contiene las sedes
 * @date 21/03/2023
 */
public static void sumSedes (Map<String,String> sedes){

    if(sedes.containsKey('1210')){
        sedes.put('1240', sedes.get('1210'));
        sedes.put('1280', sedes.get('1210'));
        sedes.put('1220', sedes.get('1210'));
        sedes.put('1230', sedes.get('1210'));
    }
    if(sedes.containsKey('4510')){
        sedes.put('4590', sedes.get('4510'));
        sedes.put('4610', sedes.get('4510'));
        sedes.put('4520', sedes.get('4510'));
    }
    if(sedes.containsKey('1410')){
        sedes.put('1420', sedes.get('1410'));
    }
    if(sedes.containsKey('1110')){
        sedes.put('1120', sedes.get('1110'));
    }

}
}