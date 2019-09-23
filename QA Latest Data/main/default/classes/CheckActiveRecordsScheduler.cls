global class CheckActiveRecordsScheduler implements Schedulable {
	 
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new ValidateActiveLicensesBatch());
		Database.executeBatch(new ValidateActiveCertificationsBatch());
		Database.executeBatch(new ValidateActiveInsurancesBatch());
	}

	private static String getTime() {
        String result = '0 0 1 * * ? *';
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
    	return System.schedule(Constants.ALERTS_SCHEDULER_NAME, getTime(), new CheckActiveRecordsScheduler());
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