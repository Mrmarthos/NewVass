trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
	TriggerFactory.createHandler(OpportunityTeamMember.sObjectType);
}