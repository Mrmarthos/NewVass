@isTest
private class LOBCalculationTest {

    @testSetup
    static void setupData() {
        // Creamos una oportunidad de prueba
        Opportunity opp = new Opportunity(
            Name = 'Oportunidad Test',
            StageName = 'Identificada',
            CloseDate = Date.today(),
            Mercado__c = 'Banca-Banca',
            Amount=10,
            lob__c = '01'
        );
        insert opp;

        // Creamos una línea de proyecto principal
        Linea_de_Proyecto__c lineaPrincipal = new Linea_de_Proyecto__c(

            sede__c='1410',
            Gerencia__c = 'Intelligent Technology',
            Linea_principal__c = true,
            Oportunidad__c = opp.Id
        );
        insert lineaPrincipal;

        // Creamos una línea de proyecto secundaria
        Linea_de_Proyecto__c lineaSecundaria = new Linea_de_Proyecto__c(
             sede__c='1410',

            Gerencia__c = 'Intelligent Technology',
            Linea_principal__c = false,
            Oportunidad__c = opp.Id
        );
        insert lineaSecundaria;
    }

    @isTest
    static void testActualizarLOB_Basico() {
        // Obtenemos la línea principal por nombre
        Linea_de_Proyecto__c linea = [SELECT Name FROM Linea_de_Proyecto__c  LIMIT 1];

        // Creamos la request correctamente
        LOBCalculation.Request req = new LOBCalculation.Request();
        req.lineaDeProyectoId = linea.Name;

        Test.startTest();
        LOBCalculation.actualizarLOB(new List<LOBCalculation.Request>{ req });
        Test.stopTest();

        // Verificamos la actualización de la línea
        Linea_de_Proyecto__c updatedLinea = [SELECT lob__c FROM Linea_de_Proyecto__c  LIMIT 1];
        System.assertEquals('05', updatedLinea.lob__c, 'El LOB de la línea principal no se actualizó correctamente.');

        // Verificamos la actualización de la oportunidad
        Opportunity updatedOpp = [SELECT lob__c FROM Opportunity WHERE Name = 'Oportunidad Test' LIMIT 1];
        System.assert(updatedOpp.lob__c.contains('05'), 'El LOB de la oportunidad no contiene el valor esperado.');
        System.assert(updatedOpp.lob__c.contains('06'), 'El LOB de la oportunidad no contiene el valor 06 para mercado especial.');
        System.assert(updatedOpp.lob__c.contains('01'), 'El LOB de la oportunidad no mantiene el valor original.');
    }

    @isTest
    static void testActualizarLOB_GerenciaNoMapeada() {
        // Creamos una línea con gerencia no mapeada
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Linea_de_Proyecto__c lineaNoMapeada = new Linea_de_Proyecto__c(
             sede__c='1410',
            Gerencia__c = '	S/4',
            Linea_principal__c = true,
            Oportunidad__c = opp.Id
        );
        insert lineaNoMapeada;

        LOBCalculation.Request req = new LOBCalculation.Request();
        req.lineaDeProyectoId = lineaNoMapeada.Name;

        Test.startTest();
        LOBCalculation.actualizarLOB(new List<LOBCalculation.Request>{ req });
        Test.stopTest();

        Linea_de_Proyecto__c updatedLinea = [SELECT lob__c FROM Linea_de_Proyecto__c  LIMIT 1];
    }

    @isTest
    static void testActualizarLOB_SinRequests() {
        // Prueba de manejo de lista vacía (debe lanzar excepción)
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            LOBCalculation.actualizarLOB(new List<LOBCalculation.Request>());
            Test.stopTest();
        } catch(Exception e) {
            exceptionThrown = true;
            System.assert(e.getMessage().contains('Se debe proporcionar'), 'Mensaje de excepción no esperado.');
        }
        System.assert(exceptionThrown, 'No se lanzó excepción con lista vacía.');
    }
}