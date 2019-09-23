@isTest
private class CustomProfileMenuControllerTest {

	@isTest
	private static void testCustomProfileMenuController() {
		User currentUser = [
			SELECT
					Id,
					UserRoleId
			FROM	User
			WHERE	Id =: UserInfo.getUserId()
		];

		if (currentUser.UserRoleId == null) {
			List<UserRole> roles = [
				SELECT	Id
				FROM	UserRole
				LIMIT	1
			];
			currentUser.UserRoleId = roles[0].Id;
			update currentUser;
		}

		String profileName = 'Custom Customer Community Plus'; // TODO

		List<Profile> listOfProfiles = [
			SELECT	Id
			FROM	Profile
			WHERE	Name =: profileName//'Partner Community User'
		];

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
			LastName ='test contact',
			AccountId = a.Id,
			Level__c = 'Primary'
		);
        insert c;
                  
        User communityUser = new User(
			Alias = 'test123',
			Email = 'test123@noemail.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = listOfProfiles[0].Id,
			Country = 'United States',
			IsActive = true,
            ContactId = c.Id,
			TimeZoneSidKey='America/Los_Angeles',
			Username='tester@noemail.com'
		);
		
        System.runAs(communityUser) {
			System.assert(CustomProfileMenuController.prepareProfileMenuData().userId == communityUser.Id);
		}
	}
}