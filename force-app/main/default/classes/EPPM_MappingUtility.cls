public class EPPM_MappingUtility {
    private static EPPM_MappingUtility instance;
    private final Map<String, String> mercadoMapping;
    private final Map<String, String> clanMapping;
    private final Map<String, String> stageMapping;
    private final Map<String, String> TipoMapping;
        private final Map<String, String> TypoMapping;
    private EPPM_MappingUtility() {
        mercadoMapping = new Map<String, String>{
        'A.Pub-Admin. Pública' => '100',
        'Banca-Banca' => '200',
        'Telco-Telco' => '300',
        'Education & Services' => '410',
        'Logistics & Transportation' => '420',
        'Automotive & Mobility' => '430',
        'Life Science' => '440',
        'Manufacturing' => '450',
        'Travel & Hospitality & Leisure' => '460',
        'Seguros-Seguros' => '500',
        'Retail & Consu Goods' => '700',
        'Energía' => '600'
    };

        clanMapping = new Map<String, String>{
        'Estructura' => 'N000',
        'Comercial' => 'N001',
        'Nateevo - Consulting' => 'N002',
        'Nateevo - Experience' => 'N003',
        'Nateevo - Smartech' => 'N004',
        'Nateevo - Development' => 'N005',
        'Nateevo - Brand Services' => 'N006',
        'Nateevo-Business Value' => 'N007',
        'Sin Asignar' => 'N008',
        'Digital Experience' => 'V002',
        'Tailor-Made Solutions' => 'V003',
        'Governance & Infrastructure' => 'V005',
        'Talent Solutions' => 'V007',
        'Operaciones' => 'V009',
        'Integration & Processes' => 'V014',
        'Delivery Cross' => 'V016',
        'Customer Centric' => 'V017',
        'Regulatory & Data' => 'V004',
        'No utilizar (Consultoría)' => 'V006',
        'Innovación (BV)' => 'V010',
        'Proyectos Internos' => 'V011',
        'Hybris' => 'V013',
        'Business Consulting' => 'V018',
        'Datamorphosys' => 'V019',
        'Staffing (MX)' => 'MX20',
        'Servicios Diversos (Serb)' => 'S020',
        'Customer Experience' => 'T002',
        'Intelligent Technology' => 'T005',
        'S/4' => 'T004',
        'Comunytek' => 'V021',
        'Intelligent Enterprise' => 'T001',
        'SAP CX' => 'V023',
        'Nateevo Inside VASS' => 'V024',
           'T4S Inside VASS'=>'V025',
        'Nateevo - Delivery Success' => 'N011',
        'Nateevo - Data & Analytics' => 'N009',
        'Nateevo - Media' => 'N010'
    };
    

        stageMapping = new Map<String, String>{
            'Preventa' => 'PRV',
                'Entregada' =>'ENT' ,
                'Presentada' => 'PRS',
                'Ganada' => 'GAN',
                'Perdida' => 'PER',
                'Cancelada'=>'CAN'
    };
         TipoMapping = new Map<String, String>{
            'Estándar' => 'ST',
                'T&M' =>'TM' 
    };
           TypoMapping = new Map<String, String>{
            'New' => 'NEW',
            'Renewal' =>'RNV' ,
            'Extension' =>'EXT' 
    };
    }

    public static EPPM_MappingUtility getInstance() {
        if(instance == null) instance = new EPPM_MappingUtility();
        return instance;
    }

    public String getMercadoCode(String mercadoName) {
        return mercadoMapping.get(mercadoName);
    }
    
     public String getTipoCode(String Tipo) {
        return TipoMapping.get(Tipo);
    }
      public String getTypoCode(String typo) {  // Cambio de parámetro a minúscula (convención)
    return TypoMapping.containsKey(typo) ? 
           TypoMapping.get(typo) : '';    // Devuelve vacío si no existe
}


    public String getClanCode(String clanName) {
        return clanMapping.containsKey(clanName) ? 
               clanMapping.get(clanName) : clanMapping.get('Sin Asignar');
    }

    public String getStageCode(String stageName) {
        return stageMapping.get(stageName) ?? stageName;
    }
}