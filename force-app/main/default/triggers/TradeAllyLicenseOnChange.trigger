trigger TradeAllyLicenseOnChange on Trade_Ally_License__c (before insert, before update)  {
	RelatedRecordsOnChangeTriggerHandler.reviewUpdateJunctionRecords(Trigger.new, Constants.LICENSE);
}