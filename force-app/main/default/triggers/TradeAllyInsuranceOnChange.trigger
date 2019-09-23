trigger TradeAllyInsuranceOnChange on Trade_Ally_Insurance__c (before insert, before update)  {
	RelatedRecordsOnChangeTriggerHandler.reviewUpdateJunctionRecords(Trigger.new, Constants.INCURANCE);
}