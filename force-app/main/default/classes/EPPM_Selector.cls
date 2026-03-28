public inherited sharing class EPPM_Selector {
    public static List<Opportunity> getOpportunitiesWithDetails(Set<Id> opportunityIds) {
        return [SELECT 
            Id, Codigo_de_oportunidad__c, RecordType.Name, 
            N_Cargas_Excel__c, Oportunidad_Relacionada__r.Codigo_de_oportunidad__c, 
            Name, Fecha_de_inicio__c, Fecha_de_fin__c, CreatedDate, CloseDate,
            Sede_Venta__r.sede__c, CurrencyIsoCode,HasLineInterco__c, LOB__c, Description, Clan_Principal__c,
            Margen_real__c, Amount, Strategic_Partner__c, Account.ID_SAP__c,StageName, Account.Name,GPM__r.Codigo_de_empleado__c,Margen_bruto__c,
            Owner.EmployeeNumber, Probability, Commited__c, ID_SAP__c, EPPMID__c , GSO_Validated__c,Bid_Manager__r.employeenumber,GSO_Sede__c,
            Framework_Contract__r.Codigo_de_oportunidad__c, Mercado__c,type,
            (SELECT 
                Id, Fecha_Inicio__c, Fecha_Fin__c, Oportunidad__r.Codigo_de_oportunidad__c,
                Sede__c, Org_Ventas__c, Name, Oficina_tecnica__c, RecordType.Name,Coste_estimado__c,
                Gerencia__c, Area__c, Linea_principal__c, Importe_total_2__c, No_aplica_para_ejecucion__c,
                Margen_de_venta__c, Precio_Venta__c, CurrencyIsoCode, Fabricantes__c,
                Responsable_de_LDP__r.EmployeeNumber, Jefe_de_Proyecto_de_Preventa__r.Codigo_de_empleado__c,Margen_bruto__c,
                Jefe_de_Proyecto_de_Ejecucion__r.Codigo_de_empleado__c, Oportunidad__r.Account.Name,Oportunidad__r.Account.ID_SAP__c,Oportunidad__r.GPM__r.Codigo_de_empleado__c,
                Jefe_Proyecto_Ejecucion_Adicional__r.Codigo_de_empleado__c, PEP_Interco__r.Name,Tecnologia__c,Oportunidad__r.StageName,
              	Oportunidad__r.Owner.EmployeeNumber,Oportunidad__r.Bid_Manager__r.employeenumber,NEW_Nombre_SAP__c,Execution_SAP_Name__c,
                LOB__c, Oportunidad__r.Proyecto_Padre__c, Oportunidad__r.Mercado__c,EsIntercompany__c,Oportunidad__r.CreatedDate,Codigo_SAP_Ejecucion__c,Codigo_SAP_Preventa__c
             FROM Lineas_de_proyecto__r where   Agrupacion_Tipo_Registro__c!='Licencias')
        FROM Opportunity 
        WHERE Id IN :opportunityIds   ];
    }

    public static Map<Id, List<Hito_de_facturacion__c>> getHitosPorLinea(Set<Id> opportunityIds) {
        Map<Id, List<Hito_de_facturacion__c>> hitosPorLinea = new Map<Id, List<Hito_de_facturacion__c>>();
        
        for (Hito_de_facturacion__c hito : [
            SELECT 
                Fecha__c, Name, Id, Descripcion__c, oportunidad__r.Codigo_de_oportunidad__c,
                Importe__c, Porcentaje__c, Linea_de_Proyecto__c ,OppCode__c
            FROM Hito_de_facturacion__c 
            WHERE Linea_de_Proyecto__r.Oportunidad__c IN :opportunityIds
        ]) {
            if (!hitosPorLinea.containsKey(hito.Linea_de_Proyecto__c)) {
                hitosPorLinea.put(hito.Linea_de_Proyecto__c, new List<Hito_de_facturacion__c>());
            }
            hitosPorLinea.get(hito.Linea_de_Proyecto__c).add(hito);
        }
        
        return hitosPorLinea;
    }
}