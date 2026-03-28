trigger tieneadjunto on ContentDocumentLink (after insert) {
    Set<Id> opportunityIds = new Set<Id>();

    // Recoger las oportunidades asociadas a los archivos recién subidos
    if (Trigger.isInsert) {
        for (ContentDocumentLink cdl : Trigger.new) {
            // Verificar si el archivo está vinculado a una Oportunidad
            if (cdl.LinkedEntityId != null && cdl.LinkedEntityId.getSObjectType() == Opportunity.SObjectType) {
                opportunityIds.add(cdl.LinkedEntityId);
            }
        }
    } 
    // Si hay oportunidades que actualizar
    if (!opportunityIds.isEmpty()) {
        // Realizar una consulta SOQL para contar los archivos asociados a las oportunidades
        Map<Id, Integer> attachmentCountMap = new Map<Id, Integer>();

        // Consulta SOQL para contar el número de archivos asociados a cada oportunidad
        for (AggregateResult ar : [
            SELECT LinkedEntityId, COUNT(Id) total
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :opportunityIds
            GROUP BY LinkedEntityId
        ]) {
            attachmentCountMap.put((Id)ar.get('LinkedEntityId'), (Integer)ar.get('total'));
        }

        // Crear una lista para almacenar las oportunidades que se actualizarán
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        // Iterar sobre los Ids de las oportunidades y actualizar el campo tieneattachment__c
        for (Id oppId : opportunityIds) {
            Opportunity opp = new Opportunity(Id = oppId);
            Integer attachmentCount = attachmentCountMap.get(oppId);

            // Establecer 'tieneattachment__c' a true si hay archivos, false si no
            opp.tieneattachment__c = (attachmentCount != null && attachmentCount > 0);

            opportunitiesToUpdate.add(opp);
        }

        // Actualizar las oportunidades si hay algo que actualizar
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}