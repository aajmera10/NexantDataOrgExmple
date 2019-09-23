@IsTest
private class StripeApiUtilityTest {
	/*@TestSetup
	static void testSetup() {
		List<Stripe_Settings__c> stripeSettingList = new List<Stripe_Settings__c>();
		Stripe_Settings__c endpoint = new Stripe_Settings__c();
		endpoint.Name = 'Endpoint';
		endpoint.Value__c = 'Endpoint';
		stripeSettingList.add(endpoint);
		Stripe_Settings__c version = new Stripe_Settings__c();
		version.Name = 'Version';
		version.Value__c = 'Version';
		stripeSettingList.add(version);
		Stripe_Settings__c secretKey = new Stripe_Settings__c();
		secretKey.Name = 'SecretKey';
		secretKey.Value__c = 'SecretKey';
		stripeSettingList.add(secretKey);
		insert stripeSettingList;
	}*/

	@IsTest
	static void convertDateToUnixTest() {
		Date testDate =  Date.newInstance(1980, 1, 1);
		Integer unixDate = StripeApiUtility.convertDateToUnix(testDate);
		System.assertEquals(315532800, unixDate);
	}

	@IsTest
	static void convertDateFromUnixTest() {
		Integer testDate = 500000000;
		Date apexDate = StripeApiUtility.convertDateFromUnix(testDate);
		System.assertEquals(Date.newInstance(1985, 11, 05), apexDate);
	}



	@IsTest
	static void createCustomerTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		User currentUser = new User();
		currentUser.Email = 'rest@mail.com';
		String customerId;
		Test.startTest();
		Map<String, Object> customerMap = StripeApiUtility.createCustomer(currentUser);
		customerId =  (String) customerMap.get('id');
		System.assertEquals('testId', customerId);
		Test.stopTest();
	}

	@IsTest
	static void createCardTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String token = 'token';
		String customerId = 'customerId';
		Test.startTest();
		String cardId = StripeApiUtility.createCard(token, customerId);
		System.assertEquals('testId', cardId);
		Test.stopTest();
	}

	@IsTest
	static void createProductTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String productName = 'productName';
		Test.startTest();
		String productId = StripeApiUtility.createProduct(productName);
		System.assertEquals('testId', productId);
		Test.stopTest();
	}

	@IsTest
	static void createPlanTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String productId = 'productId';
		String amount = 'amount';
		Test.startTest();
		String planId = StripeApiUtility.createPlan(productId, amount);
		System.assertEquals('testId', planId);
		Test.stopTest();
	}

	@IsTest
	static void createSubscriptionTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String customerId = 'customerId';
		String planId = 'planId';
		Test.startTest();
		Map<String, Object> subscriptionMap = StripeApiUtility.createSubscription(customerId, planId);
		String subscriptionId = (String) subscriptionMap.get('id');
		System.assertEquals('testId', subscriptionId);
		Test.stopTest();
	}

	@IsTest
	static void getSubscriptionTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String subscriptionId = 'subscriptionId';
		Test.startTest();
		Map<String, Object> results = StripeApiUtility.getSubscription(subscriptionId);
		System.assertEquals('testId', results.get('id'));
		Test.stopTest();
	}

	@IsTest
	static void getCustomerTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String customerId = 'customerId';
		Test.startTest();
		Map<String, Object> results = StripeApiUtility.getCustomer(customerId);
		System.assertEquals('testId', results.get('id'));
		Test.stopTest();
	}

	@IsTest
	static void updateSubscriptionTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String planId = 'planId';
		String SubscriptionId = 'SubscriptionId';
		Test.startTest();
		Map<String, Object> results = StripeApiUtility.updateSubscription(planId, SubscriptionId);
		System.assertEquals('testId', results.get('id'));
		Test.stopTest();
	}

	@IsTest
	static void updateSubscriptionItemTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		String planId = 'planId';
		String SubscriptionItemId = 'SubscriptionItemId';
		Test.startTest();
		Map<String, Object> results = StripeApiUtility.updateSubscriptionItem(planId, SubscriptionItemId);
		System.assertEquals('testId', results.get('id'));
		Test.stopTest();
	}



	@IsTest
	static void getPlansTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();
		List<Object> results = StripeApiUtility.getPlans();
		System.assert(results != null);
		Test.stopTest();
	}

	@IsTest
	static void getProductsTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();
		List<Object>  results = StripeApiUtility.getProducts();
		System.assert(results != null);
		Test.stopTest();
	}

	@IsTest
	static void getInvoicesTest() {
		Test.setMock(HttpCalloutMock.class, new StripeHttpCalloutMock());
		Test.startTest();
		String customerId = 'customerId';
		String subscriptionId = 'subscriptionId';
		String starting_after = 'starting_after';
		String dateString = 'dateString';
		List<Object> results = StripeApiUtility.getInvoices(customerId,  subscriptionId,  starting_after,  dateString);
		System.assert(results != null);
		Test.stopTest();
	}



}