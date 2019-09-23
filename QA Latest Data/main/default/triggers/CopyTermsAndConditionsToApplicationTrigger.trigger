trigger CopyTermsAndConditionsToApplicationTrigger on Application__c(before insert, before update) {

	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
			//Query for active terms and conditions
			List<Terms_And_Conditions__c> activeTermsAndConditionsList = new List<Terms_And_Conditions__c> ();
			if (
			    ESAPI.securityUtils().isAuthorizedToView(
			                                             Constants.NAMESPACE + 'Terms_And_Conditions__c',
			                                             new List<String> { 'Id', Constants.NAMESPACE + 'Text__c', Constants.NAMESPACE + 'Application_Type__c' }
			)
			) {
				activeTermsAndConditionsList = [
				                                SELECT
				                                Id,
				                                Text__c,
				                                Application_Type__c
				                                FROM Terms_And_Conditions__c
				                                WHERE Active__c = TRUE
				                               ];
			}
			//Check if active terms and conditions record exists and its text is not empty
			if (!activeTermsAndConditionsList.isEmpty()) {
				//Copy the terms and conditions text from the active record to the new application,
				//and copy the reference of the active T&C record to the Application record
				for (Application__c newApplication : Trigger.new) {
					if (newApplication.Business_Types__c != null) {
						for (Terms_And_Conditions__c tc : activeTermsAndConditionsList) {
							if (tc.Application_Type__c != null && tc.Application_Type__c.equalsIgnoreCase(newApplication.Business_Types__c)) {
								newApplication.Terms_And_Conditions__c = tc.Id;
								if (String.isNotBlank(tc.Text__c)) {
									newApplication.Terms_And_Conditions_Text__c = tc.Text__c;
								}
							}
						}
					} else {
						newApplication.Terms_And_Conditions__c = activeTermsAndConditionsList[0].Id;
						if (String.isNotBlank(activeTermsAndConditionsList[0].Text__c)) {
							newApplication.Terms_And_Conditions_Text__c = activeTermsAndConditionsList[0].Text__c;
						}
					}
				}
			}
		}
		ApplicationOnChangeTriggerHandler.reviewApplicationStatus(Trigger.new); //Updated
	}

}