@isTest
private class SchedulersAndBatchesTest {

	@isTest
	private static void testAlertsReviewScheduler() {

		Certification__c certification = new Certification__c(
			Expiry_Date__c = Date.today()
		);
		insert certification;

		Task t = [
			SELECT
					Id,
					Status
			FROM	Task
			WHERE	WhatId =: certification.Id
		];
		t.Status = Constants.NOT_STARTED_STATUS;
		update t;
		
		Test.startTest();
			String alertsReviewSchedulerId1 = AlertsReviewScheduler.runMe();
			String alertsReviewSchedulerId2 = AlertsReviewScheduler.runMe();
			new AlertsReviewScheduler().execute(null);
			List<Application_Settings__c> appSettings = new List<Application_Settings__c>{
				new Application_Settings__c(
					Name = Constants.ALERTS_CERTIFICATION_EMAIL,
					Value__c = '0,10,20'
				),
				new Application_Settings__c(
					Name = Constants.ALERTS_CERTIFICATION_SHOW,
					Value__c = '0,10,20'
				)
			};
			insert appSettings;
			new AlertsReviewScheduler().execute(null);
		Test.stopTest();

		Integer numberOfRecords = [
			SELECT	Count()
			FROM	Task
			WHERE	Status =: Constants.IN_PROGRESS_STATUS
		];
		System.assert(numberOfRecords == 1);
	}

	@isTest
	private static void testCheckActiveRecordsScheduler() {
		
		RecordType rt = [
			SELECT	Id
			FROM	RecordType
			WHERE	Name = 'Trade Ally'
		];
       
        Account a = new Account(
			Name = 'test account',
			Projects_Completed__c = 0,
			Business_Type__c = 'Contractor',
			Status__c = 'Active',
			Legal_Company_Name__c = 'test',
			Business_Structure__c = 'Other', 
			President_Owner_of_Company__c = 'test',
			RecordTypeId = rt.Id
		);
        insert a;
	
		Certification__c certification = new Certification__c(
			Expiry_Date__c = Date.today()
		);
		insert certification;

		Trade_Ally_Certification__c tac = new Trade_Ally_Certification__c(
			Certification__c = certification.Id,
			Trade_Ally__c = a.Id
		);
		insert tac;

		Insurance__c insurance = new Insurance__c(
			Expiry_Date__c = Date.today()
		);
		insert insurance;

		Trade_Ally_Insurance__c tai = new Trade_Ally_Insurance__c(
			Insurance__c = insurance.Id,
			Trade_Ally__c = a.Id
		);
		insert tai;

		License__c license = new License__c(
			Expiry_Date__c = Date.today()
		);
		insert license;

		Trade_Ally_License__c tal = new Trade_Ally_License__c(
			License__c = license.Id,
			Trade_Ally__c = a.Id
		);
		insert tal;
		
		Test.startTest();
			String checkActiveRecordsSchedulerId1 = CheckActiveRecordsScheduler.runMe();
			String checkActiveRecordsSchedulerId2 = CheckActiveRecordsScheduler.runMe();
			new CheckActiveRecordsScheduler().execute(null);
		Test.stopTest();

		Trade_Ally_Certification__c taCertification = [
			SELECT	Is_Active__c
			FROM	Trade_Ally_Certification__c
			WHERE	Certification__c =: certification.Id
		];
		System.assert(!taCertification.Is_Active__c);
	}
}