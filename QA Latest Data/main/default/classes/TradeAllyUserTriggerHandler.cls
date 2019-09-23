public class TradeAllyUserTriggerHandler {

	// Generate sharing settings for new user
	public static void generateSharingSettings(List<User> tradeAlliesUsersList) {
		Set<Id> tradeAlliesUsersIdsSet = new Set<Id>();
		Set<Id> tradeAlliesContactsIdsSet = new Set<Id>();
		for (User tradeAllyUser : tradeAlliesUsersList) {
			// Check if user is active, Account_Share can not work with inactive users
			if (tradeAllyUser.IsActive) {
				tradeAlliesUsersIdsSet.add(tradeAllyUser.Id);
			}
			if (String.isNotBlank(tradeAllyUser.ContactId)) {
				tradeAlliesContactsIdsSet.add(tradeAllyUser.ContactId);
			}
		}
		Map<String, Set<Id>> relatedTradeAlliesInfo = TradeAllyUserTriggerHandler.getRelatedTradeAlliesInfo(tradeAlliesContactsIdsSet);
		Set<Id> availableTradeAlliesIds = TradeAllySharingUtility.getAvailableTradeAlliesIds(
			relatedTradeAlliesInfo.get(Constants.RELATED_TRADE_ALLIES_IDS_KEY), 
			relatedTradeAlliesInfo.get(Constants.RELATED_TRADE_ALLIES_PARENT_IDS_KEY)
		);
		TradeAllySharingUtility.shareTradeAlliesRecords(
			availableTradeAlliesIds, 
			tradeAlliesUsersIdsSet, 
			Constants.TRADE_ALLY_SHARING_ACCESS_LEVEL,
			Constants.RELATED_OPPORTUNITY_SHARING_ACCESS_LEVEL
		);
	}

	// Get ids and parent ids of related trade allies
	private static Map<String, Set<Id>> getRelatedTradeAlliesInfo(Set<Id> tradeAlliesContactsIdsSet) {
		Set<Id> relatedTradeAlliesIdsSet = new Set<Id>();
		Set<Id> relatedTradeAlliesParentIdsSet = new Set<Id>();
		Map<String, Set<Id>> result = new Map<String, Set<Id>>();
		List<Contact> relatedTradeAlliesContactsList = new List<Contact>();
		if (ESAPI.securityUtils().isAuthorizedToView('Contact',new List<String>{'AccountId'})) {
			relatedTradeAlliesContactsList = [
				SELECT 	
						AccountId,
						Account.ParentId
				FROM 	Contact
				WHERE 	
						Id IN: tradeAlliesContactsIdsSet AND
						AccountId != NULL AND
						Account.RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
				LIMIT 	50000
			];
		}
		for (Contact relatedTradeAlliesContact : relatedTradeAlliesContactsList) {
			relatedTradeAlliesIdsSet.add(relatedTradeAlliesContact.AccountId);
			if (String.isNotBlank(relatedTradeAlliesContact.Account.ParentId)) {
				relatedTradeAlliesParentIdsSet.add(relatedTradeAlliesContact.Account.ParentId);
			}
		}
		result.put(Constants.RELATED_TRADE_ALLIES_IDS_KEY, relatedTradeAlliesIdsSet);
		result.put(Constants.RELATED_TRADE_ALLIES_PARENT_IDS_KEY, relatedTradeAlliesParentIdsSet);
		return result;
	}

}