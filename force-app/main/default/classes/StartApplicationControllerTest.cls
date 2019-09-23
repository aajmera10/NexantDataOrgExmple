@isTest
private class StartApplicationControllerTest {

	private static ContentDocument generateContentDocument() {
		ContentVersion contentV = new ContentVersion(
			Title = 'Test',
			PathOnClient = 'Test.jpg',
			VersionData = Blob.valueOf('Test Content Data'),
			IsMajorVersion = true
		);

		insert contentV;
		ContentVersion searchVersion = [SELECT ID, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentV.Id LIMIT 1];
		List<ContentDocument> documents = [SELECT ID, Title FROM ContentDocument];
		return documents.get(0);
	}

	@isTest
	private static void testStartApplicationController() {
		
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
       
        Contact c = new Contact(
			LastName ='test contact',
			AccountId = a.Id,
			Level__c = 'Primary'
		);
        insert c;

		/*Attachment att = new Attachment(
			Name = Constants.PRIMARY_CONTACT_IMAGE,
			Body = Blob.valueOf('test'),
			ParentId = c.Id
		);
		insert att;*/
                  
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
            StartApplicationAllInfoWrapper wrappedInfo = StartApplicationController.getAllInfoWrapper(null,null);
			System.assert(wrappedInfo.applicationId != null);
			Application__c app = [
				SELECT	
						Id,
						Application_Status__c
				FROM	Application__c
				WHERE	Id =: wrappedInfo.applicationId
			];
			app.Application_Status__c = Constants.PENDING_STATUS;
			update app;

			List<Trade_Ally_Reference__c> listOfTradeAllyReferences = new List<Trade_Ally_Reference__c>{
				new Trade_Ally_Reference__c(
					Application__c = app.Id,
					Trade_Ally__c = a.Id,
					Reference_Type__c = Constants.CUSTOMER_REFERENCE
				),
				new Trade_Ally_Reference__c(
					Application__c = app.Id,
					Trade_Ally__c = a.Id,
					Reference_Type__c = Constants.TRADE_REFERENCE
				)
			};
			insert listOfTradeAllyReferences;

			Insurance__c insurance = new Insurance__c();
			insert insurance;

			Trade_Ally_Insurance__c tradeAllyInsurance = new Trade_Ally_Insurance__c(
				Application__c = app.Id,
				Trade_Ally__c = a.Id,
				Insurance__c = insurance.Id
			);
			insert tradeAllyInsurance;

			License__c license = new License__c();
			insert license;

			Trade_Ally_License__c tradeAllyLicense = new Trade_Ally_License__c(
				Application__c = app.Id,
				Trade_Ally__c = a.Id,
				License__c = license.Id
			);
			insert tradeAllyLicense;

			Certification__c certification = new Certification__c(
				Expiry_Date__c = Date.today()
			);
			insert certification;

			Trade_Ally_Certification__c tradeAllyCertification = new Trade_Ally_Certification__c(
				Application__c = app.Id,
				Trade_Ally__c = a.Id,
				Certification__c = certification.Id
			);
			insert tradeAllyCertification;

			Id attachmentId1 = StartApplicationController.saveTheChunk(
				c.Id,
				Constants.PRIMARY_CONTACT_IMAGE,
				EncodingUtil.base64Encode(Blob.valueOf('test')),
				'jpeg',
				null,
				'test'
			);
			attachmentId1 = StartApplicationController.saveTheChunk(
				c.Id,
				Constants.PRIMARY_CONTACT_IMAGE,
				EncodingUtil.base64Encode(Blob.valueOf('test')),
				'jpeg',
				null,
				'test'
			);

			List<Specialty__c> specialties = new List<Specialty__c>{
				new Specialty__c(Name = 'test1'),
				new Specialty__c(Name = 'test2'),
				new Specialty__c(Name = 'test3')
			};
			insert specialties;

			wrappedInfo = StartApplicationController.getAllInfoWrapper(app.Id,null);

			System.assert(wrappedInfo.applicationId == app.Id);

			Id attachmentId2 = StartApplicationController.saveTheChunk(
				certification.Id,
				'test',
				EncodingUtil.base64Encode(Blob.valueOf('test')),
				'jpeg',
				null,
				'test'
			);
			Id attachmentId3 = StartApplicationController.saveTheChunk(
				certification.Id,
				'test',
				EncodingUtil.base64Encode(Blob.valueOf('test')),
				'jpeg',
				attachmentId2,
				'test'
			);
			System.assert(attachmentId2 == attachmentId3);
			
			wrappedInfo.listOfTradeAllyFields[0].wasUpdated = true;
			wrappedInfo.listOfTradeAllyBACIFields[0].wasUpdated = true;
			wrappedInfo.listOfContactFields[0].wasUpdated = true;
			wrappedInfo.listOfTradeAllyPPFields[0].wasUpdated = true;
			//wrappedInfo.listOfTradeAllyPPFields[0].wasUpdated = true;
			wrappedInfo.listOfTradeAllyReferencesFields[0][0].wasUpdated = true;
			wrappedInfo.listOfTradeAllyTradeReferencesFields[0][0].wasUpdated = true;
			wrappedInfo.listOfInsurancesFields[0][0].wasUpdated = true;
			wrappedInfo.listOfLicensesFields[0][0].wasUpdated = true;
//			wrappedInfo.listOfCertificationsFields[0][0].wasUpdated = true;
			wrappedInfo.listOfApplicationFields[0].wasUpdated = true;

			String serializedData = JSON.serialize(wrappedInfo);
			
			/*StartApplicationController.savePartOfInfo(
				serializedData,
				'1'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'2'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'3'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'4'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'5'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'6'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'7'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'8'
			);
			StartApplicationController.savePartOfInfo(
				serializedData,
				'9'
			);*/
        }

	}

	@isTest
	private static void testGetPartOfData() {
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
       
        Contact c = new Contact(
			LastName ='test contact',
			AccountId = a.Id,
			Level__c = 'Primary'
		);
        insert c;

		/*Attachment att = new Attachment(
			Name = Constants.PRIMARY_CONTACT_IMAGE,
			Body = Blob.valueOf('test'),
			ParentId = c.Id
		);
		insert att;*/
                  
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
			System.assert(!StartApplicationController.getPartOfData(null,'4').isEmpty());
			System.assert(!StartApplicationController.getPartOfData(null,'5').isEmpty());
			System.assert(StartApplicationController.getPartOfData(null,'6').isEmpty());
			System.assert(StartApplicationController.getPartOfData(null,'7').isEmpty());
			System.assert(StartApplicationController.getPartOfData(null,'8').isEmpty());
            System.assert(StartApplicationController.getPartOfData(null,'9').isEmpty());
            System.assert(StartApplicationController.getPartOfData(null,'10').isEmpty());
		}
	}

	@IsTest
	private static void testAssociateFileWithObjectRecord() {
		License__c newLicense = new License__c(Type__c = 'ABC');
		ContentDocument newDoc = generateContentDocument();

		insert newLicense;

		Boolean success = StartApplicationController.associateFileWithObjectRecord(newLicense.Id, newDoc.Id);
		System.assert(success);
	}

	@IsTest
	private static void testAssociateFilesWithObjectRecord() {
		License__c newLicense = new License__c(Type__c = 'ABC');
		ContentDocument doc = generateContentDocument();

		List<String> docIds = new List<String>{doc.Id};

		insert newLicense;
		Boolean success = StartApplicationController.associateFilesWithObjectRecord(newLicense.Id, docIds);
		System.assert(success);
	}

	@IsTest
	private static void testAssociateFilesWithObjectRecords() {
		License__c newLicense = new License__c(Type__c = 'ABC');
		ContentDocument doc = generateContentDocument();

		List<String> docIds = new List<String>{doc.Id};

		insert newLicense;
		List<String> recordIds = new List<String>{newLicense.Id};
		Boolean success = StartApplicationController.associateFilesWithObjectRecords(recordIds, docIds);
		System.assert(success);
	}

	@IsTest
	private static void testServerDeleteFilesByIDs() {
		ContentDocument doc = generateContentDocument();
		List<String> docIds = new List<String>{doc.Id};
		Boolean success = StartApplicationController.serverDeleteFilesByIDs(docIds);
		System.assert(success);

		Boolean fail = StartApplicationController.serverDeleteFilesByIDs(null);
		System.assert(fail == false);
	}

	@IsTest
	private static void testSaveLicenseAndFiles() {
		Boolean result;

		result = StartApplicationController.saveLicenseAndFiles(null, null, null);
		System.assert(result == false);

		License__c newLicense = new License__c(Type__c = 'ABC');
		insert newLicense;

		result = StartApplicationController.saveLicenseAndFiles(newLicense.Id, new List<String>(), new List<String>());
		System.assert(result == true);
	}

	@IsTest
	private static void testSaveInsuranceAndFiles() {
		Boolean result;

		result = StartApplicationController.saveInsuranceAndFiles(null, null, null);
		System.assert(result == false);

		Insurance__c newInsurance = new Insurance__c(Type__c = 'ABC');
		insert newInsurance;

		result = StartApplicationController.saveInsuranceAndFiles(newInsurance.Id, new List<String>(), new List<String>());
		System.assert(result == true);
	}

	@IsTest
	private static void testSaveTaxAndFiles() {
		Boolean result;

		result = StartApplicationController.saveTaxAndFiles(null, null, null);
		System.assert(result == false);

		Tax__c newTax = new Tax__c();
		insert newTax;

		result = StartApplicationController.saveTaxAndFiles(newTax.Id, new List<String>(), new List<String>());
		System.assert(result == true);
	}

	@IsTest
	private static void testSaveOtherAndFiles() {
		Boolean result;

		result = StartApplicationController.saveOtherAndFiles(null, null, null);
		System.assert(result == false);

		Other_Document__c newOtherDoc = new Other_Document__c();
		insert newOtherDoc;

		result = StartApplicationController.saveOtherAndFiles(newOtherDoc.Id, new List<String>(), new List<String>());
		System.assert(result == true);
	}
}