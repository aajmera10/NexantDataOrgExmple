global with sharing class SubscriptionPopUpController{
	@AuraEnabled
	public static String activateStandardSubscription(String applicationId) {
		String serverStatus = 'Your subscription level is Basic';
		Account account;
		if (
			ESAPI.securityUtils().isAuthorizedToView('Account', new List<String>{'Id'}) &&
			ESAPI.securityUtils().isAuthorizedToView(
				'Trade_Ally_Subscription__c',
				new List<String>{'Id', 'Subscription_Status__c', 'Subscription_Level__c'}
			)	
		) {
			account = [
					SELECT
							Id, 
							(
								SELECT
										Id,
										Subscription_Status__c,
										Subscription_Level__r.Name
								FROM	Trade_Ally_Subscriptions__r
							)
					FROM	Account
					WHERE	Id IN (
									SELECT	Trade_Ally__c
									FROM	Application__c
									WHERE	Id = :applicationId
							)
					LIMIT 1
			];
		}
		Trade_Ally_Subscription__c currentSubscription;
		if (account.Trade_Ally_Subscriptions__r.size() > 0) {
			currentSubscription = account.Trade_Ally_Subscriptions__r[0];
			currentSubscription.Subscription_Status__c = 'Active';
			serverStatus = 'Subscription is activated';
		}
		else {
			currentSubscription = new Trade_Ally_Subscription__c();
			currentSubscription.Account__c = account.Id;
			currentSubscription.Subscription_Status__c = 'Active';
			serverStatus = 'New active Subscription record is created';
		}
		try {
			ESAPI.securityUtils().validatedUpsert(new List<Trade_Ally_Subscription__c>{currentSubscription});
		}
		catch (Exception e) {
			serverStatus = 'The following exception has occurred: ' + e.getMessage();
		}
		return serverStatus;
	}
}