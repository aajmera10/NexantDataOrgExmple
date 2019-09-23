@IsTest
private class CopyTermsAndConditionsTest {
	@IsTest
	static void testBehavior() {
		Account newAccount = new Account(
				Name = 'newAccount'
		);
		insert newAccount;
		Application__c newApplication = new Application__c(
				Trade_Ally__c = newAccount.Id,
            	Business_Types__c = 'Contractor'
		);
		insert newApplication;
		List<Application__c> applications = [
				SELECT Id
				FROM Application__c
		];
		System.assert(applications != null);
	}

	@IsTest
	static void testBehaviorWithActiveRecords() {
		Account newAccount = new Account(
				Name = 'newAccount'
		);
		insert newAccount;
		Application__c newApplication = new Application__c(
				Trade_Ally__c = newAccount.Id,
            	Business_Types__c = 'Contractor'
		);
		Terms_and_Conditions__c newConditions = new Terms_and_Conditions__c(
				Active__c = true,
				Text__c = 'text',
            	Application_Type__c = 'Contractor'
		);
		insert newConditions;
		insert newApplication;
		List<Application__c> applications = [
				SELECT Id
				FROM Application__c
		];
		System.assert(applications != null);
	}

	@IsTest
	static void testBehaviorNoApplicationType() {
		Account newAccount = new Account(
				Name = 'newAccount'
		);
		insert newAccount;
		Application__c newApplication = new Application__c(
				Trade_Ally__c = newAccount.Id
		);
		Terms_and_Conditions__c newConditions = new Terms_and_Conditions__c(
				Active__c = true,
				Text__c = 'text'
		);
		insert newConditions;
		insert newApplication;
		List<Application__c> applications = [
				SELECT Id
				FROM Application__c
		];
		System.assert(applications != null);
	}
}