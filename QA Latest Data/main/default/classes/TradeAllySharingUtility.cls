public class TradeAllySharingUtility {

	// This method returns the set of Ids of Trade Allies records that should be shared
	public static Set<Id> getAvailableTradeAlliesIds(Set<Id> tradeAlliesIds, Set<Id> tradeAlliesParentIds) {
		List<Account> availableTradeAllies = new List<Account>();
		if (ESAPI.securityUtils().isAuthorizedToView('Account',new List<String>{'Id','Name'})) {
			availableTradeAllies = [
				SELECT  Name
        		FROM	Account
				WHERE
            			(
							// Query for records with the same parent
            				(
								ParentId IN: tradeAlliesParentIds AND 
								ParentId != NULL
							) OR
            				// Query for children
            				ParentId IN: tradeAlliesIds
						) AND
						RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
				LIMIT 	50000
			];
		}
		Map<Id, Account> availableTradeAlliesMap = new Map<Id, Account>(availableTradeAllies);
		// Add current trade allies ids and its parents ids to the set to create sharing rules for them too
		Set<Id> availableTradeAlliesIds = availableTradeAlliesMap.keySet().clone();
		availableTradeAlliesIds.addAll(tradeAlliesIds);
		availableTradeAlliesIds.addAll(tradeAlliesParentIds);
        return availableTradeAlliesIds;
	}

	// This method creates the AccountShare records to create custom sharing settings for trade ally
	// Parameters:
	// - tradeAlliesIds - ids of the Trade Ally records that should be shared
	// - userOrGroupdsIds  - ids of the User of User Groups that should be affected by custom sharing
	// - tradeAllyAccessLevel - the access level for the shared trade ally records. Possible values: Read, Edit, All
	// - opportunityAccessLevel - the access level for the opportunity that is related to the Trade Ally. Possible values: Read, Edit, All
	public static void shareTradeAlliesRecords(Set<Id> tradeAlliesIds, Set<Id> usersOrGroupsIds, String tradeAllyAccessLevel, String relatedOpportunityAccessLevel) {
		List<AccountShare> tradeAllyShareList = new List<AccountShare>();
		// Create Apex Sharing for account
		for (Id tradeAllyId : tradeAlliesIds) {
			for (Id userOrGroupId : usersOrGroupsIds) {
                if (Schema.sObjectType.AccountShare.fields.AccountId.isCreateable() && 
                   Schema.sObjectType.AccountShare.fields.UserOrGroupId.isCreateable() &&
                   Schema.sObjectType.AccountShare.fields.RowCause.isCreateable() &&
                   Schema.sObjectType.AccountShare.fields.AccountAccessLevel.isCreateable() &&
                   Schema.sObjectType.AccountShare.fields.OpportunityAccessLevel.isCreateable()) { 
                        tradeAllyShareList.add(
                            new AccountShare(
                                // Set the ID of record being shared
                                AccountId = tradeAllyId,
                                // Set the ID of user or group being granted access
                                UserOrGroupId = userOrGroupId,
                                // This line can be omitted as 'manual' is the default value for sharing objects
                                RowCause = Schema.AccountShare.RowCause.Manual,
                                // The Access level for the Trade Ally record
                                AccountAccessLevel = tradeAllyAccessLevel,
                                // The Access level for the related opportunity record
                                OpportunityAccessLevel = relatedOpportunityAccessLevel
                            )
                        );
               }
			}
		}
		// Seems that ESAPI does not work with Account_Share object
		try {
			if(Schema.sObjectType.AccountShare.isCreateable())
            {
                insert tradeAllyShareList;
                System.debug('Inserted ----- >>>> !!!!');
            }
		} catch (Exception e) {
			System.debug(e.getMessage());
		}
	}

	// This method creates the AccounntShare records async.
	// Parameters:
	// - tradeAlliesIds - ids of the Trade Ally records that should be shared
	// - userOrGroupdsIds  - ids of the User of User Groups that should be affected by custom sharing
	// - tradeAllyAccessLevel - the access level for the shared trade ally records. Possible values: Read, Edit, All
	// - opportunityAccessLevel - the access level for the opportunity that is related to the Trade Ally. Possible values: Read, Edit, All
	@Future
	public static void shareTradeAlliesRecordsAsync(Set<Id> tradeAlliesIds, Set<Id> usersOrGroupsIds, String tradeAllyAccessLevel, String relatedOpportunityAccessLevel) {
		TradeAllySharingUtility.shareTradeAlliesRecords(tradeAlliesIds, usersOrGroupsIds, tradeAllyAccessLevel, relatedOpportunityAccessLevel);
	}

}