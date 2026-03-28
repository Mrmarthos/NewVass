@isTest

public class Test_Forecast_Rafa{
    // ******************* TEST INDIVIDUALES Y CASOS ESPECIALES ******************* 
    // 
    
       public static User u1;
    public static User u2;
    public static User u3;
    public static User u4;
    public static User u5;
    public static User u6;
    public static User u7;
    
    @isTest
    static void ForecastImpxprob() 
    {
        // Insertar 5 usuarios
        Id comercialProfileId = [SELECT Id FROM Profile WHERE Name = 'Comercial'].Id;
        Id adminProfileId = [SELECT Id FROM Profile WHERE Name = 'Administrador del sistema' OR Name = 'System administrator'].Id;
        Id gerenteOperacionesRolId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Gerente_de_operaciones'].Id;        
        Id responsableAreaRolId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Responsable_de_area'].Id;
        User admin = [SELECT Id FROM User WHERE ProfileId =: adminProfileId AND IsActive = true LIMIT 1];
       
       System.runAs(admin){
         u1 = new User(
            ProfileId = comercialProfileId,
            LastName = 'last',
            Email = 'resp1@vass.com',
            Username = 'resp1@vass.com.' + System.currentTimeMillis(),
            CompanyName = 'ExampleCompany',
            Title = 'Title',
            Alias = 'Alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Gerente__c=True,
            LocaleSidKey = 'en_US'
        );
        insert u1;
        
     
       //*******************************************/
       }
		List<Account> accs = TestUtil.generaCuentasTest();
        // Insertar dos oportunidades
        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();

        List<Opportunity> opptys = new List<Opportunity>();
        
		List<Opportunity> opptys2 = new List<Opportunity>();
        
        Opportunity opp1 = new Opportunity(
            Name = 'Opportunity 1',
            RecordTypeId = preventaRecordTypeId,
            StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED,
            CloseDate = Date.newInstance(2018, 12, 16),
            Bid_Manager__c = u1.Id,
            Offering__c = u1.Id,
            Business_Value__c = u1.Id,
            Mercado__c='Banca-Banca',
            Probability=50,
            Amount=99,
            AccountId=accs.get(0).id
        );
        
        opptys.add(opp1);

        insert opptys;

 
              
        insert opptys2;
        
        opp1 = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity 1'];
        
        // Insertar cuatro lineas de proyecto
        List<Linea_de_Proyecto__c> projectLines = new List<Linea_de_Proyecto__c>();
        
        projectLines.add(new Linea_de_Proyecto__c(
            Oportunidad__c = opp1.Id,
            Responsable_de_LDP__c = u1.Id,
            Fecha_Inicio__c=date.newInstance(2019, 01, 01),
            Fecha_Fin__c=date.newInstance(2019, 01, 30),
            Oficina_tecnica__c='1000',
            Importe_total_2__c=8000
            
        ));
 
      
 		
        insert projectLines;
        
     
     integer i=0;
     List<Linea_de_Proyecto__c>   linea = new List<Linea_de_Proyecto__c>();
    List<Opportunity>   Oportunidad1 = new List<Opportunity>();

     integer prob =0;




                            linea = [SELECT   Id,
                                                    Gerencia__c,
                                                    Area__c, 
                                                    CurrencyISOCode,
                                                    Oportunidad__r.OwnerId,
                                                    RecordType.Name, 
                                                    Oportunidad__r.AccountId,
                                                    Duracion_de_Linea__c, 
                                                    Importe_prorrateado_x_prob__c, 
                                                    Fecha_Inicio__c,
                                                    Fecha_Fin__c,
                                                    Duracion_lineas_por_meses__c,
                                                    Importe_a_elevar__c,
                                                    Coste_real__c,
                                                    Oportunidad__c,
                                                    Oportunidad__r.probability,
                                                    Oportunidad__r.Sede_Venta__c,
                                                    Oportunidad__r.Owner.Name,
                                                    Oportunidad__r.Multibooking__c,
                                                    Oportunidad__r.mercado__c,
                                                    Importe_x_Prob__c 
                            from Linea_de_Proyecto__c WHERE Oportunidad__c = :opp1.id
                           

                                ];
  			Oportunidad1 = [SELECT   Id,probability,StageName  ,Importe_total__c,Fecha_de_fin__c,Fecha_de_inicio__c,Multibooking__c from Opportunity  where Id= :opp1.id];

   		  map<Id,Opportunity>  oportunidad = new map<Id,Opportunity> ();
        
        oportunidad.put(Oportunidad1.get(0).Id, Oportunidad1.get(0));
     
       

		ForecastRafa.GenerarForecastNuevasLineas(linea, 'opor');
             
    
        Analitica__c analitica = [SELECT Id ,Importe_Forecast__c FROM Analitica__c WHERE   Oportunidad__c =:opp1.id];

        test.startTest();
		ForecastRafa.serializeandGenerateForecastLinea ([SELECT Id FROM Linea_de_Proyecto__c WHERE No_aplica_para_ejecucion__c = FALSE and id='a021X000001xk1cQAA' ] , 'Linea');
        test.stopTest();
        system.assert(analitica.Importe_Forecast__c >0);
        system.assertEquals(ForecastRafa.CumpleCondicionesOportunidadForecast(Oportunidad1,oportunidad),0);
      


    }
    
    
    
    
    
    

    

}