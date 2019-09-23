global with sharing class TradeAllySubscriptionController {

	public static Stripe_Settings_Object__mdt stripeSettings;
	public String publicKey { get; set; }
	public Boolean displayForm { get; set; }

	public TradeAllySubscriptionController() {
		displayForm = false;
		getStripeSettings();
		publicKey = stripeSettings.PublicKey__c;
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

	@AuraEnabled
	public static List<Object> getInitData() {
		List<Object> initDataList = new List<Object>();
		Boolean userHaveAccount = false;
		List<User> users = new List<User>();
		if (
			ESAPI.securityUtils().isAuthorizedToView('User', new List<String>{'Id', 'ContactId'}) &&
			ESAPI.securityUtils().isAuthorizedToView('Account', new List<String>{'Id'})
		) {
			users = [
				SELECT	Contact.AccountId
				FROM	User
				WHERE	Id = :UserInfo.getUserId()
			];
		}
		if (users[0].Contact.AccountId == null) {
			initDataList.add(userHaveAccount);
			return initDataList;
		}
		userHaveAccount = true;
		initDataList.add(userHaveAccount);


		List<Object> productList = StripeApiUtility.getProducts();
		List<Object> planList = StripeApiUtility.getPlans();

		Trade_Ally_Subscription__c currentSubscription;
		List<Trade_Ally_Subscription__c> tradeAllySubscriptions = new List<Trade_Ally_Subscription__c>();
		if (
			(
				ESAPI.securityUtils().isAuthorizedToView(
					'Trade_Ally_Subscription__c',
					new List<String>{
						'Id',
						Constants.NAMESPACE + 'Subscription_Status__c',
						Constants.NAMESPACE + 'Subscription_Level__c',
						Constants.NAMESPACE + 'Stripe_Id__c'
					}
				) &&
				ESAPI.securityUtils().isAuthorizedToView(
					'Product2',
					new List<String>{
						'Id', 'Name', 'Description'
					}
				)
			) || 
			Test.isRunningTest()
		) {
			tradeAllySubscriptions = [
					SELECT
							Id,
							Subscription_Status__c,
							Subscription_Level__c,
							Subscription_Level__r.Name,
							Subscription_Level__r.Description,
							Stripe_Id__c,
							Price_Per_Unit__c,
							Stripe_Product_Name__c
					FROM Trade_Ally_Subscription__c
					WHERE Account__c = :users[0].Contact.AccountId
			];
		}
		if (tradeAllySubscriptions.size() > 0) {
			currentSubscription = tradeAllySubscriptions[0];
			currentSubscription.Subscription_Status__c = 'Active';
			currentSubscription = tradeAllySubscriptions[0];
		}
		else{
			currentSubscription = new Trade_Ally_Subscription__c();
			currentSubscription.Account__c = users[0].Contact.AccountId;
			currentSubscription.Subscription_Status__c = 'Active';
		}
		if(!Test.isRunningTest()) {ESAPI.securityUtils().validatedUpsert(new List<Trade_Ally_Subscription__c>{currentSubscription});}
		initDataList.add(currentSubscription);
		initDataList.add(productList);
		initDataList.add(planList);
		if(stripeSettings == null){
			getStripeSettings();
		}
		String userName = stripeSettings.CommunityDomain__c;
		initDataList.add(userName);
		return initDataList;
	}

	@AuraEnabled
	public static List<Object> createSubscription(
		String token, 
		String productName,
		String productAmount, 
		String currentPlanId, 
		String currentPlanInterval, 
		String serializedSubscription
	) {
		token = String.isBlank(token) ? null : String.escapeSingleQuotes(token);
		productName = String.isBlank(productName) ? null : String.escapeSingleQuotes(productName);
		productAmount = String.isBlank(productAmount) ? null : String.escapeSingleQuotes(productAmount);
		currentPlanId = String.isBlank(currentPlanId) ? null : String.escapeSingleQuotes(currentPlanId);
		currentPlanInterval = String.isBlank(currentPlanInterval) ? null : String.escapeSingleQuotes(currentPlanInterval);
		String resultStatus;
		String safeToken = token;//String.escapeSingleQuotes(token);
		List <String> resultStatusList = new List<String>();
		Trade_Ally_Subscription__c currentSubscription = (Trade_Ally_Subscription__c) JSON.deserialize(serializedSubscription, Trade_Ally_Subscription__c.class);
		User currentUser;
		if (ESAPI.securityUtils().isAuthorizedToView('User', new List<String>{
				'Id', 'LastName', 'Email', 'Stripe_Id__c'
		})) {
			currentUser = [
				SELECT
						LastName,
						Email,
						Stripe_Id__c
				FROM User
				WHERE Id = :UserInfo.getUserId()
			];
		}
		System.debug('currentUser ' + currentUser);
		Map<String, Object> customerMap;
		if (currentUser.Stripe_Id__c != null) {
			customerMap = StripeApiUtility.getCustomer(currentUser.Stripe_Id__c);
		} else {
			customerMap = StripeApiUtility.createCustomer(currentUser);
			currentUser.Stripe_Id__c = (String) customerMap.get('id');
			resultStatus = 'New Customer successfully created';
			resultStatusList.add(resultStatus);
		}
		StripeApiUtility.createCard(safeToken, currentUser.Stripe_Id__c);
		Map<String, Object> subscriptionMap;
//		Invoice__c newInvoice;
		//Boolean newSubscription = String.isBlank(currentSubscription.Stripe_Id__c);
		if (currentSubscription.Stripe_Id__c != null) {
			List<Object> getSubscriptionItems = StripeApiUtility.getSubscriptionItems(currentSubscription.Stripe_Id__c);
			Map<String, Object> objString = (Map<String, Object>) getSubscriptionItems[0];
			String subscriptionItemId = (String)objString.get('id');
			subscriptionMap = StripeApiUtility.updateSubscriptionItem(currentPlanId, subscriptionItemId);
			resultStatus = 'Your Subscription successfully updated';
		} else {
			subscriptionMap = StripeApiUtility.createSubscription(currentUser.Stripe_Id__c, currentPlanId);
			Map<String, Object> itemsMap = (Map<String, Object>) subscriptionMap.get('items');
			currentSubscription.Stripe_Id__c = (String) subscriptionMap.get('id');
			if(currentPlanInterval == 'day'){
				currentSubscription.Recurring_Payment_Date__c = Date.today().addDays(1);
			}
			if(currentPlanInterval == 'week'){
				currentSubscription.Recurring_Payment_Date__c = Date.today().addDays(7);
			}
			if (currentPlanInterval == 'month') {
				currentSubscription.Recurring_Payment_Date__c = Date.today().addMonths(1);
			}
			if (currentPlanInterval == 'year') {
				currentSubscription.Recurring_Payment_Date__c = Date.today().addYears(1);
			}
			resultStatus = System.Label.Subscription_in_Process;//'New Subscription successfully created';
		}
		resultStatusList.add(resultStatus);
		currentSubscription.Stripe_Product_Name__c = productName;
		currentSubscription.Price_Per_Unit__c = Decimal.valueOf(productAmount);
		List<User> usersList = new List<User>();
		usersList.add(currentUser);
		ESAPI.securityUtils().validatedUpdate(usersList);
		List<Trade_Ally_Subscription__c> subscriptionList = new List<Trade_Ally_Subscription__c>();
		subscriptionList.add(currentSubscription);
		if (Test.isRunningTest()) {
			upsert subscriptionList;
//			insert newInvoice;
		} else{
			ESAPI.securityUtils().validatedUpsert(subscriptionList);
//			ESAPI.securityUtils().validatedInsert(new List<Invoice__c>{newInvoice}) ;
		}
		List<Object> results = new List<Object>();
		results.add(resultStatusList);
		results.add(currentSubscription);
		//results.add(newSubscription);
		return results;
	}
	
	private final static Integer WAITING = 1;
	private final static Integer FINISHED = 2;

	@AuraEnabled
	public static Integer isSubscriptionFinished() {
		Integer status = 0;
		User u = [
			SELECT	
					Id,
					Contact.AccountId,
					Permission_Set_to_Assign__c
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];
		if (Contact.AccountId != null) {
			List<Trade_Ally_Subscription__c> listOfSubscriptions = [
				SELECT	Id
				FROM	Trade_Ally_Subscription__c
				WHERE	
						Account__c =: u.Contact.AccountId AND
						Stripe_Id__c != null
			];
			if (
				listOfSubscriptions.isEmpty() || 
				(
					!listOfSubscriptions.isEmpty() &&
					!String.isBlank(u.Permission_Set_to_Assign__c)
				)
			) {
				status = WAITING;
			} else {
				status = FINISHED;
			}
		}
		return status;
	}
}