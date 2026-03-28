public class Constants 
{

    public static final string CAMPAIGN_RECORDTYPE_INTERNAL = 'Campana_interna';
    public static final string CAMPAIGN_STATE_PLANIFIED = 'Planificada';
	public static final string CAMPAIGN_STATE_ACTIVE = 'Activa';
    public static final string CAMPAIGN_STATE_ENDED = 'Finalizada';
    
    public static final string NAMED_CREDENTIALS_SAP = 'Current_Org';

    public static final string SAP_ACCOUNTS_PATH = '/services/apexrest/TestWS';
    /*LAS 3 SIGUIENTES VARIABLES SIRVEN PARA ESPECIFICAR EL ENDPOINT DE UNA LLAMADA REST*/
    public static final string SAP_LPS_PREVENTA_PATH = '';  //POR DEFINR
    public static final string SAP_LPS_EJECUCION_PATH = ''; //POR DEFINIR
    public static final string SAP_OPPORTUNITIES_PATH = ''; //POR DEFINIR

    ///////////////////////////OPPORTUNITY STAGE DEVELOPERNAMES 
    public static final string OPPORTUNITY_STAGE_IDENTIFIED = 'Identificada';
    public static final string OPPORTUNITY_STAGE_PRESALE = 'Preventa';
    public static final string OPPORTUNITY_STAGE_SUBMITTED = 'Entregada';
    public static final string OPPORTUNITY_STAGE_DISPLAYED = 'Presentada';
    public static final string OPPORTUNITY_STAGE_WON = 'Ganada';

    ///////////////////////////OPPORTUNITY RECORDTYPE DEVELOPERNAMES 
    public static final string OPPORTUNITY_RECORDTYPE_PRESALE = 'Preventa';
    public static final string OPPORTUNITY_RECORDTYPE_CONCEPTUALIZATION = 'Conceptualizacion';
    public static final string OPPORTUNITY_RECORDTYPE_TM = 'TM';
    public static final string OPPORTUNITY_RECORDTYPE_RENOVACION = 'Renovacion';

	public static final string TASK_RECORDTYPE_ACTIONPLAN = 'Action Plan';
    //AnaliticaRecordTypes
    public static final string TASK_RECORDTYPE_DEVCACTIONPLAN = 'Action_Plan';
    
    public static final string ANALITIC_FORECAST_LINEAS = 'ForecastDeLinea';
    public static final string ANALITIC_FORECAST_OPORTUNIDADES = 'ForecastDeOportunidades';

    public static final string ANALITIC_FORECAST_LINEAS_Rafa = 'ForecastImporteTotal_Presupuesto';
    public static final string ANALITIC_FORECAST_OPORTUNIDADES_Rafa = 'ForecastImporteXprob_Presupuesto';
  


    public static final string ACCOUNT_RECORDTYPE_INTERNAL = 'Cuenta_interna';
    public static final string ACCOUNT_RECORDTYPE_EXTERNAL = 'Cuenta_externa';
    public static final string ACCOUNT_RECORDTYPE_GROUP = 'Grupo';

    public static final string PROJECT_LINE_RECORDTYPE_AM = 'AM';
    public static final string PROJECT_LINE_RECORDTYPE_LICENSES = 'Licencias';
    public static final string PROJECT_LINE_RECORDTYPE_TURNKEY = 'Llave_en_Mano';
    public static final string PROJECT_LINE_RECORDTYPE_RENOVE = 'Licencias_Renovaci_n';
    public static final string PROJECT_LINE_RECORDTYPE_SERVICIOS = 'Licencias_Servicios';



    public static final string CONTACT_RECORDTYPE_PROJECTMANAGER = 'Jefe_de_Proyecto';
    public static final string CONTACT_RECORDTYPE_STANDAR = 'Ordinario';


    public static final string DEFAULT_TEAM_MEMBER_ROLE_OPPORTUNITY_TEAM = 'Equipo_generado';
    public static final string DEFAULT_ACCESS_LEVEL_OPPORTUNITY_TEAM = 'Edit';
    public static final string DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY = 'Read';
    public static final string DEFAULT_ACCESS_LEVEL_OPPS_WHEN_SHARING_OPPTY = 'None';
    public static final string DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME = 'VASS Madrid';

    /*LA SIGUIENTE VARIABLE ESTABLECE LOS CAMPOS CUYO VALOR SE DEBE COMPROBAR QUE HA CAMBIADO (AL MENOS UNO) PARA ENVIAR UNA CUENTA A SINCRONIZAR TRAS SU ACTUALIZACION*/
    public static final List<string> CAMPOS_A_COMPROBAR_ACCOUNT = new List<String>
    {   
                                                                                        'Name', 
                                                                                        'Razon_Social__c', 
                                                                                        'NIF_CIF__c', 
                                                                                        'BillingAddress', 
                                                                                        'BillingStreet', 
                                                                                        'BillingCity', 
                                                                                        'BillingCountryCode', 
                                                                                        'BillingPostalCode', 
                                                                                        'Phone', 
                                                                                        'Fax', 
                                                                                        'Mercado__c', 
                                                                                        'Sectores__c'
    };

    //---------Linea_de_Proyecto__c----------------CAMPOS--------------------
    //Lista de campos necesarios para invocar el WS de de actualización de PEP
    public static final List<String> CAMPOS_COMPROBAR_LINEA_PREVENTA = new List<String>
    {
                                                                                        'Name',
                                                                                        'Area__c',
                                                                                        'Fecha_Fin__c',
                                                                                        'Fecha_Inicio__c',
                                                                                        'Gerencia__c',
                                                                                        'Jefe_de_Proyecto_de_Preventa__c',
                                                                                        'Margen_real__c',
                                                                                        'Importe_total_2__c',
                                                                                        'Responsable_de_LDP__c',
                                                                                        'Tecnologia__c'
    }; 

    public static final List<String> CAMPOS_COMPROBAR_LINEA_EJECUCION = new List<String>
    {
                                                                                        'Name',
                                                                                        'Codigo_SAP_Ejecucion__c',
                                                                                        'Area__c',
                                                                                        'Clave_de_Periodificacion__c',
                                                                                        'Fecha_Fin__c',
                                                                                        'Fecha_Inicio__c',
                                                                                        'Gerencia__c',
                                                                                        'Jefe_de_Proyecto_de_Ejecucion__c',
                                                                                        'Margen_real__c',
                                                                                        'Importe_total_2__c',
                                                                                        'Responsable_de_LDP__c',
                                                                                        'Tecnologia__c'
    };

    public static final List<String> ESTADOS_OPP_RELACIONADA_PREVENTA = new List<String>{'Preventa','Presentada','Entregada'};



    ////////////////////////////////////////////////////SECTORES////////////////////////////////////////////////////////////////////
    //Mapeo de códigos de sectores en SAP VS nombres en Salesforce
    public static final Map<String,String> SECTORESSAP = new Map<String,String>
    {
        'Estruct.-Estructura'       => '00',
        'A.Pub-Admin. Pública'      => '10',
        'Banca-Banca'               => '20',
        'Telco-Telco'               => '30',
        'Telco-Media'               => '40',
        'Industria-Industria'       => '60',
        'Seguros-Seguros'           => '70',
        'Environment'               => '80',
        'Energía'                   => '90'
    };

    ////////////////////////////////////////////////////MERCADOS////////////////////////////////////////////////////////////////////
    //Mapeo de códigos de mercados en SAP VS nombres de sectores en Salesforce   
    public static final Map<String,String> MERCADOSSAP = new Map<String,String>
    {
        'Estruct.-Estructura'       => '00',     
        'A.Pub-Admin. Pública'      => '10',          
        'Banca-Banca'               => '20',      
        'Telco-Telco'               => '30',              
        'TTelco-Media'              => '30',              
        'Industria-Industria'       => '40', 
        'Seguros Global'            => '50',          
        'Environment'               => '60',              
        'Energía'                   => '60'              
    };


public static final List<String> SEDE_VENTA_SINCRO_SAP = new List<String>{'VASS Madrid2'};

    public static final List<String> SEDE_SINCRO_SAP = new List<String>{'1210','1000','	1110'};
    
    public static final List<String> REGION_CUENTA_SINCRO_SAP = new List<String>{'Madrid','Barcelona','Sedes España'};

    public static final List<String> DIVISAS_CRM = new List<String>{'AUD', 'CAD', 'CHF', 'CLP', 'COP', 'DKK', 'EUR', 'GBP', 'MKD', 'MXN', 'MYR', 'NOK', 'PEN', 'RON', 'SEK', 'SGD', 'USD'};
}