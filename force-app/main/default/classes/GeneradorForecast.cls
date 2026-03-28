public class GeneradorForecast {

      /**
    *@description: MetodoFuture para crear el forecast desde las lineas serializadas
    *@param serializedObjs Description: linea de proyecto a serializar
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
    **/ 

    @future(callout=true)
    public static void CreateForecastFromTrigger(String serializedObjs,String tipo) 
    {
        List<Linea_de_Proyecto__c> Lineas = (List<Linea_de_Proyecto__c>) JSON.deserialize(serializedObjs, List<Linea_de_Proyecto__c>.class); 
        GeneradorForecast.GenerarForecastNuevasLineas(Lineas,tipo);
    }

      @future(callout=true)
    public static void CreateForecastFromTriggerLicenses(String serializedObjs,String tipo) 
    {
        List<Linea_de_Proyecto__c> Lineas = (List<Linea_de_Proyecto__c>) JSON.deserialize(serializedObjs, List<Linea_de_Proyecto__c>.class); 
        GeneradorForecast.GenerarForecastNuevasLineasLicencias(Lineas);
    }


     /**
    *@description: Comprueba si las lineas cumplen las condiciones para la generacion de forecast y las lineas serializadas
    *@param name Description: linea de proyecto a comprobar
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
    **/ 
  public static void serializeandGenerateForecastLinea (list<Linea_de_Proyecto__c> lineasProyecto, String tipo){


     String serializedLineas;
     integer i=0;
     List<Linea_de_Proyecto__c>   linea = new List<Linea_de_Proyecto__c>();
       List<Linea_de_Proyecto__c>   licencias = new List<Linea_de_Proyecto__c>();
     Set<String> idsLP = new Set<String>();
     integer prob =0;

     if(tipo=='Linea'){
      
        prob=70;

     }


     for (Linea_de_Proyecto__c lp : lineasProyecto){

          idsLP.add(lp.Id);
          
     }

          
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
                                                     Oportunidad__c,
                                                    Oportunidad__r.probability,
                                                    Oportunidad__r.Sede_Venta__c,
                                                    Oportunidad__r.Owner.Name,
                                                    Oportunidad__r.Multibooking__c,
                                                    Oportunidad__r.mercado__c,
                                                    Oficina_tecnica__c,
                                                    Importe_Total_Intercompany__c,
                                                    Coste_Estimado_Intercompany__c,
                                                    Margen_Intercompany__c,
                                                      Oportunidad__r.CloseDate,
                                                    Beneficio_Intercompany__c,
                                                    Fecha_Activacion_Licencias__c,
                                                    sede__c,
                                                    EsIntercompany__c,
                                                    Importe_x_Prob__c 
                            from Linea_de_Proyecto__c WHERE Id IN :idsLP
                            AND Gerencia__c!=Null 
                            AND Fecha_Inicio__c!=Null 
                            AND Fecha_Fin__c!=null 
                            AND Oportunidad__r.probability >=:prob 
                            AND Oportunidad__r.StageName in('Identificada','Solicitada','Preventa','Entregada','Presentada')
                            AND Comprobacion_Fecha__c =true
                            AND No_aplica_para_ejecucion__c = FALSE
                            AND Agrupacion_Tipo_Registro__c='Servicios'

                                ];


                            licencias = [SELECT   Id,
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
                                                Oportunidad__c,
                                              Oportunidad__r.probability,
                                              Oportunidad__r.Sede_Venta__c,
                                              Oportunidad__r.Owner.Name,
                                              Oportunidad__r.Multibooking__c,
                                              Oportunidad__r.CloseDate,
                                              Oportunidad__r.mercado__c,
                                              Oficina_tecnica__c,
                                              Importe_Total_Intercompany__c,
                                              Coste_Estimado_Intercompany__c,
                                              Margen_Intercompany__c,
                                              Beneficio_Intercompany__c,
                                              sede__c,
                                              Fecha_Activacion_Licencias__c,
                                              EsIntercompany__c,
                                              Importe_x_Prob__c 
                      from Linea_de_Proyecto__c WHERE Id IN :idsLP
                      AND Area__c !=Null 
                      AND Gerencia__c!=Null 
                      AND Fecha_Inicio__c!=Null 
                      AND Fecha_Fin__c!=null 
                      AND Oportunidad__r.probability >=:prob 
                      AND Oportunidad__r.StageName in('Identificada','Solicitada','Preventa','Entregada','Presentada')
                      AND Comprobacion_Fecha__c =true
                      AND No_aplica_para_ejecucion__c = FALSE
                      AND Agrupacion_Tipo_Registro__c='Licencias'

                          ];
      
                                    
            if(!linea.isEmpty())
            {
            
               serializedLineas = JSON.serialize(linea);
               GeneradorForecast.CreateForecastFromTrigger(serializedLineas,tipo);
            }   

            if(!licencias.isEmpty() && label.SwitchForcastLicencias=='True')
            {
            
               serializedLineas = JSON.serialize(licencias);
             GeneradorForecast.CreateForecastFromTriggerLicenses(serializedLineas,tipo);
            }   

  }



