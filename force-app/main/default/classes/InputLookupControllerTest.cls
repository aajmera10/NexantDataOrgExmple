@isTest
private class InputLookupControllerTest {

	@isTest
	private static void testInputLookupController() {
		Account tradeAlly = new Account(
			Name = 'John Smith',
			Phone = '7172398',
			NumberOfEmployees = 10,
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Trade Ally').getRecordTypeId()
		);
		insert tradeAlly;

		List<Contact> listOfTradeAllyUsers = new List<Contact>{
			new Contact(
				LastName = 'Smith 1',
				Level__c = 'Primary',
				AccountId = tradeAlly.Id
			),
			new Contact(
				LastName = 'Smith 2',
				Level__c = 'Secondary',
				AccountId = tradeAlly.Id
			),
			new Contact(
				LastName = 'Smith 3',
				Level__c = 'Secondary',
				AccountId = tradeAlly.Id
			)
		};
		insert listOfTradeAllyUsers;

		List<InputLookupController.SearchWrapper> listSearchWrapper = InputLookupController.searchData('Smith','Contact');
		System.assert(listSearchWrapper.size() == 3);
		listSearchWrapper = InputLookupController.searchData('Smith','Some Bad Name');
		System.assert(listSearchWrapper.size() == 0);
	}
}