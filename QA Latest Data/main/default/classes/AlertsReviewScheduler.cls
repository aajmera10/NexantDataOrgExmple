global class AlertsReviewScheduler implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new AlertsReviewBatch());
		Database.executeBatch(new AlertsEmailsBatch());
	}

	private static String getTime() {
        String result = '0 0 7 * * ? *';
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
    	return System.schedule(Constants.ALERTS_SCHEDULER_NAME, getTime(), new AlertsReviewScheduler());
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
    			WHERE	CronJobDetail.Name =: Constants.ALERTS_SCHEDULER_NAME
			];
		}
    	if (!lSobj.isEmpty()) {
    		result = lSobj.get(0).Id;
    	}
    	return result;
    }
}