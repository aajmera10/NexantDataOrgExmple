trigger CertificationOnChange on Certification__c (before insert, before update, after insert, after update)  {
	if (trigger.isAfter) {
		if (trigger.isInsert || trigger.isUpdate) {
			GenerateAlertsController.generateAlerts(trigger.newMap, 'Expiry_Date__c', 'Certification');
		}
	} else {
		RelatedRecordsOnChangeTriggerHandler.reviewUpdateRecords(Trigger.new,Trigger.oldMap,Constants.TRADE_ALLY_CERTIFICATION);
	}
}