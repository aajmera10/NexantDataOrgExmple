public with sharing class CommunicationHistoryController {

	@AuraEnabled
	public static List<Task> getCommunicationHistoryResults() {
		List<Task> communicationHistoryResults = new List<Task>();
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				'Task',
				new List<String>{
					'Id',
					'ActivityDate',
					'WhoId',
					'WhatId',
					'OwnerId',
					'Type',
					'Subject',
					'Description'
				}
			)
		) {
			communicationHistoryResults = [
				SELECT  
						Id,
						ActivityDate,
						Who.Name,
						What.Name,
						Owner.Name,
						Type,
						Subject,
						Description
				FROM	Task 
				WHERE   Type != 'Alert' 
				LIMIT   50000
			];
		}
		return communicationHistoryResults;
	}

}