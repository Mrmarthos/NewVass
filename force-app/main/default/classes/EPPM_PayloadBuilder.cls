public class EPPM_PayloadBuilder {
    private static final EPPM_MappingUtility mapper = EPPM_MappingUtility.getInstance();


    public static String generatePayload(Set<Id> opportunityIds) {
        List<Opportunity> opportunities = EPPM_Selector.getOpportunitiesWithDetails(opportunityIds);
        Map<Id, List<Hito_de_facturacion__c>> hitosPorLinea = EPPM_Selector.getHitosPorLinea(opportunityIds);
        
        if(opportunities.isEmpty()) return '{}';
        
        // Construir payload para la primera oportunidad (asumiendo 1 oportunidad por llamada)
        Map<String, Object> payload = buildOpportunityPayload(opportunities[0], hitosPorLinea);
        
        return JSON.serializePretty(payload, true);
    }

    private static Map<String, Object> buildOpportunityPayload(
        Opportunity opp, 
        Map<Id, List<Hito_de_facturacion__c>> hitosPorLinea
    ) {
        return new Map<String, Object>{
            'a_iniciativa' => new List<Map<String, Object>>{ buildInitiative(opp, hitosPorLinea) },
            'IdOportunidadRelacionada' => FormatUtility.handleNull(opp.Oportunidad_Relacionada__r?.Codigo_de_oportunidad__c),
            'VersionCSV' => opp.N_Cargas_Excel__c?.intValue() ?? 0,
            'Etapa' => FormatUtility.handleNull(mapper.getStageCode(opp.StageName)),
            'TipoProyecto' =>  mapper.getTipoCode(opp.RecordType.Name),
            'IdOportunidad' => FormatUtility.handleNull(opp.Codigo_de_oportunidad__c)
            
        };
    }

    private static Map<String, Object> buildInitiative(
        Opportunity opp, 
        Map<Id, List<Hito_de_facturacion__c>> hitosPorLinea
    ) {
        return new Map<String, Object>{
            'a_item' => buildLineItems(opp.Lineas_de_proyecto__r, hitosPorLinea),
            'IdOportunidad' => FormatUtility.handleNull(opp.Codigo_de_oportunidad__c),
            'IniativeName' => FormatUtility.handleNull(opp.Name),
            'FechaInicio' => FormatUtility.formatDate(opp.Fecha_de_inicio__c),
            'FechaFin' => FormatUtility.formatDate(opp.Fecha_de_fin__c),
            'FechaCreacion' => FormatUtility.formatDateTime(opp.CreatedDate),
            'FechaCierre' => FormatUtility.formatDate(opp.CloseDate),
            'SedeVenta' => FormatUtility.handleNull(opp.Sede_Venta__r?.sede__c),
            'Currency' => FormatUtility.handleNull(opp.CurrencyIsoCode),
            'LoB' => FormatUtility.convertirMultiPicklistASeparadorPipe(opp.lob__c),
            'IniativeDescription' => FormatUtility.handleNull(opp.Description),
            'ServicelineId' =>  '',
            'TheoreticalSalesMargin' => opp.Margen_bruto__c ?? 0,
            'TotalAmount' => opp.Amount ?? 0,
            'StrategicPartner' => FormatUtility.handleNull(opp.Strategic_Partner__c),
            'PropietarioOportunidad' => FormatUtility.padLeftWithZeros(opp.Owner?.EmployeeNumber),
            'Probabilidad' => opp.Probability ?? 0,
            'Comprometida' => FormatUtility.handleNull(opp.Commited__c),
            'WonValidated' => opp.GSO_Validated__c,
            'FrameworkContract' => FormatUtility.handleNull(opp.Framework_Contract__r?.Codigo_de_oportunidad__c),
            'VerticalNegocio' => mapper.getMercadoCode(opp.Mercado__c),
            'PresupuestoVenta' => opp.Amount,
            'BidManager' => FormatUtility.padLeftWithZeros(opp.Bid_Manager__r.employeenumber),
            'NombreCuentaTxt' => FormatUtility.handleNull(opp.Account.name),
            'NombreCuenta' => FormatUtility.handleNull(opp.Account.ID_SAP__c),
          	'PepInterco' => (opp.HasLineInterco__c != null && opp.HasLineInterco__c > 0),
            'AreaId' => mapper.getClanCode(opp.Clan_Principal__c),
            'TipoRegistro' =>mapper.getTipoCode(opp.recordtype.name),
               'Type'=>mapper.getTypoCode(opp.type),
  			'GPM' => FormatUtility.padLeftWithZeros(opp.GPM__r.Codigo_de_empleado__c)
           
 
   
        };
    }

private static List<Map<String, Object>> buildLineItems(
    List<Linea_de_proyecto__c> lineas, 
    Map<Id, List<Hito_de_facturacion__c>> hitosPorLinea
) {
    List<Map<String, Object>> items = new List<Map<String, Object>>();
    if(lineas == null || lineas.isEmpty()) return items;

    // 1. Agrupación por criterios clave
    Map<String, List<Linea_de_proyecto__c>> lineasAgrupadas = new Map<String, List<Linea_de_proyecto__c>>();
    for(Linea_de_proyecto__c linea : lineas) {
        String claveGrupo = String.valueOf(linea.Sede__c) + 
                          String.valueOf(linea.Gerencia__c);
        
        if(!lineasAgrupadas.containsKey(claveGrupo)) {
            lineasAgrupadas.put(claveGrupo, new List<Linea_de_proyecto__c>());
        }
        lineasAgrupadas.get(claveGrupo).add(linea);
    }

    // 2. Procesar cada grupo
    for(List<Linea_de_proyecto__c> grupo : lineasAgrupadas.values()) {
        if(grupo.isEmpty()) continue;

        // 2.1 Selección de línea base
        Linea_de_proyecto__c lineaBase = seleccionarLineaBase(grupo);

        // 2.2 Calcular totales y fechas
        CalculosGrupo resultados = calcularTotalesYFechas(grupo);

        // 2.3 Generar hitos consolidados
        List<Hito_de_facturacion__c> hitosConsolidados = generarHitosConsolidados(
            lineaBase, 
            hitosPorLinea, 
            resultados.sumaImporteTotal, 
            resultados.fechaInicioMin, 
            resultados.fechaFinMax
        );

        // 2.4 Construir item
        items.add(construirItem(lineaBase, resultados, hitosConsolidados));
    }
    return items;
}

// Clase wrapper para resultados
private class CalculosGrupo {
    public Decimal sumaImporteTotal;
    public Decimal sumaCosteEstimado;
    public Date fechaInicioMin;
    Public String NameConcat;
    public Date fechaFinMax;
}

// Métodos auxiliares
private static Linea_de_proyecto__c seleccionarLineaBase(List<Linea_de_proyecto__c> grupo) {
    Linea_de_proyecto__c lineaBase = null;
    Decimal maxImporte = -1;
    
    // Primero buscar líneas principales
    for(Linea_de_proyecto__c linea : grupo) {
        if(linea.Linea_principal__c) {
            Decimal currentImporte = linea.Importe_total_2__c != null ? linea.Importe_total_2__c : 0;
            if(lineaBase == null || currentImporte > maxImporte) {
                lineaBase = linea;
                maxImporte = currentImporte;
            }
        }
    }
    
    // Si no hay principales, buscar mayor importe
    if(lineaBase == null) {
        for(Linea_de_proyecto__c linea : grupo) {
            Decimal currentImporte = linea.Importe_total_2__c != null ? linea.Importe_total_2__c : 0;
            if(currentImporte > maxImporte) {
                lineaBase = linea;
                maxImporte = currentImporte;
            }
        }
    }
    
    return lineaBase != null ? lineaBase : grupo[0];
}

private static CalculosGrupo calcularTotalesYFechas(List<Linea_de_proyecto__c> grupo) {
    CalculosGrupo resultados = new CalculosGrupo();
    resultados.sumaImporteTotal = 0;
    resultados.sumaCosteEstimado = 0;
    resultados.fechaInicioMin = Date.newInstance(4000, 1, 1);
    resultados.fechaFinMax = Date.newInstance(1000, 1, 1);
    resultados.NameConcat = '';

    for (Integer i = 0; i < grupo.size(); i++) {
        Linea_de_proyecto__c l = grupo[i];
        resultados.sumaImporteTotal += l.Importe_total_2__c != null ? l.Importe_total_2__c : 0;
        resultados.sumaCosteEstimado += l.Coste_estimado__c != null ? l.Coste_estimado__c : 0;

        resultados.NameConcat += l.Name;
        if (i < grupo.size() - 1) {
            resultados.NameConcat += '_';
        }

        // Nueva lógica para fechas según etapa "Preventa"
        Date fechaInicioLinea;
        Date fechaFinLinea;

        if (l.Oportunidad__r != null && l.Oportunidad__r.StageName == 'Preventa') {
            fechaInicioLinea = l.Oportunidad__r.CreatedDate.date();
            fechaFinLinea = fechaInicioLinea.addMonths(3);
        } else {
            fechaInicioLinea = l.Fecha_Inicio__c;
            fechaFinLinea = l.Fecha_Fin__c;
        }

        // Actualizar fechas mínimas/máximas
        if (fechaInicioLinea != null && fechaInicioLinea < resultados.fechaInicioMin) {
            resultados.fechaInicioMin = fechaInicioLinea;
        }
        if (fechaFinLinea != null && fechaFinLinea > resultados.fechaFinMax) {
            resultados.fechaFinMax = fechaFinLinea;
        }
    }
    return resultados;
}


private static List<Hito_de_facturacion__c> generarHitosConsolidados(
    Linea_de_proyecto__c lineaBase, 
    Map<Id, List<Hito_de_facturacion__c>> hitosPorLinea,
    Decimal sumaImporteTotal,
    Date fechaInicioMin,
    Date fechaFinMax
) {
    List<Hito_de_facturacion__c> hitosConsolidados = new List<Hito_de_facturacion__c>();
    List<Hito_de_facturacion__c> hitosLineaBase = hitosPorLinea.get(lineaBase.Id);
    
    if(hitosLineaBase == null || hitosLineaBase.isEmpty()) return hitosConsolidados;
    
    Integer numHitos = hitosLineaBase.size();
    if(numHitos == 0 || sumaImporteTotal == 0) return hitosConsolidados;
    
    Decimal importePorHito = (sumaImporteTotal / numHitos).setScale(2, System.RoundingMode.HALF_UP);
    Decimal porcentajeHito = (100.0 / numHitos).setScale(2);
    Integer diasPorHito = fechaInicioMin.daysBetween(fechaFinMax) / (numHitos > 1 ? numHitos - 1 : 1);
    
    for(Integer i = 0; i < numHitos; i++) {
        Hito_de_facturacion__c hitoOriginal = hitosLineaBase[i];
        Date fechaHito = fechaInicioMin.addDays(i * diasPorHito);
        
        hitosConsolidados.add(new Hito_de_facturacion__c(
            Name = hitoOriginal.Name,
            Descripcion__c = hitoOriginal.Descripcion__c,
            Fecha__c = (i == numHitos-1) ? fechaFinMax : fechaHito,
            OppCode__c=hitoOriginal.OppCode__c,
            Importe__c = importePorHito,
            Porcentaje__c = porcentajeHito
        ));
    }
    
    return hitosConsolidados;
}

private static Map<String, Object> construirItem(
    Linea_de_proyecto__c lineaBase, 
    CalculosGrupo resultados,
    List<Hito_de_facturacion__c> hitosConsolidados
) {
    Decimal margenReal = resultados.sumaImporteTotal != 0 ? 
        ((resultados.sumaImporteTotal - resultados.sumaCosteEstimado) / resultados.sumaImporteTotal * 100).setScale(2) : 0;

    return new Map<String, Object>{
        'a_hito' => buildHitos(hitosConsolidados),
        'PlannedStart' => FormatUtility.formatDate(resultados.fechaInicioMin),
        'PlannedFinish' => FormatUtility.formatDate(resultados.fechaFinMax),
        'IdOportunidad' => FormatUtility.handleNull(lineaBase.Oportunidad__r?.Codigo_de_oportunidad__c),
        'SedeDeliveryCompany' => FormatUtility.handleNull(lineaBase.Sede__c),
        'IniativeId' => FormatUtility.handleNull(lineaBase.Sede__c+'_'+mapper.getClanCode(lineaBase.Gerencia__c)),
        'OrgDeliveryCompany' => FormatUtility.handleNull(lineaBase.Org_Ventas__c),
        'ItemId' => FormatUtility.handleNull(resultados.NameConcat),
        'OficinaTecnica' => FormatUtility.handleNull(lineaBase.Oficina_tecnica__c),
        'ItemName' => FormatUtility.handleNull(lineaBase.Execution_SAP_Name__c),
        'ItemNamePS' => FormatUtility.handleNull(lineaBase.NEW_Nombre_SAP__c),   
        'TipoRegistro' => FormatUtility.handleNull(lineaBase.RecordType.Name),
        'AreaId' => mapper.getClanCode(lineaBase.Gerencia__c),
        'ServicelineId' => '',
        'Practices' => FormatUtility.handleNull(lineaBase.Area__c),
        'LineaPrincipal' => FormatUtility.handleNull(lineaBase.Linea_principal__c),
        'ImporteTotal' => resultados.sumaImporteTotal.setScale(2),
        'MargenReal' => margenReal,
        'SalesPrice' => resultados.sumaImporteTotal.setScale(2),
        'Coste' => resultados.sumaCosteEstimado.setScale(2),
        'Currency' => FormatUtility.handleNull(lineaBase.CurrencyIsoCode),
        'Fabricante' => FormatUtility.handleNull(lineaBase.Fabricantes__c),
        'Comercial' => FormatUtility.padLeftWithZeros(lineaBase.Oportunidad__r?.Owner?.EmployeeNumber),
        'ComercialVass' =>'',
        'ResponsableOferta' => '',
        'JProPreventa' =>'',
        'JProEjecucion' => '',
        'JProEjecucionAdicional' => '',
        'PepInterco' => FormatUtility.handleNull(lineaBase.PEP_Interco__r?.Name),
        'NaEjecucion' =>  FormatUtility.handleNull(lineaBase.No_aplica_para_ejecucion__c),
        'LoB' => FormatUtility.handleNull(lineaBase.LOB__c),
        'PEPCode' => FormatUtility.handleNull(lineaBase.Codigo_SAP_Preventa__c),
        'ProyectoPadre' => FormatUtility.handleNull(lineaBase.Oportunidad__r?.Proyecto_Padre__c),
        'Mercado' => mapper.getMercadoCode(lineaBase.Oportunidad__r?.Mercado__c),
        'Competence' => lineaBase.Tecnologia__c,
        'NombreCuentaTxt' => FormatUtility.handleNull(lineaBase.Oportunidad__r?.Account?.Name),
        'NombreCuenta' => FormatUtility.handleNull(lineaBase.Oportunidad__r?.Account?.ID_SAP__c),
        'GPM' => ''
    };
}

     // Métodos auxiliares para combinación
    private static String getFechaMinima(List<Linea_de_proyecto__c> lineas) {
        Date fechaMin = lineas[0].Fecha_Inicio__c;
        for(Linea_de_proyecto__c l : lineas) {
            if(l.Fecha_Inicio__c < fechaMin) fechaMin = l.Fecha_Inicio__c;
        }
        return FormatUtility.formatDate(fechaMin);
    }

    private static String getFechaMaxima(List<Linea_de_proyecto__c> lineas) {
        Date fechaMax = lineas[0].Fecha_Fin__c;
        for(Linea_de_proyecto__c l : lineas) {
            if(l.Fecha_Fin__c > fechaMax) fechaMax = l.Fecha_Fin__c;
        }
        return FormatUtility.formatDate(fechaMax);
    }
    
    

    private static Decimal getSumaCampo(List<Linea_de_proyecto__c> lineas, String campo) {
        Decimal suma = 0;
        for(Linea_de_proyecto__c l : lineas) {
            suma += (Decimal)l.get(campo) != null ? (Decimal)l.get(campo) : 0;
        }
        return suma;
    }

    private static List<Map<String, Object>> buildHitos(List<Hito_de_facturacion__c> hitos) {
        List<Map<String, Object>> hitosPayload = new List<Map<String, Object>>();
        if(hitos == null) return hitosPayload;
        
        for(Hito_de_facturacion__c hito : hitos) {
            hitosPayload.add(new Map<String, Object>{
                'HitoDate' => FormatUtility.formatDate(hito.Fecha__c),
                    'IdOportunidad' => FormatUtility.handleNull(hito.OppCode__c),
                    'IniativeId' => '',
                    'ItemId' => '',  
                    'HitoId' =>  FormatUtility.handleNull(hito.id),
                    'HitoDescription' => FormatUtility.handleNull(hito.Descripcion__c),
                    'HitoAmount' => hito.Importe__c ?? 0,     
                    'HitoPorcentage' => hito.Porcentaje__c ?? 0,
                    'HitoDate' => FormatUtility.formatDate(hito.Fecha__c)
            });
        }
        return hitosPayload;
    }
}