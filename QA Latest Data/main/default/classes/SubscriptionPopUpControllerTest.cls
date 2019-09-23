@IsTest
private class SubscriptionPopUpControllerTest {
	@TestSetup
	public static void testSetup() {
		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
		UserRole portalRole = [
				SELECT
						Id
				FROM UserRole
				WHERE PortalType = 'None'
				LIMIT 1
		];
		Profile profileSA = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		List<User> portalAccountOwnerList = new List<User>();
		for (Integer i = 0; i < 10; i++) {
			User portalAccountOwner = new User(
					UserRoleId = portalRole.Id,
					ProfileId = profileSA.Id,
					Username = System.now().millisecond() + 'test2@test.com' + i,
					Alias = 'batman' + i,
					Email = i + 'bruce.wayne@wayneenterprises.com',
					EmailEncodingKey = 'UTF-8',
					FirstName = 'BruceBruce' + i,
					LastName = 'WayneWayne' + i,
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US',
					TimeZoneSidKey = 'America/Chicago'
			);
			portalAccountOwnerList.add(portalAccountOwner);
		}
		Database.insert(portalAccountOwnerList);
		List<Account> accountList = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			Account portalAccount = new Account(
					Name = 'TestAccount' + i,
					OwnerId = portalAccountOwnerList[i].Id,
					RecordTypeId = tradeAllyRecordTypeId
			);
			accountList.add(portalAccount);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert accountList;
		}
		List<Contact> contactList = new List<Contact>();
		for (Account account : accountList) {
			Contact contact = new Contact(
					FirstName = 'Test ' + account.Name,
					LastName = 'McTesty ' + account.Name,
					AccountId = account.Id,
					Email = account.Name + System.now().millisecond() + 'test@test.com',
					Level__c = 'Tier 1'
			);
			contactList.add(contact);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert contactList;
		}
		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> userList = new List<User>();
		for (Integer i = 0; i < 10; i++) {
			User user = new User(
					Username = i + System.now().millisecond() + 'test12345@test.com',
					ContactId = contactList[i].Id,
					ProfileId = portalProfile.Id,
					Alias = 'test123' + i,
					Email = i + 'test12345@test.com',
					EmailEncodingKey = 'UTF-8',
					LastName = 'McTestyMcTesty' + i,
					CommunityNickname = 'test12345' + i,
					TimeZoneSidKey = 'America/Los_Angeles',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US'
			);
			userList.add(user);
		}

		insert userList;

		List<Product2> product2List = new List<Product2>();
		Product2 firstProduct = new Product2();
		firstProduct.Name = 'Trade Ally Plus Test';
		product2List.add(firstProduct);
		Product2 secondProduct = new Product2();
		secondProduct.Name = 'Trade Ally Basic Test';
		product2List.add(secondProduct);
		System.runAs(portalAccountOwnerList[0]) {
			insert product2List;
		}

		Id standardPriceBookId = Test.getStandardPricebookId();
		PricebookEntry firstProductEntry = new PricebookEntry(
				Pricebook2Id = standardPriceBookId,
				Product2Id = firstProduct.Id,
				UnitPrice = 20
		);
		PricebookEntry secondProductEntry = new PricebookEntry(
				Pricebook2Id = standardPriceBookId,
				Product2Id = secondProduct.Id,
				UnitPrice = 20
		);
		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
				firstProductEntry,
				secondProductEntry
		};
		System.runAs(portalAccountOwnerList[0]) {
			insert pricebookEntryList;
		}


		PermissionSet newPermissionSet = new PermissionSet(
				Name = firstProduct.Name.replaceAll(' ', '_'),
				Label = firstProduct.Name
		);
		System.runAs(portalAccountOwnerList[0]) {
			insert newPermissionSet;
		}
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = new List<Trade_Ally_Subscription__c>();
		List<Application__c> tradeAllyApplications = new List<Application__c>();
		for (Account account : accountList) {
			Trade_Ally_Subscription__c newSubscription = new Trade_Ally_Subscription__c(
					Account__c = account.Id,
					Subscription_Level__c = secondProduct.Id,
					Subscription_Status__c = 'Active',
					Stripe_Product_Name__c = 'Trade Ally Plus Test'
			);
			tradeAllySubscriptions.add(newSubscription);
			Application__c newApplication = new Application__c(
					Trade_Ally__c = account.Id
			);
			tradeAllyApplications.add(newApplication);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert tradeAllySubscriptions;
			insert tradeAllyApplications;
		}
	}

	@IsTest
	public static void activateStandardSubscriptionTest() {
		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'System Administrator'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
		];
		List<Application__c> applications = [
				SELECT Id
				FROM Application__c
		];
		String serverStatus;
		System.runAs(users[0]) {
			serverStatus = SubscriptionPopUpController.activateStandardSubscription(applications[0].Id);
		}
		System.assertEquals('Subscription is activated', serverStatus);
	}

	@IsTest
	public static void activateStandardSubscriptionTestWithoutSubscription () {
		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'System Administrator'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
		];
		List<Application__c> applications = [
				SELECT Id
				FROM Application__c
		];
		Application__c currentApplication = applications[0];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT Id
				FROM Trade_Ally_Subscription__c
				WHERE Account__c IN (SELECT Trade_Ally__c FROM Application__c WHERE Id =: currentApplication.Id)
		];
		delete tradeAllySubscriptions;
		String serverStatus;
		System.runAs(users[0]) {
			serverStatus = SubscriptionPopUpController.activateStandardSubscription(currentApplication.Id);
		}
		System.assertEquals('New active Subscription record is created', serverStatus);
	}

}