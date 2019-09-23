@IsTest
public with sharing class TradeAllySearchControllerTest {

	@IsTest
	public static void getSelectedTradeAlliesTest() {
		RecordType rt = [
			SELECT	Id
			FROM	RecordType
			WHERE	Name = 'Trade Ally'
		];
		Account newAccount = new Account(
			Name = 'Account',
			RecordTypeId = rt.Id
		);
		insert newAccount;
		Contact newContact = new Contact(
			LastName = 'Last Name',
			Level__c = 'Tier 1'
		);
		insert newContact;
		Referral__c newReferral = new Referral__c(
			Customer__c = newContact.Id//,
			//Trade_Ally__c = newAccount.Id
		);
		insert newReferral;
		Trade_Ally_Referral__c newTradeAllyReferral = new Trade_Ally_Referral__c(
				Trade_Ally__c = newAccount.Id,
				Referral__c = newReferral.Id,
				Referral_Status__c = 'Assigned'
		);
		insert newTradeAllyReferral;
		List<TradeAllySearchController.TradeAllyWrapper> newWrappers = TradeAllySearchController.getSelectedTradeallies(newReferral.Id);
		System.assertEquals(true, newWrappers != null);
	}

	@IsTest
	public static void createTradeAllyReferralRelationTest() {
		RecordType rt = [
			SELECT	Id
			FROM	RecordType
			WHERE	Name = 'Trade Ally'
		];
		Account newAccount = new Account(
			Name = 'Account',
			RecordTypeId = rt.Id
		);
		insert newAccount;
		List<TradeAllySearchController.TradeAllyWrapper> wrappers = new List<TradeAllySearchController.TradeAllyWrapper>();
		TradeAllySearchController.TradeAllyWrapper newWrapper;
		List<User> users = [
			SELECT Id,
					Latitude,
					Longitude
			FROM User
			WHERE Id =: UserInfo.getUserId()
		];
		for (Integer i = 0; i < 5; i++) {
			newWrapper = new TradeAllySearchController.TradeAllyWrapper(
				true,
				newAccount,
				users[0]
			);
			wrappers.add(newWrapper);
		}
		String serialisedAccounts = JSON.serialize(wrappers);
		Contact newContact = new Contact(
			LastName = 'Last Name',
			Level__c = 'Tier 1'
		);
		insert newContact;

		Referral__c newReferral = new Referral__c(
			Customer__c = newContact.Id//,
			//Trade_Ally__c = newAccount.Id
		);
		insert newReferral;
		TradeAllySearchController.createTradeAllyReferralRelation(serialisedAccounts, newReferral.Id);
        List<TradeAllySearchController.TradeAllyWrapper> newWrappers = TradeAllySearchController.getSelectedTradeallies(newReferral.Id);
		System.assertEquals(true, newWrappers != null);
	}

	@IsTest
	public static void getTradeAllyIdListTest() {
		Specialty__c newSpecialty = new Specialty__c(
				Name = 'Specialty'
		);
		List<Id>  specialtyNameOptions = TradeAllySearchController.getTradeAllyIdList(newSpecialty.Id);
		System.assertEquals(true, specialtyNameOptions != null);
	}

	@IsTest
	public static void getSpecialtyNameOptionsTest() {
		Map<String, String> specialtyNameOptions = TradeAllySearchController.getSpecialtyNameOptions();
		System.assertEquals(true, specialtyNameOptions != null);
	}

	@IsTest
	public static void getSectorsOptionsTest() {
		Map<String, String> specialtyNameOptions = TradeAllySearchController.getSectorsOptions();
		System.assertEquals(true, specialtyNameOptions != null);
	}

@IsTest
	public static void searchForTradeAlliesTest() {
	Specialty__c newSpecialty = new Specialty__c(
			Name = 'Specialty'
	);
	insert newSpecialty;
	List<TradeAllySearchController.TradeAllyWrapper> specialtyNameOptions = TradeAllySearchController.searchForTradeAllies(newSpecialty.Id, '');
	System.assertEquals(true, specialtyNameOptions != null);
	}



}