public with sharing class OpportunityTeamMemberUtil 
{

	public static Set<Id> getOpportunityIDs(List<SObject> members)
	{
		Set<Id> oppIds = new Set<Id>();
		for (OpportunityTeamMember member : (List<OpportunityTeamMember>) members)
		{
			oppIds.add(member.OpportunityId);
		}
		return oppIds;
	}

	/**
	 * Dado una lista de identificadores de oportunidad, devuelve las cuentas asociadas con su Id y OwnerId
	 **
	 * @author: amartinez (2018/11/16)
	 */
	public static Map<Id, Account> getAccounts(Set<Id> opportunityIds)
	{
		Map<Id, Account> oppIdToAccount = new Map<Id, Account>();

		Map<Id, List<Id>> accountIds = new Map<Id, List<Id>>();
		for (Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN :opportunityIds])
		{
			if (opp.AccountId != null)
			{
				if (!accountIds.containsKey(opp.AccountId)) 
				{
					accountIds.put(opp.AccountId, new List<Id>());
				}
				accountIds.get(opp.AccountId).add(opp.Id);
			}
		}

		if (!accountIds.isEmpty())
		{
			for (Account acc : [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds.keySet()])
			{
				for (Id oppId : accountIds.get(acc.Id))
				{
					oppIdToAccount.put(oppId, acc);
				}
			}
		}

		return oppIdToAccount;
	}

	public static List<AccountShare> createAccountShares(Map<Id, Account> oppIdToAcc, List<OpportunityTeamMember> memberList) 
	{
		List<AccountShare> accountShares = new List<AccountShare>();

    	for (OpportunityTeamMember member : memberList)
    	{
			if (member.User.IsActive)
			{   
				if (oppIdToAcc.get(member.OpportunityId) != null && oppIdToAcc.get(member.OpportunityId).OwnerId != member.UserId)
				{
					accountShares.add(new AccountShare(
						AccountId = oppIdToAcc.get(member.OpportunityId).Id,
						UserOrGroupId = member.UserId,
						AccountAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_ACC_WHEN_SHARING_OPPTY,
						OpportunityAccessLevel = Constants.DEFAULT_ACCESS_LEVEL_OPPS_WHEN_SHARING_OPPTY			
					));
				}
			}
    	}

    	return accountShares;
	}

}