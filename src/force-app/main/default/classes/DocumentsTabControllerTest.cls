@isTest
private class DocumentsTabControllerTest {

	@isTest
	private static void testDocumentsTabController() {
		List<Application_Settings__c> appSettings = new List<Application_Settings__c>{
			new Application_Settings__c(
				Name = Constants.NUMBER_OF_CUSTOMER_REFERENCES,
				Value__c = '3'
			),
			new Application_Settings__c(
				Name = Constants.NUMBER_OF_TRADE_REFERENCES,
				Value__c = '5'
			)
		};
		insert appSettings;

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

		Id accountAttachmentId = DocumentsTabController.saveTheChunk(
			a.Id,
			'test',
			EncodingUtil.base64Encode(Blob.valueOf('test')),
			'jpeg',
			null,
			'test'
		);

		System.assert(accountAttachmentId != null);
       
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
			Insurance__c insurance = new Insurance__c();
			insert insurance;
			
			Id attachmentId = DocumentsTabController.saveTheChunk(
				insurance.Id,
				'test',
				EncodingUtil.base64Encode(Blob.valueOf('test')),
				'jpeg',
				null,
				'test'
			);

			System.assert(attachmentId != null);

			DocumentsTabController.SmallInfoWrapper infoWrapper = DocumentsTabController.getAllInfoWrapper(null,null,null);

			Trade_Ally_Insurance__c tradeAllyInsurance = new Trade_Ally_Insurance__c(
				Application__c = infoWrapper.applicationId,
				Trade_Ally__c = infoWrapper.accountId,
				Insurance__c = insurance.Id
			);
			insert tradeAllyInsurance;

			infoWrapper = DocumentsTabController.getAllInfoWrapper(null,null,null);

			DocumentsTabController.SectionInfoWrapper allInfoWrapper = infoWrapper.sections[0];

			for (DocumentsTabController.SubSectionInfoWrapper convertedField : allInfoWrapper.listOfFieldsConverted) {
				for (FieldInfoWrapper f : convertedField.listOfFields) {
					f.wasUpdated = true;
				}
			}

			String wrappedInfoSTR = JSON.serialize(allInfoWrapper);
			DocumentsTabController.createNewRecord(
				wrappedInfoSTR,
				infoWrapper.accountId,
				infoWrapper.applicationId
			);

			Integer numberOfRecords = [
				SELECT	Count()
				FROM	Insurance__c
			];
			System.assert(numberOfRecords == 2);
		}
	}
}