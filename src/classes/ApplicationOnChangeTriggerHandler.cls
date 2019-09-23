public with sharing class ApplicationOnChangeTriggerHandler {

	public static void reviewApplicationStatus(List<Application__c> listOfNewApps) {
		Map<Id,Boolean> mapOfInfoByAccountId = new Map<Id,Boolean>();
		for (Application__c newApp : listOfNewApps) {
			if (newApp.Trade_Ally__c != null) {
				mapOfInfoByAccountId.put(
					newApp.Trade_Ally__c,
					(newApp.Application_Status__c == 'Active')
				);
			}
		}
		System.debug('mapOfInfoByAccountId '+mapOfInfoByAccountId);
		List<User> listOfCommunityUsers = new List<User>();
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				'User',
				new List<String>{
					'Id',
					'ContactId',
					Constants.NAMESPACE + 'Approved_Application__c'
				}
			) &&
			ESAPI.securityUtils().isAuthorizedToView(
				'Contact',
				new List<String>{
					'AccountId'
				}
			)
		) {
			listOfCommunityUsers = [
				SELECT
						Id,
						Contact.AccountId,
						Approved_Application__c
				FROM	User
				WHERE	Contact.AccountId IN: mapOfInfoByAccountId.keySet()
			];
		}
		List<User> listOfCommunityUsersToUpdate = new List<User>();
		for (User u : listOfCommunityUsers) {
			if (u.Approved_Application__c != mapOfInfoByAccountId.get(u.Contact.AccountId)) {
				u.Approved_Application__c = mapOfInfoByAccountId.get(u.Contact.AccountId);
				listOfCommunityUsersToUpdate.add(u);
			}
		}
		ESAPI.securityUtils().validatedUpdate(listOfCommunityUsersToUpdate);
	}
}