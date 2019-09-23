trigger TradeAllyTrigger on Account (before insert, after insert, after update) {
	
	if (Trigger.isBefore && Trigger.isInsert) {
		TradeAllyTriggerHandler.generateAutonumbers(Trigger.new);
	}

	if (Trigger.isAfter && Trigger.isUpdate) {
		TradeAllyTriggerHandler.generateSharingSettings(Trigger.new);
		Set<Id> setOfIdsToReview = new Set<Id>();
		for (Account a : Trigger.new) {
			if (a.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId() || a.Tier_Level__c != Trigger.oldMap.get(a.Id).Tier_Level__c) {
				setOfIdsToReview.add(a.Id);
			}
		}
		if (!setOfIdsToReview.isEmpty()) {
			TradeAllyTriggerHandler.tier1ChatterGroupHandler(setOfIdsToReview);
		}
	}

	if (Trigger.isAfter && Trigger.isInsert) {
//		TradeAllyTriggerHandler.insertSubscription(Trigger.new);
		TradeAllyTriggerHandler.generateSharingSettings(Trigger.new);
		Set<Id> setOfIdsToReview = new Set<Id>();
		for (Account a : Trigger.new) {
			if (a.RecordTypeId == Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()) {
				setOfIdsToReview.add(a.Id);
			}
		}
		if (!setOfIdsToReview.isEmpty()) {
			TradeAllyTriggerHandler.tier1ChatterGroupHandler(setOfIdsToReview);
		}
	}


}