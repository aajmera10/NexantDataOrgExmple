public with sharing class NewCommunicationController {
	
	public static final String TYPE_FIELD_NAME = 'Type';
	public static final String SUBJECT_FIELD_NAME = 'Subject';

	private static Map<String, Schema.SObjectField> taskSObjectFieldsMap = Schema.getGlobalDescribe().get('Task').getDescribe().fields.getMap();

	@AuraEnabled
	public static void createNewCommunication(String communication) {
		System.debug('communication= ' + communication);
		Task newCommunication = (Task) JSON.deserialize(
			communication, 
			Task.class
		);
		System.debug('newCommunication= ' + newCommunication);
		//ESAPI.securityUtils().validatedInsert(new List<Task>{newCommunication});
		insert newCommunication;
	}

	@AuraEnabled
	public static TaskFieldsWrapper prepareTaskFieldOptionsInfo() {
		TaskFieldsWrapper taskWrapper = new TaskFieldsWrapper();
		taskWrapper.listOfTaskTypeOptions = getPicklistValuesForField(
			getTaskDescribeFieldResult(TYPE_FIELD_NAME)
		);
		taskWrapper.listOfTaskSubjectOptions = getPicklistValuesForField(
			getTaskDescribeFieldResult(SUBJECT_FIELD_NAME)
		);
		return taskWrapper;
	}

	private static Schema.DescribeFieldResult getTaskDescribeFieldResult(String fieldName) {
		return taskSObjectFieldsMap.get(fieldName).getDescribe();
	}
	
	private static List<FieldInfoWrapper.PickListWrapper> getPicklistValuesForField(Schema.DescribeFieldResult fieldResult) {
		List<FieldInfoWrapper.PickListWrapper> picklistValuesList = new List<FieldInfoWrapper.PickListWrapper>();

		if (fieldResult.isCreateable()) {
			List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry value : pickListEntries) {
				picklistValuesList.add(
					new FieldInfoWrapper.PickListWrapper(
						value.getValue(),
						value.getLabel(),
						false,
						null
					)
				);
			}     
		}

		return picklistValuesList;
	}

	public class TaskFieldsWrapper {
		
		@AuraEnabled 
		public List<FieldInfoWrapper.PickListWrapper> listOfTaskTypeOptions {get;set;}
		@AuraEnabled 
		public List<FieldInfoWrapper.PickListWrapper> listOfTaskSubjectOptions {get;set;}
	
	}

}