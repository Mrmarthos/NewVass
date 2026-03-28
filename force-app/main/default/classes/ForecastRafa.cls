public class ForecastRafa {

      /**
    *@description: MetodoFuture para crear el forecast desde las lineas serializadas
    *@param serializedObjs Description: linea de proyecto a serializar
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: ForecastRafa
    **/ 

    @future(callout=true)
    public static void CreateForecastFromTrigger(String serializedObjs,String tipo) 
    {
        List<Linea_de_Proyecto__c> Lineas = (List<Linea_de_Proyecto__c>) JSON.deserialize(serializedObjs, List<Linea_de_Proyecto__c>.class); 
        ForecastRafa.GenerarForecastNuevasLineas(Lineas,tipo);
    }


     /**
    *@description: Comprueba si las lineas cumplen las condiciones para la generacion de forecast y las lineas serializadas
    *@param name Description: linea de proyecto a comprobar
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: ForecastRafa
    **/ 
  public static void serializeandGenerateForecastLinea (list<Linea_de_Proyecto__c> lineasProyecto, String tipo){


     String serializedLineas;
     integer i=0;
     List<Linea_de_Proyecto__c>   linea = new List<Linea_de_Proyecto__c>();
     Set<String> idsLP = new Set<String>();
     integer prob =0;

     if(tipo=='Linea'){
      
        prob=70;

     }


     for (Linea_de_Proyecto__c lp : lineasProyecto){

          idsLP.add(lp.Id);
          
     }

          system.debug(idsLP.size());
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
                                                    Oficina_tecnica__c,
                                                    Oportunidad__r.mercado__c,
                                                    Coste_total_licencias__c,
                                                    Coste_real__c,
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

                                ];
      
                                
            if(!linea.isEmpty())
            {
              system.debug('Tamaño'+linea.size());
               serializedLineas = JSON.serialize(linea);
               ForecastRafa.CreateForecastFromTrigger(serializedLineas,tipo);
            }    

  }




 /**
    *@description: Generara las analiticas de forecast en la creacion de las lineas si se cumplen las condiciones necesarias
    *@param name Description: lineasProyecto, las lineas sobre las que generar Forecast
    *@author name: Amartos
    *@date date: 23/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: ForecastRafa
    **/ 

    public static void GenerarForecastNuevasLineas(list<Linea_de_Proyecto__c> lineasProyecto,String Tipo){
            
        try {       
              Integer i;
              Integer j;
              Integer diasdelmes;
              Decimal prorrateo;
              Decimal prorrateoCoste;
              Integer diasdelmesInicio;
              Integer diasdelmesFinal;
              Integer Numeroanaliticas;
              Integer Numerodedias;
              Integer Flag1mes=0;
              Decimal ImporteParcial=0;
              Integer prueba;
              Integer suma=0;
       

              list<Linea_de_Proyecto__c> lineasagenerar = new List<Linea_de_Proyecto__c>();
              List<Analitica__c> analist = new List<Analitica__c>(); 
               List<Analitica__c> analist2 = new List<Analitica__c>();
              system.debug('-------ForecastRafa-----------');

              System.debug('sizeee'+lineasProyecto.size());

              for (i=0; i<lineasProyecto.size();i++){
                      //comprobamos si la linea cumple las condiciones necesarias para generar Forecast
                      Linea_de_Proyecto__c linea =lineasProyecto.get(i);

                      system.debug(lineasProyecto.get(i).RecordType.Name);
                      if((lineasProyecto.get(i).RecordType.Name=='Licencias' || lineasProyecto.get(i).RecordType.Name=='Licencias - Renovación')){
						
                         /* 
                          
                          
                          //obtenemos las fechas de inicio y de fin de la linea y las convertimos a formato Date
                          date fechainicio=Date.newInstance(linea.Fecha_Inicio__c.year() ,linea.Fecha_Inicio__c.month(), linea.Fecha_Inicio__c.day());
                          date fechafin=Date.newInstance(linea.Fecha_Fin__c.year() ,linea.Fecha_Fin__c.month(), linea.Fecha_Fin__c.day());
                          
                            //Si empiza y acaba en el mismo mes , se generara solo una analitica con toda la cantidad de la linea       
                   
                            Flag1mes=1;
                            Numeroanaliticas=1;



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
                               

                                

                                if(Tipo=='Linea'){
                                analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_LINEAS_Rafa).getRecordTypeId();
                                analitica.Tipo__c='ForecastImporteTotal_Presupuesto';
                                }else{
                                analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_OPORTUNIDADES_Rafa).getRecordTypeId();
                                analitica.Tipo__c='ForecastImporteXprob_Presupuesto';
                                }
                                //si la linea solo inicia y finaliza el mismo mes, el importe de la analitica es todo el de la linea
                                if(Flag1mes==1 && j==0){
                                
                                      if(Tipo=='Linea'){
                                           analitica.Importe_Forecast__c= linea.Importe_a_elevar__c;
                                           system.debug('no entiendo imp----' +linea.Importe_a_elevar__c);
                                           ImporteParcial+=linea.Importe_a_elevar__c;
                                           analitica.Importe_Coste__c=linea.Coste_total_licencias__c;
                                           system.debug('no entiendo----'+linea.Coste_total_licencias__c);
                                          
                                      }

                                         else {
                                          analitica.Importe_Forecast__c= linea.Importe_a_elevar__c* (linea.Oportunidad__r.probability/100);
                                          analitica.Importe_Coste__c=linea.Coste_total_licencias__c * (linea.Oportunidad__r.probability/100);
                                        

                                            }
                                     

                                //para la primera analitica que se genera se mira el numero de dias del primer mes y se multiplica por el prorrateo
                                }
                             
                      
                                analist.add(analitica);

                                
                                Flag1mes=0;
								                ImporteParcial=0;	
                                suma=0;
                                }




						*/
                      }
                  
                      
                      //si ha cumplido las condiciones necesarias sigue
                  if(linea!=null  && lineasProyecto.get(i).RecordType.Name!='Licencias' && lineasProyecto.get(i).RecordType.Name!='Licencias - Renovación' && lineasProyecto.get(i).RecordType.Name!='Licencias - Renovación'){   

                        System.debug('NOOE EEEEEEEEEEEEEEEEENTRETERTER' +lineasProyecto.get(i).RecordType.Name);
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

                            system.debug('suma----------------------------'+suma);
                            system.debug('numanaliticas----------------------------'+Numeroanaliticas);
                           
                            //se calcula el numerod e dias entre las fecha de inicio y fin y se calcula la cantidad que corresponderia por dias.
                            Numerodedias=fechainicio.daysBetween(fechafin)+1;
                            prorrateo=linea.Importe_a_elevar__c/Numerodedias;
                            prorrateocoste=linea.Coste_real__c/Numerodedias;
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
                               

                                

                                if(Tipo=='Linea'){
                                analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_LINEAS_Rafa).getRecordTypeId();
                                analitica.Tipo__c='ForecastImporteTotal_Rafa';
                                }else{
                                analitica.RecordTypeId=Schema.SObjectType.Analitica__c.getRecordTypeInfosByDeveloperName().get(Constants.ANALITIC_FORECAST_OPORTUNIDADES_Rafa).getRecordTypeId();
                                analitica.Tipo__c='ForecastImporteXprob_Rafa';
                                }
                                //si la linea solo inicia y finaliza el mismo mes, el importe de la analitica es todo el de la linea
                                if(Flag1mes==1 && j==0){
                                
                                      if(Tipo=='Linea'){
                                           analitica.Importe_Forecast__c= linea.Importe_a_elevar__c;
                                           system.debug(linea.Importe_a_elevar__c);
                                           ImporteParcial+=linea.Importe_a_elevar__c;
                                           analitica.Importe_Coste__c=linea.Coste_real__c;
                                          
                                      }else {
                                           analitica.Importe_Forecast__c= linea.Importe_a_elevar__c* (linea.Oportunidad__r.probability/100);
                                           ImporteParcial+= linea.Importe_a_elevar__c * (linea.Oportunidad__r.probability/100);
                                           analitica.Importe_Coste__c=linea.Coste_real__c* (linea.Oportunidad__r.probability/100);
                                        

                                            }
                                     

                                //para la primera analitica que se genera se mira el numero de dias del primer mes y se multiplica por el prorrateo
                                }else if(j==0) {
											/*
                                      if(Tipo=='Linea'){
                                      analitica.Importe_Forecast__c=diasdelmesInicio*prorrateo;
                                      analitica.Importe_Coste__c=diasdelmesInicio*prorrateocoste;
                                      ImporteParcial+=diasdelmesInicio*prorrateo;
                                      }else {
                                         
                                       analitica.Importe_Forecast__c= diasdelmesInicio * prorrateo * (linea.Oportunidad__r.probability/100);
                                       analitica.Importe_Coste__c=diasdelmesInicio * prorrateocoste * (linea.Oportunidad__r.probability/100);
                                       ImporteParcial+= prorrateo * (linea.Oportunidad__r.probability/100);


                                            }
										*/
                                //para la ultima analitica se mira los dias del ultimo mes y se prorratea.    
                                }else if(j==Numeroanaliticas-1){
									/*
                                      if(Tipo=='Linea'){
                                      analitica.Importe_Forecast__c=fechafin.day()*prorrateo;    
                                      analitica.Importe_Coste__c=fechafin.day()*prorrateocoste;    
                                      ImporteParcial+=fechafin.day()*prorrateo;
                                      }else {
                                          analitica.Importe_Forecast__c=fechafin.day()* prorrateo * (linea.Oportunidad__r.probability/100);
                                          analitica.Importe_Coste__c=fechafin.day()* prorrateocoste * (linea.Oportunidad__r.probability/100);
                                          ImporteParcial+= prorrateo * (linea.Oportunidad__r.probability/100);

                                            }
									*/
                                //Para las analiticas intermedias, se coge el numero de dias del mes y se multiplica por el prorrateo
                                }else {
                                   date fecha_analitica=Date.newInstance(linea.Fecha_Inicio__c.year() ,linea.Fecha_Inicio__c.month(), linea.Fecha_Inicio__c.day());
                                      fecha_analitica=fecha_analitica.addMonths(j);
                                      if(Tipo=='Linea'){
                                     
                                      analitica.Importe_Forecast__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo;
                                      analitica.Importe_Coste__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateocoste;
                                      ImporteParcial+=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo;
                                      }else {
                                    
                                          analitica.Importe_Forecast__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo*(linea.Oportunidad__r.probability/100) ;
                                          analitica.Importe_Coste__c=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateocoste*(linea.Oportunidad__r.probability/100) ;
                                          ImporteParcial+=date.daysInMonth(fecha_analitica.year(), fecha_analitica.month())*prorrateo*(linea.Oportunidad__r.probability/100) ;

                                            }
                                }
                                system.debug('Multiboookinf'+linea.Oportunidad__r.Multibooking__c);

                                if(linea.Oportunidad__r.Multibooking__c==true){

                                     List<Comerciales_Multibooking__c >   relacion = new List<Comerciales_Multibooking__c >();
                                    
                                    //relacion=[select   id ,Mercado__c ,Comercial__r.Name ,Principal__c  from Comerciales_Multibooking__c where Oportunidad__c = :linea.Oportunidad__c];
                             
                                    
                                    
                                  

                               }
                      
                                analist.add(analitica);

                                
                                Flag1mes=0;
								                ImporteParcial=0;	
                                suma=0;
                                }

                          
                      
                  }





              }

            
              insert analist;
               system.debug('finllll'+analist.size());
              

                } catch(DmlException e) {
             LogUtil.addLog('Error en la generadion de forecast para las lineas'+lineasProyecto);

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
    *@see class/method: ForecastRafa
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

          system.debug('lpssid' + idsLP);

    anadelete=[SELECT Id FROM Analitica__c WHERE    RecordType.Name='ForecastImporteTotal_Rafa'  AND Linea_de_Proyecto__c IN :idsLP ];
    system.debug('deleteeee'+anadelete);
    //delete anadelete;

    //Se vuelven a generar el forecast a partir de las modificaciones
    ForecastRafa.serializeandGenerateForecastLinea(lineasProyecto,'Linea');
    
   

}


 /**
    *@description: Si se modifica la oportunidad  , se vuelve hacer la generacion de forecast con los nuevos datos si cumplen los requesitos
    *@param name Description: Oportunididad Modificada
    *@author name: Amartos
    *@date date: 28/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: ForecastRafa
  **/ 


