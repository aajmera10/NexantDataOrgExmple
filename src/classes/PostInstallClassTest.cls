@IsTest
public with sharing class PostInstallClassTest {
	@IsTest
	static void postInstallTest() {
		PostInstallClass newPostInstallClass = new PostInstallClass();
		Test.testInstall(newPostInstallClass, null);
		List<Application_Settings__c> applicationSettings = [
				SELECT Id
				FROM Application_Settings__c
		];
		System.assert(applicationSettings.size() > 0);
	}
}