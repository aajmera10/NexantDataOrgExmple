@IsTest
public with sharing class TradeAllySubscriptionControllerTest {

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

//		List<Product2> product2List = new List<Product2>();
//		Product2 firstProduct = new Product2();
//		firstProduct.Name = 'Trade Ally Plus Test';
//		product2List.add(firstProduct);
//		Product2 secondProduct = new Product2();
//		secondProduct.Name = 'Trade Ally Basic Test';
//		product2List.add(secondProduct);
//		System.runAs(portalAccountOwnerList[0]) {
//			insert product2List;
//		}
//
//		Id standardPriceBookId = Test.getStandardPricebookId();
//		PricebookEntry firstProductEntry = new PricebookEntry(
//				Pricebook2Id = standardPriceBookId,
//				Product2Id = firstProduct.Id,
//				UnitPrice = 20
//		);
//		PricebookEntry secondProductEntry = new PricebookEntry(
//				Pricebook2Id = standardPriceBookId,
//				Product2Id = secondProduct.Id,
//				UnitPrice = 20
//		);
//		List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>{
//				firstProductEntry,
//				secondProductEntry
//		};
//		System.runAs(portalAccountOwnerList[0]) {
//			insert pricebookEntryList;
//		}
//
//
		PermissionSet newPermissionSet = new PermissionSet(
				Name ='Trade Ally Plus Test Second'.replaceAll(' ', '_'),
				Label = 'Trade Ally Plus Test Second'
		);
		System.runAs(portalAccountOwnerList[0]) {
			insert newPermissionSet;
		}
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = new List<Trade_Ally_Subscription__c>();
		for (Account account : accountList) {
			Trade_Ally_Subscription__c newSubscription = new Trade_Ally_Subscription__c(
					Account__c = account.Id,
					Subscription_Status__c = 'Active',
					Stripe_Product_Name__c = 'Trade Ally Plus Test'
			);
			tradeAllySubscriptions.add(newSubscription);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert tradeAllySubscriptions;
		}
	}

	@IsTest
	public static void TradeAllySubscriptionControllerTest() {
		TradeAllySubscriptionController tradeAllySubscriptionController = new TradeAllySubscriptionController();
		String publicKey = tradeAllySubscriptionController.publicKey;
		System.assertEquals(true, publicKey != null);
	}


	@IsTest
	public static void getInitDataTestWithoutUsers() {
		List<Object> initData;
		initData = TradeAllySubscriptionController.getInitData();
		System.assertEquals(1, initData.size());
		System.assertEquals(false, initData[0]);
	}

	@IsTest
	public static void getInitDataTest() {
		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Object> initData;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			initData = TradeAllySubscriptionController.getInitData();
			Test.stopTest();
		}
		System.assertEquals(5, initData.size());
		System.assertEquals(true, initData[0] != null);
		System.assertEquals(true, initData[1] != null);
		System.assertEquals(true, initData[2] != null);
		System.assertEquals(true, initData[3] != null);
	}


	@IsTest
	public static void createSubscriptionTestDay() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'day';
		String serializedSubscription;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
				WHERE Account__c = :users[0].Contact.AccountId
		];
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}

	@IsTest
	public static void createSubscriptionTestWeek() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'week';
		String serializedSubscription;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
				WHERE Account__c = :users[0].Contact.AccountId
		];
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}


	@IsTest
	public static void createSubscriptionTestMonth() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'month';
		String serializedSubscription;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
				WHERE Account__c = :users[0].Contact.AccountId
		];
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}


	@IsTest
	public static void createSubscriptionTestYear() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'year';
		String serializedSubscription;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
				WHERE Account__c = :users[0].Contact.AccountId
		];
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}

	@IsTest
	public static void createSubscriptionTestWithoutProducts() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'day';
		String serializedSubscription;

		List<Product2> product2s = [
				SELECT Id
				FROM Product2
		];
		delete product2s;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
				WHERE Account__c = :users[0].Contact.AccountId
		];
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}


	@IsTest
	public static void createSubscriptionTestAsSystemAdministrator() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'day';
		String serializedSubscription;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'System Administrator'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
		];
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}

	@IsTest
	public static void createSubscriptionTestWithStripeId() {
		String token =                      'token';
		String productName =                'Trade Ally Plus Test';
		String productAmount =              '200';
		String currentPlanId =              'currentPlanId';
		String currentPlanInterval =        'year';
		String serializedSubscription;

		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> users = [
				SELECT Id,
						Name,
						Contact.AccountId
				FROM User
				WHERE ProfileId = :portalProfile.Id
				AND IsActive = TRUE
				AND Contact.AccountId != NULL
		];
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = [
				SELECT
						Id,
						Subscription_Status__c,
						Subscription_Level__c,
						Subscription_Level__r.Name,
						Subscription_Level__r.Description,
						Stripe_Id__c
				FROM Trade_Ally_Subscription__c
				WHERE Account__c = :users[0].Contact.AccountId
		];
		tradeAllySubscriptions[0].Stripe_Id__c = 'stripe_id';
		serializedSubscription = JSON.serialize(tradeAllySubscriptions[0]);
		List<Object> results;
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();

		System.runAs(users[0]) {
			results = TradeAllySubscriptionController.createSubscription(token, productName, productAmount, currentPlanId, currentPlanInterval, serializedSubscription);
			Test.stopTest();
		}
		System.assertEquals(true, results[0] != null);
		System.assertEquals(true, results[1] != null);
	}

}