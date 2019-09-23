trigger SetTermsAndConditionsStatusTrigger on Terms_and_Conditions__c(before insert, before update) {

	if (Trigger.isBefore) {
		if (Trigger.isInsert || Trigger.isUpdate) {
			Set<Id> existingTermsAndConditionsIds = new Set<Id> ();
			for (Terms_and_Conditions__c newTermsAndConditionsRecord : Trigger.new) {
				if (newTermsAndConditionsRecord.Active__c) {
					//Get the ids and exclude them from the query later - necessary to prevent SELF_REFERENCE_FROM_TRIGGER Error
					if (String.isNotBlank(newTermsAndConditionsRecord.Id)) {
						existingTermsAndConditionsIds.add(newTermsAndConditionsRecord.Id);
					}
				}
			}
			List<Terms_and_Conditions__c> existingActiveTermsAndConditionsList = new List<Terms_and_Conditions__c> ();
			if (
			    ESAPI.securityUtils().isAuthorizedToView(
			                                             Constants.NAMESPACE + 'Terms_And_Conditions__c',
			                                             new List<String> {
				                                            'Id',
				                                            Constants.NAMESPACE + 'Text__c',
				                                            Constants.NAMESPACE + 'Application_Type__c',
				                                            Constants.NAMESPACE + 'Active__c'
			                                             }
			)
			) {
				existingActiveTermsAndConditionsList = [
				                                        SELECT
				                                        Id,
				                                        Active__c,
				                                        Application_Type__c,
				                                        Text__c
				                                        FROM Terms_and_Conditions__c
				                                        WHERE Id NOT IN :existingTermsAndConditionsIds AND
				                                        Active__c = TRUE
				                                        LIMIT 50000
				                                       ];
			}

			Boolean termsAndConditionsDeactivated = false;

			for (Terms_and_Conditions__c newTermsAndConditionsRecord : Trigger.new) {
				if (newTermsAndConditionsRecord.Active__c) {
					if (newTermsAndConditionsRecord.Application_Type__c != null) {
						for (Terms_and_Conditions__c tc : existingActiveTermsAndConditionsList) {
							if (tc.Application_Type__c != null && tc.Application_Type__c.equals(newTermsAndConditionsRecord.Application_Type__c)) {
								tc.Active__c = false;
								termsAndConditionsDeactivated = true;
							}
						}
					} else {
						for (Terms_and_Conditions__c tc : existingActiveTermsAndConditionsList) {
							if (tc.Application_Type__c == null) {
								tc.Active__c = false;
								termsAndConditionsDeactivated = true;
							}
						}
					}
				}
			}
			if (termsAndConditionsDeactivated)
				ESAPI.securityUtils().validatedUpdate(existingActiveTermsAndConditionsList);
		}
	}

}