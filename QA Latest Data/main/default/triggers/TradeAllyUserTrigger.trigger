trigger TradeAllyUserTrigger on User (after insert, after update) {

    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
		List<User> listOfUsersToGenerateSharing = new List<User>();
		Map<Id,User> oldMap = Trigger.oldMap;
		for (User u : Trigger.new) {
			if (
				Trigger.isInsert || 
				(
					u.Permission_Set_to_Assign__c == oldMap.get(u.Id).Permission_Set_to_Assign__c &&
					u.ProfileId == oldMap.get(u.Id).ProfileId
				)
			) {
				listOfUsersToGenerateSharing.add(u);
			}
		}
		TradeAllyUserTriggerHandler.generateSharingSettings(listOfUsersToGenerateSharing);
	}

}