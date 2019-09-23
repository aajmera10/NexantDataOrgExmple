trigger TradeAllyReferralOnChange on Trade_Ally_Referral__c (before insert, before update)  {
	
	TradeAllyReferralOnChangeTriggerHandler.checkAndUpdateStatus(
		Trigger.new,
		Trigger.oldMap,
		Trigger.isInsert
	);
}