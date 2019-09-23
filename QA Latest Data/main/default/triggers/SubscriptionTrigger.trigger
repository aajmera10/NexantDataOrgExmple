trigger SubscriptionTrigger on Trade_Ally_Subscription__c (after insert, after update, after delete, before update ) {
	if(Trigger.isAfter && Trigger.isUpdate) {
		SubscriptionTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
	}
	if(Trigger.isAfter && Trigger.isDelete){
		SubscriptionTriggerHandler.afterDeleteHandler(Trigger.oldMap);
	}
	if(Trigger.isAfter && Trigger.isInsert){
		SubscriptionTriggerHandler.afterInsertHandler(Trigger.new);
	}

}