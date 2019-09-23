global class AlertsReviewBatch implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		String query = 'SELECT Id, ActivityDate, Status FROM Task WHERE Type = \'Alert\' AND (';
		query += getDatesBasedPartOfQuery(Constants.ALERTS_INCURANCE_SHOW,'Insurance') + ' OR ';
		query += getDatesBasedPartOfQuery(Constants.ALERTS_LICENSE_SHOW,'License') + ' OR ';
		query += getDatesBasedPartOfQuery(Constants.ALERTS_CERTIFICATION_SHOW,'Certification') + ' OR ';
		String comparationDateStr = Datetime.newInstance(
			Date.today(),
			Time.newInstance(0, 0, 0, 0)
		).format('YYYY-MM-dd');
		query += 'ActivityDate = ' + comparationDateStr + ') AND ' +
					'Status != \'' + Constants.ACTIVE_STATUS + '\' AND ' +
					'Status != \'' + Constants.IN_PROGRESS_STATUS + '\'';
		System.debug(query);
		Database.QueryLocator ql;
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				'Task',
				new List<String>{
					'Id',
					'ActivityDate',
					'Status'
				}
			)
		) {
			ql = Database.getQueryLocator(query);
		}
		return ql;
	}

	public static Set<Integer> getSetOfDates(String recordName) {
		Set<Integer> setOfDates = new Set<Integer>();
		Application_Settings__c applicationSettings = Application_Settings__c.getValues(recordName);
		if (
			applicationSettings != null && 
			applicationSettings.Value__c != null && 
			applicationSettings.Value__c.trim() != ''
		) {
			for (String value : applicationSettings.Value__c.split(',')) {
				if (value.trim().isNumeric()) {
					setOfDates.add(
						Integer.valueOf(
							value.trim()
						)
					);
				}
			}
		}
		if (setOfDates.isEmpty()) {
			setOfDates.addAll(Constants.DEFAULT_ALERTS_DAYS);
		}
		return setOfDates;
	}

	private String getDatesBasedPartOfQuery(String recordName, String typeOfObject) {
		String query = '((';
		Date today = Date.today();
		Datetime comparationDate;
		for (Integer days : getSetOfDates(recordName)) {
			comparationDate = Datetime.newInstance(
				today.addDays(days),
				Time.newInstance(0, 0, 0, 0)
			);
			//query += 'ActivityDate = \'' + comparationDate.format() + '\' OR ';
			query += 'ActivityDate = ' + comparationDate.format('YYYY-MM-dd') + ' OR ';
		}
		return query.removeEnd(' OR ') + ') AND Subject LIKE \'' + String.escapeSingleQuotes(typeOfObject) + '%\')';
	}

   	global void execute(Database.BatchableContext context, List<Task> scope) {
		System.debug(scope);
		List<Messaging.SingleEmailMessage> listOfEmails = new List<Messaging.SingleEmailMessage>();
		for (Task alert : scope) {
			alert.Status = Constants.IN_PROGRESS_STATUS;
		}
		ESAPI.securityUtils().validatedUpdate(scope);
	}
	
	global void finish(Database.BatchableContext context) {
	}
}