public static void GenerarForecastNuevasLineasLicencias(list<Linea_de_Proyecto__c> lineasProyecto){

            List<Licencia__c>   licencias = new List<Licencia__c>();
            Set<id>   lps = new Set<id>();

            map<id,list<Licencia__c>> lclpmap =new   map<id,list<Licencia__c>>();
            map<Linea_de_Proyecto__c,list<Licencia__c>> lclpmap2 =new   map<Linea_de_Proyecto__c,list<Licencia__c>>();
            map<id,Linea_de_Proyecto__c> lpsmap= new map<id,Linea_de_Proyecto__c> ();
            map<id,Licencia__c> lcsmap= new map<id,Licencia__c> ();
            List<Analitica__c> analist = new List<Analitica__c>(); 
            for ( Linea_de_Proyecto__c linea:lineasProyecto ){
                
                lps.add(linea.id);
                lpsmap.put(linea.id,linea);

            }

            Licencias=[Select  Fecha_de_activacion__c ,Importe_a_elevar__c ,Linea_de_Proyecto__c from Licencia__c where  Linea_de_Proyecto__c IN : lps  and Activa__c=True];


              
            
            for(Licencia__c lc :Licencias  ){
                
                if(lclpmap.containskey(lc.Linea_de_Proyecto__c)){
                  lclpmap.get(lc.Linea_de_Proyecto__c).add(lc);
                }else {
                  lclpmap.put(lc.Linea_de_Proyecto__c,new list<Licencia__c>{lc});
                }
                
            }
          
            for(Linea_de_Proyecto__c lp :lineasProyecto ){

              if(lclpmap.get(lp.id)!=null){
                lclpmap2.put(lp,lclpmap.get(lp.id));
              }


            }

            for(Linea_de_Proyecto__c linea:lclpmap2.keyset() ){

              for(Licencia__c lc:lclpmap2.get(linea) ){

                  Analitica__c analitica = new Analitica__c();
                  analitica.Clan__c = linea.Gerencia__c;
                  analitica.Consejo__c = linea.Area__c;
                  analitica.Cuenta__c = linea.Oportunidad__r.AccountId;
                  analitica.CurrencyISOCode = linea.CurrencyISOCode;
                  analitica.Linea_de_Proyecto__c = linea.Id;
                  analitica.Propietario__c = linea.Oportunidad__r.OwnerId;
                  analitica.Tipo_de_Proyecto__c = linea.RecordType.Name;                 
                  analitica.Oportunidad__c=linea.Oportunidad__c;
                  analitica.Mercado__c=linea.Oportunidad__r.mercado__c;
                  analitica.Propietarios_Multibooking__c=linea.Oportunidad__r.Owner.Name;
                  analitica.fecha__c=linea.Oportunidad__r.CloseDate;
                  analitica.descripcion__c='Nuevo forecast licencias';
                  
                  if(label.TipoDeRegistroForecastLicencias=='True'){
                    analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_LINEAS).getRecordTypeId();
                    analitica.Tipo__c='ForecastDeLinea';
                  }else{
                    analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_OPORTUNIDADES).getRecordTypeId();
                    analitica.Tipo__c='ForecastDeOportunidades';
                  }

                  if(linea.Oficina_tecnica__c!=null){
                    analitica.Oficina_Tecnica__c=linea.Oficina_tecnica__c;
                  }

                  analitica.Sede_Venta__c=linea.Oportunidad__r.Sede_Venta__c;
                  analitica.Importe_Forecast__c=lc.Importe_a_elevar__c;

                if(linea.EsIntercompany__c==true){
                List<Account>  sede_inter= [Select id from Account where Sede_Analitica__c=: linea.sede__c] ;
    
                  analist.add(GeneradorForecast.GenerarForecastNuevasLineasLicenciasintercompany(linea));
                  analitica.Importe_Forecast__c=lc.Importe_a_elevar__c;
                  analitica.Sede_Venta__c=sede_inter.get(0).id;

                  }else{
                     analitica.Importe_Forecast__c=lc.Importe_a_elevar__c;
                     analitica.Sede_Venta__c=linea.Oportunidad__r.Sede_Venta__c;
                  }
                 
                  
                
                  
                 
          
    
                  analist.add(analitica);
                  }
                }
       
          insert(analist);
}

