public with sharing class GenerateAlertsController {
 
	public static void generateAlerts(Map<Id,sObject> scope, String expirationDateFieldApi, String typeOfSObject) {
		List<Task> listOfNewTasks = new List<Task>();
		List<Task> existingTasks = new List<Task>();
		List<String> fieldsToCheck = new List<String>{'Id','WhatId','ActivityDate'};
		if (ESAPI.securityUtils().isAuthorizedToView('Task',fieldsToCheck)) {
			existingTasks = [
				SELECT 
						Id, 
						WhatId, 
						ActivityDate 
				FROM	Task 
				WHERE	WhatId IN: scope.keySet()
			];
		}
		Map<Id,Task> mapOfTasksByWhatId = new Map<Id,Task>();
		for (Task t : existingTasks) {
			mapOfTasksByWhatId.put(
				t.WhatId,
				t
			);
		}
		Task tempTask;
		for (Id recordId : scope.keySet()) {
			//recordId = (Id)record.get('Id');
			if (mapOfTasksByWhatId.containsKey(recordId)) {
				tempTask = mapOfTasksByWhatId.get(recordId);
			} else {
               /*if (Schema.sObjectType.Task.fields.Type.isCreateable() &&  Schema.sObjectType.Task.fields.Type.isUpdateable() &&
                   Schema.sObjectType.Task.fields.Subject.isCreateable() &&  Schema.sObjectType.Task.fields.Subject.isUpdateable() &&
                   Schema.sObjectType.Task.fields.Priority.isCreateable() &&  Schema.sObjectType.Task.fields.Priority.isUpdateable() &&
                   Schema.sObjectType.Task.fields.Description.isCreateable() &&  Schema.sObjectType.Task.fields.Description.isUpdateable() &&
                   Schema.sObjectType.Task.fields.OwnerId.isCreateable() &&  Schema.sObjectType.Task.fields.OwnerId.isUpdateable() &&
                   Schema.sObjectType.Task.fields.Status.isCreateable() &&  Schema.sObjectType.Task.fields.Status.isUpdateable() &&
                   Schema.sObjectType.Task.fields.WhatId.isCreateable() &&  Schema.sObjectType.Task.fields.WhatId.isUpdateable()) { */
                    tempTask = new Task(
                        Type = Constants.ALERT_TYPE,
                        Subject = typeOfSObject + ' Expiration Alert',
                        Priority = 'Normal',
                        Description = Constants.ALERT_TYPE,
                        OwnerId = (Id) scope.get(recordId).get('ownerId'),
                        //OwnerId = UserInfo.getUserId(),
                        Status = Constants.NOT_STARTED_STATUS,
                        WhatId = recordId
                    );
               //}
			}
            if(tempTask != null) {
                //if (Schema.sObjectType.Task.fields.ActivityDate.isCreateable() &&  Schema.sObjectType.Task.fields.ActivityDate.isUpdateable()) {
                    tempTask.ActivityDate = (Date)scope.get(recordId).get(expirationDateFieldApi);
                //}
                //if (Schema.sObjectType.Task.fields.Status.isCreateable() &&  Schema.sObjectType.Task.fields.Status.isUpdateable()) {
                    tempTask.Status = tempTask.ActivityDate == Date.today() ? Constants.IN_PROGRESS_STATUS : Constants.NOT_STARTED_STATUS;
                //}
                listOfNewTasks.add(tempTask);
            }
		}
		/*if(Schema.sObjectType.Task.isUpdateable() && Schema.sObjectType.Task.isCreateable())
        {*/
            upsert listOfNewTasks;
        	System.debug('Upserted!!!');
        //}
		/*Schema.SObjectType sObjectType = scope.getSObjectType();
		if (sObjectType != null) {
			Map<Integer, Task> alerts = new Map<Integer, Task>();
			Map<Id, Integer> alertIds = new Map<Id, Integer>();
			//Convert type to upsert records dynamically
			String scopeType = 'List<' + sObjectType + '>';
			List<SObject> convertedScope = (List<SObject>)Type.forName(scopeType).newInstance();
			convertedScope.addAll(scope);
			for (Integer i = 0; i < convertedScope.size(); i++) {
				//If Expiry Date is not null, create the record
				if (convertedScope[i].get(expirationDateFieldApi) != null) {
					//If Alert lookup field is not empty, create new record for Alert custom object, otherwise modify the related Alert
					if (convertedScope[i].get(alertFieldApi) == null) {
						Task alert = new Task(
						    ActivityDate = Date.valueOf(convertedScope[i].get(expirationDateFieldApi))
						);
						alerts.put(i, alert);
					} else {
						alertIds.put(String.valueOf(convertedScope[i].get(alertFieldApi)), i);
					}
				}
			}
			//If related alerts are existed, modify its Expiration Date
			if (!alertIds.isEmpty()) {
				List<Task> existingAlerts = [
                    SELECT 	Id,
                    		ActivityDate
                    FROM 	Task
                    WHERE 	Id IN :alertIds.keySet()
                    LIMIT 	50000
                ];
				for (Task existingAlert : existingAlerts) {
					if (alertIds.containsKey(existingAlert.Id)) {
						Integer count = alertIds.get(existingAlert.Id);
						existingAlert.ActivityDate = Date.valueOf(convertedScope[count].get(expirationDateFieldApi));
						alerts.put(count, existingAlert);
					}
				}
			}
			//Create records for alerts
			if (!alerts.isEmpty()) {
				upsert alerts.values();
				//Match related alerts with new records
				for (Integer i = 0; i < convertedScope.size(); i++) {
					if (alerts.containsKey(i)) {
						convertedScope[i].put(alertFieldApi, alerts.get(i).Id);
					}
				}
			}
		}*/
	}

}