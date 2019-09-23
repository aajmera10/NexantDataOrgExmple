@IsTest
private class SubscriptionTriggerTest {

	@TestSetup
	static void methodName() {
        Profile portalProfile = [
				SELECT
						Id,
						Name
				FROM    Profile
				WHERE   Name LIKE '%Custom Community Profile%'
				LIMIT   1
		];
		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
		UserRole portalRole = [
				SELECT
						Id
				FROM    UserRole
				WHERE   PortalType = 'None'
				LIMIT   1
		];
		Profile profileSA = [
				SELECT
						Id
				FROM    Profile
				WHERE   Name = 'System Administrator'
		];
		List<User> portalAccountOwnerList = new List<User>();
		for (Integer i = 0; i < 10; i++) {
			User portalAccountOwner = new User(
					UserRoleId = portalRole.Id,
					ProfileId = profileSA.Id,
					Username = System.now().millisecond() + 'test2@test.com' + i,
					Alias = 'batman' + i,
					Email= i + 'bruce.wayne@wayneenterprises.com',
					EmailEncodingKey='UTF-8',
					FirstName='BruceBruce' + i,
					LastName='WayneWayne' + i,
					LanguageLocaleKey='en_US',
					LocaleSidKey='en_US',
					TimeZoneSidKey='America/Chicago'
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
            Application_Settings__c setting = new Application_Settings__c(
			Name = Constants.SUBSCRIBED_PROFILE_NAME,
			Value__c = 'Custom Customer Community Plus'
		);
		insert setting;
		}
		List<Contact> contactList = new List<Contact>();
		for (Account account : accountList) {
			Contact contact = new Contact(
					FirstName = 'Test ' + account.Name,
					LastName = 'McTesty '  + account.Name,
					AccountId = account.Id,
					Email = account.Name + System.now().millisecond() + 'test@test.com',
					Level__c = 'Tier 1'
			);
			contactList.add(contact);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert contactList;
		}

		List<User> userList = new List<User>();
		for (Integer i = 0; i < 10; i++) {
			User user = new User(
					Username = i + System.now().millisecond() + 'test12345@test.com',
					ContactId = contactList[i].Id,
					ProfileId = portalProfile.Id,
					Alias = 'test123' + i,
					Email = i +'test12345@test.com',
					EmailEncodingKey = 'UTF-8',
					LastName = 'McTestyMcTesty' + i,
					CommunityNickname = 'test12345' + i,
					TimeZoneSidKey = 'America/Los_Angeles',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US'
			);
			userList.add(user);
		}
	System.runAs(portalAccountOwnerList[0]) {
		insert userList;
	}

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
		PermissionSet newPermissionSet = new PermissionSet(
				Name = firstProduct.Name.replaceAll(' ', '_'),
				Label = firstProduct.Name
		);
		System.runAs(portalAccountOwnerList[0]) {
			insert newPermissionSet;
		}
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = new List<Trade_Ally_Subscription__c>();
		for (Account account : accountList) {
			Trade_Ally_Subscription__c newSubscription = new Trade_Ally_Subscription__c(
					Account__c = account.Id,
					Subscription_Level__c = secondProduct.Id,
					Subscription_Status__c = 'Active',
					Stripe_Product_Name__c ='Trade Ally Plus Test'
			);
			tradeAllySubscriptions.add(newSubscription);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert tradeAllySubscriptions;
		}
	}

	@IsTest
	static void testBehavior() {
		List<Product2> product2s = [
				SELECT  Id,
						Name
				FROM    Product2
		];
		Product2 firstProduct;
		Product2 secondProduct;
		for (Product2 product2 : product2s) {
			if(product2.Name == 'Trade Ally Plus Test'){
				firstProduct = product2;
			}
			else{
				secondProduct = product2;
			}
		}
		System.debug('firstProduct ' + firstProduct);
		System.debug('secondProduct ' + secondProduct);
		List<Trade_Ally_Subscription__c> subscriptions = [
				SELECT Id,
						Subscription_Status__c,
						Subscription_Level__c
				FROM Trade_Ally_Subscription__c
				WHERE Subscription_Status__c = 'Active'
		];
		List<PermissionSet> permissionSets = [
				SELECT Id
				FROM PermissionSet
				WHERE Name = 'Trade_Ally_Plus_Test'
				OR Name = 'Trade_Ally_Basic_Test'
		];
		System.debug('permissionSets ' + permissionSets);
		System.debug('subscriptions ' + subscriptions);

		Map<Id, PermissionSet> permissionSetsMap = new Map<Id, PermissionSet>(permissionSets);
		System.debug('permissionSetsMap.keySet() ' + permissionSetsMap.keySet());

		List<PermissionSetAssignment> permissionSetAssignments = [
				SELECT
						Id
				FROM    PermissionSetAssignment
				WHERE Id IN: permissionSetsMap.keySet()
		];
		System.assertEquals(0, permissionSetAssignments.size());
		for (Trade_Ally_Subscription__c tradeAllySubscription : subscriptions) {
			tradeAllySubscription.Subscription_Level__c = firstProduct.Id;
			tradeAllySubscription.Subscription_Status__c = 'Active';
		}
		update subscriptions;
		permissionSetAssignments = [
				SELECT
						Id
				FROM    PermissionSetAssignment
				WHERE PermissionSetId IN: permissionSetsMap.keySet()

		];
		System.assertEquals(0, permissionSetAssignments.size());
		for (Trade_Ally_Subscription__c tradeAllySubscription : subscriptions) {
			tradeAllySubscription.Subscription_Level__c = secondProduct.Id;
		}
		update subscriptions;
		permissionSetAssignments = [
				SELECT
						Id
				FROM    PermissionSetAssignment
				WHERE PermissionSetId IN: permissionSetsMap.keySet()

		];
		System.assertEquals(0, permissionSetAssignments.size());
		for (Trade_Ally_Subscription__c tradeAllySubscription : subscriptions) {
			tradeAllySubscription.Subscription_Status__c = 'Inactive';
		}
		update subscriptions;
		permissionSetAssignments = [
				SELECT
						Id
				FROM    PermissionSetAssignment
				WHERE PermissionSetId IN: permissionSetsMap.keySet()

		];
		System.assertEquals(0, permissionSetAssignments.size());
		for (Trade_Ally_Subscription__c tradeAllySubscription : subscriptions) {
			tradeAllySubscription.Subscription_Status__c = 'Active';
		}
		update subscriptions;
		permissionSetAssignments = [
				SELECT
						Id
				FROM    PermissionSetAssignment
				WHERE PermissionSetId IN: permissionSetsMap.keySet()

		];
		System.assertEquals(0, permissionSetAssignments.size());
		delete subscriptions;
		permissionSetAssignments = [
				SELECT
						Id
				FROM    PermissionSetAssignment
				WHERE PermissionSetId IN: permissionSetsMap.keySet()

		];
		System.assertEquals(0, permissionSetAssignments.size());
	}


}