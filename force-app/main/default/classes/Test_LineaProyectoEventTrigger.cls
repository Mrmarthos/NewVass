@IsTest
private class Test_LineaProyectoEventTrigger {
    
    @isTest
    static void test_triggerUpdateCorrect()
    {
        Test.setMock(WebServiceMock.class, new WebServiceMockGenerator()); 
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());        
        //se inicializan los datos
        List<Linea_de_Proyecto__c> lineaProtyectoList = new List<Linea_de_Proyecto__c>();
        List<E_Linea_de_Proyecto__e> eventoList = new List<E_Linea_de_Proyecto__e>();

        Map<String, List<Object>> camposLineaProyecto;
        Map<String, List<Object>> camposEvento;
        
        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        //Inserta 2 Oportunidades preventa
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
 
        //Crear dos Lineas de Proyecto una para ejecución y otra para preventa
        camposLineaProyecto = new Map<String, List<Object>>{

            'Codigo_SAP_Ejecucion__c' => new List<String>{
                                                    '1E',
                                                    ''},
            'Codigo_SAP_Preventa__c'  => new List<String>{
                                                    '',
                                                    '2P'},
                                                     'Oficina_tecnica__c' 				  => new List<String>{'1000','1000'},
            'Oportunidad__c'          => new List<String>{
                                                    opps[0].Id,
                                                    opps[0].Id}                                                   
        };
        
        lineaProtyectoList = TestUtil.rellenarSObject(Linea_de_Proyecto__c.sObjectType, camposLineaProyecto);
        Test.startTest();
        //Crear dos eventos para actualizar ejecución y otra para preventa
        insert lineaProtyectoList;
        camposEvento = new Map<String, List<Object>>{
            'eoperacion__c'           => new List<String>{    
                                                    'UPDATE',
                                                    'UPDATE',
                                                    'UPDATE',
                                                    'UPDATE',
                                                    'UPDATE'},
            'Codigo_SAP_Ejecucion__c' => new List<String>{
                                                    '1E',
                                                    '1ep',
                                                    '',
                                                    '',
                                                    '3E'},
            'Codigo_SAP_Preventa__c'  => new List<String>{
                                                    '',
                                                    '',
                                                    '2P',
                                                    '2pe',
                                                    '3P'},            
            'Hito_1__c'             => new List<String>{
                                                    'prueba',
                                                    '',
                                                    'prueba',
                                                    '2pe',
                                                    '3P'},
            'Oportunidad__c'          => new List<String>{
                                                    opps[0].Id,
                                                    opps[0].Id,
                                                    opps[0].Id,
                                                    opps[0].Id,
                                                    opps[0].Id}                                                   
        };
                    
        eventoList = TestUtil.rellenarSObject(E_Linea_de_Proyecto__e.sObjectType, camposEvento);

        //insert eventoList;
        List<Database.SaveResult> result = EventBus.publish(eventoList);
        Test.stopTest();

        List<Linea_de_Proyecto__c> lps = [ select Id, Codigo_SAP_Preventa__c, Hito_1__c from Linea_de_Proyecto__c
                                            where Codigo_SAP_Preventa__c IN ('2P','2pe','3P') OR 
                                                  Codigo_SAP_Ejecucion__c IN ('1E','1ep','3E')];

        //ASSERT comprobamos que solo devuelve una Lista de tamaño dos (son los registros existentes en salesforce)
        //y que la clave de periodificación de ambos ha cambiado a prueba
        System.assertEquals(lps.size(), 2);
        System.assertEquals(lps.get(0).get('Hito_1__c'), 'prueba');
        System.assertEquals(lps.get(1).get('Hito_1__c'), 'prueba');

 
    }
}