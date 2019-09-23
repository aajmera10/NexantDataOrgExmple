@IsTest
private class TradeAllyUserTriggerTest {

	private static final String DEFAULT_PROFILE_NAME = 'Partner Community User';

	@IsTest
	static void tradeAlliesUsersTriggerLogicTest() {
		TradeAllyUserTriggerTest.createNonTradeAllyAccount();
		Account testParentTradeAlly = TradeAllyUserTriggerTest.createParentTradeAlly();
		Account testChildTradeAlly = TradeAllyUserTriggerTest.createChildTradeAlly(testParentTradeAlly.Id);
		Contact testTradeAllyContact = TradeAllyUserTriggerTest.createTradeAllyContact(testChildTradeAlly.Id);
		Id defaultProfileId = TradeAllyUserTriggerTest.getDefaultProfileId();
		User testTradeAllyUser = new User(
				FirstName = 'Testname' ,
				LastName = 'Testlastname',
				Alias = 'testal',
				Email = 'test@email.com',
				Username = 'testusername@counter.com',
				CommunityNickname = 'testnickname',
				LocaleSidKey = 'en_US',
				LanguageLocaleKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				TimeZoneSidKey = 'America/Los_Angeles',
				ProfileId = defaultProfileId,
				ContactId = testTradeAllyContact.Id
		);
		Test.startTest();
		insert testTradeAllyUser;
		Test.stopTest();
		System.runAs(testTradeAllyUser) {
			List<Account> availableTradeAllies = [
					SELECT 	Name,
							RecordTypeId
					FROM 	Account
					LIMIT 	50000
			];
			System.assert(availableTradeAllies != null);
			System.assert(availableTradeAllies.size() == 2);
		}
	}

	private static Id getDefaultProfileId() {
		return [
				SELECT 	Id,
						Name
				FROM 	Profile
				WHERE 	Name = :TradeAllyUserTriggerTest.DEFAULT_PROFILE_NAME
				LIMIT 	1
		].Id;
	}

	private static Account createNonTradeAllyAccount() {
		Account simpleAccount = new Account(
				Name = 'Simple Account'
		);
		insert simpleAccount;
		return simpleAccount;
	}

	private static Account createParentTradeAlly() {
		Account testParentTradeAlly = new Account(
				Name = 'Test Trade Ally',
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
		);
		insert testParentTradeAlly;
		return testParentTradeAlly;
	}

	private static Account createChildTradeAlly(Id parentTradeAllyId) {
		Account testChildTradeAlly = new Account(
				Name = 'Test Trade Ally',
				ParentId = parentTradeAllyId,
				RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
		);
		insert testChildTradeAlly;
		return testChildTradeAlly;
	}

	private static Contact createTradeAllyContact(Id tradeAllyId) {
		Contact testTradeAllyContact = new Contact(
				Lastname = 'Test Trade Ally Account',
				Level__c = 'Primary',
				AccountId = tradeAllyId
		);
		insert testTradeAllyContact;
		return testTradeAllyContact;
	}

}