global with sharing class GetStripeInvoicesScheduler implements Schedulable{
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new GetStripeInvoicesBatch());
	}

	private static String getTime() {
		String result = '0 0 2 * * ? *';
		return result;
	}

	global static String runMe() {
		String result = getSchedulerID();
		if (result == null){
			result = startScheduler();
		}
		return result;
	}

	private static String startScheduler() {
		return System.schedule(Constants.STRIPE_INVOICES_SCHEDULER_NAME, getTime(), new GetStripeInvoicesScheduler());
	}

	private static String getSchedulerID(){
		String result;
		List<SObject> lSobj = new List<SObject>();
		if (
				ESAPI.securityUtils().isAuthorizedToView(
						'CronTrigger',
						new List<String>{
								'Id'
						}
				)
				) {
			lSobj = [
					SELECT	Id
					FROM	CronTrigger
					WHERE	CronJobDetail.Name =: Constants.STRIPE_INVOICES_SCHEDULER_NAME
			];
		}
		if (!lSobj.isEmpty()) {
			result = lSobj.get(0).Id;
		}
		return result;
	}
}