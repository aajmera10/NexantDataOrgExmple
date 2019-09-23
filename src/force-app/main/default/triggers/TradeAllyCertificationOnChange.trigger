trigger TradeAllyCertificationOnChange on Trade_Ally_Certification__c (before insert, before update)  {
	RelatedRecordsOnChangeTriggerHandler.reviewUpdateJunctionRecords(Trigger.new, Constants.CERTIFICATION);
}