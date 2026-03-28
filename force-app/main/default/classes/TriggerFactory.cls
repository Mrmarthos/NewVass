global class TriggerFactory 
{
	
	private class TriggerHandlerException extends Exception {}

	/** 
	* Public static method to create and execute a trigger handler
	*/
	global static void createHandler(Schema.sObjectType soType)
	{
		ITrigger handler = getHandler(soType);
		
		if (handler == null)	throw new TriggerHandlerException('No Trigger Handler registered for Object Type: ' + soType);
		
		execute(handler);
	}

	/** 
	*  Method to control the execution of the handler
	*/
	private static void execute(ITrigger handler)
	{
		if(Trigger.isBefore)
		{
			handler.bulkBefore(trigger.new, trigger.oldMap);
			
			if		(Trigger.isInsert)		handler.beforeInsert(trigger.new);
			else if	(Trigger.isUpdate)		handler.beforeUpdate(trigger.new, trigger.oldMap);
			else if	(Trigger.isDelete)		handler.beforeDelete(trigger.oldMap);
		}
		else
		{
			handler.bulkAfter(trigger.new, trigger.oldMap);
			
			if 		(Trigger.isInsert)		handler.afterInsert(trigger.new);
			else if (Trigger.isUpdate)		handler.afterUpdate(trigger.new, trigger.oldMap);
			else if (Trigger.isDelete)		handler.afterDelete(trigger.oldMap);
		}

		handler.andFinally();
	}

	/** 
	*  Method to get the appropriate handler for the object type. Modify this method to add any additional handlers.
	*/ 
	private static ITrigger getHandler(Schema.sObjectType soType)
	{
		 if 		(soType == Account.sObjectType)					return new AccountHandler();		 
		 else if	(soType == Opportunity.sObjectType)			    return new OpportunityHandler();
         else if    (soType == Campaign.sObjectType)                return new CampaignHandler();
		 else if    (soType == Linea_de_Proyecto__c.sObjectType)    return new ProjectLineHandler();
		 else if    (soType == OpportunityTeamMember.sObjectType)   return new OpportunityTeamMemberHandler();
		 else if    (soType == Comerciales_Multibooking__c.sObjectType)   return new RelacionComercialHandler();
		 else														return null;
	}
}