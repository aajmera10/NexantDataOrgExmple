@isTest
private class ConvertReferralControllerTest {

	@isTest
	private static void testConvertReferralController() {
		
		RecordType rt = [
			SELECT	Id
			FROM	RecordType
			WHERE	Name = 'Trade Ally'
		];
       
        Account a = new Account(
			Name = 'test account',
			Projects_Completed__c = 0,
			Business_Type__c = 'Contractor',
			Status__c = 'Active',
			Legal_Company_Name__c = 'test',
			Business_Structure__c = 'Other', 
			President_Owner_of_Company__c = 'test',
			RecordTypeId = rt.Id
		);
		insert a;

		Contact c = new Contact(
			LastName = 'Smith',
			Level__c = 'Primary'
		);
		insert c;

		Program__c program = new Program__c();
		insert program;

		Referral__c referral = new Referral__c(
			//Trade_Ally__c = a.Id,
			Customer__c = c.Id
		);
		//System.debug(referral.Trade_Ally__c);
		insert referral;

		Trade_Ally_Referral__c taReferral = new Trade_Ally_Referral__c(
			Program__c = program.Id,
			Referral__c = referral.Id,
			Referral_Status__c = 'Assigned',
			Trade_Ally__c = a.Id
		);
		insert taReferral;

		System.assert(!ConvertReferralController.getRecordStatus(taReferral.Id));

		ConvertReferralController.startReferralConvertation(taReferral.Id);
	}
}