public static void ModificarForecastFromOpportunity(list<Opportunity> Oportunidad,Integer Flag){  

      
      List<Linea_de_Proyecto__c> lineas = new List<Linea_de_Proyecto__c>(); 
      system.debug('opooooor' +Oportunidad);
      integer i=0;

        for (i=0; i<Oportunidad.size();i++){
            lineas.addAll([SELECT id ,name FROM Linea_de_Proyecto__c where Oportunidad__c IN (:Oportunidad.get(i).id)]);
            
        }
      

        //se tiene en cuenta si se ha modificado la probabilidad u otros campos de la oportunidad se genera el forecast de linea  
          if((Flag==1 ||Flag==2) ){

            
            ForecastRafa.ModificarForecast(lineas);
          
          }  
        
        //si se modifica algun otro campo de vuelve a generar el forecast para las oportunidades se genera el de oportuniades
        if(Flag==2 || Flag ==3 || Flag==1){

    
            ForecastRafa.GenerarForecastOportunidad(Oportunidad);
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
    *@see class/method: ForecastRafa
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

            if((oldOpp.probability!=Opp.probability) && oldOpp.StageName==Opp.StageName   && oldOpp.Importe_total__c==Opp.Importe_total__c &&oldOpp.Fecha_de_fin__c==Opp.Fecha_de_fin__c
              &&oldOpp.Fecha_de_inicio__c==Opp.Fecha_de_inicio__c  ){
              Flag=1;
            }
  
            if((oldOpp.probability!=Opp.probability)  && oldOpp.StageName!=Opp.StageName   || oldOpp.Importe_total__c!=Opp.Importe_total__c || oldOpp.Fecha_de_fin__c!=Opp.Fecha_de_fin__c
             || oldOpp.Fecha_de_inicio__c!=Opp.Fecha_de_inicio__c || oldOpp.Multibooking__c!=Opp.Multibooking__c  ){
               Flag=2;
              }

            if((oldOpp.probability==Opp.probability)  && oldOpp.StageName!=Opp.StageName   || oldOpp.Importe_total__c!=Opp.Importe_total__c || oldOpp.Fecha_de_fin__c!=Opp.Fecha_de_fin__c
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
    *@see class/method: ForecastRafa
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
          
          analiticas.addAll([SELECT Id  FROM Analitica__c  where   RecordType.Name='ForecastImporteXprob_Presupuesto'  AND Oportunidad__c IN :idsOPP]);
  			 system.debug('--------------------------------------------------------------------aaa' +analiticas.size());
          if (analiticas.size()>0){
              
           
            //delete analiticas;
          }

   			
          lineas.addAll([SELECT id  FROM Linea_de_Proyecto__c where Oportunidad__c IN  :idsOPP]);
               
          system.debug(lineas.size());
          ForecastRafa.serializeandGenerateForecastLinea(lineas,'opor');

    }


    
 /**
    *@description: Comprueba si ha cmabiado los cambios de fecha de la linea, en caso afirmativo modifica el forcecast asociado al impxprob
    *@param name Description: Oportunididad Modificada
    *@author name: Amartos
    *@date date: 03/05/2019
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: ForecastRafa
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

            
            ForecastRafa.ModificarForecastFromOpportunity( Oportunidad,3);


  
          }
        
              
              return true;
            }
  

        
        }

        return false;
  
  }
      


}