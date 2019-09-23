@IsTest
private class TradeAllyTriggerHandlerTest {
//	@TestSetup
//	static void testInstall() {
//		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
//		UserRole portalRole = [
//				SELECT
//						Id
//				FROM UserRole
//				WHERE PortalType = 'None'
//				LIMIT 1
//		];
//		Profile profileSA = [
//				SELECT
//						Id
//				FROM Profile
//				WHERE Name = 'System Administrator'
//		];
//		User portalAccountOwner = new User(
//				UserRoleId = portalRole.Id,
//				ProfileId = profileSA.Id,
//				Username = System.now().millisecond() + 'test2@test.com',
//				Alias = 'batman',
//				Email = 'bruce.wayne@wayneenterprises.com',
//				EmailEncodingKey = 'UTF-8',
//				FirstName = 'BruceBruce',
//				LastName = 'WayneWayne',
//				LanguageLocaleKey = 'en_US',
//				LocaleSidKey = 'en_US',
//				TimeZoneSidKey = 'America/Chicago',
//				IsActive = true
//		);
//		Database.insert(portalAccountOwner);
//		Account portalAccount = new Account(
//				Name = 'TestAccount',
//				OwnerId = portalAccountOwner.Id,
//				RecordTypeId = tradeAllyRecordTypeId,
//				Tier_Level__c = 'Tier 1'
//		);
//		System.runAs(portalAccountOwner) {
//			insert portalAccount;
//		}
//		List<Contact> contactList = new List<Contact>();
//		for (Integer i = 0; i < 10; i++) {
//			Contact contact = new Contact(
//					FirstName = 'Test ' + portalAccount.Name + i,
//					LastName = 'McTesty ' + portalAccount.Name + i,
//					AccountId = portalAccount.Id,
//					Email = portalAccount.Name + i + System.now().millisecond() + 'test@test.com',
//					Level__c = 'Tier 1'
//			);
//			contactList.add(contact);
//		}
//		System.runAs(portalAccountOwner) {
//			insert contactList;
//		}
//
//		List<CollaborationGroup> newGroupsList = new List<CollaborationGroup>();
//		String organizationName = 'TEST ORG';
//		String firstGroupName = 'Tier 1 Trade Allies';
//		String secondGroupName = organizationName + ' Announcements';
//		String thirdGroupName = organizationName + ' Q&A';
//		CollaborationGroup firstGroup = new CollaborationGroup();
//		firstGroup.Name = firstGroupName;
//		firstGroup.CollaborationType = 'Private';
//		newGroupsList.add(firstGroup);
//		CollaborationGroup secondGroup = new CollaborationGroup();
//		secondGroup.Name = secondGroupName;
//		secondGroup.CollaborationType = 'Public';
//		secondGroup.IsBroadcast = true;
//		newGroupsList.add(secondGroup);
//		CollaborationGroup thirdGroup = new CollaborationGroup();
//		thirdGroup.Name = thirdGroupName;
//		thirdGroup.CollaborationType = 'Public';
//		newGroupsList.add(thirdGroup);
//
//		System.runAs(portalAccountOwner) {
//			insert newGroupsList;
//		}
//
//
//	}
//
//	@IsTest
//	static void tier1ChatterGroupHandlerTest() {
//		List<Contact> contactList = [
//				SELECT Id
//				FROM Contact
//		];
//		List<User> portalAccountOwnerList = [
//				SELECT Id
//				FROM User
//		];
//		List<Account> accountList = [
//				SELECT Id
//				FROM Account
//		];
//		Profile portalProfile = [
//				SELECT
//						Id
//				FROM Profile
//				WHERE Name LIKE '%Portal User%'
//				LIMIT 1
//		];
//		List<User> userList = new List<User>();
//		for (Integer i = 0; i < 10; i++) {
//			User user = new User(
//					Username = i + System.now().millisecond() + 'test12345@test.com',
//					ContactId = contactList[i].Id,
//					ProfileId = portalProfile.Id,
//					Alias = 'test123' + i,
//					Email = i + 'test12345@test.com',
//					EmailEncodingKey = 'UTF-8',
//					LastName = 'McTestyMcTesty' + i,
//					CommunityNickname = 'test12345' + i,
//					TimeZoneSidKey = 'America/Los_Angeles',
//					LocaleSidKey = 'en_US',
//					LanguageLocaleKey = 'en_US',
//					IsActive = true
//			);
//			userList.add(user);
//		}
//
//		insert userList;
//
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
//		PermissionSet newPermissionSet = new PermissionSet(
//				Name = firstProduct.Name.replaceAll(' ', '_'),
//				Label = firstProduct.Name
//		);
//		System.runAs(portalAccountOwnerList[0]) {
//			insert newPermissionSet;
//		}
//		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = new List<Trade_Ally_Subscription__c>();
//		for (Account account : accountList) {
//			Trade_Ally_Subscription__c newSubscription = new Trade_Ally_Subscription__c(
//					Account__c = account.Id,
//					Subscription_Level__c = secondProduct.Id,
//					Subscription_Status__c = 'Active'
//			);
//			tradeAllySubscriptions.add(newSubscription);
//		}
//		System.runAs(portalAccountOwnerList[0]) {
//			insert tradeAllySubscriptions;
//		}
//
//		List<CollaborationGroupMember> groupMembersList = [
//				SELECT
//						MemberId,
//						CollaborationGroupId
//				FROM CollaborationGroupMember
//		];
//		System.assertEquals(3, groupMembersList.size());
//
//		List<CollaborationGroup> tier1GroupList = [
//				SELECT Name
//				FROM CollaborationGroup
//				WHERE Name = :Constants.TIER_ONE_CHATTER_GROUP_NAME
//		];
//		Map<Id, CollaborationGroup> tier1GroupMap = new Map<Id, CollaborationGroup>(tier1GroupList);
//		Set<Id> tier1GroupIdSet = tier1GroupMap.keySet();
//		List<CollaborationGroupMember> collaborationGroupMembers = [
//				SELECT Id
//				FROM CollaborationGroupMember
//				WHERE	CollaborationGroupId IN: tier1GroupIdSet
//				AND MemberId NOT IN (
//						SELECT OwnerId FROM CollaborationGroup
//				)
//		];
//		accountList[0].Name = 'IsChangedName';
//		System.runAs(portalAccountOwnerList[0]) {
//			delete collaborationGroupMembers;
//			update accountList[0];
//		}
//
//
//
//		List<CollaborationGroupMember> secondGroupMembersList = [
//				SELECT
//						MemberId,
//						CollaborationGroupId
//				FROM CollaborationGroupMember
//		];
//		System.assertEquals(3, secondGroupMembersList.size());
//	}
//
//	@IsTest
//	static void insertSubscriptionTest() {
//		List<Subscription_Products__c> subscriptionProductsList = new List<Subscription_Products__c>();
//		Subscription_Products__c firstSubscriptionProduct = new Subscription_Products__c();
//		firstSubscriptionProduct.Name = 'First Product';
//		firstSubscriptionProduct.Standard__c = true;
//		subscriptionProductsList.add(firstSubscriptionProduct);
//		Subscription_Products__c secondSubscriptionProduct = new Subscription_Products__c();
//		secondSubscriptionProduct.Name = 'Second Product';
//		subscriptionProductsList.add(secondSubscriptionProduct);
//		insert subscriptionProductsList;
//		List<Product2> product2List = new List<Product2>();
//		for (Subscription_Products__c subscriptionProducts : subscriptionProductsList) {
//			Product2 newProduct = new Product2(Name = subscriptionProducts.Name);
//			product2List.add(newProduct);
//		}
//		insert product2List;
//		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
//		List<Account> testTradeAllies = new List<Account>();
//		RecordType anotherRecordType = [
//				SELECT
//						Id,
//						RecordType.Name
//				FROM RecordType
//				WHERE SobjectType = 'Account'
//				AND Id != :tradeAllyRecordTypeId
//				LIMIT 1
//		];
//		Id anotherRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(anotherRecordType.Name).getRecordTypeId();
//		for (Integer i = 0; i < 5; i++) {
//			testTradeAllies.add(
//					new Account(
//							Name = 'Test Trade Ally ' + i,
//							Tier_Level__c = 'Tier 1',
//							RecordTypeId = tradeAllyRecordTypeId
//					)
//			);
//		}
//		insert testTradeAllies;
//		List<Account> accounts = [
//				SELECT
//						Id, (
//						SELECT Id,
//								Subscription_Status__c
//						FROM Trade_Ally_Subscriptions__r
//				)
//				FROM Account
//		];
//		List<Trade_Ally_Subscription__c> subscriptions = new List<Trade_Ally_Subscription__c>();
//		for (Account account : accounts) {
//			for (Trade_Ally_Subscription__c tradeAllySubscription : account.Trade_Ally_Subscriptions__r) {
//				subscriptions.add(tradeAllySubscription);
//				System.assert(tradeAllySubscription.Subscription_Status__c != 'Active');
//			}
//		}
//		System.assertEquals(6, subscriptions.size());
//	}
//
//	@IsTest
//	static void insertSubscriptionTest2() {
//		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
//		List<Account> testTradeAllies = new List<Account>();
//		RecordType anotherRecordType = [
//				SELECT
//						Id,
//						RecordType.Name
//				FROM RecordType
//				WHERE SobjectType = 'Account'
//				AND Id != :tradeAllyRecordTypeId
//				AND Id != '012f4000000ehDoAAI'
//				LIMIT 1
//		];
//		for (Integer i = 0; i < 5; i++) {
//			testTradeAllies.add(
//					new Account(
//							Name = 'Test Trade Ally ' + (i + 5),
//							Tier_Level__c = 'Tier 2',
//							RecordTypeId = anotherRecordType.Id
//					)
//			);
//		}
//		insert testTradeAllies;
//		List<Account> accounts = [
//				SELECT
//						Id, (
//						SELECT Id
//						FROM Trade_Ally_Subscriptions__r
//				)
//				FROM Account
//		];
//		List<Trade_Ally_Subscription__c> subscriptions = new List<Trade_Ally_Subscription__c>();
//		for (Account account : accounts) {
//			for (Trade_Ally_Subscription__c tradeAllySubscription : account.Trade_Ally_Subscriptions__r) {
//				subscriptions.add(tradeAllySubscription);
//			}
//		}
//		System.assertEquals(1, subscriptions.size());
//	}
}