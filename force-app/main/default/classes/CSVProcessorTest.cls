@isTest
private class CSVProcessorTest {
    @testSetup
    static void setupData() {
        // Crear datos de prueba usando utilidades propias
        List<Account> accs = TestUtil.generaCuentasTest();
        List<Contact> conts = TestUtil.generaContactosTest(accs);
        List<Opportunity> opps = TestUtil.generaOportunidadesPreventaTest(accs, conts);
        List<Account> Sedes = TestUtil.generaSedeTest();
        List<Linea_de_proyecto__c> lps = TestUtil.generaLineasLlaveManoTest(opps, conts);

        // Crear ContentVersion simulando un CSV válido
String csvContent = 
'OPPCODE;ID_SALESBU;DESC_SALESBU;ID_BUSINESSUNIT;DESC_BUSINESSUNIT;ID_SERVICELINE;DESC_SERVICELINE;ID_PRACTISE;DESC_PRACTISE;ID_PHASE;DESC_PHASE;CUSTOMERROLE;ID_ROL;DESC_ROL;STARTDATE;ENDDATE;HOURS;TOTALHOURS;SOWPRICE;LISTHOUR;MINSTARTING;BREAKPOINT;PRICE_ROL;COST_ROL;SOURCE_COST;TOTAL_COST;DISCFRONLISTCURR;DISCFRONLISTPERCENTAGE;TOTAL_PRICE;TSTARTDATE;TENDDATE;CURR;ID_TYPE;DESC_TYPE;ID_FILE\n' +
'VASS2581828;1410;T4S SPAIN;1410;T4S SPAIN;T004;SAP S/4;TS00T04001;SAP S/4;PH01;Project;EDI;ZCA0146;Senior Functional Consultant;01/09/2025;05/09/2025;22;64;77,53164557;87,5;87,5;68,18;4962,025316;2400;Medium;2400;637,9746835;0,1139;7000;01/09/2025;26/09/2025;EUR;SFTYPE01;Project;SFC_FP_3\n' +
'VASS2581828;1410;T4S SPAIN;1410;T4S SPAIN;T004;SAP S/4;TS00T04001;SAP S/4;PH01;Project;EDI 2;ZCA0148;Associate Functional Consultant;01/09/2025;05/09/2025;10;40;39,87341772;45;45;28,85;1594,936709;634,8;Medium;634,8;205,0632911;0,1139;7000;01/09/2025;26/09/2025;EUR;SFTYPE01;Project;SFC_FP_3';

        Blob csvBlob = Blob.valueOf(csvContent);

        ContentVersion cv = new ContentVersion(
            Title = 'TestCSV',
            PathOnClient = 'test.csv',
            VersionData = csvBlob
        );
        insert cv;
    }

    @isTest
    static void testProcessCSV_Success() {
        Opportunity opp = [SELECT Id, Codigo_de_oportunidad__c FROM Opportunity LIMIT 1];

     

String csvContent = 
'OPPCODE;ID_SALESBU;DESC_SALESBU;ID_BUSINESSUNIT;DESC_BUSINESSUNIT;ID_SERVICELINE;DESC_SERVICELINE;ID_PRACTISE;DESC_PRACTISE;ID_PHASE;DESC_PHASE;CUSTOMERROLE;ID_ROL;DESC_ROL;STARTDATE;ENDDATE;HOURS;TOTALHOURS;SOWPRICE;LISTHOUR;MINSTARTING;BREAKPOINT;PRICE_ROL;COST_ROL;SOURCE_COST;TOTAL_COST;DISCFRONLISTCURR;DISCFRONLISTPERCENTAGE;TOTAL_PRICE;TSTARTDATE;TENDDATE;CURR;ID_TYPE;DESC_TYPE;ID_FILE\n' +
opp.Codigo_de_oportunidad__c + ';1410;T4S SPAIN;1410;T4S SPAIN;T004;SAP S/4;TS00T04001;SAP S/4;PH01;Project;EDI;ZCA0146;Senior Functional Consultant;01/09/2025;05/09/2025;22;64;77,53164557;87,5;87,5;68,18;4962,025316;2400;Medium;2400;637,9746835;0,1139;7000;01/09/2025;26/09/2025;EUR;SFTYPE01;Project;SFC_FP_3\n' +
opp.Codigo_de_oportunidad__c + ';1410;T4S SPAIN;1410;T4S SPAIN;T004;SAP S/4;TS00T04001;SAP S/4;PH01;Project;EDI 2;ZCA0148;Associate Functional Consultant;01/09/2025;05/09/2025;10;40;39,87341772;45;45;28,85;1594,936709;634,8;Medium;634,8;205,0632911;0,1139;7000;01/09/2025;26/09/2025;EUR;SFTYPE01;Project;SFC_FP_3\n' +
opp.Codigo_de_oportunidad__c + ';1410;T4S SPAIN;1410;T4S SPAIN;T004;SAP S/4;TS00T04001;SAP S/4;PH01;Project;JP;ZCA0111;Project Manager;01/09/2025;05/09/2025;2;8;55,3797468;62,5;62,5;51,67;443,037975;227,36;Medium;227,36;56,9620253;0,1139;7000;01/09/2025;26/09/2025;EUR;SFTYPE01;Project;SFC_FP_3';

        Blob csvBlob = Blob.valueOf(csvContent);

        ContentVersion cv = new ContentVersion(
            Title = 'TestCSV',
            PathOnClient = 'test.csv',
            VersionData = csvBlob
        );
        insert cv;

        // Recuperar el ContentDocumentId generado
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id documentId = cv.ContentDocumentId;

        Test.startTest();
        CSVProcessor.CSVResult result = CSVProcessor.processCSV(documentId, opp.Id);
     
        Test.stopTest();
   CSVProcessor.crearHistorico('Q09MVU1OQTtDT0xVTU5CClZBTFVFMTtWQUxVRTI=', 'test', opp.Id);
    
    }

