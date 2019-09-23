global class GetStripeInvoicesBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
	global static final Integer FREQUENCY_IN_DAYS = 1;
	global Database.QueryLocator start(Database.BatchableContext context) {
		String query = 'SELECT Id, ' +
				Constants.NAMESPACE + 'Customer__r.' +
				Constants.NAMESPACE + 'Stripe_Id__c, ' +
				Constants.NAMESPACE + 'Customer__c, ' +
				Constants.NAMESPACE + 'Stripe_Id__c FROM ' +
				Constants.NAMESPACE + 'Trade_Ally_Subscription__c ' +
				'WHERE ' + Constants.NAMESPACE + 'Stripe_Id__c != NULL';
		Database.QueryLocator ql;
		if (
				ESAPI.securityUtils().isAuthorizedToView(
						Constants.NAMESPACE + 'Trade_Ally_Subscription__c',
						new List<String>{
								'Id',
								Constants.NAMESPACE + 'Customer__c',
								Constants.NAMESPACE + 'Stripe_Id__c'
						}
				)&&
						ESAPI.securityUtils().isAuthorizedToView(
								'User',
								new List<String>{
										Constants.NAMESPACE + 'Stripe_Id__c'
								}
						)
				) {
			ql = Database.getQueryLocator(query);
		}
		return ql;
	}

	global void execute(Database.BatchableContext context, List<Trade_Ally_Subscription__c> scope) {
		Date today = Date.today();
		Date startDate = today.addDays(-FREQUENCY_IN_DAYS);
		Integer startDateUnix = StripeApiUtility.convertDateToUnix(startDate);
		List<Invoice__c> invoiceList = new List<Invoice__c>();
		for (Trade_Ally_Subscription__c tradeAllySubscription : scope) {
			String starting_after;
			List<Object> stripeInvoiceList = StripeApiUtility.getInvoices(tradeAllySubscription.Customer__r.Stripe_Id__c, tradeAllySubscription.Stripe_Id__c, starting_after, String.valueOf(startDateUnix));
			if(stripeInvoiceList == null) continue;
			while (Math.mod(stripeInvoiceList.size(), 10) == 0) {
				starting_after = (String) ((Map<String, Object>) stripeInvoiceList[stripeInvoiceList.size() - 1]).get('id');
				List<Object> additionalStripeInvoiceList = StripeApiUtility.getInvoices(tradeAllySubscription.Customer__r.Stripe_Id__c, tradeAllySubscription.Stripe_Id__c, String.valueOf(starting_after), String.valueOf(startDateUnix));
				if (additionalStripeInvoiceList.size() == 0) break;
				stripeInvoiceList.addAll(additionalStripeInvoiceList);
			}
			for (Object stripeInvoice : stripeInvoiceList) {
				Map<String, Object> invoiceMap = (Map<String, Object>) stripeInvoice;
				if ((String) invoiceMap.get('subscription') == tradeAllySubscription.Stripe_Id__c) {
					Invoice__c newInvoice = new Invoice__c(
							Trade_Ally_Subscription__c = tradeAllySubscription.Id,
							Customer__c = tradeAllySubscription.Customer__c,
							Invoice_Date__c = StripeApiUtility.convertDateFromUnix(Integer.valueOf(invoiceMap.get('date'))),
							Amount_Paid__c = (Decimal.valueOf((Integer)invoiceMap.get('amount_paid'))) / 100
					);
					invoiceList.add(newInvoice);
				}
			}

		}
		if (invoiceList.size() > 0) {
			ESAPI.securityUtils().validatedUpsert(invoiceList);
		}
	}

	global void finish(Database.BatchableContext context) {
	}
}