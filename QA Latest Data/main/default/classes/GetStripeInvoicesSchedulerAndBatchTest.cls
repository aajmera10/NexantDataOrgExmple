@IsTest
public with sharing class GetStripeInvoicesSchedulerAndBatchTest {

	@TestSetup
	public static void testSetup() {
			Trade_Ally_Subscription__c newAllySubscription = new Trade_Ally_Subscription__c(
					Stripe_Id__c = 'subscription'
			);
			insert newAllySubscription;

	}

	@IsTest
	public static void schedulerTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();
		String checkActiveRecordsSchedulerId1 = GetStripeInvoicesScheduler.runMe();
		new GetStripeInvoicesScheduler().execute(null);
		Test.stopTest();
		List<Invoice__c> invoices = [
				SELECT Id
				FROM Invoice__c
		];
		System.assertEquals(1, invoices.size());
	}


}