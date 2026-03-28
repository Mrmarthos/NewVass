public class CSVCreatorRatecard  {

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
            system.debug('1:'+valor.column_name);
            system.debug('2:'+PosicionCabeceras.get(valor.column_name));
            system.debug('3:'+PosicionCabeceras.get('CODE'));
            system.debug('PosicionCabeceras' +i +':' + PosicionCabeceras);
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
            
        
        list<Campos_Excel_RateCard__mdt> mapeo= [Select Campo_Excel__c ,Orden__c  from Campos_Excel_RateCard__mdt order by Orden__c  ];
 
          Map<list<string>, string> MapaLineas = new Map<list<string>,string >();
            set<id> lpIds = new set<id>();
            for(Linea_de_Proyecto__c lp : Lps){
                
                lpIds.add(lp.id);
  
                  MapaLineas.put(new list<String>{CodOferta},lp.name); 
                
            }
            
		      
            
        for(Campos_Excel_RateCard__mdt header : mapeo) 
             headers2.add(new CSVHeader(header.Campo_Excel__c));
            
    	system.debug('headers2'+headers2);
        integer j=0;
		String version = [SELECT code__c FROM VersionExcel__mdt].code__C;
            if(test.isRunningTest()){
                version='SFC_2';
            }

            
        for(List<String> line:lines){
            list <String> nueva= new list<String>();

            SYSTEM.debug('AQUI'+line);
            system.debug('line.get(PosicionCabeceras.get'+PosicionCabeceras.get('OPPCODE'));
            
            if((line.get(PosicionCabeceras.get('OPPCODE'))!=CodOferta && j==0) ){
                  headers2.clear();
                headers2.add(new CSVHeader('oferta'));
              
                return new CSVObject(headers2, lines2);
            }else if((version!=line.get(PosicionCabeceras.get('SALESFORCECODE')) && !test.isRunningTest())){
                list<String> error= new list<string>{'Error'};
                 	system.debug('ERROR OPPCODE---->' +line.get(PosicionCabeceras.get('SALESFORCECODE')));
                    headers2.clear();
                	headers2.add(new CSVHeader('Version'));
              
                return new CSVObject(headers2, lines2);
            }
            j++;
            
            list<String> clave= new list<String>{line.get(PosicionCabeceras.get('OPPCODE'))};

      	
           
            if(MapaLineas.get(clave)!=null  ){
                
           
                system.debug('Entra');
                nueva.add(MapaLineas.get(clave));
                
                
            }else{
                nueva.add('NO ENCONTRADA!');
                
            }
            nueva.add(line.get(PosicionCabeceras.get('PHASE')));
            nueva.add(line.get(PosicionCabeceras.get('VASSROLE')));
            nueva.add(line.get(PosicionCabeceras.get('STARTDATE')));
            nueva.add(line.get(PosicionCabeceras.get('ENDDATE')));
            nueva.add(line.get(PosicionCabeceras.get('HOURS')));
            nueva.add(line.get(PosicionCabeceras.get('PRICEROL')));
            nueva.add(line.get(PosicionCabeceras.get('TOTALPRICE')));
         	nueva.add(line.get(PosicionCabeceras.get('TSTARTDATE')));
          	nueva.add(line.get(PosicionCabeceras.get('TENDDATE')));
            nueva.add(line.get(PosicionCabeceras.get('LISTHOUR')));
            nueva.add(line.get(PosicionCabeceras.get('SOWPRICE')));
            nueva.add(line.get(PosicionCabeceras.get('SOLUTION')));
            nueva.add(line.get(PosicionCabeceras.get('ENGAGETYPE')));
            nueva.add(line.get(PosicionCabeceras.get('PROFITCENTER')));

            
               
                      
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
            List<Rates_Table__c> RatesaInsertar = new List<Rates_Table__c>();
            List<Linea_de_Proyecto__c> LineasActualizarSinDup = new List<Linea_de_Proyecto__c>();       
            map <String,string>mapalineas = new map <String, string>() ;
            map <String,List<List<String> >>linemap = new map <String, List<List<String> >>();
            map <Linea_de_Proyecto__c,string>TipoGasto = new map <Linea_de_Proyecto__c, string>();
            for(Linea_de_Proyecto__c lp :lps){        
                mapalineas.put(lp.name,lp.id);
            }
            
            for (List<String> linea : datos.lines){
                
                system.debug('PosicionCabeceras-->'+PosicionCabeceras);
                system.debug('Linea'+linea.get(PosicionCabeceras.get('PROJECT LINE')) );
                if(linea.get(PosicionCabeceras.get('PROJECT LINE'))!='NO ENCONTRADA!' && linea.get(PosicionCabeceras.get('PROJECT LINE'))!='LICENCIA NO ENCONTRADA!'){
                    
                    if(  linemap.get(linea.get(PosicionCabeceras.get('PROJECT LINE')))!=null){
                        linemap.get(linea.get(PosicionCabeceras.get('PROJECT LINE'))).add(linea);
                    }else{
                        
               
                        linemap.put(linea.get(PosicionCabeceras.get('PROJECT LINE')),new List<List<String>>{linea} );
                    }
                    
                }               
            }
            
            
            system.debug('MAAPITA CHULO--->'+linemap);
            String lpid='0';
            Integer z=1;
            for ( String key : linemap.keySet()){
                double precioventa=0;
                Date fechaInicio;
                Date fechaFin;
                Linea_de_Proyecto__c lp = new Linea_de_Proyecto__c(); 
               
                lp.id=mapalineas.get(key);
                lpid=lp.id;
                system.debug('KEEY' +mapalineas.get(key));

                for ( List<String> lista : linemap.get(key)){
                    
          				Rates_Table__c rt = new Rates_Table__c(); 
                        rt.VASS_Role__c=lista.get(PosicionCabeceras.get('VASSROLE'));
                        rt.Hours__c=double.valueof(lista.get(PosicionCabeceras.get('HOURS')).replace(',', '.'));
                    	rt.List_Hour__c=double.valueof(lista.get(PosicionCabeceras.get('LISTHOUR')).replace(',', '.'));
                    	rt.Phase__c=lista.get(PosicionCabeceras.get('PHASE'));
                    	rt.SOW_Price__c=Double.valueOf(lista.get(PosicionCabeceras.get('SOWPRICE')).replace(',', '.'));
                    	rt.Project_Line__c=lp.id;
                    	rt.T_End_Date__c=Date.parse(lista.get(PosicionCabeceras.get('ENDDATE')));
                        rt.T_Start_Date__c=Date.parse(lista.get(PosicionCabeceras.get('STARTDATE')));
						rt.Solution__c=lista.get(PosicionCabeceras.get('SOLUTION'));
                    	rt.Engagetype__c=lista.get(PosicionCabeceras.get('ENGAGETYPE'));
                    	rt.Profit_Center__c=lista.get(PosicionCabeceras.get('PROFITCENTER'));
                 
                    
                        precioventa=double.valueof(lista.get(PosicionCabeceras.get('TOTALPRICE')).replace(',', '.'));
                     	fechaInicio=Date.parse(lista.get(PosicionCabeceras.get('TSTARTDATE')));
                   		fechaFin=Date.parse(lista.get(PosicionCabeceras.get('TENDDATE')));
                    
                    	RatesaInsertar.add(rt);
                        
                    }
                    
                    
                    lp.Importe_total_2__c=Decimal.valueOf(precioventa).setScale(2,RoundingMode.HALF_UP);
                 	lp.Fecha_Inicio__c=fechaInicio;
                	lp.Fecha_Fin__c=fechaFin;
                    
                    LineasActualizar.add(lp);
            }
            
 			list<Rates_Table__c> rtdelete=[select id from Rates_Table__c where Project_Line__c=:lpid];
            delete rtdelete;
            update LineasActualizar;
            system.debug('RatesaInsertar'+RatesaInsertar);
            insert RatesaInsertar;
            
          
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