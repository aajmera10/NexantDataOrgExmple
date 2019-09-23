global with sharing class StripeApiUtility {
	public static final Date DATE_OF_START_OF_WORLD = Date.newInstance(1970, 1, 1);
	public static Stripe_Settings_Object__mdt stripeSettings;

	public static Date convertDateFromUnix(Integer unixDate) {
		Integer countOfDays = unixDate / (3600 * 24);
		Date apexDate = DATE_OF_START_OF_WORLD.addDays(countOfDays);
		return apexDate;
	}

	public static Integer convertDateToUnix(Date apexDate) {
		Integer countOfDays = DATE_OF_START_OF_WORLD.daysBetween(apexDate);
		Integer unixDate = countOfDays * 3600 * 24;
		return unixDate;
	}

	private static void getStripeSettings() {
		if(stripeSettings != null) return;
		List<Stripe_Settings_Object__mdt> stripeSettingsObjects;
		if (ESAPI.securityUtils().isAuthorizedToView('Stripe_Settings_Object__mdt', new List<String>{
				'Id', 'CommunityDomain__c', 'Endpoint__c', 'PublicKey__c', 'SecretKey__c', 'Version__c'
		})) {
			stripeSettingsObjects = [
				SELECT	
						Id,
						CommunityDomain__c,
						Endpoint__c,
						PublicKey__c,
						SecretKey__c,
						Version__c
				FROM	Stripe_Settings_Object__mdt
				LIMIT	50000
			];
		}
		if(stripeSettingsObjects.size() > 0){
			stripeSettings = stripeSettingsObjects[0];
		}
	}


	public static String createCard(String token, String customerId) {
		List<String> paramsList = new List<String>();
		paramsList.add('source=' + token);
		String method = 'POST';
		if(stripeSettings == null){
			getStripeSettings();
		}
		String endPoint = stripeSettings.Endpoint__c + '/' + stripeSettings.Version__c + '/' + 'customers/' + customerId + '/sources' + '?';
		for (Integer i = 0, j = paramsList.size(); i < j; i++) {
			String param = paramsList[i].replaceAll(' ', '%20');
			endPoint = endPoint + param + '&';
		}
		HttpResponse response = httpRequestHandler(endPoint, method);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		String cardId = (String) results.get('id');
		return cardId;
	}


	public static Map<String, Object> createCustomer(User currentUser) {
		List<String> paramsList = new List<String>();
		paramsList.add('email=' + currentUser.Email);
		String objectName = 'customer';
		String method = 'POST';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return results;
	}


	public static String createProduct(String productName) {
		List<String> paramsList = new List<String>();
		paramsList.add('name=' + productName);
		paramsList.add('type=service');
		String objectName = 'product';
		String method = 'POST';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		String productId = (String) results.get('id');
		return productId;
	}

	public static String createPlan(String productId, String amount) {
		List<String> paramsList = new List<String>();
		paramsList.add('interval=month');
		paramsList.add('currency=usd');
		paramsList.add('product=' + productId);
		paramsList.add('amount=' + amount + '00');
		String objectName = 'plan';
		String method = 'POST';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		String planId = (String) results.get('id');
		return planId;
	}

	public static Map<String, Object> createSubscription(String customerId, String planId) {
		List<String> paramsList = new List<String>();
		paramsList.add('customer=' + customerId);
		paramsList.add('items[0][plan]=' + planId);
		String objectName = 'subscription';
		String method = 'POST';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return results;
	}

	public static Map<String, Object> getSubscription(String subscriptionId) {
		List<String> paramsList = new List<String>();
		String objectName = 'subscription';
		String method = 'GET';
		HttpResponse response = objectHandler(paramsList, objectName, method, subscriptionId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return results;
	}


	public static Map<String, Object> getCustomer(String customerId) {
		List<String> paramsList = new List<String>();
		String objectName = 'customer';
		String method = 'GET';
		HttpResponse response = objectHandler(paramsList, objectName, method, customerId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return results;
	}


	public static Map<String, Object> updateSubscription(String planId, String subscriptionId) {
		List<String> paramsList = new List<String>();
		paramsList.add('items[0][plan]=' + planId);
		String objectName = 'subscription';
		String method = 'POST';
		HttpResponse response = objectHandler(paramsList, objectName, method, subscriptionId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return results;
	}

	public static Map<String, Object> updateSubscriptionItem(String planId, String subscriptionItemId) {
		List<String> paramsList = new List<String>();
		paramsList.add('plan=' + planId);
		String objectName = 'subscription_item';
		String method = 'POST';
		HttpResponse response = objectHandler(paramsList, objectName, method, subscriptionItemId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		return results;
	}




	public static List<Object> getPlans() {
		List<String> paramsList = new List<String>();
		paramsList.add('limit=100');
		String objectName = 'plan';
		String method = 'GET';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, String> planMap = new Map<String, String>();
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> resultList = (List<Object>) results.get('data');
		for (Object obj : resultList) {
			Map<String, Object> objString = (Map<String, Object>) obj;
			planMap.put('product', (String) objString.get('product'));
			planMap.put('active', String.valueOf(objString.get('active')));
			planMap.put('amount', String.valueOf(objString.get('amount')));
			planMap.put('interval', (String) objString.get('interval'));
		}
		return resultList;
	}

	public static List<Object> getSubscriptionItems( String subscriptionId) {
		List<String> paramsList = new List<String>();
		paramsList.add('limit=100');
		paramsList.add('subscription=' + subscriptionId);
		String objectName = 'subscription_item';
		String method = 'GET';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, String> subscriptionItemsMap = new Map<String, String>();
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> resultList = (List<Object>) results.get('data');
		for (Object obj : resultList) {
			Map<String, Object> objString = (Map<String, Object>) obj;
			subscriptionItemsMap.put('id', (String) objString.get('id'));
		}
		return resultList;
	}



	public static List<Object> getProducts() {
		List<String> paramsList = new List<String>();
		paramsList.add('limit=100');
		String objectName = 'product';
		String method = 'GET';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, String> productMap = new Map<String, String>();
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> resultList = (List<Object>) results.get('data');
		for (Object obj : resultList) {
			Map<String, Object> objString = (Map<String, Object>) obj;
			productMap.put('name', (String) objString.get('name'));
		}
		return resultList;
	}

	public static List<Object> getInvoices(String customerId, String subscriptionId, String starting_after, String dateString) {
		List<String> paramsList = new List<String>();
		paramsList.add('limit=10');
		if(customerId != null){
			paramsList.add('customer=' + customerId);
		}
		if(customerId != null){
			paramsList.add('subscription=' + subscriptionId);
		}
		if(starting_after != null){
			paramsList.add('starting_after=' + starting_after);
		}
		if(dateString != null){
			paramsList.add('date[gte=' + dateString);
		}
		String objectName = 'invoice';
		String method = 'GET';
		String objectId;
		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
		List<Object> resultList = (List<Object>) results.get('data');
		return resultList;
	}


	private static HttpResponse objectHandler(List<String> paramsList, String objectName, String method, String objectId) {
		String endPoint;
		if (objectId != null) {
			endPoint = createEndPoint(objectName, objectId);
		}
		else {
			endPoint = createEndPoint(objectName);
		}
		for (Integer i = 0, j = paramsList.size(); i < j; i++) {
			String param = paramsList[i].replaceAll(' ', '%20');
			endPoint = endPoint + param + '&';
		}
		HttpResponse response = httpRequestHandler(endPoint, method);
		return response;
	}

	private static HttpResponse httpRequestHandler(String endPoint, String method) {
		if(stripeSettings == null){
			getStripeSettings();
		}
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endPoint);
		request.setMethod(method);
		String userName = stripeSettings.SecretKey__c;
		String password;
		Blob headerValue = Blob.valueOf(userName + ':' + password);
		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
		request.setHeader('Authorization', authorizationHeader);
		request.setHeader('Cache-Control', 'no-cache');
		HttpResponse response = http.send(request);
		return response;
	}

	private static String createEndPoint(String objectName) {
		if(stripeSettings == null){
			getStripeSettings();
		}		String endPoint = stripeSettings.Endpoint__c + '/' + stripeSettings.Version__c + '/' + objectName + 's?';
		return endPoint;
	}

	private static String createEndPoint(String objectName, String objectId) {
		if(stripeSettings == null){
			getStripeSettings();
		}
		String endPoint = stripeSettings.Endpoint__c + '/' + stripeSettings.Version__c + '/' + objectName + 's' + '/' + objectId + '?';
		return endPoint;
	}

//	public static void updateCustomer(User currentUser, String customerId) {
//		List<String> paramsList = new List<String>();
//		paramsList.add('email=' + currentUser.Email);
//		paramsList.add('source=');
//		String objectName = 'customer';
//		String method = 'POST';
//		Map<String, Stripe_Settings__c> settingsMap = Stripe_Settings__c.getall();
//		String endPoint = settingsMap.get('Endpoint').Value__c + '/' + settingsMap.get('Version').Value__c + '/' + objectName + 's' + '/' + customerId + '?';
//		String userName = settingsMap.get('SecretKey').Value__c;
//		for (Integer i = 0, j = paramsList.size(); i < j; i++) {
//			String param = paramsList[i].replaceAll(' ', '%20');
//			endPoint = endPoint + param + '&';
//		}
//		Http http = new Http();
//		HttpRequest request = new HttpRequest();
//		request.setEndpoint(endPoint);
//		request.setMethod(method);
//		String password;
//		Blob headerValue = Blob.valueOf(userName + ':' + password);
//		String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
//		request.setHeader('Authorization', authorizationHeader);
//		request.setHeader('Cache-Control', 'no-cache');
//		HttpResponse response = http.send(request);
//		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
//		System.debug('productMap.get sources ' + results.get('sources'));
//		System.debug('productMap.get id ' + results.get('id'));
//	}

//	public static Map<String, Object> getCustomer(String customerId) {
//		List<String> paramsList = new List<String>();
//		String objectName = 'customer';
//		String method = 'GET';
//		HttpResponse response =objectHandler(paramsList, objectName, method, customerId);
//		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
//		return results;
//	}


//	public static void createCharge(Decimal amount) {
//		List<String> paramsList = new List<String>();
//		paramsList.add('amount=' + amount);
//		paramsList.add('currency=usd');
//		String objectName = 'charge';
//		String method = 'POST';
//		System.debug(objectHandler(paramsList, objectName, method).getStatus());
//	}

//	public static Map<String, String> getCustomers() {
//		List<String> paramsList = new List<String>();
//		paramsList.add('limit=100');
//		String objectName = 'customer';
//		String method = 'GET';
//		String objectId;
//		HttpResponse response = objectHandler(paramsList, objectName, method, objectId);
//		Map<String, String> productMap = new Map<String, String>();
//		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
//		List<Object> resultList = (List<Object>) results.get('data');
//		for (Object obj : resultList) {
//			Map<String, Object> objString = (Map<String, Object>) obj;
//			productMap.put((String) objString.get('email'), (String) objString.get('id'));
//		}
//		return productMap;
//	}


}