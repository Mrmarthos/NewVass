public class Generacion_Hitos_Controller {
    
    @AuraEnabled 
    public static List<HitoWrapper> CalculateHitos(id Identificador, Integer Numerohitos){     
        List<HitoWrapper> HitoWrapperlst = new List<HitoWrapper>();
        // query account records and create 'accountListWrapper' class instance for each record. 
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        decimal cien=100.00;
        list<Hito_de_facturacion__c> hitos; 
        List<Opportunity> oportunidad;
        List<Linea_de_Proyecto__c> lp;
        if(Identificador.getSObjectType().getDescribe().getName()=='Opportunity'){
            hitos= [Select Name,Descripcion__c,Fecha__c,Porcentaje__c,Importe__c from Hito_de_facturacion__c where Oportunidad__c=:Identificador and Linea_de_Proyecto__c=null ];
            oportunidad = [Select Fecha_de_inicio__c ,Fecha_de_fin__c,Importe_total__c from Opportunity where id=:Identificador ] ;
        }else{
            
            hitos= [Select Name,Descripcion__c,Fecha__c,Porcentaje__c,Importe__c from Hito_de_facturacion__c where   Linea_de_Proyecto__c=: Identificador ];
            lp=[select Fecha_Inicio__c,Fecha_Fin__c,oportunidad__c,Importe_a_elevar__c,RecordType.DeveloperName from Linea_de_Proyecto__c where id =:Identificador and  Precio_Venta__c!=null];
            oportunidad = [Select Fecha_de_inicio__c ,Fecha_de_fin__c,Importe_total__c from Opportunity where id=:lp.get(0).oportunidad__c ]  ;
            
        }
        
        
        integer j=1;
        if(hitos.size()>0 && hitos!=null && Numerohitos==null ){
            
            for(Hito_de_facturacion__c hito :hitos){
                HitoWrapperlst.add(new HitoWrapper(hito.Descripcion__c,hito.Fecha__c,hito.Porcentaje__c,j,hito.Importe__c));
                j++;
                
            }
            
            
        }else if(Numerohitos!=null){
            
            
            
            Date FechaInicio= Identificador.getSObjectType().getDescribe().getName()=='Opportunity'  ? oportunidad.get(0).Fecha_de_inicio__c : lp.get(0).Fecha_Inicio__c;
            Date FechaFin=Identificador.getSObjectType().getDescribe().getName()=='Opportunity'  ? oportunidad.get(0).Fecha_de_fin__c : lp.get(0).Fecha_Fin__c;
            
            Decimal ImporteOpor=Identificador.getSObjectType().getDescribe().getName()=='Opportunity'  ? oportunidad.get(0).Importe_total__c : lp.get(0).Importe_a_elevar__c;
            Boolean esLicencia = false;
            
            
            Integer dt1 = FechaInicio.daysBetween(FechaFin);
            Decimal incremento =dt1/Numerohitos;
            Decimal Porcentaje= (cien/Numerohitos).setScale(2);
            Integer incrementoparcial=(integer)incremento.round(System.RoundingMode.HALF_UP);
            Decimal porcentajeSum = 0.00;
            Decimal incrementoSum = 0.00;
            Date Fecha=FechaInicio.addDays(incrementoparcial);
            List<Licencia__c> licencias;
	
            if(lp!=null){
            //De tipo licencia
            if(Identificador.getSObjectType().getDescribe().getName()=='Linea_de_Proyecto__c' && (lp.get(0).RecordType.DeveloperName == 'Licencias' || lp.get(0).RecordType.DeveloperName == 'Licencias_Servicios' ||lp.get(0).RecordType.DeveloperName == 'Licencias_Renovaci_n')  ){
                licencias = [Select id,Precio_total__c,Fecha_de_activacion__c   from Licencia__c where Linea_de_Proyecto__c =:lp.get(0).id];
                ImporteOpor=0;
                esLicencia = true;
                system.debug('Tipo licencia.');
                for (Licencia__c licencia : licencias) {
                    ImporteOpor += licencia.Precio_total__c;
                }
                if(Numerohitos == licencias.size() && licencias.size()>= 1){
                    FechaInicio = licencias.get(0).Fecha_de_activacion__c;
                    FechaFin = licencias.get(licencias.size()-1).Fecha_de_activacion__c;
                
                }

            }
            }
            
            if(Numerohitos>1){
                for(integer i=1; i<=Numerohitos;i++){
                    if(i==1){
                        porcentajeSum += Porcentaje;
                        incrementoSum += importeOpor*(Porcentaje/100);
                        HitoWrapperlst.add(new HitoWrapper('Hito nº' + i,FechaInicio,Porcentaje,i,ImporteOpor*(Porcentaje/100)));
                    }else if(i==Numerohitos)
                        
                    {
                        porcentajeSum= 100 - porcentajeSum;
                        incrementoSum = (porcentajeSum * ImporteOpor) / 100;
                        HitoWrapperlst.add(new HitoWrapper('Hito nº' + i,FechaFin,porcentajeSum,i,incrementoSum));
                    }else{
                        if(esLicencia && Numerohitos == licencias.size()){
                            Fecha = licencias.get(i-1).Fecha_de_activacion__c;
                        }
                        porcentajeSum += Porcentaje;
                        incrementoSum += ImporteOpor*(Porcentaje/100);
                        HitoWrapperlst.add(new HitoWrapper('Hito nº' + i,Fecha,Porcentaje,i,ImporteOpor*(Porcentaje/100)));
                        Fecha=fecha.addDays(incrementoparcial);
                    }
                    
                }
            }else {
                
                HitoWrapperlst.add(new HitoWrapper('Hito nº1',FechaFin,Porcentaje,1,ImporteOpor));
            }
        }
        // return the 'lstaccountListWrapper' list 
        system.debug('Hioiiiiitos' +HitoWrapperlst );
        return HitoWrapperlst; 
    }

    @AuraEnabled 
    public static boolean  guardarHitos(id Identificador,list<HitoWrapper> datosmodificados){     
        
        system.debug('Datosmodificados' + datosmodificados);
        List<Linea_de_proyecto__c>lps;
        list<Hito_de_facturacion__c> borrar;
        decimal porcentajetotal=0;
        for(HitoWrapper h1 :datosmodificados  ){
            porcentajetotal=porcentajetotal+h1.porcentaje;
            
        }
        
        if(porcentajetotal<99.9 || porcentajetotal>100){
            system.debug('NULL');
            return null;
        }
        if(Identificador.getSObjectType().getDescribe().getName()=='Opportunity'){
                    lps= [Select id,Precio_Venta__c,oportunidad__c from Linea_de_proyecto__c where oportunidad__c=:Identificador and RecordType.Name !='AM'  and  Precio_Venta__c!=null] ;
					  borrar = [Select id from Hito_de_facturacion__c where oportunidad__c =:Identificador];
        }else{
           lps= [Select id,Precio_Venta__c,oportunidad__c from Linea_de_proyecto__c where id=:Identificador and Precio_Venta__c!=null];
            
              borrar= [Select id from Hito_de_facturacion__c where Linea_de_Proyecto__c  =:Identificador];
        }
        
                system.debug('Identificador' + lps);
        Integer numeroHitosAgenerar=datosmodificados.size();
        
       
        
        
        try {
        delete borrar;
            
        insert(generarHitosparaLPs(lps,datosmodificados));
            
            if(Identificador.getSObjectType().getDescribe().getName()=='Opportunity'){    
                insert(generarHitosparaOportunidad(Identificador,datosmodificados));
            }
        
            } catch(DmlException e) {
                return false;
            }
    return true;
        
    }
    
    public static list<Hito_de_facturacion__c> generarHitosparaLPs(List<Linea_de_proyecto__c>lps,list<HitoWrapper> datosmodificados){
        
        list<Hito_de_facturacion__c> nuevosHitos= new  list<Hito_de_facturacion__c>();
        

        for(Linea_de_proyecto__c lp : lps){
            
            for(HitoWrapper h: datosmodificados){
                Hito_de_facturacion__c hito =new Hito_de_facturacion__c();
                
                hito.Linea_de_Proyecto__c=lp.id;
                hito.oportunidad__c=lp.Oportunidad__c;
                hito.Fecha__c=h.FechaHito;
                hito.importe__c=lp.Precio_Venta__c*(h.Porcentaje/100);
                hito.Porcentaje__c=h.Porcentaje;
                hito.descripcion__c=h.Descripcion;
                nuevosHitos.add(hito);
            }
            
        }
        
        system.debug('@@hitos' +nuevosHitos);
        return nuevosHitos;
    }
    
    
    public static list<Hito_de_facturacion__c> generarHitosparaOportunidad(id Identificador,list<HitoWrapper> datosmodificados){
        
        list<Hito_de_facturacion__c> nuevosHitos= new  list<Hito_de_facturacion__c>();
        Decimal Importe=0;
        if (Identificador.getSObjectType().getDescribe().getName()=='Opportunity'){
           
         Importe= [Select Importe_total__c from Opportunity where id =:Identificador].Importe_total__c;
        }else{
           Importe= [Select Importe_a_elevar__c from Linea_de_proyecto__c where id =:Identificador].Importe_a_elevar__c;
        }
        
        for(HitoWrapper h: datosmodificados){
            Hito_de_facturacion__c hito =new Hito_de_facturacion__c();
            
            hito.Oportunidad__c=Identificador;
            hito.Fecha__c=h.FechaHito;
            hito.importe__c=Importe*(h.Porcentaje/100);
            hito.Porcentaje__c=h.Porcentaje;
            system.debug('Porcentaje'+h.Porcentaje);
            hito.descripcion__c=h.Descripcion;
            nuevosHitos.add(hito);
        }
        
        
        
        return nuevosHitos;
    }
    
    @AuraEnabled 
    public static list<HitoWrapper> ActualizarHitosTabla(id Identificador,list<HitoWrapper> datosmodificados,list<HitoWrapper> datosoriginales){
        
        list<HitoWrapper> hitosWrapper= new  list<HitoWrapper>();
        Decimal Importe=0;
        String sObjName = Identificador.getSObjectType().getDescribe().getName();
        if(sObjName=='Opportunity'){
         Importe= [Select Importe_total__c from Opportunity where id =:Identificador].Importe_total__c;
        }else {
         Importe= [Select Precio_Venta__c from Linea_de_Proyecto__c where id =:Identificador].Precio_Venta__c;     
        }
        system.debug('datosmodificados'+datosmodificados);
        system.debug('datosmodificados'+datosoriginales);
        map<Integer,HitoWrapper > mapahitos=new  map<Integer,HitoWrapper >();
        decimal porcentajetotal=0;

        for(HitoWrapper h1:datosoriginales){
            
            mapahitos.put(h1.indice,h1);
        }
    
        
        
        for(Integer i=0; i<datosmodificados.size(); i++){
            if(datosmodificados.get(i).Porcentaje!=null){
                mapahitos.get(datosmodificados.get(i).indice).importe=Importe*(datosmodificados.get(i).Porcentaje/100);
                mapahitos.get(datosmodificados.get(i).indice).Porcentaje=datosmodificados.get(i).Porcentaje;
            }
            
            if(datosmodificados.get(i).FechaHito!=null){
                mapahitos.get(datosmodificados.get(i).indice).FechaHito=datosmodificados.get(i).FechaHito;
            }
            
            if(datosmodificados.get(i).Descripcion!=null){
                mapahitos.get(datosmodificados.get(i).indice).Descripcion=datosmodificados.get(i).Descripcion; 
            }
            
            
        }
        hitosWrapper=mapahitos.values();
        
        
        system.debug('Al final' +hitosWrapper);
        return hitosWrapper;
    }
    
    /* wrapper class */  
    public class HitoWrapper {
        @AuraEnabled public String Descripcion {get;set;}
        @AuraEnabled public  Date FechaHito{get;set;}
        @AuraEnabled public Decimal Porcentaje{get;set;}
        @AuraEnabled public Decimal Importe{get;set;}
        @AuraEnabled public integer indice{get;set;}
        public HitoWrapper(String Descripcion, Date FechaHito,decimal porcentaje,integer indice,Decimal Importe){
            this.Descripcion = Descripcion;
            this.FechaHito = FechaHito;
            this.porcentaje=porcentaje;
            this.indice=indice;
            this.importe=importe;
        }
        
        public HitoWrapper(){
            
        }
    }
    
}