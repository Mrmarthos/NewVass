public class EPPM_Config {
    // Configuración base
    // 
    private static final Eppm__mdt CONFIG = Eppm__mdt.getInstance('Eppm');
    public static final String ENDPOINT = CONFIG?.Endpoint__c; // Safe navigation
    public static final String USERNAME = CONFIG?.Username__c;
    public static final String PASSWORD = CONFIG?.Password__c;
    public static final Integer MAX_RETRIES = 0;
   
    // Campos monitoreados para cambios
    public static final Set<String> TRACKED_FIELDS = new Set<String>{
        'StageName','OportunidadRelacionada__c',
        'CodOferta__c','Importe_total__c','Importe_de_lineas__c','Name','GSO_Validated__c',
        'Amount','Fecha_de_inicio__c','Fecha_de_fin__c','CloseDate',
        'Sede_Venta__c','CurrencyIsoCode','LOB__c','Description',
        'Clan_Principal__c','Margen_real__c','Strategic_Partner__c','N_Cargas_Excel__c',
        'Account__c','OwnerId','Probability','Commited__c','ID_SAP__c','Oportunidad_Relacionada__c','SendToEppm__c',
        'Framework_Contract__c','Mercado__c','Probability'
    };

    
    
}