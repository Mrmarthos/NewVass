public with sharing class OpportunityUtil 
{
    
    public class SetOppCodeResult
    {
        public List<Opportunity> opportunities;
        public Opportunity_code_counter__c opportunityCounter;
    }
    /** 
     * Función que rellena el código de la oportunidad con el formato VASS[año][código comercial][autonumérico], donde el autonumerico se reinicia cada año
      ** 
     * @Autor: amartinez (2018/11/19)
     */
    public static SetOppCodeResult setOppCode(List<Opportunity> newList)   
    {
        // Recuperar todos los propietarios de las oportunidades
        Set<Id> ownerIds = new Set<Id>();
        for (Opportunity opp : newlist)
        {
            ownerIds.add(opp.OwnerId);
        }

        Map<Id, User> owners = new Map<Id, User>([SELECT EmployeeNumber FROM User WHERE Id = :ownerIds]);

        // Recuperar las configuraciones
        Map<Integer, Integer> yearToNumber = new Map<Integer, Integer>();

        List<Opportunity_code_counter__c> oppCfgs = [SELECT Year__c, Number__c FROM Opportunity_code_counter__c LIMIT 1];

        Opportunity_code_counter__c oppCfg;
        if (oppCfgs.size() == 0)
        {
            oppCfg = new Opportunity_code_counter__c();
            oppCfg.Year__c = String.valueOf(System.now().year());
            oppCfg.Number__c = '0';
        }
        else 
        {
            oppCfg = oppCfgs.get(0);
        }

        List<String> years = oppCfg.Year__c.split(';');
        List<String> numbers = oppCfg.Number__c.split(';');
        for (Integer i = 0; i < years.size(); i++)
        {
            yearToNumber.put(Integer.valueOf(years.get(i)), Integer.valueOf(numbers.get(i)));
        }

        // Si no existe del año actual se genera el contador en 0 y si existe, se aumenta en 1
        Integer nextNumber = 0;
        if (yearToNumber.containsKey(System.now().year()))
        {
            Integer currentNumber = yearToNumber.get(System.now().year());
            nextNumber = currentNumber;
        }
        else 
        {
            nextNumber = 0;
        }
        
        // Crear el codigo bien formateado
        for (Opportunity opp : newList)
        {
            String employeeCode = owners.get(opp.OwnerId).EmployeeNumber;
            employeeCode = employeeCode.leftPad(4).replaceAll(' ', '0').left(4);
            nextNumber++;
            String numero = String.valueOf(nextNumber);

            opp.Codigo_de_oportunidad__c = 'VASS' + (String.valueOf(System.now().year())).substring(2) + employeeCode + (numero.leftPad(4, '0'));
        }

        // Guardamos el último número
        yearToNumber.put(System.now().year(), nextNumber);

        // Actualizamos la configuración
        List<String> yearsUpdated = new List<String>();
        List<String> numbersUpdated = new List<String>();
        for(Integer year : yearToNumber.keySet())
        {
            yearsUpdated.add(String.valueOf(year));
            numbersUpdated.add(String.valueOf(yearToNumber.get(year)));
        }
        oppCfg.Year__c = String.join(yearsUpdated, ';');
        oppCfg.Number__c = String.join(numbersUpdated, ';');

        SetOppCodeResult res = new SetOppCodeResult();
        res.opportunities = newList;
        res.opportunityCounter = oppCfg;

        return res;
    }

    /**
    * Recupera las cuentas asociadas a las oportunidades
    **
    * @author: amartinez (2018/11/20)
    */
    public static Map<Id, Account> queryOpportunityAccounts(List<Opportunity> newList)
    {
        Set<Id> accIds = new Set<Id>();
        for (Opportunity opp : newList)
        {
            if (opp.AccountId != null)
            {
                accIds.add(opp.AccountId);
            }
        }

        if (accIds.isEmpty())
        {
            return new Map<Id, Account>();
        }
        else 
        {
            return new Map<Id, Account>([SELECT OwnerId FROM Account WHERE Id IN :accIds]);
        }
    }

    /**
    * Asigna a cada oportunidad como propietario el propietario de la cuenta relacionada
    *  opp.OwnerId = opp.Account.OwnerId
    **
    * @author: amartinez (2018/11/20)
    */
    /*public static List<Opportunity> assignOpptyOwnerFromAccountOwner(List<Opportunity> opportunities, Map<Id, Account> accIdToAccount)
    {
        for (Opportunity opp : opportunities)
        {
            if (opp.AccountId != null && accIdToAccount.get(opp.AccountId) != null)
            {
                opp.OwnerId = accIdToAccount.get(opp.AccountId).OwnerId;
            }
        }

        return opportunities;
    }
    */
    /**
    * Asigna a las oportunidades valores por defecto en los campos Oficina_tecnica__c y Sede_Venta__c
    * si no tienen valores previos
    **
    * @author: amartinez (2018/11/20)
    */
    public static List<Opportunity> defaultSalesAndTechnicalOffices(List<Opportunity> opportunities)
    {
        Id defaultAccountId = null;

        for (Opportunity opp : opportunities)
        {
            // Recuperar la cuenta por defecto si se va a usar
            if (defaultAccountId == null && (opp.Oficina_tecnica__c == null || opp.Sede_Venta__c == null))
            {
                List<Account> defaultAccounts = [SELECT Id FROM Account WHERE Name = :Constants.DEFAULT_OPPORTUNITY_OFFICE_ACCOUNT_NAME];
                if (defaultAccounts.isEmpty())
                {
                    break; // Si no hay cuenta por defecto no se puede realizar el cambio
                }
                else 
                {
                    defaultAccountId = defaultAccounts.get(0).Id;   
                }
            }
            // Rellenar la oficina tecnica y sede de venta por defecto si estan vacios
            if (opp.Oficina_tecnica__c == null)
            {
                opp.Oficina_tecnica__c = defaultAccountId;
            }
            if (opp.Sede_Venta__c == null)
            {
                opp.Sede_Venta__c = defaultAccountId;
            }
        }

        return opportunities;
    }
    
    public class GenerateLicenseAndAMOpportunitiesResult
    {
        public List<Opportunity> opportunities;
        public Map<Opportunity, List<Linea_de_Proyecto__c>> opportunityToProjectLines;
        public Map<Linea_de_Proyecto__c, List<Licencia__c>> projectLinesToLicenses;
    }
    //Se usan para que sea posible incluir dentro del mapa como clave varias Oportunidades iguales como clave
    //Y varias Lineas de Proyecto iguales como clave
    //cuando una línea tiene licencias con diferente fecha de expiración, se deben replicar en dos Opp diferentes
    //que parten de lo mismo ocurre con la Líneas que contienen las licencias
    public static Integer tempProjLineSAPId = 0;
    public static Integer tempOppNameCont = 0;
    
    /**
    * Genera nuevas oportunidades a partir de oportunidades ganadas de tipo Licencia o AM
    **
    * @author: amartinez (2018/11/21)
    */
    public static GenerateLicenseAndAMOpportunitiesResult generateLicenseAndAMOpportunities(List<Opportunity> opportunities, Map<Id, Opportunity> oldOpportunities)
    {
        tempProjLineSAPId = 0; 
        tempOppNameCont = 0;

        Id amProjectLineRecordType = Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_AM).getRecordTypeId();
        Id licenseProjectLineRecordType = Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_LICENSES).getRecordTypeId();
        Id licenseRevProjectLineRecordType = Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_RENOVE).getRecordTypeId();
         Id licenseServicios = Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_SERVICIOS).getRecordTypeId();

        Id preventaRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_PRESALE).getRecordTypeId();
        Map<Id, Opportunity> changedOpptys = new Map<Id, Opportunity>(opportunities);

        // Recuperar los IDs de todas las oportunidades ganadas
        Set<Id> wonOpportunityIds = new Set<Id>();
        for (Opportunity opp : opportunities)
        {
            if (oldOpportunities.get(opp.Id).StageName != Constants.OPPORTUNITY_STAGE_WON && opp.StageName == Constants.OPPORTUNITY_STAGE_WON)
            {
                wonOpportunityIds.add(opp.Id);
            }
        }
        // Crear nuevas oportunidades y agruparlas por mes, teniendo cada oportunidad distintas lineas para las licencias y AMs de ese mes
        List<Opportunity> newOpportunities = new List<opportunity>();
        Map<Opportunity, List<Linea_de_Proyecto__c>> newOpptysWithLines = new Map<Opportunity, List<Linea_de_Proyecto__c>>();
        Map<Linea_de_Proyecto__c, List<Licencia__c>> linesToLicenses = new Map<Linea_de_Proyecto__c, List<Licencia__c>>();
        //Mapa controlador de fechas, se guarda en el mapa las oportunidades (ID), y dentro otro mapa de lista de Lineas por fechas
        Map<Opportunity, Map<Date, Map<Linea_de_proyecto__c, List<Licencia__c>>>> OportunidadConLPporFecha = new Map<Opportunity, Map<Date, Map<Linea_de_proyecto__c, List<Licencia__c>>>>();
        //Se guarda la fecha de fin con clave y las lienas como valor, para agruparlos según su fecha de cierre
        Map<Date, Map<Linea_de_proyecto__c, List<Licencia__c>>> lpPorFecha;
        Map<Linea_de_proyecto__c, List<Licencia__c>> lps;

        
    if(wonOpportunityIds.size()!=0){
        system.debug('wonopport' +wonOpportunityIds);
        // Recorremos todas las lineas de proyecto y licencias, y creamos las nuevas oportunidades y lineas de proyecto
        for (Linea_de_Proyecto__c projLine : [SELECT Name, Oportunidad__c,Responsable_de_SW__c, Oficina_tecnica__c,Fecha_Inicio__c,Fecha_Fin__c, RecordTypeId, Jefe_de_Proyecto_de_Ejecucion__c, Area__c,
                                                     Jefe_de_Proyecto_de_Preventa__c, Linea_principal__c, No_aplica_para_ejecucion__c, Tecnologia__c,Coste_estimado__c, 
                                                     Contacto__c, Fabricantes__c,Registrar_oportunidad_en_fabricante__c,CurrencyIsoCode, Gerencia__c,Sede__c,Importe_total_2__c,
                                                     (SELECT Fabricante__c, Name, Coste_unitario__c, Comision__c, CurrencyIsoCode, Precio_unitario__c, 
                                                             Unidades__c, Fecha_de_activacion__c, Fecha_de_expiracion__c 
                                                      FROM Licencias__r
                                                      ORDER BY Fecha_de_expiracion__c ASC)
                                              FROM Linea_de_Proyecto__c
                                              WHERE Oportunidad__c IN :wonOpportunityIds    AND 
                                                 (RecordTypeId = :licenseProjectLineRecordType OR RecordTypeId=:licenseRevProjectLineRecordType) 
                                                    AND RecordTypeId != :licenseServicios AND  No_aplica_para_ejecucion__c =False ]  )
        {
            lpPorFecha = new Map<Date, Map<Linea_de_proyecto__c, List<Licencia__c>>>();
            lps = new Map<Linea_de_proyecto__c, List<Licencia__c>>();
            system.debug('LPPPP'+projLine);

            // Si es una linea de tipo AM, copiamos la linea de proyecto y las colocamos en base a fecha de expiracion de la licencia
            /*if (projLine.RecordTypeId == amProjectLineRecordType)
            {
                //Se extrae la fecha de fin de la Línea de proyecto
                Date monthDate = Date.newInstance(projLine.Fecha_Fin__c.year(), projLine.Fecha_Fin__c.month(), 1);
                
                //si no existe ninguna Opp anteriormente guardada en el mapa, quiere decir que aún no se han procesado líneas de esta Opp
                if (!OportunidadConLPporFecha.containsKey(changedOpptys.get(projLine.Oportunidad__c))) 
                {
                    //Se genera una nueva Opp
                    // Opportunity newOpp = (Opportunity)createForRenewal(changedOpptys.get(projLine.Oportunidad__c));
                    // newOpp.CloseDate = monthDate;//la fecha será la misma que la fecha de fin de la línea de proyecto
                    Linea_de_Proyecto__c amRenewalLine = (Linea_de_Proyecto__c)createForRenewal(projLine);
                    //añadimos la línea
                    lps.put(amRenewalLine, null);
                    //Asociamos la nueva oportunidad con la nueva línea relacionada.
                    //newOpptysWithLines.put(newOpp, lps);
                    //añadimos al mapa la fecha de fin de la línea y la núeva línea
                    lpPorFecha.put(monthDate, lps);
                    //Finalmente añadimos al mapa como Clave la Opp que ha pasado a ganada, y las nueva línea generada para renovar (agrupadas por fecha)
                    OportunidadConLPporFecha.put(changedOpptys.get(projLine.Oportunidad__c), lpPorFecha);
                }
                else 
                {
                    //se genera la nueva línea para renovar
                    Linea_de_Proyecto__c amRenewalLine = (Linea_de_Proyecto__c)createForRenewal(projLine);
                    lpPorFecha = OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c));
                    //Se comprueba si hay mas líneas para esta Opp con la misma fecha de fin
                    if (lpPorFecha.containsKey(monthDate)) 
                    //si es así se agrupa esta línea con las demás
                    {
                        OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c)).get(monthDate).put(amRenewalLine ,null);
                    }
                    //De lo contrario se crea un nuevo mapa y se incluye la línea a la lista de Líneas para esta fecha de fin
                    else
                    {
                        lps.put(amRenewalLine, null);   
                        OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c)).put(monthDate, lps);
                    }
                }
                // Verificamos si no existe ninguna opp en esta fecha, y sino creamos una oportunidad
                // if (!dateToOppty.containsKey(monthDate))
                // {
                //     Opportunity newOpp = (Opportunity)createForRenewal(changedOpptys.get(projLine.Oportunidad__c));
                //     newOpp.CloseDate = monthDate;
                //     dateToOppty.put(monthDate, newOpp);
                //     newOpptysWithLines.put(newOpp, new List<Linea_de_Proyecto__c>());
                // }

                // // Añadimos a la opp existente en esta fecha una nueva linea de proyecto
                // Opportunity dateOpp = dateToOppty.get(monthDate);
                // Linea_de_Proyecto__c licenseRenewalLine = (Linea_de_Proyecto__c)createForRenewal(projLine);
                // licenseRenewalLine.Fecha_Fin__c = monthDate;
                // newOpptysWithLines.get(dateOpp).add(licenseRenewalLine);
            }*/
            if (projLine.RecordTypeId == licenseProjectLineRecordType ||  projLine.RecordTypeId == licenseRevProjectLineRecordType )
            {
                //Se extrae la fecha de fin de la Línea de proyecto
                //Date monthDate = Date.newInstance(projLine.Fecha_Fin__c.year(), projLine.Fecha_Fin__c.month(), 1);
                Map<Date, List<Licencia__c>> licenciasPorFecha = new Map<Date, List<Licencia__c>>();

                //si no existe ninguna Opp anteriormente guardada en el mapa, quiere decir que aún no se han procesado líneas de esta Opp
                if (!OportunidadConLPporFecha.containsKey(changedOpptys.get(projLine.Oportunidad__c))) 
                {
                    //Se genera una nueva Opp
                    // Opportunity newOpp = (Opportunity)createForRenewal(changedOpptys.get(projLine.Oportunidad__c));
                    // newOpp.CloseDate = monthDate;//la fecha será la misma que la fecha de fin de la línea de proyecto

                    //se recorren las licencias
                    for (Licencia__c license : projLine.Licencias__r)
                    {
                        //Se obtiene la fecha de expiración de la licencia
                        Date monthDateLicense = Date.newInstance(license.Fecha_de_expiracion__c.year(), license.Fecha_de_expiracion__c.month(), 1);

                        //Si no hay licencias que coincidan con esta fecha de expiración se crea un nuevo mapa (grupo de licencias)
                        if (!licenciasPorFecha.containsKey(monthDateLicense)) 
                        {
                            //lpPorFecha = new Map<Date, Map<Linea_de_proyecto__c, Licencia__c>>();
                            //lps = new Map<Linea_de_proyecto__c, Licencia__c>();

                            List<Licencia__c> licenciaList = new List<Licencia__c>();
                            //Se genera una nueva licencia
                            Licencia__c nuevaLicencia = (Licencia__c)createForRenewal(license);
                            licenciaList.add(nuevaLicencia);
                            licenciasPorFecha.put(monthDateLicense, licenciaList);
                            //Se incluyen dentro de un mapa auxiliar las licencias agrupadas por fecha
                        }
                        //De lo contrario se recupera el grupo y se añade una licencia más
                        else 
                        {
                            //Si existe el grupo de licencias por la fecha de la licencia actual, se añaden las licencias
                            Licencia__c nuevaLicencia = (Licencia__c)createForRenewal(license);
                            licenciasPorFecha.get(monthDateLicense).add(nuevaLicencia);
                        }
                    }
                   
                    //Se recorre el mapa agrupado por fechas
                    for (Date fechaLicencia : licenciasPorFecha.keySet()) 
                    {
                        //Se crea una Línea por cada grupo de fechas de Licencias
                        Linea_de_Proyecto__c licenseRenewalLine = (Linea_de_Proyecto__c)createForRenewal(projLine);
                        //se añade al mapa la línea con sus nuevas licencias
                        lps = new Map<Linea_de_proyecto__c, List<Licencia__c>>();
                        lps.put(licenseRenewalLine, licenciasPorFecha.get(fechaLicencia));

                        lpPorFecha.put(fechaLicencia, lps);
                       
                    }
                    // //añadimos la línea
                    // lps.add(licenseRenewalLine);
                    // //Asociamos la nueva oportunidad con la nueva línea relacionada.
                    // newOpptysWithLines.put(newOpp, lps);
                    //añadimos al mapa la fecha de fin de la línea y la núeva línea
                  
                    //Finalmente añadimos al mapa como Clave la Opp que ha pasado a ganada, y las nueva línea generada para renovar (agrupadas por fecha)
                    OportunidadConLPporFecha.put(changedOpptys.get(projLine.Oportunidad__c), lpPorFecha);
                }
                else

                {
                   

                    lpPorFecha = OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c));
                    //Se comprueba si hay mas líneas para esta Opp con la misma fecha de fin que la licencia
                    Date fechaFlag = null;
                    Linea_de_Proyecto__c licenseRenewalLineFlag = null; 
                    for (Licencia__c license : projLine.Licencias__r)
                    {
                        //Se obtiene la fecha de expiración de la licencia
                        Date monthDateLicense = Date.newInstance(license.Fecha_de_expiracion__c.year(), license.Fecha_de_expiracion__c.month(), 1);
                        if (lpPorFecha.containsKey(monthDateLicense)) 
                        //si es así se agrupa esta línea con las demás
                        {
                            Licencia__c nuevaLicencia = (Licencia__c)createForRenewal(license);
                            Linea_de_Proyecto__c licenseRenewalLine = new Linea_de_Proyecto__c();   
                            Boolean existeLineaLicencias = false;
                            //si ya existe una Fecha igual a la de la licencia, se busca alguna Línea de tipo Licencia donde agruparla
                            //se comprueba que la flag fechaFlag sea nula o su contenido sea diferente a a fecha de expiración de la licencia
                            //esto significa que la licenciaaún no tiene un padre Linea_deProyecto__c asociada para clonar
                            if ( fechaFlag == null || fechaFlag != monthDateLicense ) 
                            {
                                //igualamos las fechas para la siguiente línea
                                //si la siguiente lícencia contiene esta fecha de expiración, se agrupará dentro de 
                                //esta línea
                                fechaFlag = monthDateLicense;
                                licenseRenewalLine = (Linea_de_Proyecto__c)createForRenewal(projLine);
                                licenseRenewalLineFlag = licenseRenewalLine;

                                
                                List<Licencia__c> licencias = new List<Licencia__c>();
                                licencias.add(nuevaLicencia);
                                OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c)).get(monthDateLicense).put(licenseRenewalLine, licencias);
                            }
                            else 
                            {   
                               
                                //Se utiliza lps con la Línea de licencias existente y la Licencia incluida
                                OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c)).get(monthDateLicense).get(licenseRenewalLineFlag).add(nuevaLicencia);
                            }
                        }
                        //De lo contrario se crea un nuevo mapa y se incluye la línea a la lista de Líneas para esta fecha de fin
                        else
                        {
                               
                            //Se crea una nueva Línea para almacenar la fecha de esta Licencia
                            Linea_de_Proyecto__c licenseRenewalLineNew = (Linea_de_Proyecto__c)createForRenewal(projLine);   
                            Licencia__c nuevaLicencia = (Licencia__c)createForRenewal(license);

                            lps.put(licenseRenewalLineNew, new List<Licencia__c>());
                            lps.get(licenseRenewalLineNew).add(nuevaLicencia);  
                            OportunidadConLPporFecha.get(changedOpptys.get(projLine.Oportunidad__c)).put(monthDateLicense, lps);
                        }
                    }
                }               
                
            }   
            // Si es una linea de tipo licencias, hay que hacer todo por cada una de las licencias
            // else if (projLine.RecordTypeId == licenseProjectLineRecordType)
            // {
            //     Map<Date, Linea_de_Proyecto__c> monthToProjectLine = new Map<Date, Linea_de_Proyecto__c>();
            //     for (Licencia__c license : projLine.Licencias__r)
            //     {
            //         // Verificamos si no existe ninguna opp en esta fecha, y sino creamos una oportunidad
            //         Date monthDate = Date.newInstance(license.Fecha_de_expiracion__c.year(), license.Fecha_de_expiracion__c.month(), 1);
            //         if (!dateToOppty.containsKey(monthDate))
            //         {
            //             Opportunity newOpp = (Opportunity)createForRenewal(changedOpptys.get(projLine.Oportunidad__c));
            //             newOpp.CloseDate = monthDate;
            //             dateToOppty.put(monthDate, newOpp);
            //             newOpptysWithLines.put(newOpp, new List<Linea_de_Proyecto__c>());
            //         }
            //         Opportunity dateOpp = dateToOppty.get(monthDate);
            //         // Si para este mes no hemos creado una linea de proyecto (esta)
            //         if (!monthToProjectLine.containsKey(monthDate))
            //         {
            //             Linea_de_Proyecto__c licenseRenewalLine = (Linea_de_Proyecto__c)createForRenewal(projLine);
            //             licenseRenewalLine.Fecha_Fin__c = monthDate;

            //             monthToProjectLine.put(monthDate, licenseRenewalLine);
            //             linesToLicenses.put(licenseRenewalLine, new List<Licencia__c>());

            //             newOpptysWithLines.get(dateOpp).add(licenseRenewalLine);
            //         }
                    
            //         // Añadimos a la linea de proyecto una nueva licencia (única por mes y línea, al estar en el bucle de linea de proyecto)
            //         Linea_de_Proyecto__c renewalLine = monthToProjectLine.get(monthDate);
            //         Licencia__c nuevaLicencia = (Licencia__c)createForRenewal(license);
            //         linesToLicenses.get(renewalLine).add(nuevaLicencia);
            //     }
            // }
        }
    }
        //-Map<Opportunity, Map<Date, Map<Linea_de_proyecto__c, List<Licencia__c>>>>
        //System.debug('prueba magistral -- '+OportunidadConLPporFecha);
        // Empaquetamos todo en un wrapper y lo devolvemos
        GenerateLicenseAndAMOpportunitiesResult res = new GenerateLicenseAndAMOpportunitiesResult();
        List<Linea_de_proyecto__c> lpList;
        List<Licencia__c> licenciaList;
        //Se preparan los datos en el Wrapper
        for (Opportunity opp : OportunidadConLPporFecha.keySet()) 
        {
            
            for (Date fechaLP : OportunidadConLPporFecha.get(opp).KeySet()) {
                Opportunity oppRenovar =  (Opportunity)createForRenewal(opp);
                oppRenovar.CloseDate = Date.newInstance(fechaLP.year(), fechaLP.month(), fechaLP.day());

                //se genera una opp por cada grupo de Lineas agrupadas por fecha para esta Opp
                //OPP(1) => DATE(1) - LP(1) => TODAS LICENCIAS en la segunda vuelta OPP(2) => DATE(2) - LP(2) => TODAS LICENCIAS
                lpList = new List<Linea_de_proyecto__c>();
                newOpportunities.add( oppRenovar );
                //Se recorren las líneas de la Opp para guardarlas en una lista
                for (Linea_de_proyecto__c lp : OportunidadConLPporFecha.get(opp).get(fechaLP).keySet()) 
                {
                    lpList.add(lp);
                    licenciaList = new List<Licencia__c>();
                    linesToLicenses.put(lp, OportunidadConLPporFecha.get(opp).get(fechaLP).get(lp));
                }
                //La lista de líneas se asocian con la Opp   
                newOpptysWithLines.put(oppRenovar, lpList);
            }
        }       
        res.opportunities = newOpportunities;
        res.opportunityToProjectLines = newOpptysWithLines;
        res.projectLinesToLicenses = linesToLicenses;

        System.debug('Las nuevas opor a insertar automaticamente son:' + res);
        return res;
    }


    private static SObject createForRenewal(SObject orig)
    {
        if (orig.getSObjectType() == Schema.SObjectType.Opportunity.getSObjectType())
        {
            Opportunity original = (Opportunity) orig;
            Opportunity clone = new Opportunity();
            Integer indice = (original.Name.length()>26) ? 26 : original.Name.length();
            clone.Name = original.Name.substring(0, indice) +' - '+ String.valueOf(++tempOppNameCont)+' (RNV)';
            clone.CloseDate = Date.newInstance(original.CloseDate.year() ,original.CloseDate.month()+11, original.CloseDate.day());
        
            clone.Offering__c = original.Offering__c;
            clone.Oficina_tecnica__c = original.Oficina_tecnica__c;
            clone.Sede_Venta__c = original.Sede_Venta__c;
            clone.Solucion__c = original.Solucion__c;
            clone.Contacto_del_cliente__c = original.Contacto_del_cliente__c;
            clone.AccountId = original.AccountId;
            clone.CurrencyIsoCode = original.CurrencyIsoCode;
            clone.LeadSource = original.LeadSource;
            clone.OwnerId = original.OwnerId;
            clone.StageName = Constants.OPPORTUNITY_STAGE_IDENTIFIED;
            clone.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(Constants.OPPORTUNITY_RECORDTYPE_RENOVACION).getRecordTypeId();
            clone.Description = 'Opportunity identified automatically for renewal of licenses or AMs';//original.Description;
            clone.mercado__c=original.mercado__c;
            clone.Type=original.type == null ? 'Estándar':original.type;
            clone.Oportunidad_Relacionada__c= original.id;
            clone.amount=original.Amount;
            clone.Origen_de_la_oportunidad__c='Existing Business';
            return clone;
        }
        else if (orig.getSObjectType() == Schema.SObjectType.Linea_de_Proyecto__c.getSObjectType())
        {
            Linea_de_Proyecto__c original = (Linea_de_Proyecto__c) orig;
            Linea_de_Proyecto__c clone = new Linea_de_Proyecto__c();
            clone.Jefe_de_Proyecto_de_Ejecucion__c = original.Jefe_de_Proyecto_de_Ejecucion__c;
            clone.Jefe_de_Proyecto_de_Preventa__c = original.Jefe_de_Proyecto_de_Preventa__c;
            clone.Linea_principal__c = original.Linea_principal__c;
           // clone.Tecnologia__c = original.Tecnologia__c;
            clone.RecordTypeId = original.RecordTypeId;
            clone.Gerencia__c = original.Gerencia__c;
            clone.Area__c = original.Area__c;
            clone.Contacto__c = original.Contacto__c;
            clone.Registrar_oportunidad_en_fabricante__c = original.Registrar_oportunidad_en_fabricante__c;
            clone.Codigo_SAP_Ejecucion__c = String.valueOf(++tempProjLineSAPId);
            clone.Fecha_Inicio__c = original.Fecha_Fin__c;
            Integer numberDaysDue = original.Fecha_Inicio__c.daysBetween(original.Fecha_Fin__c);
            clone.Fecha_Fin__c = original.Fecha_Fin__c.addDays(numberDaysDue);
            clone.Oficina_tecnica__c = original.Oficina_tecnica__c;
            clone.Sede__c=original.Sede__c;
            clone.Responsable_de_SW__c= original.Responsable_de_SW__c;
            clone.Fabricantes__c=original.Fabricantes__c;
            clone.Tecnologia__c=original.Tecnologia__c;
            system.debug('reecord type---->'+original.RecordTypeId);
                Linea_de_Proyecto__c LPoriginal;

                LPoriginal =[select 
                    Responsable_de_LDP__c, 
                    ResponsabledeSW__c
                    from Linea_de_Proyecto__c
                where Id in  (:original.Id)
                ];
            if(original.RecordTypeId==Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_LICENSES).getRecordTypeId() || original.RecordTypeId==Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_RENOVE).getRecordTypeId()){

                //system.debug('responsable sw ' +LPoriginal.ResponsabledeSW__c);
                //clone.ResponsabledeSW__c=LPoriginal.ResponsabledeSW__c;
                
                clone.RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_RENOVE).getRecordTypeId();
            
            }else if(original.RecordTypeId==Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_AM).getRecordTypeId()) {
                
                clone.RecordTypeId=Schema.SObjectType.Linea_de_Proyecto__c.getRecordTypeInfosByDeveloperName().get(Constants.PROJECT_LINE_RECORDTYPE_AM).getRecordTypeId();
                clone.Importe_total_2__c=original.Importe_total_2__c;
                clone.Coste_estimado__c=original.Coste_estimado__c;
                
                }
            
            clone.CurrencyIsoCode=original.CurrencyIsoCode;

        
                
            clone.Responsable_de_LDP__c=LPoriginal.Responsable_de_LDP__c;
            

            return clone;
        }
        else if (orig.getSObjectType() == Schema.SObjectType.Licencia__c.getSObjectType())
        {
            Licencia__c original = (Licencia__c) orig;
            Licencia__c clone = new Licencia__c();
            clone.Fabricante__c = original.Fabricante__c;
            clone.Name = original.Name;
            clone.Coste_unitario__c = original.Coste_unitario__c;
            clone.Comision__c = original.Comision__c;
            clone.CurrencyIsoCode = original.CurrencyIsoCode;
            clone.Precio_unitario__c = original.Precio_unitario__c;
            clone.Unidades__c = original.Unidades__c;
            clone.Fecha_de_activacion__c = original.Fecha_de_expiracion__c;
            Integer numberDaysDue = original.Fecha_de_activacion__c.daysBetween(original.Fecha_de_expiracion__c);
            clone.Fecha_de_expiracion__c = original.Fecha_de_expiracion__c.addDays(numberDaysDue);
            return clone;
        }
        return null;
    }


    
      /** 
      * @description: (bulk before/after - para reutilizar) 
      *                 Conseguir las Opps que han modificado su Etapa a Preventa
      *                 y vinieron de Solicitada
      **
      * @Autor: Noemi Escudero del Olmo (06/11/2018)
      **
      * @Modificacion: 
      **
      * @Parametro: - listIds   
      *             - listPaths
      **
      */
    public static list<Opportunity> getOppWithAcc(list<Opportunity> newList, map<Id,Opportunity> oldMap)   
    {
        /////////////////////////////////////////////////////////////
        Opportunity oldOpp;
        Set<ID> setOpps = new Set<ID>();
        List<Opportunity> listOpp = new List<Opportunity>();
        /////////////////////////////////////////////////////////////
        
        //system.debug('newList: '+newlist);
        //system.debug('oldMap: '+oldMap);
        
        //bucle por las opps
        for (Opportunity opp : newList)
        {
            //Conseguir el mismo registro que se modifica, pero su estado anterior en SF
            oldOpp = oldMap.get(opp.Id);
            
            //Hacer la comprobación de que se haya cambiado de etapa y la etapa sea preventa
            if ((oldOpp.StageName == 'Solicitada') && (opp.StageName == 'Preventa')) //(opp.StageName != oldOpp.StageName)
            {
                setOpps.add(opp.Id); //guardar las opps para buscar su acc
            }
        }
        
        if (!setOpps.isEmpty())
        {
            //system.debug('setOpps: '+setOpps);
            //Conseguir su nombre, y el nombre de su cuenta y el mercado__c de la cuenta
            listOpp = [Select Id, Name,Sede_Venta__r.Name, Account.Name, mercado__c, Codigo_de_oportunidad__c,Sede_Venta__r.Sede__c From Opportunity Where id in :setOpps];
            
            return listOpp;
        }
        else
        {
            return new List<Opportunity>(); //Este null sirve para que no se ejecuten checkCreateFolderSharePoint y createFolderSharePoint si no existe dicha List
        }

    }
    
      /** 
      * @description: (before update - para que al after lleguen los registros limpios)  
      *                 cuando 1 Opp cambia a Etapa Preventa, se tiene que validar que estén rellenos:
      *                         · Acc.Mercado__c 
      *                         · Acc.Name
      *                         · Opp.Name
      **
      * @Autor: Noemi Escudero del Olmo (05/11/2018)
      **
      * @Modificacion: 
      **
      * @Parametro: - listIds   
      *             - listPaths
      **
      */
    public static void checkCreateFolderSharePoint(list<Opportunity> newList, map<Id,Opportunity> oldMap, list<Opportunity> listOppsConAcc)   
    {
        //listOppsConAcc se obtiene en el BulkBefore y NO se entra en esta función si está a null
      
        //Formar la URL y meterla a una lista de URLs (paths) (Recordar hacer esto 4 veces por la estructura):
        //  - Opp.Mercado__c / Acc.Name / system.now().year()-Opp.Codigo_de_oportunidad__c.substring(16) / Economico
        //                                           Enviado
        //                                           Interno
        //                                           Recibido
        //Guardar en una lista los Ids
        for(Opportunity oppConAcc : listOppsConAcc) 
        {
            //Si la oportunidad no tiene los campos requeridos, rollback 
            //Se tiene que recuperar el registro del Trigger.new que es el de la DML, sino no se hace rollback
            if(String.isBlank(oppConAcc.mercado__c) || oppConAcc.mercado__c == null || oppConAcc.mercado__c == '')
            {
                Trigger.newMap.get(oppConAcc.Id).addError('[Integración SharePoint]: Se necesita tener relleno el campo Mercado de la Oportunidad.');  
            }
            else if(String.isBlank(oppConAcc.Account.Name) || oppConAcc.Account.Name == null || oppConAcc.Account.Name == '')
            {
                Trigger.newMap.get(oppConAcc.Id).addError('[Integración SharePoint]: Se necesita tener relleno el campo Nombre de la Cuenta.');  
            }
            else if(String.isBlank(oppConAcc.Codigo_de_oportunidad__c) || oppConAcc.Codigo_de_oportunidad__c == null || oppConAcc.Codigo_de_oportunidad__c == '' || oppConAcc.Codigo_de_oportunidad__c.length()<13)
            {
                Trigger.newMap.get(oppConAcc.Id).addError('[Integración SharePoint]: Se necesita tener relleno con un autonumérico el campo Codigo de Oportunidad de la Oportunidad.');  
            }
        }

    }
    
    /** 
    * @description: (afet update - no se puede llamar a future en el before) 
    *               cuando 1 Opp cambia a Etapa Preventa, se llama
    *               a la integración con SharePoint para crear una carpeta
    *                   - Solo funciona si se modifica 1 Opp a la vez
    *                   - En el before se habrá hecho rollback de las Opps que no tengan relleno:
    *                       · Acc.Mercado__c 
    *                       · Acc.Name
    *                       · Opp.Name
    **
    * @Autor: Noemi Escudero del Olmo (29/10/2018)
    **
    * @Modificacion: 
    **
    * @Parametro: - listIds 
    *           - listPaths
    **
    */
    public static void createFolderSharePoint(list<Opportunity> newList, map<Id,Opportunity> oldMap, list<Opportunity> listOppsConAcc)   
    {
        
        //listOppsConAcc se obtiene en el BulkAfter y NO se entra en esta función si está a null
        
        /////////////////////////////////////////////////////////////
        List<ID> listIds = new List<ID>();
        List<String> listPaths = new List<String>();
        String Mercado='';
        /////////////////////////////////////////////////////////////

        if (listOppsConAcc.size() == 1) //SI HAY MÁS DE UNA OPP NO HACE NADA, SE HARÁ EN EL BATCH
        {
            //Formar la URL y meterla a una lista de URLs (paths) (Recordar hacer esto 4 veces por la estructura):
            //  - Opp.Mercado__c / Acc.Name / system.now().year()-Opp.Codigo_de_oportunidad__c.substring(10) / Economico
            //                                           Enviado
            //                                           Interno
            //                                           Recibido
            //Guardar en una lista los Ids
            for(Opportunity oppConAcc : listOppsConAcc)
            {
                String abreviatura=[select id,Abreviatura__c from CodigoSharepointSedes__mdt where Codigo__c=:oppConAcc.Sede_Venta__r.Sede__c ].Abreviatura__c;
                if(abreviatura==null){
                    abreviatura='';
                }
                if(oppConAcc.Mercado__c=='Banca-Banca'){
                    Mercado='Global Banking';
                }
                if(oppConAcc.Mercado__c=='Seguros-Seguros'){
                    Mercado='Global Insurance';
                }
                if(oppConAcc.Mercado__c=='Telco-Media'){
                    Mercado='Telco';
                }
                if(oppConAcc.Mercado__c=='Energía'){
                    Mercado='Energy';
                }
                if(oppConAcc.Mercado__c=='A.Pub-Admin. Pública'){
                    Mercado='Goverment';
                }
     
                
                
                String NombreCuenta=oppConAcc.Account.Name;
                System.debug(NombreCuenta.substring(NombreCuenta.length()-1, NombreCuenta.length()));
                String nombreAccount= oppConAcc.Account.Name;
                    if(NombreCuenta.substring(NombreCuenta.length()-1, NombreCuenta.length())=='.'){

                       
                            nombreAccount=oppConAcc.Account.Name.substring(0,oppConAcc.Account.Name.length()-1);
                    }
                    
                if(abreviatura!=''){  
                    //Economico
                    
                    listPaths.add(abreviatura+'/'+oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Economic');
                    listIds.add(oppConAcc.Id);
                    
                    //Enviado
                    listPaths.add(abreviatura+'/'+oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Sent');
                    listIds.add(oppConAcc.Id);
                    
                    //Interno
                    listPaths.add(abreviatura+'/'+oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Intern');
                    listIds.add(oppConAcc.Id);
                    
                    //Recibido
                    listPaths.add(abreviatura+'/'+oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Received');
                    listIds.add(oppConAcc.Id);
                }else{
                    //Economico
                    listPaths.add(oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Economic');
                    listIds.add(oppConAcc.Id);
                    
                    //Enviado
                    listPaths.add(oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Sent');
                    listIds.add(oppConAcc.Id);
                    
                    //Interno
                    listPaths.add(oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Intern');
                    listIds.add(oppConAcc.Id);
                    
                    //Recibido
                    listPaths.add(oppConAcc.Mercado__c + '/' + nombreAccount + '/' + System.now().year() +'-'+ oppConAcc.Codigo_de_oportunidad__c.substring(10) + '/Received');
                    listIds.add(oppConAcc.Id);
                }


            }
            system.debug('ENLACEEEEEE' + listPaths.get(0));
            if (listPaths != null && listIds != null)
            {
                //Callout a @future
                if(!Test.isRunningTest()){
                IntegracionSharePointVass.crearCarpetaFuturo(listPaths , 'POST', listIds);  
                }
            }

        }
        
    }

    /**
    *@description: se recuperan las lineas de proyecto cuando la Opp pasa a preventa, posteriormente se marcan
                   sincronizado SAP como false, se serializan las preventas y se envían al ws de SAP.
    *@param name Description: oportunidades, las oportunidades modificadas.
                              path: ruta del WS SAP
                              olMap: trigger.old de oportunidades
    *@author name: rpolvera
    *@date date: 19/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: OpportunityHandler
    **/ 
    public static void serializeAndSendProjectLinesPreventa(list<Opportunity> oportunidades, String path, map<Id,SObject> oldMap)
    {
        Set<String> idsOpp = new Set<String>();
        String serializedPreventa;
        //recuperamos el ID de las oportunidades que sean cambiadas a Preventa
        for (Opportunity opp: oportunidades) 
        {
            if (opp.stageName.equals('Preventa') && ((Opportunity)oldMap.get(opp.Id)).get('stageName').equals('Solicitada')) 
            {
                idsOpp.add(opp.Id);
            }
        }
        if(idsOpp.size()!=0){
        //se recuperan las lineas de proyecto relacionadas a estas Oportunidades

        
        List<Linea_de_Proyecto__c> preventas = [SELECT
                                                        Id,
                                                        Codigo_SAP_Preventa__c,
                                                        Name,
                                                        Nombre_SAP__c,
                                                        Area__c,
                                                        CreatedDate,
                                                        Oficina_tecnica__c,
                                                        Fecha_Fin__c, 
                                                        Fecha_Inicio__c,
                                                        Gerencia__c,
                                                        Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,
                                                        Margen_real__c,
                                                        Importe_total_2__c,
                                                        Responsable_de_LDP__r.EmployeeNumber,
                                                        Tecnologia__c,
                                                        Oportunidad__r.Proyecto_extraordinario__c,
                                                        Oportunidad__r.Codigo_de_oportunidad__c,
                                                        Oportunidad__r.Owner.EmployeeNumber,
                                                        Oportunidad__r.CreatedDate,   
                                                        CreatedById,
                                                        Oportunidad__r.Offering__r.EmployeeNumber,
                                                        Oportunidad__r.Offering__r.Profile.Id,
                                                        Sede__c,
                                                		Fabricantes__c,
                                                        NEW_Nombre_SAP__c,
                                                		Oportunidad__r.mercado__c,
                                                        Oportunidad__r.Account.ID_SAP__c,
                                               			Oportunidad__r.Sede_Venta__r.Oficina_tecnica_SAP__c  
                                                    
                                                FROM Linea_de_Proyecto__c
                                                WHERE Oportunidad__r.Id IN :idsOpp
                                                AND Oportunidad__r.Account.ID_SAP__c != null 
                                                And sede__c!='1410'
                                                AND Validado_para_Preventa__c = true AND  Oportunidad__r.Sede_Venta__r.Name IN  :Constants.SEDE_VENTA_SINCRO_SAP];

        system.debug('LAS PREVENTAS DEL OPORUTIL--------------->' + preventas);
        if(preventas.size()>0) 
        {
            if(!Test.isRunningTest()){
            serializedPreventa = JSON.serialize(preventas);
            CalloutUtil.sendObjsToSAPFromTrigger(serializedPreventa, Constants.SAP_LPS_PREVENTA_PATH, 'Linea_de_Proyecto__c');
            }
            }
        }
    }

   

    /**
    *@description: se serializa y se envía una opp para su sincronización en SAP.
    *@param name Description: oportunidad, la oportunidad a enviar.
                              path: ruta del WS SAP
                              posponer: indica si tras recibir la respuesta de sap, se espera antes de realizar DMLs
    *@author name: gserrano
    *@date date: 27/11/2018
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    *@see class/method: Batch_SincronizarLineasDeProyecto.execute
    **/ 
    public static void serializeAndSendOpportunity(List<Opportunity> oportunidad, String path, Boolean posponer)
    {   
        if(oportunidad != null) 
        {
            String serializedOpportunity = JSON.serialize(oportunidad);
            CalloutUtil.sendObjsToSAP(serializedOpportunity, path, 'Oportunidad', true);
        }
    }

      /**
    *@description: Comprueba los margenes para hacer saltar validaciobes
    *@param name Description: oportunidad, la oportunidad para chekear el margen
    *@author name: Amartos
    *@date date: 18/05/2020
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    **/ 
    public static void CheckMargen(List<Opportunity> oportunidad,map<Id,SObject> oldMap)
    {   

        Double ImporteLL=0;
        Double CosteLL=0;
        Decimal MargenLL=1;
        Decimal ImporteAM=0;
        Double CosteAM=0;
        Decimal MargenAM=1;
        Double ImporteSW=0;
        Double CosteSW=0;
        Decimal MargenSW=1;
        Double ImporteTM=0;
        Double CosteTM=0;
        Decimal MargenTM=1;
        Boolean LL=false;
        Boolean AM=false;
        Boolean SW=false;
        Boolean TM=false;
        String Validacion='Para esta sede(';

        for (SObject sobj : oportunidad)
        {
        
            Opportunity oldOpp= (Opportunity)oldMap.get(sobj.Id);
            Opportunity newOpp = (Opportunity)Trigger.newMap.get(sobj.Id);
            
                    

                    if(newOpp.StageName=='Entregada' && oldOpp.StageName=='Preventa'  ) 
                    {
                        List<Opportunity> Sede= [Select Sede_Venta__r.Sede__c,Sede_Venta__r.Name from Opportunity where id =:newOpp.id];
                    
                        Validacion=Validacion +Sede.get(0).Sede_Venta__r.Name+'),';
                        for (Linea_de_Proyecto__c lp: [Select  RecordType.DeveloperName ,Coste_total_licencias__c , Importe_a_elevar__c,Coste_estimado__c from Linea_de_Proyecto__c where Oportunidad__c=:newOpp.id AND EsIntercompany__c=false and Gerencia__c!='Talent Solutions' and Venta_Extraordinaria__c=false and No_aplica_para_ejecucion__c=false]){

                            if(lp.RecordType.DeveloperName == Constants.PROJECT_LINE_RECORDTYPE_TURNKEY){
                                ImporteLL+=lp.Importe_a_elevar__c;
                                CosteLL+=lp.Coste_estimado__c;
                                LL=true;
                            }else if(lp.RecordType.DeveloperName == Constants.PROJECT_LINE_RECORDTYPE_AM){
                                ImporteAM+=lp.Importe_a_elevar__c;
                                CosteAM+=lp.Coste_estimado__c;
                                AM=true;

                            }else if(lp.RecordType.DeveloperName == Constants.PROJECT_LINE_RECORDTYPE_LICENSES){
                                ImporteSW+=lp.Importe_a_elevar__c;
                                CosteSW+=lp.Coste_total_licencias__c;
                                SW=true;
                            }else if(lp.RecordType.DeveloperName == 'TM'){
                                ImporteTM+=lp.Importe_a_elevar__c;
                                CosteTM+=lp.Coste_estimado__c;
                                TM=true;

                                }
                        }

                        

                        if(LL){
                            MargenLL=(ImporteLL-CosteLL)/ImporteLL;
                            MargenLL=MargenLL*100;

                        }
                        if(AM){
                            MargenAM=(ImporteAM-CosteAM)/ImporteAM;
                            MargenAM=MargenAM*100;
                        }
                        if(SW){
                            MargenSW=(ImporteSW-CosteSW)/ImporteSW;
                            MargenSW=MargenSW*100;
                        }

                        if(TM){
                            MargenTM=(ImporteTM-CosteTM)/ImporteTM;
                            MargenTM=MargenTM*100;
                        }

                        Boolean  ValidacionLL=false;
                        Boolean  ValidacionTM=false;
                        Boolean  ValidacionAM=false;
                        Boolean  ValidacionSW=false;
                        Boolean  Notificacion=false;
                        
                        for( Margenes__mdt mtd :[Select 	MargenFijo__c,MargenVariable__c,Mercado__c, Sede__c,Tipo__c from Margenes__mdt  where Sede__c=:Sede.get(0).Sede_Venta__r.Sede__c and Mercado__c=:newOpp.Mercado__c ]){
                            
                            Double margenMinino= (mtd.MargenVariable__c+mtd.MargenFijo__c);
                            
                            if(mtd.Tipo__c=='LL' & LL){
                               
                                if(MargenLL +0.1<margenMinino){
                                    Validacion=Validacion+'este mercado(' + mtd.Mercado__c+'),';
                                    Validacion=Validacion+' y este tipo de registro ('+mtd.Tipo__c+') el margen minimo es: ' + margenMinino +' y el valor del margen  en la oportunidad es de : ' + MargenLL.setScale(2);
                                    ValidacionLL=true;
                                    Notificacion=true;

                                    system.debug('SAMOS A LOS APROBADORES');
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),Sede.get(0).Sede_Venta__r.Sede__c,false);

                                    
                                }
                            
                            }
                            if(mtd.Tipo__c=='AM' & AM ){
                                
                                if(MargenAM+0.1<margenMinino){
                                    Validacion=Validacion+'este mercado(' + mtd.Mercado__c+')';
                                    Validacion=Validacion+' y este tipo de registro ('+mtd.Tipo__c+') el margen minimo es: ' + margenMinino +' y el valor del margen en la oportunidad es de : ' + MargenAM.setScale(2);
                                    ValidacionAM=true;
                                    Notificacion=true;
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),Sede.get(0).Sede_Venta__r.Sede__c,false);
                                }

                            }

                            if(mtd.Tipo__c=='TM' & TM){
                                
                                if(MargenTM+0.1<margenMinino){
                                    Validacion=Validacion+'este mercado(' + mtd.Mercado__c+')';
                                    Validacion=Validacion+' y este tipo de registro ('+mtd.Tipo__c+') el margen minimo es: ' + margenMinino +'y el valor del margen en la oportunidad es de : ' + MargenTM.setScale(2);
                                    ValidacionTM=true;
                                    Notificacion=true;
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),Sede.get(0).Sede_Venta__r.Sede__c,false);
                                }
                                
                            }

                            if(mtd.Tipo__c=='SW' & SW){
                                
                                if(MargenSW+0.1<margenMinino){
                                    Validacion=Validacion+'este mercado(' + mtd.Mercado__c+')';
                                    Validacion=Validacion+' y este tipo de registro ('+mtd.Tipo__c+') el margen minimo es: ' + margenMinino +' y el valor del margen  en la oportuniad es de : ' + MargenSW.setScale(2);
                                    ValidacionSW=true;
                                    Notificacion=true;
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),Sede.get(0).Sede_Venta__r.Sede__c,false,mtd.Tipo__c,MargenSW);
                                    
                                }
                                
                            }
                        


                        }

                        

                        for (Opportunity opp : oportunidad)
                        {
                            opp.ValidacionLL__c=ValidacionLL;
                            opp.ValidacionAM__c=ValidacionAM;
                            opp.ValidacionSW__c=ValidacionSW;
                            opp.ValidacionTM__c=ValidacionTM;
                            opp.Motivo_aprobacion__c=validacion;
                            

                        }

                        if(Notificacion){
                            Map<String, Object> params = new Map<String, Object>();
                            params.put('Titulo', 'Oportunidad enviada para aprobación');
                            params.put('Cuerpo', 'La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a que no cumple los márgenes mínimos ');
                            params.put('Usuarios', oportunidad.get(0).Ownerid);
                            params.put('idopor2',oportunidad.get(0).id);


                            Flow.Interview.EnvioNotificacion NotiFlow = new Flow.Interview.EnvioNotificacion(params);
                            NotiFlow.start();
                            Notificacion=false;
                            oportunidad.get(0).stageName='Pendiente Aprobacion';
                            


                        }



                    

                    }
                }   

    }
     /**
    *@description: Comprueba si es proyectoestrategico       para hacer saltar validaciobes
    *@param name Description: oportunidad, la oportunidad para chekear el margen
    *@author name: Amartos
    *@date date: 22/05/2020
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    **/ 
    public static void CheckProyectoEstra(List<Opportunity> oportunidad,map<Id,SObject> oldMap)
    {   
        for (SObject sobj : oportunidad)
        {
        
            Opportunity oldOpp= (Opportunity)oldMap.get(sobj.Id);
            Opportunity newOpp = (Opportunity)Trigger.newMap.get(sobj.Id);
		
      
            if(newOpp.StageName=='Entregada' && oldOpp.StageName=='Preventa' && newOpp.Proyecto_estrategico__c==true  ) {
				List<Opportunity> Sede= [Select Sede_Venta__r.Sede__c,Sede_Venta__r.Name from Opportunity where id =:newOpp.id];	
                Map<String, Object> params = new Map<String, Object>();
                params.put('Titulo', 'Oportunidad enviada para aprobación');
                String cuerpo;
                cuerpo='estratégico';
                
                params.put('Cuerpo', 'La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a que esta marcada como proyecto'+cuerpo);
                params.put('Usuarios', oportunidad.get(0).Ownerid);
                params.put('idopor2',oportunidad.get(0).id);


                Flow.Interview.EnvioNotificacion NotiFlow = new Flow.Interview.EnvioNotificacion(params);
                NotiFlow.start();
                oportunidad.get(0).stageName='Pendiente Aprobacion';
                String motivo='La oportunidad esta marcada como';
             
                motivo=motivo+' proyecto estratégico';
                OpportunityUtil.AsignarAprobadores(oportunidad.get(0),Sede.get(0).Sede_Venta__r.Sede__c,false );
                
                oportunidad.get(0).Motivo_aprobacion__c=motivo;
                oportunidad.get(0).ValidacionEstrategico__c=newOpp.Proyecto_estrategico__c;
                


            }
        }
      
    }


    public static void CheckVentaExtra(List<Opportunity> oportunidad,map<Id,SObject> oldMap)
    {   
        for (SObject sobj : oportunidad)
        {
        
            Opportunity oldOpp= (Opportunity)oldMap.get(sobj.Id);
            Opportunity newOpp = (Opportunity)Trigger.newMap.get(sobj.Id);
            String motivo='';
            String MensajeLp='';
            Map<String, Object> params = new Map<String, Object>();
		
           
            if(newOpp.StageName=='Entregada' && oldOpp.StageName=='Preventa' && newOpp.Aprobado_Venta_Extra__c==false ) {
                
             List<Linea_de_Proyecto__c> Lineas =[Select id,Venta_Extraordinaria__c,name ,Motivo_Venta_Extra__c,Margen_Intercompany__c  from Linea_de_Proyecto__c where 	Oportunidad__c=:newOpp.id and Venta_Extraordinaria__c=true  ];
             
             if(Lineas.size()!=0){
               List<Opportunity> Sede= [Select Sede_Venta__r.Sede__c,Sede_Venta__r.Name from Opportunity where id =:newOpp.id];
                motivo= 'Las siguientes líneas estan marcadas como venta extraordinaria:\n';
                for(Linea_de_Proyecto__c lp : lineas){
                    MensajeLp = MensajeLp +''+ 'Línea:' +' ' +lp.Name +' Motivos: ' +' ' +lp.Motivo_Venta_Extra__c+'\n';


                }

                params.put('Titulo', 'Algunas líenas estan marcadas como venta extraordinaria');
                params.put('Cuerpo', 'La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a que alguna de sus líneas esta marcada como venta extraordinaria');
                params.put('Usuarios', oportunidad.get(0).Ownerid);
                params.put('idopor2',oportunidad.get(0).id);


                Flow.Interview.EnvioNotificacion NotiFlow = new Flow.Interview.EnvioNotificacion(params);
                NotiFlow.start();
                oportunidad.get(0).stageName='Pendiente Aprobacion';
                

                    
                motivo=motivo+MensajeLp;
                OpportunityUtil.AsignarAprobadores(oportunidad.get(0),Sede.get(0).Sede_Venta__r.Sede__c,false,'EXTRA',Lineas.get(0).Margen_Intercompany__c);
                        
                oportunidad.get(0).Motivo_aprobacion__c=motivo;
                oportunidad.get(0).ValidacionVentaExtra__c=true;
                    


            }
            }
        }
      
    }

       /**
    *@description: Comprueba el margen intercompany
    *@param name Description: oportunidad, la oportunidad para chekear el margen
    *@author name: Amartos
    *@date date: 22/05/2020
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    **/ 
    public static void CheckMargenIntercompany(List<Opportunity> oportunidad,map<Id,SObject> oldMap)
    {   
        Double ImporteLL=0;
        

        for (SObject sobj : oportunidad)
        {
        
            Opportunity oldOpp= (Opportunity)oldMap.get(sobj.Id);
            Opportunity newOpp = (Opportunity)Trigger.newMap.get(sobj.Id);
            
                    if(newOpp.StageName=='Entregada' && oldOpp.StageName=='Preventa'  ) 
                    {
                        String SedeOpor= [Select Sede_Venta__r.Sede__c from Opportunity where id =:newOpp.id].Sede_Venta__r.Sede__c;
                        String Mercado= [Select Mercado__c  from Opportunity where id =:newOpp.id].Mercado__c;
                        for (Linea_de_Proyecto__c lp: [Select  id,Sede__c,Responsable_de_LDP__c, Name,Oportunidad__c,Margen_Intercompany__c ,Margen_de_venta__c from Linea_de_Proyecto__c where Oportunidad__c=:newOpp.id AND EsIntercompany__c=true]){
                            
                            Margenes__mdt mtd =[Select 	MargenFijo__c,MargenVariable__c,Mercado__c, Sede__c,Tipo__c from Margenes__mdt  where Sede__c=:lp.Sede__c and Mercado__c=:Mercado limit 1 ];
                            List <MargenesIntercompany__mdt> meta =[select Margen__c   from MargenesIntercompany__mdt  where SedeLinea__c =:lp.Sede__c and SedeOport__c=:SedeOpor ];

                            if(mtd!=null){
                                if(lp.Margen_de_venta__c<(mtd.MargenVariable__c+mtd.MargenFijo__c)){
                                    
                                    Map<String, Object> params = new Map<String, Object>();
                                    params.put('Titulo', 'Oportunidad enviada para aprobación');
                                    params.put('Cuerpo', 'La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a que la línea' +lp.name+' no cumple los márgenes mínimos');
                                    params.put('Usuarios', lp.Responsable_de_LDP__c);
                                    params.put('idopor2',lp.id);
                                    oportunidad.get(0).stageName='Pendiente Aprobacion';
                                    oportunidad.get(0).ValidacionIntercompany__c=true;
                                    oportunidad.get(0).Motivo_aprobacion__c='La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a que la línea ' +lp.name+' no cumple los márgenes mínimos que para este mercado( '+mercado+' ) y sede( '+lp.sede__c+' )  es un '+ (mtd.MargenVariable__c+mtd.MargenFijo__c)+' y la línea tiene un '+lp.Margen_de_venta__c +'. Por favor, revise los márgenes de venta de las líneas intercompany';
                                    Flow.Interview.EnvioNotificacion NotiFlow = new Flow.Interview.EnvioNotificacion(params);
                                    NotiFlow.start();
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),lp.sede__c,false );
                                    break;
                                }
                            }

                            if(meta.size()>0){
                            
                        
                                if(lp.Margen_Intercompany__c<meta.get(0).Margen__c ){
                        

    
                                    Map<String, Object> params = new Map<String, Object>();
                                    params.put('Titulo', 'Oportunidad enviada para aprobación');
                                    params.put('Cuerpo', 'La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a que la línea'+lp.name+' no cumple los márgenes mínimos Intercompany');
                                    params.put('Usuarios', oportunidad.get(0).Ownerid);
                                    params.put('idopor2',lp.id);
                                    oportunidad.get(0).stageName='Pendiente Aprobacion';
                                    oportunidad.get(0).ValidacionIntercompany__c=true;
                                    oportunidad.get(0).Motivo_aprobacion__c='La oportunidad no cumple con el márgen minimo intercompany';
                                    Flow.Interview.EnvioNotificacion NotiFlow = new Flow.Interview.EnvioNotificacion(params);
                                    NotiFlow.start();
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),SedeOpor,false );
                                    break;
                                }
                                }


                                }
                    }

                        

                      
        }
    }   


     /**
    *@description: Comprueba si es proyectoestrategico       para hacer saltar validaciobes
    *@param name Description: oportunidad, la oportunidad para chekear el margen
    *@author name: Amartos
    *@date date: 22/05/2020
    *@change name date description: Nuevo Método.
    *@throws Exception: 
    *@where description: 
    **/ 
    public static void CheckImporteExtra(List<Opportunity> oportunidad,map<Id,SObject> oldMap)
    {   
        for (SObject sobj : oportunidad)
        {
        
            Opportunity oldOpp= (Opportunity)oldMap.get(sobj.Id);
            Opportunity newOpp = (Opportunity)Trigger.newMap.get(sobj.Id);
		
           
            if(newOpp.StageName=='Entregada' && oldOpp.StageName=='Preventa' ) {

                String SedeOpor= [Select Sede_Venta__r.Sede__c from Opportunity where id =:newOpp.id].Sede_Venta__r.Sede__c;
        

                            List <ImporteMaximoValidacionSede__mdt> meta =[SELECT MaxImporte__c,CurrencyIsoCode__c  from ImporteMaximoValidacionSede__mdt  where Sede__c =:SedeOpor ];

                            if(meta.size()>0){
                                Decimal ConversionRate = [SELECT ISOCode, ConversionRate FROM CurrencyType WHERE IsActive=TRUE AND ISOCode=:newOpp.CurrencyIsoCode].ConversionRate;
                                Decimal  valorOPP;
                              
                                if(meta.get(0).CurrencyIsoCode__c!=newOpp.CurrencyISOCode ){
                                    valorOPP=newOpp.ImporteLineasSinLicencias__c/ConversionRate;
                                    
                                }else{

                                 valorOPP=newOpp.ImporteLineasSinLicencias__c;
                                }
                                system.debug('valorOPP' + valorOPP);
                                if(valorOPP>meta.get(0).MaxImporte__c ){
                        
                                    
    
                                    Map<String, Object> params = new Map<String, Object>();
                                    params.put('Titulo', 'Oportunidad enviada para aprobacion');
                      
                                    params.put('Cuerpo', 'La oportunidad:'+oportunidad.get(0).Name+' ha sido enviada para aprobación debido a  su importe y debe ser revisado por comite');
                                    params.put('Usuarios', oportunidad.get(0).Ownerid);
                                    params.put('idopor2',oportunidad.get(0).id);
                    		
                                    Flow.Interview.EnvioNotificacion NotiFlow = new Flow.Interview.EnvioNotificacion(params);
                                    NotiFlow.start();
                                    
                                    oportunidad.get(0).Motivo_aprobacion__c='La oportunidad supera el importe indicado para requerir aprobación';
                                    oportunidad.get(0).stageName='Pendiente Aprobacion';
                                    oportunidad.get(0).ValidacionImporte__c=true;
                                    OpportunityUtil.AsignarAprobadores(oportunidad.get(0),SedeOpor,true );
                                    break;
                    
                                }
                                }


                                
                    }


            }
        }


       public static void AsignarAprobadores(Opportunity opp,string sedeVenta,boolean Offering)
    {
          //todos los aprobadores tienen que estar rellenos, si hay menos de 4 se rellenan duplicando el valor del ultimo en la metada...Salesforce es maravilloso y
        // y no se pueden poner aprobadores dinamicamente(sin pagar claro)...esta es la mejor solucion que he conseguido...es una chapuza...pero funcioná :)

        if(Offering==false){
            system.debug('Aprobadores--->');
     		List< Aprobadores__mdt> app= [select Aprobador1__c,Aprobador2__c,Aprobador3__c,Aprobador4__c from Aprobadores__mdt where Sede__c=:sedeVenta and SW__c=false];
             if(app.size()!=0){
           
            opp.Aprobador1__c=app.get(0).Aprobador1__c;
            opp.Aprobador2__c=app.get(0).Aprobador2__c;
            opp.Aprobador3__c=app.get(0).Aprobador3__c;
            opp.Aprobador4__c=app.get(0).Aprobador4__c;   
            
            system.debug('Aprobadores--->'+ app);
             }   
        }else{
           	List< Aprobadores__mdt> app= [select Aprobador1__c,Aprobador2__c,Aprobador3__c,Aprobador4__c from Aprobadores__mdt where Offering__c=:true and SW__c=false];
            
               if(app.size()!=0){  
            opp.Aprobador1__c=app.get(0).Aprobador1__c;
            opp.Aprobador2__c=app.get(0).Aprobador2__c;
            opp.Aprobador3__c=app.get(0).Aprobador3__c;
            opp.Aprobador4__c=app.get(0).Aprobador4__c;   
               }
        }
      
     
      
    }


    public static void AsignarAprobadores(Opportunity opp,string sedeVenta,boolean Offering,string tipo, Decimal margen)
    {
          //todos los aprobadores tienen que estar rellenos, si hay menos de 4 se rellenan duplicando el valor del ultimo en la metada...Salesforce es maravilloso y
        // y no se pueden poner aprobadores dinamicamente(sin pagar claro)...esta es la mejor solucion que he conseguido...es una chapuza...pero funcioná :)

        system.debug('TIPO' +TIPO +'MARGEN ' + margen);
        if(tipo=='SW' && margen>=5 ){
            
            List< Aprobadores__mdt> app= [select Aprobador1__c,Aprobador2__c,Aprobador3__c,Aprobador4__c from Aprobadores__mdt where 	SW__c=true  and Menos_5__c=false];
            
            if(app.size()!=0){
            opp.Aprobador1__c=app.get(0).Aprobador1__c;
            opp.Aprobador2__c=app.get(0).Aprobador2__c;
            opp.Aprobador3__c=app.get(0).Aprobador3__c;
            opp.Aprobador4__c=app.get(0).Aprobador4__c;            
            }
        } else {
            List< Aprobadores__mdt> app= [select Aprobador1__c,Aprobador2__c,Aprobador3__c,Aprobador4__c from Aprobadores__mdt where SW__c=true and Menos_5__c=true ];
            
            if(app.size()!=0){
            opp.Aprobador1__c=app.get(0).Aprobador1__c;
            opp.Aprobador2__c=app.get(0).Aprobador2__c;
            opp.Aprobador3__c=app.get(0).Aprobador3__c;
            opp.Aprobador4__c=app.get(0).Aprobador4__c;   
            }
        }

        if(tipo=='EXTRA' && margen>=15){

            List< Aprobadores__mdt> app= [select Aprobador1__c,Aprobador2__c,Aprobador3__c,Aprobador4__c from Aprobadores__mdt where Extra__c=true ];
            
            if(app.size()!=0){
            opp.Aprobador1__c=app.get(0).Aprobador1__c;
            opp.Aprobador2__c=app.get(0).Aprobador2__c;
            opp.Aprobador3__c=app.get(0).Aprobador3__c;
            opp.Aprobador4__c=app.get(0).Aprobador4__c;   
            }

        }else if(tipo=='EXTRA' && margen<15){

            List< Aprobadores__mdt> app= [select Aprobador1__c,Aprobador2__c,Aprobador3__c,Aprobador4__c from Aprobadores__mdt where SW__c=true and Menos_5__c=true ];
            
            if(app.size()!=0){
            opp.Aprobador1__c=app.get(0).Aprobador1__c;
            opp.Aprobador2__c=app.get(0).Aprobador2__c;
            opp.Aprobador3__c=app.get(0).Aprobador3__c;
            opp.Aprobador4__c=app.get(0).Aprobador4__c;           

        }
       
    }
     
      
    }
    
      
    
}