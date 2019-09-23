@IsTest
private class TradeAllyTriggerTest {

	private static final Integer NUMBER_OF_TEST_TRADE_ALLIES = 10;
	private static final Integer NUMBER_OF_TEST_TRADE_ALLY_USERS = 10;

	@IsTest
	static void tradeAlliesTriggerLogicTest() {
		// Test for External Id and Registration Code autonumber logic
		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
		List<Account> testTradeAlliesPartOne = new List<Account>();
		List<Account> testTradeAlliesPartTwo = new List<Account>();
		for (Integer i = 0; i < TradeAllyTriggerTest.NUMBER_OF_TEST_TRADE_ALLIES; i++) {
			testTradeAlliesPartOne.add(
			    new Account(
			        Name = 'Test Trade Ally ' + i,
			        Tier_Level__c = 'Special',
			        RecordTypeId = tradeAllyRecordTypeId
			    )
			);
			testTradeAlliesPartTwo.add(
				new Account(
					Name = 'Test Trade Ally ' + (i + TradeAllyTriggerTest.NUMBER_OF_TEST_TRADE_ALLIES),
					Tier_Level__c = 'Common',
					RecordTypeId = tradeAllyRecordTypeId
				)
			);
		}
		Test.startTest();
		insert testTradeAlliesPartOne;
		// Set parent id to work with all cases of sharing utility
		testTradeAlliesPartTwo[0].ParentId = testTradeAlliesPartOne[0].Id;
		insert testTradeAlliesPartTwo;
		Test.stopTest();
		List<Account> result = [
			SELECT 		External_Id__c,
						Registration_Code__c
			FROM 		Account
			ORDER BY	External_Id__c
			ASC 
			LIMIT 		50000
		];
		System.assert(!result.isEmpty());
		for (Integer i = 0; i < result.size(); i++) {
			String cleanedExternalId = result[i].External_Id__c.replaceAll('[^0-9]', '');
			String cleanedRegistrationCode = result[i].Registration_Code__c.replaceAll('[^0-9]', '');
			Integer externalIdCounter = Integer.valueOf(cleanedExternalId);
			Integer registrationCodeCounter = Integer.valueOf(cleanedRegistrationCode);
			System.assert(externalIdCounter == Constants.EXTERNAL_ID_STARTING_NUMBER + i + 1);
			System.assert(registrationCodeCounter == Constants.REGISTRATION_CODE_STARTING_NUMBER + i + 1);
		}
	}

	private static Id getDefaultProfileId() {
		return [
				SELECT 	Id,
						Name
				FROM 	Profile
				WHERE 	Name = 'Partner Community User'
				LIMIT 	1
		].Id;
	}

}