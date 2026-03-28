trigger CampaignTrigger on Campaign (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TriggerFactory.createHandler(Campaign.sObjectType);
}