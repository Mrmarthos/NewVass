public class SendEmailPepsEjecucion {
    static final String NOMBRE_REMITENTE = 'VASSForce';
    
    /**
     * Método que conforma los elementos del correo electrónico y lo envía
     */
    public static void enviarCorreo(Linea_de_proyecto__c lp){

        List<Linea_de_Proyecto__c> pepsEje =
        [SELECT  Jefe_de_Proyecto_de_Ejecucion__r.Email,
        NEW_Nombre_SAP__c,
         sede__c,
         Execution_SAP_Name__c,
        Responsable_de_LDP__r.Email,
        Oportunidad__r.Codigo_de_oportunidad__c,
        UrlForm__c,
        Jefe_Proyecto_Ejecucion_Adicional__r.Email,
         
        Oportunidad__r.Owner.Email
        FROM Linea_de_Proyecto__c 
        WHERE Id =:lp.id];
        String []destinatarios = new String[]{};

        if(pepsEje!=null){
     
        if(pepsEje[0].Jefe_de_Proyecto_de_Ejecucion__r.Email != null){
            destinatarios.add(pepsEje[0].Jefe_de_Proyecto_de_Ejecucion__r.Email);
        }
        if(pepsEje[0].Responsable_de_LDP__r.Email != null){
            destinatarios.add(pepsEje[0].Responsable_de_LDP__r.Email);
        }
        if( pepsEje[0].Jefe_Proyecto_Ejecucion_Adicional__r.Email!= null){
            destinatarios.add(pepsEje[0].Jefe_Proyecto_Ejecucion_Adicional__r.Email);
        }
        if(pepsEje[0].Oportunidad__r.Owner.Email != null){
            destinatarios.add(pepsEje[0].Oportunidad__r.Owner.Email);
        }
            for( CorreoNotificacionPEPSEjecucion__mdt  correo :[select id,Email__c,DeveloperName from CorreoNotificacionPEPSEjecucion__mdt])
                if(correo.DeveloperName.Contains('Nateevo') && (lp.Sede__c=='1110'|| lp.Sede__c=='1120')){
                 destinatarios.add(correo.Email__c);        

                }else if(correo.DeveloperName.Contains('T4S') && lp.Sede__c=='1410'){
                 destinatarios.add(correo.Email__c);        

                }else if(correo.DeveloperName.Contains('Facturacion')){
                    destinatarios.add(correo.Email__c);  

                }
        }

		Messaging.Email[] messages = new Messaging.Email[0];   
     	String destinatario;
            

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(destinatarios);
            mail.setSenderDisplayName(NOMBRE_REMITENTE);
            mail.setSubject('SAP PEP Registration Form offer Nº: ' + lp.Oportunidad__r.Codigo_de_oportunidad__c);
            mail.setHtmlBody(generarPlantillaOK(lp));
            messages.add(mail);
   
    
            Messaging.sendEmail(messages, false);
    

}
    
    
        public static void enviarCorreo(Linea_de_proyecto__c lp,String msgerror){

   		Messaging.Email[] messages = new Messaging.Email[0];   
        String body;
        String asunto;
        Boolean aistente;
        asunto='SYNC ERROR PEP SAP  ';
        body=generarPlantillaKO(lp,msgerror);
        List<Linea_de_Proyecto__c> pepsEje =
        [SELECT  Jefe_de_Proyecto_de_Ejecucion__r.Email,
        NEW_Nombre_SAP__c,
        Responsable_de_LDP__r.Email,
        Execution_SAP_Name__c,
        Oportunidad__r.Codigo_de_oportunidad__c,
        UrlForm__c,
        Oportunidad__r.Owner.Email
        FROM Linea_de_Proyecto__c 
        WHERE Id =:lp.id];
        String []destinatarios = new String[]{};
     
        if(pepsEje!=null){
            asunto='SYNC ERROR PEP SAP  '+pepsEje[0].NEW_Nombre_SAP__c;
        if(pepsEje[0].Jefe_de_Proyecto_de_Ejecucion__r.Email != null){
            destinatarios.add(pepsEje[0].Jefe_de_Proyecto_de_Ejecucion__r.Email);
        }
        if(pepsEje[0].Responsable_de_LDP__r.Email != null){
            destinatarios.add(pepsEje[0].Responsable_de_LDP__r.Email);
        }
        if(pepsEje[0].Responsable_de_LDP__r.Email != null){
            destinatarios.add(pepsEje[0].Oportunidad__r.Owner.Email);
        }
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(destinatarios);
        mail.setSenderDisplayName(NOMBRE_REMITENTE);
        mail.setSubject(asunto);
        mail.setHtmlBody(body);
        messages.add(mail);
       
        Messaging.SendEmailResult[] resultado = Messaging.sendEmail(messages, false);
        system.debug('Se ha enviado el correo??               '+resultado);
}
    
    public static void enviarCorreoAltaPEP(Linea_de_proyecto__c lp,String []destinatarios){

   		Messaging.Email[] messages = new Messaging.Email[0];   
        String body;
        String asunto;
        Boolean aistente;
		asunto='SAP PEP Registration Form offer Nº:' + lp.Oportunidad__r.Codigo_de_oportunidad__c;
        body=generarPlantillaJPOK(lp);
        
        
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(destinatarios);
            mail.setSenderDisplayName(NOMBRE_REMITENTE);
            mail.setSubject(asunto);
            mail.setHtmlBody(body);
            messages.add(mail);
           
            Messaging.SendEmailResult[] resultado = Messaging.sendEmail(messages, false);
            system.debug('Se ha enviado el correo??               '+resultado);
}
    
      /**
     * Devuelve los destinatarios dependiendo del tipo de registro
     * @return                         Array de string con el email.
     */
        public static String[] ObtenerDestinatarios(Linea_de_proyecto__c lp,boolean asistentes){

            String[] destinatarios = new String[] {};
         /*if(asistentes)    {   
                for(CorreoNotificacionPEPSEjecucion__mdt  meta:[Select email__c from CorreoNotificacionPEPSEjecucion__mdt]){
                    
                    destinatarios.add(meta.email__c);
                }

            }*/
            /*list<Linea_de_proyecto__c> lps= new list<Linea_de_proyecto__c>();
            lps.add(lp);*/
            /*Map<String,Id> mapRolId = new Map<String,Id>();
            Set<String> setRol = new Set<String>{'Gerente_de_operaciones', 'Responsable_de_area'};
            mapRolId = Utils.queryUserRol(setRol);*/
            List<Linea_de_proyecto__c> emailjefes=[Select Jefe_de_Proyecto_de_Ejecucion__r.Email,Jefe_de_Proyecto_de_Preventa__r.Email from Linea_de_Proyecto__c where id=:lp.id ];
            destinatarios.add(emailjefes[0].Jefe_de_Proyecto_de_Ejecucion__r.Email);
            destinatarios.add(emailjefes[0].Jefe_de_Proyecto_de_Preventa__r.Email);
            //String emailjefeaddicional=[Select Jefe_Proyecto_Ejecucion_Adicional__r.Email from Linea_de_Proyecto__c where id=:lp.id ].Jefe_Proyecto_Ejecucion_Adicional__r.Email;
            //destinatarios.add(emailjefeaddicional);

            /*for (user u1:  [SELECT Id, email FROM User WHERE area__c =:lp.area__c and (UserRoleId =: mapRolId.get('Responsable_de_area') ) AND Sede__c =:lp.sede__c AND User.IsActive = true]){
             	    destinatarios.add(u1.email);
            }
            
            for (user u1: [SELECT Id, email FROM User WHERE Gerencia__c =:lp.Gerencia__c and (UserRoleId =: mapRolId.get('Gerente_de_operaciones') ) AND Sede__c =:lp.sede__c AND User.IsActive = true]){
                destinatarios.add(u1.email);
            }*/
            
            /*if(label.EmailAddresPEPS=='True'){
                String[] destinatario = new String[] {};
                    String email='andres.martos@vass.es';
                destinatario.add(email);
                    return destinatario;
            }else{*/
            
            return destinatarios;
            //}
    }



      /**
     * Método que genera la plantilla HTML del correo a enviar
     * @param  nuevosItemsFueraDePrecio lista con los nuevos productos fuera de precio
 
     */
    public static String generarPlantillaHTML(Linea_de_proyecto__c lp){
        String body;
        string orgventas=lp.Org_Ventas__c == null ? '' : lp.Org_Ventas__c;
        String jpAdicional=  lp.Jefe_Proyecto_Ejecucion_Adicional__r.Name == null ? '' : lp.Jefe_Proyecto_Ejecucion_Adicional__r.Name;
        String direccion=  lp.Direccion_cliente__c == null ? '' : lp.Direccion_cliente__c;
        String inducido=  lp.inducido__c == null ? '' : lp.inducido__c;
        String Padre=  lp.oportunidad__r.proyecto_padre__c == null ? '' : lp.oportunidad__r.proyecto_padre__c;
        Datetime dt3 =   Datetime.newInstanceGmt(lp.Fecha_Inicio__c, Time.newInstance(0,0,0,0));
        String fechaInicio=dt3.format('dd-MM-YYYY');
        Datetime dt4 =   Datetime.newInstanceGmt(lp.Fecha_Fin__c, Time.newInstance(0,0,0,0));
        String fechaFin=dt4.format('dd-MM-YYYY');

        String cabecera='<body lang=ES link="#0563C1" vlink="#954F72" style="word-wrap:break-word"><div class=WordSection1><p class=MsoNormal>Hola,<o:p></o:p></p><p class=MsoNormal></p><p class=MsoNormal>Se ha dado de alta el siguiente PEP de ejecución en SAP desde Salesforce:<o:p></o:p></p><div style="mso-element:para-border-div;border:solid #7E97AD 1.0pt;padding:4.0pt 6.0pt 4.0pt 6.0pt;background:#7E97AD;margin-left:7.2pt;margin-right:7.2pt"><h3 style="mso-margin-top-alt:18.0pt;margin-right:0cm;margin-bottom:12.0pt;margin-left:0cm;background:#7E97AD">Resumen del proyecto<o:p></o:p></h3></div><table class=MsoNormalTable border=0 cellspacing=0 cellpadding=0 width="100%" style="width:100.0%;border-collapse:collapse"><tr><td width=183 valign=bottom style="width:137.45pt;border:none;border-bottom:solid #BFBFBF 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:8.0pt;color:#577188;text-transform:uppercase">Fecha Solicitud<o:p></o:p></span></p></td><td width=244 valign=bottom style="width:183.2pt;border:none;border-bottom:solid #BFBFBF 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:8.0pt;color:#577188;text-transform:uppercase">Nombre del proyecto<o:p></o:p></span></p></td><td width=244 valign=bottom style="width:183.35pt;border:none;border-bottom:solid #BFBFBF 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:8.0pt;color:#577188;text-transform:uppercase">Solicitado por:<o:p></o:p></span></p></td></tr><tr><td width=183 valign=top style="width:137.45pt;border:none;padding:0cm 5.4pt 0cm 5.4pt"><w:Sdt DocPart="B180BC12775F4BFC9BD58A479430C017" Calendar="t" MapToDateTime="t" CalendarType="Gregorian" Date="2021-12-01T00:00:00Z" Title="Fecha Solicitud" SdtTag="Fecha Solicitud" DateFormat="dd/MM/yyyy" Lang="ES" ID="-1173422537"><p class=MsoNormal><span style="font-size:10.0pt;color:red">';
        Datetime dt =   Datetime.newInstanceGmt(system.today(), Time.newInstance(0,0,0,0));
        body=Cabecera+dt.format('dd-MM-YYYY');
        body=body+'</span><span style="font-size:10.0pt;font-family:"Cambria",serif;color:red"><o:p></o:p></span><span style="font-size:10.0pt;font-family:"Cambria",serif;color:red"><w:sdtPr></w:sdtPr></span></p></w:Sdt></td><td width=244 valign=top style="width:183.2pt;border:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:10.0pt;color:red">';
        body=body+lp.Nombre_SAP__c+'<o:p></o:p></span></p></td><td width=244 valign=top style="width:183.35pt;border:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:10.0pt;color:red">';
        body=body+UserInfo.getUserName() +'<o:p></o:p></span></p></td></tr></table>';
        /*string tipoproyecto='<p class=MsoNormal><span style="font-size:10.0pt"><o:p>&nbsp;</o:p></span></p><div style="mso-element:para-border-div;border:solid #7E97AD 1.0pt;padding:4.0pt 6.0pt 1.0pt 6.0pt;background:#7E97AD;margin-left:8.5pt;margin-right:8.5pt"><h3 style="margin:0cm;background:#7E97AD;border:none;padding:0cm">DATOS GENERALES  del proyecto<o:p></o:p></h3></div><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="97%" style="width:97.76%;margin-left:5.4pt;border-collapse:collapse;border:none"><tr><td width="37%" valign=bottom style="width:37.94%;border:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">clase Proyecto<o:p></o:p></span></p></td><w:Sdt ShowingPlcHdr="t" DocPart="13B9574DD7B141FD8549CFA84C1905B4" DropDown="t" Title="Tipo Proyecto" SdtTag="Tipo Proyecto" ID="1473404059"> <td width="62%" colspan=2 valign=bottom style="width:62.06%;border:solid windowtext 1.0pt;border-left:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span class=MsoPlaceholderText><span style="font-size:9.0pt">';
        body=body+tipoProyecto+lp.RecordType.Name;
        body=body+'</span></span><span style="font-size:9.0pt;color:#577188;text-transform:uppercase"><o:p></o:p><w:sdtPr></w:sdtPr></span></p></td></w:Sdt></tr><tr>';
        String clave='<td width="37%" valign=top style="width:37.94%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">clave Periodificación</span><span style="font-size:9.0pt;font-family:"Cambria",serif;color:#577188;text-transform:uppercase"><o:p></o:p></span></p></td><w:Sdt ShowingPlcHdr="t" DocPart="616BEFD897D04A2DBF66B12E80C7797E" DropDown="t" Title="Facturación" SdtTag="Facturación" ID="-1791822981"><w:ListItem ListValue="WIP Facturación Hitos fijos mensuales" DataValue="WIP Facturación Hitos fijos mensuales"></w:ListItem> <td width="62%" colspan=2 valign=top style="width:62.06%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt"><span class=MsoPlaceholderText>';
        body= body+clave+lp.Clave_Periodificacion__c+'</span><o:p></o:p><w:sdtPr></w:sdtPr></span></p></td></w:Sdt></tr><tr>';
        string canal= '<td width="37%" valign=top style="width:37.94%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">canal distribución<o:p></o:p></span></p></td><w:Sdt ShowingPlcHdr="t" DocPart="3A3E02CB14A946FEB44CB898C470AF83" DropDown="t" Title="Mercado" SdtTag="Mercado" ID="-429278456"> <td width="62%" colspan=2 valign=top style="width:62.06%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt"><span class=MsoPlaceholderText>';
        body=body+canal+lp.Oportunidad__r.Mercado__c+'</span><o:p></o:p><w:sdtPr></w:sdtPr></span></p></td></w:Sdt></tr><tr>';
        String comercial='<td width="37%" valign=top style="width:37.94%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">Comercial de venta<o:p></o:p></span></p></td><td width="62%" colspan=2 valign=top style="width:62.06%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal>';
        Body=body+comercial+lp.Oportunidad__r.Owner.Name+'<span style="font-size:9.0pt;color:#595959"><o:p>&nbsp;</o:p></span></p></td></tr>';
    
        
        string Area='<td width="37%" valign=top style="width:37.94%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">área funcional(clan)<o:p></o:p></span></p></td><td width="62%" colspan=2 valign=top style="width:62.06%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt"><w:Sdt ShowingPlcHdr="t" DocPart="34BE2F0EB2D9425EA05B6B3B3B70CDE2" DropDown="t" Title="Area Funcional" SdtTag="Area Funcional" ID="1149937381"> <span class=MsoPlaceholderText>';
        body=body+area+lp.gerencia__c+'</span></w:Sdt>  <span style="color:#595959"><o:p></o:p></span></span></p></td></tr>';
        string gerente='<td width="37%" valign=top style="width:37.94%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">gerente área funcional<o:p></o:p></span></p></td><td width="62%" colspan=2 valign=top style="width:62.06%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt">'+lp.Responsable_de_LDP__r.Name+'<p class=MsoNormal><span style="font-size:9.0pt;color:#595959"><o:p>&nbsp;</o:p></span></p></td></tr><tr>';
        body=body+gerente;
        string gerencia= '<td width="37%" valign=top style="width:37.94%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt;color:#577188;text-transform:uppercase">cebe (Consejo)<o:p></o:p></span></p></td><w:Sdt ShowingPlcHdr="t" DocPart="DAA8852D0F294B7DB97202848C44D123" DropDown="t" Title="Area Proyecto" SdtTag="Area Proyecto" ID="-485398960"><td width="62%" colspan=2 valign=top style="width:62.06%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><span style="font-size:9.0pt"><span class=MsoPlaceholderText>'+lp.area__c+'</span><o:p></o:p><w:sdtPr></w:sdtPr></span></p></td></w:Sdt></tr><tr>';
        body=body+gerencia;

        
        body=body+'</table><a href="mailto:	pepsejecucion@un6ifb7n3g0azp7lp7gaf3rusa7xu4iomsv9y8j169gvfrtt5.9e-eedvuac.cs88.apex.sandbox.salesforce.com?subject=Confirmar Creacion de PEP:'+lp.id+'">Confirmar creacion PEP</a><o:p></o:p></p><p class="MsoNormal"><o:p>&nbsp;</o:p></p><p class="MsoNormal"><b>';*/
        body=body+'<body lang="ES" link="#0563C1" vlink="#954F72" style="word-wrap:break-word"><div class="WordSection1"><p class="MsoNormal"><o:p>&nbsp;</o:p></p><h1 style="mso-margin-top-alt:0cm;margin-right:8.5pt;margin-bottom:0cm;margin-left:8.5pt"><a name="_Hlk89963360"><span style="font-size:12.0pt">DATOS GENERALES&nbsp; del proyecto<o:p></o:p></span></a></h1><table class="MsoNormalTable" border="0" cellspacing="0" cellpadding="0" width="100%" style="width:100.0%;margin-left:5.4pt;border-collapse:collapse"><tr><td width="30%" valign="bottom" style="width:30.42%;border:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">PEP PADRE-dEfinición proyecto<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="bottom" style="width:69.58%;border:solid windowtext 1.0pt;border-left:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+padre+'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="bottom" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">clase Proyecto</span></span><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;font-family:&quot;Cambria&quot;,serif;color:#577188;text-transform:uppercase"><o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="bottom" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.recordtype.name+'</span></span><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188"><o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">clave Periodificación</span></span><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;font-family:&quot;Cambria&quot;,serif;color:#577188;text-transform:uppercase"><o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.clave_periodificacion__c+'</span></span><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188"><o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">canal distribución<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.oportunidad__r.mercado__c +'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Comercial de venta<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+ lp.Oportunidad__r.Owner.Name +'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">área funcional(clan)<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+ lp.Gerencia__c +'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">gerente área funcional<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+ lp.responsable_de_ldp__r.Name +'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">cebe (Consejo)<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.area__c+'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">GERENTE AREA TÉCNICA/CEBE<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+ lp.responsable_de_ldp__r.Name +'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">NOMBRE jefe proyecto pRINCIPAL<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Jefe_de_Proyecto_de_Ejecucion__r.Name+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Nombre GESTOR/eS de Proyecto<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+jpAdicional+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Cliente a facturar<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Oportunidad__r.Account.Name+'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Fecha Inicio pronóstico<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+fechaInicio+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr style="height:18.9pt"><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt;height:18.9pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Fecha fin pronóstico<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt;height:18.9pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+fechaFin+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">fABRICANTES<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Fabricantes__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">PRÁCTICAS<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Tecnologia__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">organización de ventas<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+orgventas+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Oficina Técnica<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Oficina_tecnica__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">código de oferta<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Oportunidad__r.Codigo_de_oportunidad__c+'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">proyecto Estratégico<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Oportunidad__r.Proyecto_estrategico__c +'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">REquiere controlling/PLANIFICACIÓN<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Sin_Controlling__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Venta Extraordinaria<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Venta_Extraordinaria__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Margen de Venta Teórico (%)<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Margen_Real_Economico__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">COSTE BRUTO PLANIFICADO <o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Coste_real__c+lp.CurrencyIsoCode+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Proyecto Sin contrato<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Sin_Contrato__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">Proyecto Agile (Elegir clase proyecto)<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Agile__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">proyecto ejecutado en cliente (indicar ubicación)<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="38%" valign="top" style="width:38.12%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Ejecutado_en_cliente__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="31%" valign="top" style="width:31.46%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+direccion+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">presupuesto Proy serv variable<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+lp.Importe_a_elevar__c+'<o:p></o:p></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr><tr><td width="30%" valign="top" style="width:30.42%;border:solid windowtext 1.0pt;border-top:none;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188;text-transform:uppercase">NEGOCIO INDUCIDO<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span><td width="69%" colspan="2" valign="top" style="width:69.58%;border-top:none;border-left:none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;padding:0cm 5.4pt 0cm 5.4pt"><p class="MsoNormal" style="line-height:106%"><span style="mso-bookmark:_Hlk89963360"><span style="font-size:10.0pt;line-height:106%;color:#577188">'+inducido+'<o:p></o:p></span></span></p></td><span style="mso-bookmark:_Hlk89963360"></span></tr></table><span style="mso-bookmark:_Hlk89963360"></span><p class="MsoNormal"><span style="font-size:10.0pt;font-family:&quot;Cambria&quot;,serif;color:#595959"><o:p>&nbsp;</o:p></span></p></body></html>';

        body=body+'<body lang=ES link="#0563C1" vlink="#954F72" style="word-wrap:break-word"><div class=WordSection1><div style="mso-element:para-border-div;border:solid #7E97AD 1.0pt;padding:4.0pt 6.0pt 4.0pt 6.0pt;background:#7E97AD;margin-left:7.2pt;margin-right:7.2pt"><h3 style="mso-margin-top-alt:10.0pt;margin-right:0cm;margin-bottom:10.0pt;margin-left:0cm;background:#7E97AD">Detalle de Plan de facturación <o:p></o:p></h3></div><table class=MsoNormalTable border=1 cellspacing=0 cellpadding=0 width="97%" style="width:97.76%;margin-left:5.4pt;border-collapse:collapse;border:none"><tr><td width="53%" valign=top style="width:53.58%;border:solid #A5A5A5 1.0pt;border-right:none;background:#A5A5A5;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><b><span style="font-family:"Calibri",sans-serif;color:black;text-transform:uppercase">Concepto<o:p></o:p></span></b></p></td><td width="17%" valign=top style="width:17.28%;border-top:solid #A5A5A5 1.0pt;border-left:none;border-bottom:solid #A5A5A5 1.0pt;border-right:none;background:#A5A5A5;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal align=right style="text-align:right"><b><span style="font-family:"Calibri",sans-serif;color:black;text-transform:uppercase">Fecha<o:p></o:p></span></b></p></td><td width="29%" valign=top style="width:29.14%;border:solid #A5A5A5 1.0pt;border-left:none;background:#A5A5A5;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal align=right style="text-align:right"><b><span style="font-family:"Calibri",sans-serif;color:black;text-transform:uppercase">Importe (Sin Iva)<o:p></o:p></span></b></p></td></tr>';

        list < Hito_de_facturacion__c > hitosLP = [Select Descripcion__c, Fecha__c, Importe__c from Hito_de_facturacion__c where Linea_de_Proyecto__c =: lp.id];
                
        
        for (Hito_de_facturacion__c h: hitosLP) {
            Datetime dt2 =   Datetime.newInstanceGmt(system.today(), Time.newInstance(0,0,0,0));
            String fecha=Cabecera+dt2.format('dd-MM-YYYY');
            body=body+'<tr><td width="53%" valign=top style="width:53.58%;border:solid #C9C9C9 1.0pt;border-top:none;background:#EDEDED;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal><b><span style="font-family:"Calibri",sans-serif;color:#577188">'+h.Descripcion__c+'<o:p></o:p></span></b></p></td><td width="17%" valign=top style="width:17.28%;border-top:none;border-left:none;border-bottom:solid #C9C9C9 1.0pt;border-right:solid #C9C9C9 1.0pt;background:#EDEDED;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal>'+String.valueof(h.Fecha__c)+'<o:p></o:p></p></td><td width="29%" valign=top style="width:29.14%;border-top:none;border-left:none;border-bottom:solid #C9C9C9 1.0pt;border-right:solid #C9C9C9 1.0pt;background:#EDEDED;padding:0cm 5.4pt 0cm 5.4pt"><p class=MsoNormal>'+ String.valueof(h.Importe__c.setScale(2))+'<o:p></o:p></p></td></tr>';
            
        }

        body=body+'</table><p class=MsoNormal><o:p>&nbsp;</o:p></p></div><p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto"><span style="font-size:10.0pt;font-family:"Cambria",serif;color:#595959">&nbsp;<p class=MsoNormal>Si quieres modificar algún dato, por favor, ponte en contacto con el comercial( '+lp.Oportunidad__r.Owner.Email+' ) o con  <a href="mailto:crminterno.salesforce@vass.es">crminterno.salesforce@vass.es</a>.<o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal>Un saludo,<o:p></o:p></p><p class=MsoNormal style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto">&nbsp;<o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p></div></body>';
		//</span><o:p></o:p></p><p class=MsoNormal> Si está de acuerdo con la información contenida en la plantilla puede confirmar la creación del PEP confirmando en el formulario en el siguiente enlace: <a href="https://vasscompanyectest.tfaforms.net/5?id='+lp.Id+'"> Dirigirse al formulario. </a><o:p></o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p>
        return body;
  
    }

    public static String generarPlantillaOK(Linea_de_proyecto__c lp){
		String idpep=[Select Codigo_SAP_Ejecucion__c from Linea_de_proyecto__c where id=:lp.id ].Codigo_SAP_Ejecucion__c;
        if(idpep==null){
            return generarPlantillaKO(lp,'unhandled exception');
        }else{
        String body='<html></head><body lang=ES link="#0563C1" vlink="#954F72" style="word-wrap:break-word"><div class=WordSection1><img src="https://encuestasvass.force.com/visualforce/resource/vassheader" alt="APEX Logo"><p class=MsoNormal><span style="mso-fareast-language:ES">The PEP was successfully synchronized with id: <b>'+idpep+'</b>  and name: <b>'+lp.Execution_SAP_Name__c+'<o:p></o:p></b></span></p><p class=MsoNormal><b><span style="mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></b></p><p class=MsoNormal><span style="mso-fareast-language:ES">You should view it in the workcenter <o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES">if you have any doubt , please contact: <a href="mailto:crminterno.salesforce@vass.es">crminterno.salesforce@vass.es</a><o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES">Regards</span><o:p></o:p></p><p class=MsoNormal> <o:p></o:p></p></div></body></html>';

        return body;
        }
    }
    
    public static String generarPlantillaJPOK(Linea_de_proyecto__c lp){
       
        String url = URL.getSalesforceBaseUrl().toExternalForm();
        String body='<html><body lang=EN link="#0563C1" vlink="#954F72" style="word-wrap:break-word"><div class=WordSection1><img src="https://encuestasvass.force.com/visualforce/resource/vassheader" alt="APEX Logo"><p class=MsoNormal><span style="mso-fareast-language:EN">Hello ,<o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:EN"><o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:EN">There has been a request to register a PEP in SAP, please, verify through <a href="https://vass.tfaforms.net/'+lp.UrlForm__c+'?id='+lp.Id+'">this</a> link.<o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:EN"><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:EN"><o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:EN">Best regards,<o:p></o:p></span></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal><o:p></o:p></p></div></body></html>';
		
        return body;
    }

    
    public static String generarPlantillaKO(Linea_de_proyecto__c lp,String error){

        String body='<html><body lang=ES link="#0563C1" vlink="#954F72" style="word-wrap:break-word"><div class=WordSection1><img src="https://encuestasvass.force.com/visualforce/resource/vassheader" alt="APEX Logo"><p class=MsoNormal><span style="mso-fareast-language:ES">Hello,<o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES">An error occurred during synchronization with SAP related to the PEP:  <b>'+lp.Execution_SAP_Name__c+'</b><br> The error returned by SAP is: '+error+'<o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES"><o:p>&nbsp;</o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES">Please contact <a href="mailto:crminterno.salesforce@vass.es">crminterno.salesforce@vass.es</a><o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES"><o:p></o:p></span></p><p class=MsoNormal><span style="mso-fareast-language:ES">Un saludo,<o:p></o:p></span></p><p class=MsoNormal><o:p>&nbsp;</o:p></p><p class=MsoNormal><o:p>&nbsp;</o:p></p></div></body></html>';

        return body;
    }


}