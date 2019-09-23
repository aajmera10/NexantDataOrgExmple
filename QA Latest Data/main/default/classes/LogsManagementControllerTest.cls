@isTest
private class LogsManagementControllerTest {

	@isTest
	private static void testLogsManagementController() {
		Account tradeAlly = new Account(
			Name = 'John Smith',
			Phone = '7172398',
			NumberOfEmployees = 10,
			RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Trade Ally').getRecordTypeId()
		);
		insert tradeAlly;
		
		System.assert(LogsManagementController.getListOfAccounts('10',null,null) != null);
		System.assert(LogsManagementController.getListOfAccounts('723','ASC','Name') != null);
		System.assert(LogsManagementController.getListOfAccounts('Smith','ASC','Name') != null);
	}
}