public static Analitica__c GenerarForecastNuevasLineasLicenciasintercompany(Linea_de_Proyecto__c linea){

                  Analitica__c analitica = new Analitica__c();
                  analitica.Clan__c = linea.Gerencia__c;
                  analitica.Consejo__c = linea.Area__c;
                  analitica.Cuenta__c = linea.Oportunidad__r.AccountId;
                  analitica.CurrencyISOCode = linea.CurrencyISOCode;
                  analitica.Linea_de_Proyecto__c = linea.Id;
                  analitica.Propietario__c = linea.Oportunidad__r.OwnerId;
                  analitica.Tipo_de_Proyecto__c = linea.RecordType.Name;                 
                  analitica.Oportunidad__c=linea.Oportunidad__c;
                  analitica.Mercado__c=linea.Oportunidad__r.mercado__c;
                  analitica.Propietarios_Multibooking__c=linea.Oportunidad__r.Owner.Name;
                  analitica.fecha__c=linea.Oportunidad__r.CloseDate;
                  analitica.descripcion__c='Nuevo forecast licencias';
                  
                  if(label.TipoDeRegistroForecastLicencias=='True'){
                    analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_LINEAS).getRecordTypeId();
                    analitica.Tipo__c='ForecastDeLinea';
                  }else{
                    analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_OPORTUNIDADES).getRecordTypeId();
                    analitica.Tipo__c='ForecastDeOportunidades';
                  }

                  if(linea.Oficina_tecnica__c!=null){
                    analitica.Oficina_Tecnica__c=linea.Oficina_tecnica__c;
                  }


               
                 
                  analitica.Importe_Forecast__c=linea.Importe_Total_Intercompany__c;
                  analitica.Sede_Venta__c=linea.Oportunidad__r.Sede_Venta__c;

                  return analitica;
                 


}


 /**
    *@description: Generara las analiticas de forecast en la creacion de las lineas si se cumplen las condiciones necesarias
    *@param name Description: lineasProyecto, las lineas sobre las que generar Forecast
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
    **/ 

    public static void GenerarForecastNuevasLineas(list<Linea_de_Proyecto__c> lineasProyecto,String Tipo){
            
        try {       
              Integer i;
              Integer j;
              Integer diasdelmes;
              Decimal prorrateo;
              Integer diasdelmesInicio;
              Integer diasdelmesFinal;
              Integer Numeroanaliticas;
              Integer Numerodedias;
              Integer Flag1mes=0;
              Decimal ImporteParcial=0;
              Integer prueba;
              Integer suma=0;
              boolean bool=true;
              Decimal Importetotal;
       
				List<Comerciales_Multibooking__c >   relacion = new List<Comerciales_Multibooking__c >();
              list<Linea_de_Proyecto__c> lineasagenerar = new List<Linea_de_Proyecto__c>();
              List<Analitica__c> analist = new List<Analitica__c>(); 
               List<Analitica__c> analist2 = new List<Analitica__c>();
              system.debug('-------GeneradorForecast-----------');
        	
                   if(lineasProyecto.get(0).Oportunidad__r.Multibooking__c==true){

                          relacion=[select   id ,Mercado__c ,Comercial__r.Name ,Principal__c  from Comerciales_Multibooking__c where Oportunidad__c = :lineasProyecto.get(0).Oportunidad__c];
                           
                            }
                            system.debug('numero lin' + lineasProyecto.size());               
              for ( Linea_de_Proyecto__c linea:lineasProyecto ){
                      //comprobamos si la linea cumple las condiciones necesarias para generar Forecast
                      system.debug('lineaaaaaaaaaa'+lineasProyecto.size());
                     
                      
                              
                         
                              
                              //si ha cumplido las condiciones necesarias sigue
                          if(linea!=null){              

                                        
                                          //obtenemos las fechas de inicio y de fin de la linea y las convertimos a formato Date
                                          date fechainicio=Date.newInstance(linea.Fecha_Inicio__c.year() ,linea.Fecha_Inicio__c.month(), linea.Fecha_Inicio__c.day());
                                          date fechafin=Date.newInstance(linea.Fecha_Fin__c.year() ,linea.Fecha_Fin__c.month(), linea.Fecha_Fin__c.day());

                                          Numerodedias=fechainicio.daysBetween(fechafin)+1;
                                          system.debug('gheg'+linea.EsIntercompany__c);


                                          if(linea.EsIntercompany__c ==true){
                                           
                                            analist.addAll(GenerarForecastNuevasLineasIntercompany(linea,tipo));                                                                                  
                                            prorrateo=linea.Importe_Total_Intercompany__c/Numerodedias;
                                            Importetotal=linea.Importe_Total_Intercompany__c;
                                          }else{
                                            prorrateo=linea.Importe_a_elevar__c/Numerodedias;
                                            Importetotal=linea.Importe_a_elevar__c;
                                          }
                                          
                                            //Si empiza y acaba en el mismo mes , se generara solo una analitica con toda la cantidad de la linea       
                                          if(fechainicio.month()== fechafin.month() && fechainicio.year()==fechafin.year()){
                                            
                                            Flag1mes=1;

                                          //Si empieza y acaba en meses diferentes tenemos que obtener los dias que del mes inicial para prorratear el importe por dias el primer mes
                                        }else {

                                            diasdelmesInicio=date.daysInMonth(fechainicio.year(), fechainicio.month()) -fechainicio.day() +1 ;

                                        }

                                            //Se calcula el numero de analitcas necesarias, que seria el  nº de meses de fin-inicial +1
                                            Numeroanaliticas=fechainicio.monthsBetween(fechafin) +1;

                                            suma+=Numeroanaliticas;

                              
                                          
                                          
                                            //se calcula el numerod e dias entre las fecha de inicio y fin y se calcula la cantidad que corresponderia por dias.
                                            //Numerodedias=fechainicio.daysBetween(fechafin)+1;
                                            //prorrateo=linea.Importe_a_elevar__c/Numerodedias;

                                    
                              
                                            // Para cada analitica:
                                            for(j=0; j<Numeroanaliticas;j++){

                                                              Analitica__c analitica = new Analitica__c();
                                                              analitica.Clan__c = linea.Gerencia__c;
                                                              analitica.Consejo__c = linea.Area__c;
                                                              analitica.Cuenta__c = linea.Oportunidad__r.AccountId;
                                                              analitica.CurrencyISOCode = linea.CurrencyISOCode;
                                                              analitica.Linea_de_Proyecto__c = linea.Id;
                                                              analitica.Propietario__c = linea.Oportunidad__r.OwnerId;
                                                              analitica.Tipo_de_Proyecto__c = linea.RecordType.Name;
                                                              analitica.Fecha__c = linea.Fecha_Inicio__c.addMonths(j);
                                                              analitica.Oportunidad__c=linea.Oportunidad__c;
                                                              analitica.Sede_Venta__c=linea.Oportunidad__r.Sede_Venta__c;
                                                              analitica.Mercado__c=linea.Oportunidad__r.mercado__c;
                                                              analitica.Propietarios_Multibooking__c=linea.Oportunidad__r.Owner.Name;

                                                              if(linea.Oficina_tecnica__c!=null){
                                                                analitica.Oficina_Tecnica__c=linea.Oficina_tecnica__c;
                                                              }
                                                            

                                                              

                                                              if(Tipo=='Linea'){
                                                              analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_LINEAS).getRecordTypeId();
                                                              analitica.Tipo__c='ForecastDeLinea';
                                                              }else{
                                                              analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_OPORTUNIDADES).getRecordTypeId();
                                                              analitica.Tipo__c='ForecastDeOportunidades';
                                                              }
                                                              //si la linea solo inicia y finaliza el mismo mes, el importe de la analitica es todo el de la linea
                                                              if(Flag1mes==1 && j==0){
                                                              
                                                                    if(Tipo=='Linea'){
                                                                        analitica.Importe_Forecast__c= Importetotal;
                                                                      
                                                                        ImporteParcial+=Importetotal;
                                                                    }else {
                                                                        analitica.Importe_Forecast__c= Importetotal* (linea.Oportunidad__r.probability/100);
                                                                        ImporteParcial+= Importetotal * (linea.Oportunidad__r.probability/100);

                                                                          }
                                                                  

                                                              //para la primera analitica que se genera se mira el numero de dias del primer mes y se multiplica por el prorrateo
                                                              }else if(j==0) {

                                                                    if(Tipo=='Linea'){
                                                                    analitica.Importe_Forecast__c=diasdelmesInicio*prorrateo;
                                                                  
                                                                    ImporteParcial+=diasdelmesInicio*prorrateo;
                                                                    }else {
                                                                      
                                                                    analitica.Importe_Forecast__c= diasdelmesInicio * prorrateo * (linea.Oportunidad__r.probability/100);
                                                                    ImporteParcial+= prorrateo * (linea.Oportunidad__r.probability/100);


                                                                          }

                                                              //para la ultima analitica se mira los dias del ultimo mes y se prorratea.    
                                                              }else if(j==Numeroanaliticas-1){

                                                                    if(Tipo=='Linea'){
                                                                    analitica.Importe_Forecast__c=fechafin.day()*prorrateo;    
                                                                    ImporteParcial+=fechafin.day()*prorrateo;
                                                                    }else {
                                                                        analitica.Importe_Forecast__c=fechafin.day()* prorrateo * (linea.Oportunidad__r.probability/100);
                                                                        ImporteParcial+= prorrateo * (linea.Oportunidad__r.probability/100);

                                                                          }

                                                              //Para las analiticas intermedias, se coge el numero de dias del mes y se multiplica por el prorrateo
                                                              }else {
                                                                date fecha_analitica=Date.newInstance(linea.Fecha_Inicio__c.year() ,linea.Fecha_Inicio__c.month(), linea.Fecha_Inicio__c.day());
                                                                    fecha_analitica=fecha_analitica.addMonths(j);
                                                                    if(Tipo=='Linea'){
                                                                  
                                                                    analitica.Importe_Forecast__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo;
                                                                    ImporteParcial+=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo;
                                                                    }else {
                                                                  
                                                                        analitica.Importe_Forecast__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo*(linea.Oportunidad__r.probability/100) ;
                                                                        ImporteParcial+=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo*(linea.Oportunidad__r.probability/100) ;

                                                                          }
                                                              }
                                                              
                                                              if(linea.Oportunidad__r.Multibooking__c==true){

                                                                  
                                                                  
                                                                  for(i=0;i<relacion.size();i++){
                                                                    if(relacion.get(i).Principal__c==false){
                                                                    
                                                                      
                                                                      analitica.Mercado__c=analitica.Mercado__c+';'+relacion.get(i).Mercado__c;
                                                                      analitica.Propietarios_Multibooking__c+=  '\n' + relacion.get(i).Comercial__r.Name ;

                                                          
                                                                    
                                                                    }
                                                                  }
                                                                  
                                                                  
                                                                

                                                            }

                                                              system.debug('suma----------------------------'+analist.size());
                                                              analist.add(analitica);
                                                              system.debug('suma----------------------------'+analist.size());
                                                              
                                                              Flag1mes=0;
                                                              ImporteParcial=0;	
                                                              suma=0;
                                                          
                                                }

                                      
                                                
                          }
                     
                          system.debug('linea'+lineasProyecto.size());
                        
              }

              system.debug('----------sss-----------------'+analist.size());
              insert analist;
              
              

                } catch(DmlException e) {
             LogUtil.addLog('Error en la generadion de forecast para las lineas'+lineasProyecto);

        }
          }
 /**
    *@description: Generara las analiticas de forecast intercompany en la creacion de las lineas si se cumplen las condiciones necesarias
    *@param name Description: lineasProyecto, las lineas sobre las que generar Forecast
    *@author name: Amartos
    *@date date: 12/04/2020
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
    **/ 


  public static list<Analitica__c> GenerarForecastNuevasLineasIntercompany(Linea_de_Proyecto__c linea,String Tipo){
            
            try {       
                  Integer z;
                  Integer j;
                  Integer diasdelmes;
                  Decimal prorrateo;
                  Integer diasdelmesInicio;
                  Integer diasdelmesFinal;
                  Integer Numeroanaliticas;
                  Integer Numerodedias;
                  Integer Flag1mes=0;
                  Decimal ImporteParcial=0;
                  Integer prueba;
                  Integer suma=0;
                  boolean bool=true;
           
                  
                  list<Linea_de_Proyecto__c> lineasagenerar = new List<Linea_de_Proyecto__c>();
                  List<Analitica__c> analist = new List<Analitica__c>(); 
                   List<Analitica__c> analist2 = new List<Analitica__c>();
                   List<Account>  sede_inter= [Select id from Account where Sede_Analitica__c=: linea.sede__c ] ;

                  
    
         
                      
                          
                          //si ha cumplido las condiciones necesarias sigue
                      if(linea!=null){              
    
                              //obtenemos las fechas de inicio y de fin de la linea y las convertimos a formato Date
                              date fechainicio=Date.newInstance(linea.Fecha_Inicio__c.year() ,linea.Fecha_Inicio__c.month(), linea.Fecha_Inicio__c.day());
                              date fechafin=Date.newInstance(linea.Fecha_Fin__c.year() ,linea.Fecha_Fin__c.month(), linea.Fecha_Fin__c.day());
                              
                                //Si empiza y acaba en el mismo mes , se generara solo una analitica con toda la cantidad de la linea       
                              if(fechainicio.month()== fechafin.month() && fechainicio.year()==fechafin.year()){
                                
                                Flag1mes=1;
    
                              //Si empieza y acaba en meses diferentes tenemos que obtener los dias que del mes inicial para prorratear el importe por dias el primer mes
                            }else {
    
                                diasdelmesInicio=date.daysInMonth(fechainicio.year(), fechainicio.month()) -fechainicio.day() +1 ;
    
                            }
    
                                //Se calcula el numero de analitcas necesarias, que seria el  nº de meses de fin-inicial +1
                                Numeroanaliticas=fechainicio.monthsBetween(fechafin) +1;
    
                                suma+=Numeroanaliticas;
    
                               
                              
                               
                                //se calcula el numerod e dias entre las fecha de inicio y fin y se calcula la cantidad que corresponderia por dias.
                                Numerodedias=fechainicio.daysBetween(fechafin)+1;
                                prorrateo=linea.Importe_a_elevar__c/Numerodedias;
    
                         
                   
                                // Para cada analitica:
                                for(j=0; j<Numeroanaliticas;j++){
    
                                    Analitica__c analitica = new Analitica__c();
                                    analitica.Clan__c = linea.Gerencia__c;
                                    analitica.Consejo__c = linea.Area__c;
                                    analitica.Cuenta__c = linea.Oportunidad__r.Sede_Venta__c;
                                    analitica.CurrencyISOCode = linea.CurrencyISOCode;
                                    analitica.Linea_de_Proyecto__c = linea.Id;
                                    analitica.Propietario__c = linea.Oportunidad__r.OwnerId;
                                    analitica.Tipo_de_Proyecto__c = linea.RecordType.Name;
                                    analitica.Fecha__c = linea.Fecha_Inicio__c.addMonths(j);
                                    analitica.Oportunidad__c=linea.Oportunidad__c;
                                    analitica.Sede_Venta__c=sede_inter.get(0).id;
                                    analitica.Mercado__c=linea.Oportunidad__r.mercado__c;
                                    analitica.Propietarios_Multibooking__c=linea.Oportunidad__r.Owner.Name;
                                    analitica.GeneradoIntercompany__c=true;
    
                                    if(linea.Oficina_tecnica__c!=null){
                                       analitica.Oficina_Tecnica__c=linea.Oficina_tecnica__c;
                                    }
                                  
    
                                    
    
                                    if(Tipo=='Linea'){
                                    analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_LINEAS).getRecordTypeId();
                                    analitica.Tipo__c='ForecastDeLinea';
                                    }else{
                                    analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_OPORTUNIDADES).getRecordTypeId();
                                   analitica.Tipo__c='ForecastDeOportunidades';
                                    }
                                    //si la linea solo inicia y finaliza el mismo mes, el importe de la analitica es todo el de la linea
                                    if(Flag1mes==1 && j==0){
                                    
                                          if(Tipo=='Linea'){
                                               analitica.Importe_Forecast__c= linea.Importe_a_elevar__c;
                                          
                                               ImporteParcial+=linea.Importe_a_elevar__c;
                                          }else {
                                               analitica.Importe_Forecast__c= linea.Importe_a_elevar__c* (linea.Oportunidad__r.probability/100);
                                               ImporteParcial+= linea.Importe_a_elevar__c * (linea.Oportunidad__r.probability/100);
    
                                                }
                                         
    
                                    //para la primera analitica que se genera se mira el numero de dias del primer mes y se multiplica por el prorrateo
                                    }else if(j==0) {
    
                                          if(Tipo=='Linea'){
                                          analitica.Importe_Forecast__c=diasdelmesInicio*prorrateo;
                                         
                                          ImporteParcial+=diasdelmesInicio*prorrateo;
                                          }else {
                                             
                                           analitica.Importe_Forecast__c= diasdelmesInicio * prorrateo * (linea.Oportunidad__r.probability/100);
                                           ImporteParcial+= prorrateo * (linea.Oportunidad__r.probability/100);
    
    
                                                }
    
                                    //para la ultima analitica se mira los dias del ultimo mes y se prorratea.    
                                    }else if(j==Numeroanaliticas-1){
    
                                          if(Tipo=='Linea'){
                                          analitica.Importe_Forecast__c=fechafin.day()*prorrateo;    
                                          ImporteParcial+=fechafin.day()*prorrateo;
                                          }else {
                                              analitica.Importe_Forecast__c=fechafin.day()* prorrateo * (linea.Oportunidad__r.probability/100);
                                              ImporteParcial+= prorrateo * (linea.Oportunidad__r.probability/100);
    
                                                }
    
                                    //Para las analiticas intermedias, se coge el numero de dias del mes y se multiplica por el prorrateo
                                    }else {
                                       date fecha_analitica=Date.newInstance(linea.Fecha_Inicio__c.year() ,linea.Fecha_Inicio__c.month(), linea.Fecha_Inicio__c.day());
                                          fecha_analitica=fecha_analitica.addMonths(j);
                                          if(Tipo=='Linea'){
                                         
                                          analitica.Importe_Forecast__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo;
                                          ImporteParcial+=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo;
                                          }else {
                                        
                                              analitica.Importe_Forecast__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo*(linea.Oportunidad__r.probability/100) ;
                                              ImporteParcial+=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo*(linea.Oportunidad__r.probability/100) ;
    
                                                }
                                    }
                                    
                                  
                          
                                    analist.add(analitica);
    
                                    
                                    Flag1mes=0;
                                    ImporteParcial=0;	
                                    suma=0;
                                    }
    
                              
                          
                      }
    
                  
    
                      system.debug('rentornamos' + analist);
                 // insert analist;
                  return analist;
                  
    
                    } catch(DmlException e) {
                 LogUtil.addLog('Error en la generadion de forecast para las lineas'+linea);
                      return null;
            }
              }



   


  /**
    *@description: Si se modifican las lineas , se vuelve hacer la generacion de forecast con los nuevos datos si cumplen los requesitos
    *@param name Description: linea de proyecto a compobar y modifcar 
    *@author name: Amartos
    *@date date: 25/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
  **/ 


