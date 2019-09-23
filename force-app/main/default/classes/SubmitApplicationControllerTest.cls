@IsTest
private class SubmitApplicationControllerTest {

	@TestSetup
	public static void testSetup() {
		UserRole portalRole = [
				SELECT
						Id
				FROM UserRole
				WHERE PortalType = 'None'
				LIMIT 1
		];
		Profile profileSA = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'System Administrator'
		];
		List<User> portalAccountOwnerList = new List<User>();
		for (Integer i = 0; i < 10; i++) {
			User portalAccountOwner = new User(
					UserRoleId = portalRole.Id,
					ProfileId = profileSA.Id,
					Username = System.now().millisecond() + 'test2@test.com' + i,
					Alias = 'batman' + i,
					Email = i + 'bruce.wayne@wayneenterprises.com',
					EmailEncodingKey = 'UTF-8',
					FirstName = 'BruceBruce' + i,
					LastName = 'WayneWayne' + i,
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US',
					TimeZoneSidKey = 'America/Chicago'
			);
			portalAccountOwnerList.add(portalAccountOwner);
		}
		Database.insert(portalAccountOwnerList);
	}

	@IsTest
	static void testBehavior() {
		String processDefinitionNameOrId = 'processDefinitionNameOrId';
		Id objectId;
		String submitterUsername;
		String comment = 'comment';
		Boolean skipEntryCriteria = true;
		List<String> nextApproverUsernames = new List<String>();
		Account newAccount = new Account(
				Name = 'newAccount'
		);
		insert newAccount;
		objectId = newAccount.Id;
		List<User> users = [
				SELECT Username
				FROM User
				WHERE IsActive = TRUE
		];
		for (Integer i = 0; i < 9; i++) {
			nextApproverUsernames.add(users[i].Username);
		}
		submitterUsername = users[9].Username;
		Boolean submitRecord = SubmitApplicationController.submitRecord(processDefinitionNameOrId, objectId, submitterUsername, comment, skipEntryCriteria, nextApproverUsernames);
		System.assert(submitRecord);
	}
}