    @isTest
    static void testProcessCSV_MissingParams() {
        Test.startTest();
        try {
            CSVProcessor.processCSV(null, null);
         
        } catch (AuraHandledException e) {
          
        }
        Test.stopTest();
    }

    @isTest
    static void testProcessCSV_InvalidVersion() {
        Opportunity opp = [SELECT Id, Codigo_de_oportunidad__c FROM Opportunity LIMIT 1];

        // Crear ContentVersion con versión incorrecta
        String csvContent = 'ID_FILE;OPPCODE;ID_SALESBU;ID_SERVICELINE;ID_PRACTISE;TOTAL_PRICE;TOTAL_COST;TSTARTDATE;TENDDATE\n' +
                            'BADVERSION;OPP-001;MAD;IT;DEV;1000,00;800,00;01/07/2025;31/07/2025';
        Blob csvBlob = Blob.valueOf(csvContent);

        ContentVersion cv = new ContentVersion(
            Title = 'TestCSV2',
            PathOnClient = 'test2.csv',
            VersionData = csvBlob
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id documentId = cv.ContentDocumentId;

        Test.startTest();
        try {
            CSVProcessor.processCSV(documentId, opp.Id);
          
        } catch (AuraHandledException e) {
       
        }
        Test.stopTest();
    }

    @isTest
    static void testProcessCSV_InvalidOppCode() {
        Opportunity opp = [SELECT Id, Codigo_de_oportunidad__c FROM Opportunity LIMIT 1];

        // Crear ContentVersion con OPPCODE incorrecto
        String csvContent = 'ID_FILE;OPPCODE;ID_SALESBU;ID_SERVICELINE;ID_PRACTISE;TOTAL_PRICE;TOTAL_COST;TSTARTDATE;TENDDATE\n' +
                            'V1;WRONGCODE;MAD;IT;DEV;1000,00;800,00;01/07/2025;31/07/2025';
        Blob csvBlob = Blob.valueOf(csvContent);

        ContentVersion cv = new ContentVersion(
            Title = 'TestCSV3',
            PathOnClient = 'test3.csv',
            VersionData = csvBlob
        );
        insert cv;

        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        Id documentId = cv.ContentDocumentId;

        Test.startTest();
        try {
            CSVProcessor.processCSV(documentId, opp.Id);
          
        } catch (AuraHandledException e) {
  
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateProjectLines_Success() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Linea_de_Proyecto__c linea = [SELECT Id, Sede__c, Gerencia__c, Area__c FROM Linea_de_Proyecto__c LIMIT 1];

        // Simular datos CSV
        Map<String, String> row = new Map<String, String>{
            'ID_SALESBU' => linea.Sede__c,
            'ID_SERVICELINE' => linea.Gerencia__c,
            'ID_PRACTISE' => linea.Area__c,
            'TOTAL_PRICE' => '2000,00',
            'TOTAL_COST' => '1500,00',
            'TSTARTDATE' => '01/07/2025',
            'TENDDATE' => '31/07/2025'
        };
        List<Map<String, String>> csvRows = new List<Map<String, String>>{ row };

        String csvContent = EncodingUtil.base64Encode(Blob.valueOf('dummy'));

        Test.startTest();
        CSVProcessor.updateProjectLines(opp.Id, csvRows, csvContent);
        Test.stopTest();

        Linea_de_Proyecto__c updated = [SELECT Precio_Venta__c, Coste_Bruto__c FROM Linea_de_Proyecto__c WHERE Id = :linea.Id];

    }

    @isTest
    static void testUpdateProjectLines_EmptyContent() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        try {
            CSVProcessor.updateProjectLines(opp.Id, new List<Map<String, String>>(), '');
          
        } catch (AuraHandledException e) {
         
        }
        Test.stopTest();
    }
@isTest
static void testParseDate() {
    // Caso válido
    Date d = CSVProcessor.parseDate('09/07/2025');
    System.assertEquals(Date.newInstance(2025, 7, 9), d);

    // Cadena vacía
    Date d2 = CSVProcessor.parseDate('');
    System.assertEquals(null, d2);

    // Null
    Date d3 = CSVProcessor.parseDate(null);
    System.assertEquals(null, d3);

    // Formato incorrecto
    Date d4 = CSVProcessor.parseDate('2025-07-09');
    System.assertEquals(null, d4);

    // Partes no numéricas
    Date d5 = CSVProcessor.parseDate('xx/yy/zz');
    System.assertEquals(null, d5);

    // Menos de 3 partes
    Date d6 = CSVProcessor.parseDate('09/07');
    System.assertEquals(null, d6);
}
     @IsTest
    static void testValidDecimalWithComma() {
        Decimal d = CSVProcessor.parseDecimal('123,45');

    }

    @IsTest
    static void testValidDecimalWithPoint() {
        Decimal d = CSVProcessor.parseDecimal('678.90');
   
    }

    @IsTest
    static void testEmptyString() {
        Decimal d = CSVProcessor.parseDecimal('');
 
    }

    @IsTest
    static void testNullString() {
        Decimal d = CSVProcessor.parseDecimal(null);
        System.assertEquals(0, d, 'Valor null debe devolver 0');
    }

    @IsTest
    static void testInvalidDecimal() {
        try {
            CSVProcessor.parseDecimal('abc');
        
        } catch (AuraHandledException e) {
         
        }
    }
    
    
    
}