public static void ModificarForecast(list<Linea_de_Proyecto__c> lineasProyecto){  


      Integer i=0;
      List<Analitica__c> analist = new List<Analitica__c>(); 
      List<Analitica__c> anadelete=new List<Analitica__c>(); 
      Set<String> idsLP = new Set<String>();

    //Borramos las analiticas asociadas a la linea que se ha modificado
      for (Linea_de_Proyecto__c lp: lineasProyecto) 
            {
              idsLP.add(lp.Id);       
            }

          
  if(idsLP.size()!=0){

    anadelete=[SELECT Id FROM Analitica__c WHERE    RecordType.Name='ForecastDeLinea'  AND Linea_de_Proyecto__c IN :idsLP ];

    delete anadelete;
  }

		system.debug('deleteamos')  ;
    //Se vuelven a generar el forecast a partir de las modificaciones
    GeneradorForecast.serializeandGenerateForecastLinea(lineasProyecto,'Linea');
    
   

}


 /**
    *@description: Si se modifica la oportunidad  , se vuelve hacer la generacion de forecast con los nuevos datos si cumplen los requesitos
    *@param name Description: Oportunididad Modificada
    *@author name: Amartos
    *@date date: 28/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
  **/ 


public static void ModificarForecastFromOpportunity(list<Opportunity> Oportunidad,Integer Flag){  

      
      List<Linea_de_Proyecto__c> lineas = new List<Linea_de_Proyecto__c>(); 
      set<id> ids= new set<id>();
      system.debug('opooooor' +Oportunidad);
      integer i=0;

        for (i=0; i<Oportunidad.size();i++){
          
            ids.add(Oportunidad.get(i).id);
        }
      
        lineas.addAll([SELECT id ,name FROM Linea_de_Proyecto__c where Oportunidad__c IN :ids]);

        //se tiene en cuenta si se ha modificado la probabilidad u otros campos de la oportunidad se genera el forecast de linea  
          if((Flag==1 ||Flag==2) ){

            
            GeneradorForecast.ModificarForecast(lineas);
          
          }  
        
        //si se modifica algun otro campo de vuelve a generar el forecast para las oportunidades se genera el de oportuniades
        if(Flag==2 || Flag ==3 || Flag==1){

            if(Label.SwitchForecastOpor=='True'){
            GeneradorForecast.GenerarForecastOportunidad(Oportunidad);
            }
        }

        
        
    
  
}

 /**
    *@description: Comprueba que campos de la oportunidad se han modificado para tomar una decision sobre la modificacion del forecast
    *@param name Description: Oportunididad Modificada
    *@author name: Amartos
    *@date date: 28/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
  **/ 


