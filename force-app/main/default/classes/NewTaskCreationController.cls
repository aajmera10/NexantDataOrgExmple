public with sharing class NewTaskCreationController {
	
	@AuraEnabled
	public static LogInfoWrapper getWrappedLogInfo(String accountId) {
		accountId = String.isBlank(accountId) ? null : String.escapeSingleQuotes(accountId);
		List<Contact> listOfContacts = new List<Contact>();
		List<String> fieldsToCheck = new List<String>{'Id','Name'};
		if (ESAPI.securityUtils().isAuthorizedToView('Contact',fieldsToCheck)) {
			listOfContacts = [
				SELECT
						Id,
						Name
				FROM	Contact
				WHERE	AccountId =: accountId
			];
		}
		return new LogInfoWrapper(listOfContacts, accountId);
	}

	@AuraEnabled
	public static void createNewLog(String wrappedLogInfoJSON) {
		LogInfoWrapper wrappedLogInfo = (LogInfoWrapper)JSON.deserialize(wrappedLogInfoJSON,LogInfoWrapper.class);
		System.debug(wrappedLogInfo);
		System.debug(wrappedLogInfo.log);
		Task newTask = (Task)WrappedInfoParser.parseWrapperToFields(
			wrappedLogInfo.log,
			wrappedLogInfo.listOfTaskFields
		);
		System.debug(newTask);
		if (Test.isRunningTest()) {
			newTask.Status = 'Not Started';
			newTask.Priority = 'High';
		}
		//ESAPI.securityUtils().validatedInsert(new List<Task>{newTask});
		insert newTask;

		List<TaskRelation> assignments = new List<TaskRelation>();
		for (ContactInfoWrapper wrappedContact : wrappedLogInfo.wrappedContacts) {
			if (wrappedContact.selected) {
				System.debug(wrappedContact.tradeAllyUser.Id);
				assignments.add(
					new TaskRelation(
						RelationId = wrappedContact.tradeAllyUser.Id,
						TaskId = newTask.Id
					)
				);
			}
		}
		//ESAPI.securityUtils().validatedInsert(assignments);
		insert assignments;
		/*List<Log_Assignment__c> assignments = new List<Log_Assignment__c>();
		System.debug(wrappedLogInfo.log.Id);
		for (ContactInfoWrapper wrappedContact : wrappedLogInfo.wrappedContacts) {
			if (wrappedContact.selected) {
				System.debug(wrappedContact.tradeAllyUser.Id);
				assignments.add(
					new Log_Assignment__c(
						Contact__c = wrappedContact.tradeAllyUser.Id,
						Log__c = wrappedLogInfo.log.Id
					)
				);
			}
		}
		ESAPI.securityUtils().validatedInsert(assignments);*/
	}

	public class LogInfoWrapper {
		@AuraEnabled public Task log {get;set;}
		@AuraEnabled public List<FieldInfoWrapper> listOfTaskFields {get;set;}
		//@AuraEnabled public List<FieldInfoWrapper.PickListWrapper> picklistValues {get;set;}
		@AuraEnabled public List<ContactInfoWrapper> wrappedContacts {get;set;}

		public LogInfoWrapper(List<Contact> listOfContacts, String accountId) {
			log = new Task(
				OwnerId = UserInfo.getUserId()
			);
			listOfTaskFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
				SObjectType.Task.FieldSets.Log_Management_Fields.getFields(),
				log
			);
			for (FieldInfoWrapper info : listOfTaskFields) {
				info.editable = true;
			}
			/*picklistValues = new List<FieldInfoWrapper.PickListWrapper>();
			Schema.DescribeFieldResult fieldResult = Log__c.Type__c.getDescribe();
			for (Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()) {
				picklistValues.add(
					new FieldInfoWrapper.PickListWrapper(
						pickListVal.getValue(),
						pickListVal.getLabel(),
						false,
						null
					)
				);
			}
			log = new Log__c(
				Trade_Ally__c = accountId
			);*/

			wrappedContacts = new List<ContactInfoWrapper>();
			for (Contact c : listOfContacts) {
				wrappedContacts.add(
					new ContactInfoWrapper(c)
				);
			}
		}
	}

	public class ContactInfoWrapper {
		@AuraEnabled public Contact tradeAllyUser {get;set;}
		@AuraEnabled public Boolean selected {get;set;}

		public ContactInfoWrapper(Contact tradeAllyUser) {
			this.tradeAllyUser = tradeAllyUser;
			this.selected = false;
		}
	}
}