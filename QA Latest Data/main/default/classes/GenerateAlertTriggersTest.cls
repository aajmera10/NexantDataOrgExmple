@IsTest
private class GenerateAlertTriggersTest {

	private static final Integer NUMBER_OF_RECORDS = 20;

	@IsTest
	static void testGenerateAlertTriggers() {
		License__c license = new License__c(
			Type__c = 'test',
			Expiry_Date__c = Date.today()
		);
		insert license;
		update license;

		Insurance__c insurance = new Insurance__c(
			Expiry_Date__c = Date.today()
		);
		insert insurance;

		Certification__c certification = new Certification__c(
			Expiry_Date__c = Date.today()
		);
		insert certification;

		List<Task> listOfTasks = [
			SELECT	Id
			FROM	Task
		];
		System.assert(listOfTasks.size() == 3);
	}
	/*private static void createAlertTest(String sObjectType, String alertFieldApi, String expirationDateFieldApi) {
		//Test after insert action
		List<sObject> testLicenses = new List<sObject>();
		Date testExpirationDate = Date.valueOf('2018-10-05');// 20:00:00
		for (Integer i = 0; i < GenerateAlertTriggersTest.NUMBER_OF_RECORDS; i++) {
			sObject testLicense = Schema.getGlobalDescribe().get(sObjectType).newSObject();
			if (math.mod(i, 2) == 0) {
				testLicense.put(expirationDateFieldApi, testExpirationDate);
			}
			testLicenses.add(testLicense);
		}
		insert testLicenses;
		List<Task> alertsResult = [
			SELECT 	Id,
					ActivityDate
			FROM 	Task
			LIMIT 	50000
		];
		System.assert(!alertsResult.isEmpty());
		System.assert(alertsResult.size() == GenerateAlertTriggersTest.NUMBER_OF_RECORDS / 2);
		for (Task alert : alertsResult) {
			System.assert(alert.ActivityDate != null);
			System.assert(alert.ActivityDate.format() == '10/5/2018');// 8:00 PM
		}
		//Test after update action
		for (Integer i = 0; i < GenerateAlertTriggersTest.NUMBER_OF_RECORDS; i++) {
			if (math.mod(i, 2) != 0) {
				testLicenses[i].put(expirationDateFieldApi, testExpirationDate);
			}
		}
		update testLicenses;
		alertsResult = [
			SELECT 	Id,
					ActivityDate
			FROM 	Task
			LIMIT 	50000
		];
		System.assert(!alertsResult.isEmpty());
		System.assert(alertsResult.size() == GenerateAlertTriggersTest.NUMBER_OF_RECORDS);
		for (Task alert : alertsResult) {
			System.assert(alert.ActivityDate != null);
			System.assert(alert.ActivityDate.format() == '10/5/2018');// 8:00 PM
		}
		//Test that all related records exist
		String relatedRecordsQuery = 'SELECT' + ' ' + alertFieldApi + ',' + ' ' + expirationDateFieldApi + ' ' + 'FROM' + ' ' + sObjectType + ' ' + 'LIMIT 50000';
		List<sObject> relatedRecordsResult = Database.query(relatedRecordsQuery);
		System.assert(!relatedRecordsResult.isEmpty());
		System.assert(relatedRecordsResult.size() == GenerateAlertTriggersTest.NUMBER_OF_RECORDS);
		for (sObject relatedRecord : relatedRecordsResult) {
			System.assert(relatedRecord.get(alertFieldApi) != null);
		}
	}

	//Test method for 'GenerateAlertBasedOnLicenseTrigger'
	@IsTest
	static void generateAlertBasedOnLicenseTest() {
		GenerateAlertTriggersTest.createAlertTest('License__c', 'ActivityDate');
	}

	//Test method for 'GenerateAlertBasedOnInsuranceTrigger'
	@IsTest
	static void generateAlertBasedOnInsuranceTest() {
		GenerateAlertTriggersTest.createAlertTest('Insurance__c', 'ActivityDate');
	}*/

}