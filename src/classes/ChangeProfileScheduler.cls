global class ChangeProfileScheduler implements Schedulable {

	private final static List<Integer> listOfMinutes = new List<Integer>{
		5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55
	};
	
	global void execute(SchedulableContext sc) {
		System.debug('execute');
		Database.executeBatch(new ChangeProfileBatch());
		System.abortJob(getSchedulerID());
		startScheduler();
	}

	private static String getTime() {
		Integer minute = DateTime.now().minute();
		Integer finalMinute = 0;
		for (Integer m : listOfMinutes) {
			if (minute < m) {
				finalMinute = m;
				break;
			}
		}
        String result = '0 ' + finalMinute + ' * * * ? *';
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
    	return System.schedule('ChangeProfileScheduler', getTime(), new ChangeProfileScheduler());
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
    			WHERE	CronJobDetail.Name = 'ChangeProfileScheduler'
			];
		}
    	if (!lSobj.isEmpty()) {
    		result = lSobj.get(0).Id;
    	}
    	return result;
    }
}