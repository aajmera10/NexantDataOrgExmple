global with sharing class ChangeProfileBatch implements Database.Batchable<SObject> {
	
	public ChangeProfileBatch() {
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		String query = 'SELECT Id, Permission_Set_to_Assign__c, ProfileId FROM User WHERE Permission_Set_to_Assign__c != null';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext context, List<User> usersToUpdate) {
		if (!String.isBlank(SubscriptionTriggerHandler.subscribedProfileId)) {
			List<PermissionSetAssignment> permissionSetAssignmentToAddList = new List<PermissionSetAssignment>();
			for (User u : usersToUpdate) {
				u.ProfileId = SubscriptionTriggerHandler.subscribedProfileId;
				permissionSetAssignmentToAddList.add(
					new PermissionSetAssignment(
						AssigneeId = u.Id,
						PermissionSetId = u.Permission_Set_to_Assign__c
					)
				);
				u.Permission_Set_to_Assign__c = null;
			}
			ESAPI.securityUtils().validatedUpdate(usersToUpdate);
			ESAPI.securityUtils().validatedInsert(permissionSetAssignmentToAddList);
		}
	}
	
	global void finish(Database.BatchableContext context) {
	}
}