public static Integer CumpleCondicionesOportunidadForecast(list<Opportunity> Oportunidadnew, map<Id,Opportunity> Oportunidadold ){  
      
        system.debug('comprobacion estado------');
        Integer Flag=0;
        Opportunity oldOpp;
        Set<ID> setOpps = new Set<ID>();
        List<Opportunity> listOpp = new List<Opportunity>();


        for (Opportunity opp : Oportunidadnew)
        {            
          oldOpp = Oportunidadold.get(opp.Id);

            if((oldOpp.probability!=Opp.probability) && oldOpp.StageName==Opp.StageName  && oldOpp.SumaImportesIntercompany__c==Opp.SumaImportesIntercompany__c && oldOpp.Importe_total__c==Opp.Importe_total__c &&oldOpp.Fecha_de_fin__c==Opp.Fecha_de_fin__c
              &&oldOpp.Fecha_de_inicio__c==Opp.Fecha_de_inicio__c  ){
              Flag=1;
            }
  
            if((oldOpp.probability!=Opp.probability)  && oldOpp.StageName!=Opp.StageName  || oldOpp.SumaImportesIntercompany__c!=Opp.SumaImportesIntercompany__c || oldOpp.Importe_total__c!=Opp.Importe_total__c || oldOpp.Fecha_de_fin__c!=Opp.Fecha_de_fin__c
             || oldOpp.Fecha_de_inicio__c!=Opp.Fecha_de_inicio__c || oldOpp.Multibooking__c!=Opp.Multibooking__c  ){
               Flag=2;
              }

            if((oldOpp.probability==Opp.probability)  && oldOpp.StageName!=Opp.StageName || oldOpp.SumaImportesIntercompany__c!=Opp.SumaImportesIntercompany__c    || oldOpp.Importe_total__c!=Opp.Importe_total__c || oldOpp.Fecha_de_fin__c!=Opp.Fecha_de_fin__c
             || oldOpp.Fecha_de_inicio__c!=Opp.Fecha_de_inicio__c ){
               Flag=3;
              }

        
        }

        return Flag;
  
  }

   /**
    *@description: Generara las analiticas de forecast en la creacion de las lineas si se cumplen las condiciones necesarias
    *@param name Description: lineasProyecto, las lineas sobre las que generar Forecast
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
    **/ 

    public static void GenerarForecastOportunidad(list<Opportunity> Oportunidad){
  
        

          List<Analitica__c> analiticas = new List<Analitica__c>(); 
          List<Analitica__c> analist = new List<Analitica__c>(); 
          List<Linea_de_Proyecto__c>   lineas = new List<Linea_de_Proyecto__c>();
          Integer i=0;    

         Set<String> idsOPP = new Set<String>();
  



          for (Opportunity opp : Oportunidad){

                idsOPP.add(opp.Id);
                
          }
  

            system.debug('--------------------------------------------------------------------bbbbbbbbbb' +idsOPP);
          if(idsOPP.size()!=0){
          analiticas.addAll([SELECT Id  FROM Analitica__c  where   RecordType.Name='ForecastDeOportunidades'  AND Oportunidad__c IN :idsOPP]);
  			 
         system.debug('--------------------------------------------------------------------aaa' +analiticas.size());
          }
          if (analiticas.size()>0){
              
           
            delete analiticas;
          }

   			
          lineas.addAll([SELECT id  FROM Linea_de_Proyecto__c where Oportunidad__c IN  :idsOPP]);
               
          system.debug(lineas.size());
          GeneradorForecast.serializeandGenerateForecastLinea(lineas,'opor');

    }


    
 /**
    *@description: Comprueba si ha cmabiado los cambios de fecha de la linea, en caso afirmativo modifica el forcecast asociado al impxprob
    *@param name Description: Oportunididad Modificada
    *@author name: Amartos
    *@date date: 03/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Generadorforecast
  **/ 


