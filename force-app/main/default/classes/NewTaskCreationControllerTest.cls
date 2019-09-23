@isTest
private class NewTaskCreationControllerTest {

	@isTest
	private static void testNewTaskCreationController() {
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

		NewTaskCreationController.LogInfoWrapper wrappedLogInfo = NewTaskCreationController.getWrappedLogInfo(tradeAlly.Id);
		for (NewTaskCreationController.ContactInfoWrapper wrappedContact : wrappedLogInfo.wrappedContacts) {
			wrappedContact.selected = true;
		}
		System.assert(wrappedLogInfo != null);
		String wrappedLogInfoJSON = JSON.serialize(wrappedLogInfo);
		NewTaskCreationController.createNewLog(wrappedLogInfoJSON);
		Integer numberOfTasks = [
			SELECT	Count()
			FROM	Task
		];
		System.assert(numberOfTasks == 1);
	}
}