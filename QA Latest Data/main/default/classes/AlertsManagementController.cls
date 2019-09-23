public with sharing class AlertsManagementController {

	private static List<User> getListOfAllCompanyUsers() {
		Id currentUserAccountId = StartApplicationController.getCurrentUserInfo().Contact.AccountId;
		List<User> listOfAllCompanyUsers = new List<User>();
		List<String> fieldsToCheck = new List<String>{'Id'};
		if (ESAPI.securityUtils().isAuthorizedToView('User',fieldsToCheck)) {
			listOfAllCompanyUsers = [
				SELECT	Id
				FROM	User
				WHERE	Contact.AccountId =: currentUserAccountId
			];
		}
		return listOfAllCompanyUsers;
	}
	
	@AuraEnabled
	public static Map<String,List<AlertsInfoWrapper>> prepareAllAlertsInfo() {
		Map<String,List<AlertsInfoWrapper>> mapOfAlertsInfo = new Map<String,List<AlertsInfoWrapper>>{
			'All' => new List<AlertsInfoWrapper>()
		};
		List<Task> listOfTasks = new List<Task>();
		List<String> fieldsToCheck = new List<String>{
			'Id',
			'ActivityDate',
			'Subject',
			'Description',
			'Status',
			'WhatId',
            'What.Name'
		};
		if (ESAPI.securityUtils().isAuthorizedToView('Task',fieldsToCheck)) {
			listOfTasks = [
				SELECT
							Id,
							ActivityDate,
							Subject,
							Description,
							Status,
							WhatId,
                			What.Name
				FROM		Task
				WHERE
							//OwnerId =: UserInfo.getUserId() AND
							OwnerId IN: getListOfAllCompanyUsers() AND
							Type =: Constants.ALERT_TYPE AND
							(
								Status =: Constants.ACTIVE_STATUS OR
								Status =: Constants.IN_PROGRESS_STATUS
							)
							//ActivityDate <=: Date.today()
				ORDER BY	ActivityDate ASC
			];
		}
		System.debug(listOfTasks);
		Map<String,String> mapOfRelatedIdStarts = new Map<String,String>();
		String tempStart;
		String tempSObjectName;
		for (Task t : listOfTasks) {
			tempStart = String.valueOf(t.WhatId).substring(0, 3);
			if (!mapOfRelatedIdStarts.containsKey(tempStart)) {
				tempSObjectName = t.WhatId.getSObjectType().getDescribe().getName().removeEnd('__c').removeStartIgnoreCase(Constants.NAMESPACE);
				mapOfRelatedIdStarts.put(
					tempStart,
					tempSObjectName
				);
				mapOfAlertsInfo.put(
					tempSObjectName,
					new List<AlertsInfoWrapper>()
				);
			}
			tempSObjectName = mapOfRelatedIdStarts.get(tempStart);
			System.debug(tempSObjectName);
			System.debug(mapOfAlertsInfo);
			mapOfAlertsInfo.get(tempSObjectName).add(new AlertsInfoWrapper(t));
			mapOfAlertsInfo.get('All').add(new AlertsInfoWrapper(t));
		}
		return mapOfAlertsInfo;
	}

	public class AlertsInfoWrapper {
		@AuraEnabled public Boolean isActive {get;set;}
		@AuraEnabled public Task alert {get;set;}
		@AuraEnabled public Boolean overdue {get;set;}

		public AlertsInfoWrapper(Task alert) {
			this.alert = alert;
			this.isActive = (alert.Status == Constants.ACTIVE_STATUS);
			this.overdue = (Date.today() >= alert.ActivityDate);
		}
	}

	@AuraEnabled
	public static void updateAlertStatus(String recordId, Boolean isActive) {
		List<Task> listOfTasks = new List<Task>();
		List<String> fieldsToCheck = new List<String>{'Id','Status'};
		if (ESAPI.securityUtils().isAuthorizedToView('Task',fieldsToCheck)) {
			listOfTasks = [
				SELECT
						Id,
						Status
				FROM	Task
				WHERE	Id =: recordId
			];
		}
		if (!listOfTasks.isEmpty()) {
			listOfTasks[0].Status = isActive ? Constants.ACTIVE_STATUS : Constants.IN_PROGRESS_STATUS;
			//ESAPI.securityUtils().validatedUpdate(listOfTasks);
			update listOfTasks;
		}
	}

	@AuraEnabled
	public static void deleteSelectedAlert(String recordId) {
		List<Task> listOfTasks = new List<Task>();
		List<String> fieldsToCheck = new List<String>{'Id','ActivityDate'};
		if (ESAPI.securityUtils().isAuthorizedToView('Task',fieldsToCheck)) {
			listOfTasks = [
				SELECT	
						Id,
						ActivityDate
				FROM	Task
				WHERE	Id =: recordId
			];
		}
		if (!listOfTasks.isEmpty()) {
			if (listOfTasks[0].ActivityDate == Date.today()) {
				//ESAPI.securityUtils().validatedDelete(listOfTasks);
				delete listOfTasks;
			} else {
				listOfTasks[0].Status = Constants.DEFERRED_STATUS;
				//ESAPI.securityUtils().validatedUpdate(listOfTasks);
				update listOfTasks;
			}
		}
	}
}