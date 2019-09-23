public class TradeAllyTriggerHandler {

	// Returns the counter in Registration Code format String (REG-{000000})
	private static String registrationCodeFormatting(Integer registrationCodeCounter) {
		String formattedRegistrationCode = String.valueOf(registrationCodeCounter);
		if (formattedRegistrationCode.length() < Constants.LENGTH_OF_REGISTRATION_CODE) {
			Integer lengthDifference = Constants.LENGTH_OF_REGISTRATION_CODE - formattedRegistrationCode.length();
			String zerosString = '';
			for (Integer i = 0; i < lengthDifference; i++) {
				zerosString += '0';
			}
			formattedRegistrationCode = zerosString + formattedRegistrationCode;
		}
		return Constants.REGISTRATION_CODE_PREFIX + formattedRegistrationCode;
	}

	// Generate values for Autonumber fields such as Registration Code and External Id
	public static void generateAutonumbers(List<Account> tradeAlliesList) {
		Integer externalIdCounter = Constants.EXTERNAL_ID_STARTING_NUMBER;
		Integer registrationCodeCounter = Constants.REGISTRATION_CODE_STARTING_NUMBER;
		// Query for existing Trade Allies (accounts), ordering by external id, which in fact is autonumber
		// In fact, the latest external id will have the latest Registration Code
		List<Account> existingTradeAlliesList = new List<Account>();
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				'Account',
				new List<String>{
					'Id',
					Constants.NAMESPACE + 'Registration_Code__c',
					Constants.NAMESPACE + 'External_Id__c'
				}
			)
		) {
			existingTradeAlliesList = [
				SELECT 		
							Id,
							Registration_Code__c,
							External_Id__c
				FROM 		Account
				WHERE 		
							External_Id__c != NULL OR
							Registration_Code__c != NULL// AND
							//RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
				ORDER BY 	External_Id__c DESC
				LIMIT 		50000//1
			];
		}
		Set<String> setOfExternalIds = new Set<String>();
		Set<String> setOfRegistrationCodes = new Set<String>();
		if (!existingTradeAlliesList.isEmpty()) {
			// Remove all non-numeric symbols from the string to convert in to Integer successfully
			Boolean defaultPopulated = false;
			for (Account a : existingTradeAlliesList) {
				if (a.External_Id__c != null)
					setOfExternalIds.add(a.External_Id__c);
				if (a.Registration_Code__c != null)
					setOfRegistrationCodes.add(a.Registration_Code__c);
				if (
					!defaultPopulated &&
					a.External_Id__c != null && 
					a.Registration_Code__c != null
				) {
					String cleanedExternalId = a.External_Id__c.replaceAll('[^0-9]', '');
					String cleanedRegistrationCode = a.Registration_Code__c.replaceAll('[^0-9]', '');
					externalIdCounter = Integer.valueOf(cleanedExternalId);
					registrationCodeCounter = Integer.valueOf(cleanedRegistrationCode);
					defaultPopulated = true;
				}
			}
		}
		// Set the increased counters to necessary fields that should work as autonumber
		String tempExternalId;
		String tempRegistrationCode;
		Boolean newValuesGenerated;
		for (Account tradeAlly : tradeAlliesList) {
			// Check if Account has Trade Ally record type
			if (tradeAlly.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()) {
				newValuesGenerated = false;
				while (!newValuesGenerated) {
					externalIdCounter++;
					registrationCodeCounter++;
					tempExternalId = String.valueOf(externalIdCounter);
					tempRegistrationCode = TradeAllyTriggerHandler.registrationCodeFormatting(registrationCodeCounter);
					if (!setOfExternalIds.contains(tempExternalId) && !setOfRegistrationCodes.contains(tempRegistrationCode)) {
						tradeAlly.External_Id__c = tempExternalId;
						tradeAlly.Registration_Code__c = tempRegistrationCode;
						setOfExternalIds.add(tempExternalId);
						setOfRegistrationCodes.add(tempRegistrationCode);
						newValuesGenerated = true;
					}
				}
			}
		}
		//System.debug('tradeAlliesList '+tradeAlliesList);
	}

	// Generate sharing settings for trade allies
	public static void generateSharingSettings(List<Account> tradeAlliesList) {
		Set<Id> tradeAlliesIds = new Set<Id>();
		Set<Id> tradeAlliesParentIds = new Set<Id>();
		for (Account tradeAlly : tradeAlliesList) {
			// Check if Account has Trade Ally record type
			if (tradeAlly.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()) {
				tradeAlliesIds.add(tradeAlly.Id);
				if (String.isNotBlank(tradeAlly.ParentId)) {
					tradeAlliesParentIds.add(tradeAlly.ParentId);
				}
			}
		}
		Set<Id> availableTradeAlliesIds = TradeAllySharingUtility.getAvailableTradeAlliesIds(tradeAlliesIds, tradeAlliesParentIds);
		Set<Id> tradeAllySharingUsersIds = TradeAllyTriggerHandler.getTradeAllySharingUsersIds(availableTradeAlliesIds);
		TradeAllySharingUtility.shareTradeAlliesRecords(
			availableTradeAlliesIds,
			tradeAllySharingUsersIds,
			Constants.TRADE_ALLY_SHARING_ACCESS_LEVEL,
			Constants.RELATED_OPPORTUNITY_SHARING_ACCESS_LEVEL
		);
	}

	//Count the number of active users for Trade Ally specified by id
	private static Set<Id> getTradeAllySharingUsersIds(Set<Id> tradeAlliesIdsSet) {
		List<User> listOfUsers = new List<User>();
		if (ESAPI.securityUtils().isAuthorizedToView('User',new List<String>{'Username'})) {
			listOfUsers = [
				SELECT 	Username
				FROM 	User
				WHERE 	
						(
							Contact.AccountId IN :tradeAlliesIdsSet OR
							UserType = 'Guest'
						) AND
						IsActive = TRUE
				LIMIT 	50000
			];
		}
		return new Map<Id, User> (listOfUsers).keySet();
	}

	public static void tier1ChatterGroupHandler(Set<Id> tradeAlliesSet) {//List<Account> tradeAlliesList
		//Map<Id, Account> tradeAlliesMap = new Map<Id, Account>(tradeAlliesList);
		//Set<Id> tradeAlliesSet = tradeAlliesMap.keySet();
		List<CollaborationGroup> tier1GroupList = new List<CollaborationGroup>();
		if (ESAPI.securityUtils().isAuthorizedToView('CollaborationGroup',new List<String>{'Name'})) {
			tier1GroupList = [
					SELECT 	Name
					FROM 	CollaborationGroup
					WHERE 	Name =: Constants.TIER_ONE_CHATTER_GROUP_NAME
			];
		}
		if (tier1GroupList.size() == 0) return;
		Map<Id, CollaborationGroup> tier1GroupMap = new Map<Id, CollaborationGroup>(tier1GroupList);
		Set<Id> tier1GroupIdSet = tier1GroupMap.keySet();
		List<CollaborationGroupMember> addedGroupMembersList = new List<CollaborationGroupMember>();
		List<User> tradeAllyUsersList = new List<User>();
		if (
				ESAPI.securityUtils().isAuthorizedToView('User',new List<String>{'Id','Name'}) &&
						ESAPI.securityUtils().isAuthorizedToView('CollaborationGroupMember',new List<String>{'MemberId'})
				) {
			tradeAllyUsersList = [
					SELECT
							Id,
							Name
					FROM 	User
					WHERE
					Contact.AccountId IN: tradeAlliesSet AND
					Contact.Account.Tier_Level__c = 'Tier 1' AND
					IsActive = TRUE AND
					Id NOT IN (
							SELECT	MemberId
							FROM	CollaborationGroupMember
							WHERE	CollaborationGroupId IN: tier1GroupIdSet
					)
			];
		}
		for (Integer n = 0, k = tradeAllyUsersList.size(); n < k; n++) {
			//User groupUser = tradeAllyUsersList[n];
			CollaborationGroupMember newMember = new CollaborationGroupMember();
			newMember.MemberId = tradeAllyUsersList[n].Id;//groupUser.Id;
			newMember.CollaborationGroupId = tier1GroupList[0].Id;
			addedGroupMembersList.add(newMember);
		}
		List<CollaborationGroupMember> removedGroupMembersList = new List<CollaborationGroupMember>();
		if (ESAPI.securityUtils().isAuthorizedToView('CollaborationGroupMember',new List<String>{'MemberId','CollaborationGroupId'})) {
			removedGroupMembersList = [
					SELECT
							MemberId,
							CollaborationGroupId
					FROM 	CollaborationGroupMember
					WHERE
					Member.Contact.AccountId IN: tradeAlliesSet AND
					Member.Contact.Account.Tier_Level__c != 'Tier 1' AND
					CollaborationGroupId IN: tier1GroupIdSet
					LIMIT 	50000
			];
		}
		ESAPI.securityUtils().validatedInsert(addedGroupMembersList);
		ESAPI.securityUtils().validatedDelete(removedGroupMembersList);
	}

//	public static void insertSubscription(List<Account> accountsList) {
//		System.debug('handler is run');
//		List<Account> tradeAlliesList = new List<Account>();
//		for (Integer i = 0, j = accountsList.size(); i < j; i++) {
//			System.debug('for iteration ' + i);
//			if (ESAPI.securityUtils().isAuthorizedToView('Account',new List<String>{'Id'})) {
//				System.debug('isAuthorizedToView');
//				if (accountsList[i].RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()) {
//					System.debug('if is true');
//					tradeAlliesList.add(accountsList[i]);
//				}
//			}
//		}
//		if(tradeAlliesList.size() == 0){
//			return;
//		}
//		List<Trade_Ally_Subscription__c> subscriptionsLit = new List<Trade_Ally_Subscription__c>();
//		System.debug('tradeAlliesList.size ' + tradeAlliesList.size());
//		for (Integer i = 0, j = tradeAlliesList.size(); i < j; i++) {
//			Trade_Ally_Subscription__c newSubscription = new Trade_Ally_Subscription__c();
//			newSubscription.Account__c = tradeAlliesList[i].Id;
//			subscriptionsLit.add(newSubscription);
//		}
//		ESAPI.securityUtils().validatedInsert(subscriptionsLit);
//
//	}

}