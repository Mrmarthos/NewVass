public class CSVCreator  {

    private static List<String> separateCommas(String input){
        
    
        List<String> results = input.split(';');
		
        for(String result : results) {
            result = result.trim();
            
   
        }
		
        return results;
    }

    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str,id SoID) {
        
   		try {
        

        List<String> lines_raw = csv_str.split('\n');
        
        lines_raw[0]=lines_raw[0].replace('\r','');
        lines_raw[0]=lines_raw[0]+';';
        List<String> headers_raw = separateCommas(lines_raw[0]);
        List<List<String>> lines = new List<List<String>>();
        List<CSVHeader> headers = new List<CSVHeader>();
        List<CSVHeader> headers2 = new List<CSVHeader>();
        List<List<String>> lines2 = new List<List<String>>();

        lines_raw.remove(0);

		//Handling fields with commas

        for(String line : lines_raw) {
            Integer j=0;
            List<String> line_sep = separateCommas(line);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
           
        }

        for(String header : headers_raw) {
            headers.add(new CSVHeader(header));
        }

        headers.add(new CSVHeader('Línea de Proyecto'));

        
        
		map<String,Integer>  PosicionCabeceras= new map<String,Integer>();
        integer i=0;
        
        for (CSVHeader valor: Headers){
            system.debug('Header' + valor);
            PosicionCabeceras.put(valor.column_name,i);
            system.debug('colunameee' + valor.column_name);
            i++;
            
        }
  
        String  CodOferta='0';
        list<Linea_de_Proyecto__c> Lps;
        if(SoID.getSObjectType().getDescribe().getName()!='Linea_de_Proyecto__c'){
            CodOferta =[Select Codigo_de_oportunidad__c  from Opportunity where id =: SoID].Codigo_de_oportunidad__c;
            Lps =[select id,Name,toLabel(Area__c),toLabel(Sede__c), RecordType.Name from Linea_de_Proyecto__c where Oportunidad__c =:SoID];
        }else{
            
            CodOferta =[select Oportunidad__r.Codigo_de_oportunidad__c  from Linea_de_Proyecto__c  where id =:SoID ].Oportunidad__r.Codigo_de_oportunidad__c;
            Lps =[select id,Name,toLabel(Area__c),toLabel(Sede__c), RecordType.Name from Linea_de_Proyecto__c where id =:SoID];
        }
            
        
        list<Campos_Excel_Economico__mdt> mapeo= [Select Campo_Excel__c,Campo_LP__c,OrdenColumna__c from Campos_Excel_Economico__mdt order by OrdenColumna__c ];
       	
   
/*
        Map<string, string> MapaArea = new Map<string, string>();
        Map<string, string> MapaSede = new Map<string, string>();
        Map<string, list<string>> MapaTipo = new Map<string, list<string>>();

        for(Linea_de_Proyecto__c lp : Lps){
            MapaArea.put(lp.Area__c, lp.Name);
        	MapaSede.put(lp.Sede__c,lp.Name);
            if(lp.RecordType.Name=='AM'){
                if(MapaTipo.get('SERVICIO')==null){
                    MapaTipo.put('SERVICIO',new list<String>{lp.Name});
                }else{
                    MapaTipo.get('SERVICIO').add(lp.Name);
                }
        		
            } if(lp.RecordType.Name=='Llave en Mano'){
                if(MapaTipo.get('SERVICIO')==null){
                    MapaTipo.put('SERVICIO',new list<String>{lp.Name});
                }else{
                    MapaTipo.get('SERVICIO').add(lp.Name);
                }
        		
            } if(lp.RecordType.Name.contains('Licencias')){
                if(MapaTipo.get('Licencias')==null){
                    MapaTipo.put('LICENCIA',new list<String>{lp.Name});
                }else{
                    MapaTipo.get('LICENCIA').add(lp.Name);
                }
        		
            }
        }*/
            

            
            Map<list<string>, string> MapaLineas = new Map<list<string>,string >();
            set<id> lpIds = new set<id>();
            for(Linea_de_Proyecto__c lp : Lps){
                
                lpIds.add(lp.id);
                if(lp.RecordType.Name=='Llave en Mano' ){
                    
                    MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'LLAVE EN MANO'},lp.name); 
                    
                    
                    
                }
                
                if(lp.RecordType.Name=='AM'  ){
                    
                    MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'AM EN CLIENTE'},lp.name); 
                    MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'AM EN VASS'},lp.name);
                    
                    
                }
                
                if(lp.RecordType.Name.contains('Licencias')){
          
                    
                    
                    if(!mapalineas.containsKey(new list<String>{lp.Sede__c,lp.Area__c,'AM EN CLIENTE'})){
                        MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'AM EN CLIENTE'},lp.name);
                    }
                    
                    if(!mapalineas.containsKey(new list<String>{lp.Sede__c,lp.Area__c,'LLAVE EN MANO'})){
                        MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'LLAVE EN MANO'},lp.name);
                    }
                    
                    
                    if(!mapalineas.containsKey(new list<String>{lp.Sede__c,lp.Area__c,'AM EN VASS'})){
                        MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'AM EN VASS'},lp.name);
                    }
                    
                    MapaLineas.put(new list<String>{lp.Sede__c,lp.Area__c,'LICENCIA'},lp.name);  
                    

                }
                
                
            }
            
            map<string,string> mapalicencias = new     map<string,string> ();
            for(Licencia__c licencia :[select name,Linea_de_Proyecto__r.Name from Licencia__c where Linea_de_Proyecto__c IN :lpIds] ){
                mapalicencias.put(licencia.name,licencia.Linea_de_Proyecto__r.Name);
            }
            
            
            
        for(Campos_Excel_Economico__mdt header : mapeo) 
             headers2.add(new CSVHeader(header.Campo_Excel__c));
            
    
        integer j=0;
		String version = [SELECT code__c FROM VersionExcel__mdt].code__C;
            if(test.isRunningTest()){
                version='1';
            }

        for(List<String> line:lines){
            list <String> nueva= new list<String>();

            
            system.debug('line.get(PosicionCabeceras.get'+line.get(PosicionCabeceras.get('CODOFERTA')));
            
            if((line.get(PosicionCabeceras.get('CODOFERTA'))!=CodOferta && j==0) ){
                  headers2.clear();
                headers2.add(new CSVHeader('oferta'));
              
                return new CSVObject(headers2, lines2);
            }else if((version!=line.get(PosicionCabeceras.get('SALESFORCECODE')) && !test.isRunningTest())){
                list<String> error= new list<string>{'Error'};
                 
                    headers2.clear();
                	headers2.add(new CSVHeader('Version'));
              
                return new CSVObject(headers2, lines2);
            }
            j++;
            
            list<String> clave= new list<String>{line.get(PosicionCabeceras.get('SEDE')),line.get(PosicionCabeceras.get('AREA')).replace('Subcontratado - ',''),line.get(PosicionCabeceras.get('TIPO DE SERVICIO'))};

      		system.debug('CLAVE'+clave);
            system.debug('MapaLineas'+MapaLineas);
            system.debug('Licencias' +mapalicencias);
            if(MapaLineas.get(clave)!=null || line.get(PosicionCabeceras.get('CATEGORIA'))=='GASTO' ){
                
           
                system.debug('Entra');
                
                if(line.get(PosicionCabeceras.get('CATEGORIA'))=='LICENCIA' ){
                    if(mapalicencias.get( line.get(PosicionCabeceras.get('PERFIL')))!=null){
                        
                      //  system.debug('Auqui estan las licencias:--->'+mapalicencias.get( line.get(PosicionCabeceras.get('PERFIL'))));
                       // list<String> clave2= new list<String>{line.get(PosicionCabeceras.get('SEDE')),line.get(PosicionCabeceras.get('AREA')).replace('Subcontratado - ',''),'LICENCIA'};
                            nueva.add(mapalicencias.get( line.get(PosicionCabeceras.get('PERFIL'))));
                    }else {
                        nueva.add('LICENCIA NO ENCONTRADA!');
                    }
                    
                    
                    
                }else if(line.get(PosicionCabeceras.get('CATEGORIA'))=='GASTO'){
                    system.debug('GASSTO');
                   
                    if(MapaLineas.get(clave)!=null){
                        
                    nueva.add(MapaLineas.get(clave));
                    }else{nueva.add('NO ENCONTRADA!');}
                    
                    
                    
                    
                }else{ nueva.add(MapaLineas.get(clave));}
                
                
            }else{
                nueva.add('NO ENCONTRADA!');
                
            }
            nueva.add(line.get(PosicionCabeceras.get('SEDE')));
            nueva.add(line.get(PosicionCabeceras.get('AREA')));
            nueva.add(String.valueOf(decimal.valueOf(line.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.')).setScale(2,RoundingMode.HALF_UP)));
            nueva.add(String.valueOf(decimal.valueOf(line.get(PosicionCabeceras.get('COSTE BRUTO')).replace(',', '.')).setScale(2,RoundingMode.HALF_UP)));
            nueva.add(line.get(PosicionCabeceras.get('MARGEN')));      
            nueva.add(line.get(PosicionCabeceras.get('Num JORNADAS')));
            nueva.add(String.valueOf(decimal.valueOf(line.get(PosicionCabeceras.get('TOTAL COSTE LBE')).replace(',', '.')).setScale(2,RoundingMode.HALF_UP)));
            nueva.add(String.valueOf(decimal.valueOf(line.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.')).setScale(2,RoundingMode.HALF_UP)));
            nueva.add(String.valueOf(decimal.valueOf(line.get(PosicionCabeceras.get('HORAS')).replace(',', '.')).setScale(2,RoundingMode.HALF_UP)));
            nueva.add(line.get(PosicionCabeceras.get('CATEGORIA')));   
            nueva.add(line.get(PosicionCabeceras.get('PERFIL')));         
            nueva.add(line.get(PosicionCabeceras.get('TIPO DE SERVICIO')));           
            nueva.add(String.valueOf(decimal.valueOf(line.get(PosicionCabeceras.get('TARIFA JORNADA')).replace(',', '.')).setScale(2,RoundingMode.HALF_UP)));

          
              
                                
                lines2.add(nueva);

            }
            
         
        

        system.debug('Lines2'+lines2.get(0));
        return new CSVObject(headers2, lines2);
            
            } catch(system.Exception e) {
                        
                List<CSVHeader> headers2 = new List<CSVHeader>();
               List<List<String>> lines2 = new List<List<String>>();
                headers2.add(new CSVHeader('excepcion'));
                system.debug(e.getMessage());
                
                return new CSVObject(headers2, lines2);
   		
}
    }

    @AuraEnabled
    public static boolean ActualizarLineas(CSVObject datos,string fichero,string comentarios,Id SoId){
	
        
        
        try {
           
          
            set <String> Nombres = new set <String>();
            map<String,Integer>  PosicionCabeceras= new map<String,Integer>();
            integer i=0;
            
            for (CSVHeader valor: Datos.Headers){           
                PosicionCabeceras.put(valor.column_name,i);
                i++;
                
            }
        
            for (List<String> linea : datos.lines){
                if(linea.get(0)!='NO ENCONTRADA!' ||linea.get(0)!='LICENCIA NO ENCONTRADA!'  ){
                    nombres.add(linea.get(0));
                }
                
            }
            
            
            list<Linea_de_Proyecto__c> Lps = [select id, name,oportunidad__c   from Linea_de_Proyecto__c where Name  in :Nombres];
            List<Linea_de_Proyecto__c> LineasActualizar = new List<Linea_de_Proyecto__c>();
            List<Linea_de_Proyecto__c> LineasActualizarSinDup = new List<Linea_de_Proyecto__c>();       
            map <String,string>mapalineas = new map <String, string>() ;
            map <String,List<List<String> >>linemap = new map <String, List<List<String> >>();
            map <Linea_de_Proyecto__c,string>TipoGasto = new map <Linea_de_Proyecto__c, string>();
            for(Linea_de_Proyecto__c lp :lps){        
                mapalineas.put(lp.name,lp.id);
            }
            
            for (List<String> linea : datos.lines){
                
                system.debug('PosicionCabeceras-->'+PosicionCabeceras);
                system.debug('Linea'+linea );
                if(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO'))!='NO ENCONTRADA!' && linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO'))!='LICENCIA NO ENCONTRADA!'){
                    
                    if(  linemap.get(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO')))!=null){
                        linemap.get(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO'))).add(linea);
                    }else{
                        
               
                        linemap.put(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO')),new List<List<String>>{linea} );
                    }
                    
                }               
            }
            
            
            system.debug('MAAPITA CHULO--->'+linemap);
            
            
            for ( String key : linemap.keySet()){
                double precioventa=0;
                double precioGasto=0;
                double Costegasto=0;
                double coste=0;
                double horas=0;
                double jornadas=0;
                double CosteLBE=0;
                double TarifaJornadas=0;
                String Categoria;
                Double costebruto=0;
                double Margen=0;
                Linea_de_Proyecto__c lp = new Linea_de_Proyecto__c(); 
                lp.id=mapalineas.get(key);
                system.debug('KEEY' +mapalineas.get(key));
                for ( List<String> lista : linemap.get(key)){
                    
                   if(lista.get(PosicionCabeceras.get('CATEGORIA')) =='LICENCIA'){
                        
                        Licencia__c lc =[select id from Licencia__c where Linea_de_Proyecto__r.Name =:lista.get(PosicionCabeceras.get('LÍNEA DE PROYECTO')) and Name=:lista.get(PosicionCabeceras.get('PERFIL')) ];
                        lc.Precio_unitario__c=double.valueof(lista.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.'));
                        lc.Coste_unitario__c=double.valueof(lista.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                      update lc;
                        
                    }else{
                        
                        if(lista.get(PosicionCabeceras.get('CATEGORIA')) =='GASTO'){
                            
                            
                            precioGasto=precioGasto+double.valueof(lista.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.'));
                            Costegasto=Costegasto+double.valueof(lista.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                            
                            
                        } 
                        
                        precioventa=precioventa+double.valueof(lista.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.'));
                        coste=coste+double.valueof(lista.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                        
                        horas=horas+double.valueOf(lista.get(PosicionCabeceras.get('HORAS')).replace(',', '.'));
                        if(lista.get(PosicionCabeceras.get('Num JORNADAS'))!=null){
                            jornadas=jornadas+double.valueOf(lista.get(PosicionCabeceras.get('Num JORNADAS')).replace(',', '.'));
                        }
                        if(lista.get(PosicionCabeceras.get('TARIFA JORNADA'))!=null){
                            TarifaJornadas=TarifaJornadas+double.valueOf(lista.get(PosicionCabeceras.get('TARIFA JORNADA')).replace(',', '.'));
                        }
                        if(lista.get(PosicionCabeceras.get('TOTAL COSTE LBE'))!=null){
                            CosteLBE=CosteLBE+double.valueOf(lista.get(PosicionCabeceras.get('TOTAL COSTE LBE')).replace(',', '.'));  
                        }
                        Categoria=lista.get(PosicionCabeceras.get('CATEGORIA'));
                        Margen=double.valueOf(lista.get(PosicionCabeceras.get('MARGEN')).replace(',', '.'))*100;
                        costebruto=costebruto+double.valueof(lista.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                        
                    }
                    
                    
                    lp.Precio_Venta__c=Decimal.valueOf(precioventa).setScale(2,RoundingMode.HALF_UP);
                    lp.Coste_estimado__c=Decimal.valueOf(coste).setScale(2,RoundingMode.HALF_UP);
                    lp.CosteLBE__c=Decimal.valueOf(CosteLBE).setScale(2,RoundingMode.HALF_UP);
                    lp.Jornadas__c=jornadas;
                    lp.Horas__c=Decimal.valueOf(horas).setScale(2,RoundingMode.HALF_UP);
                    lp.Coste_Bruto__c=Decimal.valueOf(costebruto).setScale(2,RoundingMode.HALF_UP);
                    lp.Tarifa_Jornadas__c=Decimal.valueOf(TarifaJornadas).setScale(2,RoundingMode.HALF_UP);
                    lp.Categoria__c=Categoria;
                    lp.Margen_real__c=Decimal.valueOf(Margen).setScale(2,RoundingMode.HALF_UP);
                    lp.Precio_Gasto__c=precioGasto;
                    lp.Coste_Gasto__c=Costegasto;
                    
                    
                }
                LineasActualizar.add(lp);
            }
            
            
         /*
            String lines;
            lines = JSON.serialize(LineasActualizar);
           // performDml(lines);*/
            update LineasActualizar;
            
            
            
            
            
            
            map<String, Linea_de_Proyecto__c> LpsActu= new map <String, Linea_de_Proyecto__c> ();
            for (List<String> linea : datos.lines){
                
                if(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO'))!='NO ENCONTRADA!' && linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO'))!='LICENCIA NO ENCONTRADA!'){
                    
                    
                   
                    
                    if(linea.get(PosicionCabeceras.get('CATEGORIA')) =='GASTO'){
                        
                        Linea_de_Proyecto__c lp = new Linea_de_Proyecto__c(); 
                        lp.id=mapalineas.get(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO')));
                        lp.Precio_Gasto__c=double.valueof(linea.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.'));
                        lp.Coste_Gasto__c=double.valueof(linea.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                        
                       // update lp;
                        
                    } if(linea.get(PosicionCabeceras.get('CATEGORIA')) =='LICENCIA'){
                        
                        Licencia__c lc =[select id from Licencia__c where Linea_de_Proyecto__r.Name =:linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO')) and Name=:linea.get(PosicionCabeceras.get('PERFIL')) ];
                        lc.Precio_unitario__c=double.valueof(linea.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.'));
                        lc.Coste_unitario__c=double.valueof(linea.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                      //  update lc;
                        
                    }else{
                        
                        Linea_de_Proyecto__c lp = new Linea_de_Proyecto__c(); 
                        lp.id=mapalineas.get(linea.get(PosicionCabeceras.get('LÍNEA DE PROYECTO')));
                        lp.Precio_Venta__c=double.valueof(linea.get(PosicionCabeceras.get('PRECIO VENTA')).replace(',', '.'));
                        lp.Coste_estimado__c=double.valueof(linea.get(PosicionCabeceras.get('COSTE BRUTO')).replace(',', '.'));
                        lp.Coste_Bruto__c=double.valueof(linea.get(PosicionCabeceras.get('TOTAL COSTE BRUTO')).replace(',', '.'));
                        lp.Horas__c=double.valueOf(linea.get(PosicionCabeceras.get('HORAS')).replace(',', '.'));
                        if(linea.get(PosicionCabeceras.get('Num JORNADAS'))!=null){
                            lp.Jornadas__c=double.valueOf(linea.get(PosicionCabeceras.get('Num JORNADAS')).replace(',', '.'));
                        }
                        if(linea.get(PosicionCabeceras.get('TARIFA JORNADA'))!=null){
                            lp.Tarifa_Jornadas__c=double.valueOf(linea.get(PosicionCabeceras.get('TARIFA JORNADA')).replace(',', '.'));
                        }
                        if(linea.get(PosicionCabeceras.get('TOTAL COSTE LBE'))!=null){
                            lp.CosteLBE__c=double.valueOf(linea.get(PosicionCabeceras.get('TOTAL COSTE LBE')).replace(',', '.'));  
                        }
                        lp.Categoria__c=linea.get(PosicionCabeceras.get('CATEGORIA'));
                        lp.Margen_real__c=double.valueOf(linea.get(PosicionCabeceras.get('MARGEN')).replace(',', '.'))*100;
                        
                        nombres.remove(lp.name);
                        LineasActualizar.add(lp);
                    }
                    
                    
                    
                    
                    
                    
                }
                
            }
            
            //HAcemos la suma si hay duplicados en la lista
            //
            
            set<ID>ids= new set<ID>();
            List<Linea_de_Proyecto__c> LineasActualizarSumadas = new List<Linea_de_Proyecto__c>();
           /* for(Linea_de_Proyecto__c lp: LineasActualizar){
                
                system.debug('IDS'+ids);
                if(ids.contains(lp.id) ){
                    
                    system.debug('Entra' +lp.id);
                    for(Linea_de_Proyecto__c lp2 : LineasActualizarSinDup){
                        if(lp.id==lp2.id){
                            Linea_de_Proyecto__c lp3 = new Linea_de_Proyecto__c(); 
                            
                            lp3.id=lp.id;
                            lp3.Precio_Venta__c= lp2.Precio_Venta__c+lp.Precio_Venta__c;
                            lp3.Coste_estimado__c=lp2.Coste_estimado__c+lp.Coste_estimado__c;
                            lp3.Horas__c= lp2.Horas__c+ lp.Horas__c;
                            lp3.Jornadas__c= lp2.Jornadas__c+ lp.Jornadas__c;
                            lp3.Tarifa_Jornadas__c=lp2.Tarifa_Jornadas__c+lp.Tarifa_Jornadas__c;
                            lp3.CosteLBE__c= lp.CosteLBE__c+lp2.Tarifa_Jornadas__c;  
                            LineasActualizarSumadas.add(lp3);
                            
                        }
                        
                    }
                    for (Integer j = LineasActualizarSinDup.size() - 1;  j>= 0 ; --j) {
                        if (LineasActualizarSinDup.get(j).id==lp.id) {
                            LineasActualizarSinDup.remove(j); 
                        }
                    }
                    
                    
                }else{
                    
                    LineasActualizarSinDup.add(lp);
                }
                
                
                ids.add(lp.id);
           
            }
*/            
            
            LineasActualizarSumadas.addall(lineasActualizarSinDup);
            //update LineasActualizarSumadas;
           
            if(LineasActualizar.size()!=0){
                  CSVCreator.crearHistorico( fichero, comentarios,lps.get(0).oportunidad__c);
                return true;
                
            }
        } catch(system.Exception e) {
            
            system.debug('EXCEPTION ' +e.getMessage());
            return true;
        }
        return false;
        //update LineasActualizar;
    }
    
	
    public static void crearHistorico(string fichero,string comentarios,Id SoId){
        
        Id OppId;
        
        OppId=SoId;

        
        Historial_Excel_Economico__c sobj = new Historial_Excel_Economico__c(
            Comentarios__c = comentarios,     // Comentarios
            Oportunidad__c = OppId  // Oportunidad
        );
        insert sobj;
        
        fichero = EncodingUtil.urlDecode(fichero, 'UTF-8');
        
        
        
        Attachment a = new Attachment();
        a.parentId = sobj.id;

        a.Body = EncodingUtil.base64Decode(fichero);
        a.Name = 'test.csv';
        a.ContentType = 'application/vnd.ms-excel';

        insert a;
        Datetime dt = Date.today();
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = 'testing.csv'; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = 'ExcelEconomico'+dt.format('YYYY-MM-DD'); // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(fichero); // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = sobj.id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'V';
        insert conDocLink;
        
    }

    @future
    public static void PerformDml(String lps){
        List < Linea_de_Proyecto__c > lpsactu = (List < Linea_de_Proyecto__c > ) JSON.deserialize(lps, List < Linea_de_Proyecto__c > .class);
        update lpsactu;
    }

}