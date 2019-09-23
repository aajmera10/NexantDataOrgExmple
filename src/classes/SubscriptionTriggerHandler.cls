public with sharing class SubscriptionTriggerHandler {

	public static void afterUpdateHandler(
		List<Trade_Ally_Subscription__c> triggerNewList,
		Map<Id, Trade_Ally_Subscription__c>   triggerOldMap
	) {
		Map<Id, String> subscriptionsToAddMap = new Map<Id, String>();
		Map<Id, String> subscriptionsToRemoveMap = new Map<Id, String>();
		for (Trade_Ally_Subscription__c subscription : triggerNewList) {
			if (subscription.Stripe_Product_Name__c != triggerOldMap.get(subscription.Id).Stripe_Product_Name__c) {
				if (subscription.Stripe_Product_Name__c != null) {
					subscriptionsToAddMap.put(subscription.Account__c, subscription.Stripe_Product_Name__c);
				}
				if (triggerOldMap.get(subscription.Id).Stripe_Product_Name__c != null) {
					subscriptionsToRemoveMap.put(triggerOldMap.get(subscription.Id).Account__c, triggerOldMap.get(subscription.Id).Stripe_Product_Name__c);
				}

			}
		}
		deleteCreateAssignmentsFuture(subscriptionsToAddMap, subscriptionsToRemoveMap);
	}

	public static void afterDeleteHandler(Map<Id, Trade_Ally_Subscription__c>   triggerOldMap) {
		Map<Id, String> subscriptionsToRemoveMap = new Map<Id, String>();
		for (Trade_Ally_Subscription__c subscription : triggerOldMap.values()) {
			if (subscription.Stripe_Product_Name__c != null) {
				subscriptionsToRemoveMap.put(subscription.Account__c, subscription.Stripe_Product_Name__c);
			}
		}
		if(subscriptionsToRemoveMap.size() > 0){
			deleteAssignmentsFuture(subscriptionsToRemoveMap);
		}
	}

	public static void afterInsertHandler(List<Trade_Ally_Subscription__c> triggerNewList) {
		Map<Id, String> subscriptionsToAddMap = new Map<Id, String>();
		for (Trade_Ally_Subscription__c subscription : triggerNewList) {
			if (
				subscription.Subscription_Status__c == 'Active' &&
				subscription.Stripe_Product_Name__c != null
			) {
				subscriptionsToAddMap.put(subscription.Account__c, subscription.Stripe_Product_Name__c);
			}
		}
		if (subscriptionsToAddMap.size() > 0) {
			createAssignmentsFuture(subscriptionsToAddMap);
		}
	}

	@Future
	private static void createAssignmentsFuture(Map<Id, String> subscriptionsToAddMap){
		System.debug('subscriptionsToAddMap first ' + subscriptionsToAddMap);

		createAssignments(subscriptionsToAddMap);
	}

	@Future
	private static void deleteAssignmentsFuture(Map<Id, String> subscriptionsToRemoveMap){
		deleteAssignments(subscriptionsToRemoveMap);
	}

	@Future
	private static void deleteCreateAssignmentsFuture(Map<Id, String> subscriptionsToAddMap, Map<Id, String> subscriptionsToRemoveMap){
		System.debug(subscriptionsToAddMap);
		System.debug(subscriptionsToRemoveMap);
		if(subscriptionsToRemoveMap.size() > 0){
			deleteAssignments(subscriptionsToRemoveMap);
		}
		if(subscriptionsToAddMap.size() > 0){
			createAssignments(subscriptionsToAddMap);
		}
	}

	public static Id subscribedProfileId {
		get {
			if (subscribedProfileId == null) {
				Application_Settings__c setting = Application_Settings__c.getValues(Constants.SUBSCRIBED_PROFILE_NAME);
				System.debug('setting:---- '+setting);
				if (setting != null && setting.Value__c != null) {
					System.debug(setting.Value__c);
					//List<Profile> profiles = new List<Profile>();
					//if (ESAPI.securityUtils().isAuthorizedToView('Profile',new List<String>{'Id'})) {
					List<Profile> profiles = [
						SELECT	Id
						FROM	Profile
						WHERE	Name =: setting.Value__c
					];
					System.debug(profiles);
					//}
					if (!profiles.isEmpty()) {
						subscribedProfileId = profiles[0].Id;
					}
				}
			}
			return subscribedProfileId;
		}
		set;
	}

	private static void createAssignments(Map<Id, String> subscriptionsToAddMap){
		System.debug('subscriptionsToAddMap ' + subscriptionsToAddMap);
		List<PermissionSetAssignment> permissionSetAssignmentToAddList = new List<PermissionSetAssignment>();
		List<User> listOfUsersToUpdate = new List<User>();
		Set<Id> accountsIdSet = subscriptionsToAddMap.keySet();
		/*List<User> users = new List<User>();
		if (
			ESAPI.securityUtils().isAuthorizedToView('User',new List<String>{'Id'}) &&
			ESAPI.securityUtils().isAuthorizedToView('Account',new List<String>{'Id'})
		) {*/
		List<User> users = [
			SELECT
					Id,
					Contact.AccountId,
					ProfileId,
					Permission_Set_to_Assign__c
			FROM    User
			WHERE   
					Contact.AccountId IN: accountsIdSet AND
					IsActive = TRUE
		];
		//}
		Set<String> permissionSetNameSet = new Set<String>();
		for (String productName : subscriptionsToAddMap.values()) {
			String permissionSetName =productName.replaceAll(' ', '_');
			permissionSetNameSet.add(permissionSetName);
		}
        System.debug('permissionSetNameSet : '+permissionSetNameSet);
		List<PermissionSet> permissionSetList = new List<PermissionSet>();
		permissionSetList = [
			SELECT
					Id,
					Name
			FROM    PermissionSet
			WHERE   Name IN:permissionSetNameSet
		];
		if (permissionSetList == null) {
			return;
		}
		Map<String,Id> permissionSetIdMap = new Map<String,Id>();
		for (Integer i = 0, j = permissionSetList.size(); i < j; i++) {
			permissionSetIdMap.put(permissionSetList[i].Name, permissionSetList[i].Id);
		}
        System.debug('permissionSetIdMap: '+permissionSetIdMap);
		PermissionSetAssignment newAssignment;
		Set<Id> permissionSetIdSet = new Set<Id>();
		System.debug('users '+users);
		System.debug('subscribedProfileId '+subscribedProfileId);
		if (subscribedProfileId != null) {
			for (User u : users) {
				/*if (subscribedProfileId != null && u.ProfileId != subscribedProfileId) {
					u.ProfileId = subscribedProfileId;
					listOfUsersToUpdate.add(u);
				}*/
				Id permissionSetId = permissionSetIdMap.get(subscriptionsToAddMap.get(u.Contact.AccountId).replaceAll(' ', '_'));
				if (u.ProfileId != subscribedProfileId) {
                    if (Schema.sObjectType.User.fields.Permission_Set_to_Assign__c.isCreateable() &&  Schema.sObjectType.User.fields.Permission_Set_to_Assign__c.isUpdateable()) {
						u.Permission_Set_to_Assign__c = permissionSetId;
                        listOfUsersToUpdate.add(u);
                    }
				} else {
                    System.debug('u.ProfileId is == subscribedProfileId');
					if (permissionSetIdSet.contains(permissionSetId) || permissionSetId == null) {
						continue;
					} else {
						permissionSetIdSet.add(permissionSetId);
					}
					newAssignment = new PermissionSetAssignment();
					newAssignment.AssigneeId = u.Id;
					newAssignment.PermissionSetId = permissionSetId;
					permissionSetAssignmentToAddList.add(newAssignment);
				}
			}
            System.debug('listOfUsersToUpdate: '+listOfUsersToUpdate);
			if (!listOfUsersToUpdate.isEmpty()) {
				//ESAPI.securityUtils().validatedUpdate(listOfUsersToUpdate);
				if(Schema.sObjectType.User.isUpdateable()) 
                {
                    update listOfUsersToUpdate;
                    System.debug('Updated SubscriptionTriggerHandler----- >>>> !!!!');
                }
			}
			// ESAPI.securityUtils().validatedInsert(permissionSetAssignmentToAddList);
			System.debug('permissionSetAssignmentToAddList ' + permissionSetAssignmentToAddList);
			upsert permissionSetAssignmentToAddList;//(new List<PermissionSetAssignment>(permissionSetAssignmentToAddList));
		}
	}

	private static void deleteAssignments(Map<Id, String> subscriptionsToRemoveMap) {
		System.debug('subscriptionsToRemoveMap ' + subscriptionsToRemoveMap);
		Set<String> permissionSetNameSet = new Set<String>();
		for (String productName :subscriptionsToRemoveMap.values()) {
			String permissionSetName =productName.replaceAll(' ', '_');
			permissionSetNameSet.add(permissionSetName);
		}
		List<PermissionSetAssignment> permissionSetAssignmentList;
//		if (ESAPI.securityUtils().isAuthorizedToView('PermissionSetAssignment', new List<String>{'Id'})) {
		permissionSetAssignmentList = [
			SELECT
					Id
			FROM    PermissionSetAssignment
			WHERE   
					Assignee.Contact.AccountId IN: subscriptionsToRemoveMap.keySet() AND
					PermissionSetId IN (
						SELECT
								Id
						FROM    PermissionSet
						WHERE   
								IsOwnedByProfile = FALSE AND
								Name IN: permissionSetNameSet
					)
		];
//		if(permissionSetAssignmentList != null) {
//			ESAPI.securityUtils().validatedDelete(permissionSetAssignmentList);
			System.debug('delete permissionSetAssignmentList ' + permissionSetAssignmentList);
			delete permissionSetAssignmentList;
//		}
	}

}