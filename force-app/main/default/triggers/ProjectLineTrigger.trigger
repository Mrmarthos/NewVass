trigger ProjectLineTrigger on Linea_de_Proyecto__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TriggerFactory.createHandler(Linea_de_Proyecto__c.sObjectType);
}