public static Boolean CambiaFechaLP(list<Linea_de_Proyecto__c> LPNew, map<Id,Linea_de_Proyecto__c> LPOLD ){


         system.debug('comprobacion fecha Linea------');
        Linea_de_Proyecto__c oldLp;
        Set<ID> setLp = new Set<ID>();
        List<Linea_de_Proyecto__c> listlp = new List<Linea_de_Proyecto__c>();
        List<Linea_de_Proyecto__c> listlp2 = new List<Linea_de_Proyecto__c>();

        List<Opportunity> Oportunidad = new List<Opportunity>(); 

        integer i=0;

        for (Linea_de_Proyecto__c lp : LPNew)
        {            
          oldLp = LPOLD.get(lp.Id);

            if((oldLp.Fecha_Inicio__c!=lp.Fecha_Inicio__c) || (oldLp.Fecha_Fin__c!=lp.Fecha_Fin__c)  ){


                
          for (i=0; i<LPNew.size();i++){


           listlp2=[SELECT Oportunidad__r.id  FROM Linea_de_Proyecto__c where Id IN (:LPNew.get(i).id)];
           

           Oportunidad=[SELECT id  FROM Opportunity where Id IN (:listlp2.get(i).Oportunidad__c) ];

            
            GeneradorForecast.ModificarForecastFromOpportunity( Oportunidad,3);


  
          }
        
              
              return true;
            }
  

        
        }

        return false;
  
  }
      


}