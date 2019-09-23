@IsTest 
private class SetTermsAndConditionsStatusTriggerTest {

    private static final Integer NUMBER_OF_ACTIVE_TERMS_AND_CONDITIONS_FOR_TESTING = 3;
    
    @IsTest
    static void termsAndConditionsTriggerTest() {
        // Create active records
		List<Terms_And_Conditions__c> activeTermsAndConditionsForTesting = new List<Terms_And_Conditions__c>();
        for (Integer i = 0; i < SetTermsAndConditionsStatusTriggerTest.NUMBER_OF_ACTIVE_TERMS_AND_CONDITIONS_FOR_TESTING; i++) {
            activeTermsAndConditionsForTesting.add(
                new Terms_And_Conditions__c(
                    Text__c = 'Active T&C for testing ' + i,
                    Active__c = true
                )
            );
        }
        // Add another active record to override previos
        Terms_And_Conditions__c newActiveTermsAndConditionsForTesting = new Terms_And_Conditions__c(
        	Text__c = 'New Active T&C for testing',
            Active__c = true
        );
        Test.startTest();
        insert activeTermsAndConditionsForTesting;
        activeTermsAndConditionsForTesting[0].Active__c = true;
        update activeTermsAndConditionsForTesting;
       	insert newActiveTermsAndConditionsForTesting;
        Test.stopTest();
        List<Terms_And_Conditions__c> result = [
        	SELECT 	Text__c,
            		Active__c
            FROM 	Terms_And_Conditions__c
            LIMIT 	50000
        ];
        System.assert(result != null);
//        System.assert(result.size() == SetTermsAndConditionsStatusTriggerTest.NUMBER_OF_ACTIVE_TERMS_AND_CONDITIONS_FOR_TESTING - 1);
        System.assert(result[SetTermsAndConditionsStatusTriggerTest.NUMBER_OF_ACTIVE_TERMS_AND_CONDITIONS_FOR_TESTING].Active__c);
    }

}