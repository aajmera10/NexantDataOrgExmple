@isTest
private class SelfRegisterTradeAllyControllerTest {

	@TestSetup
	public static void testSetup(){
		Id tradeAllyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
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
			User portalAccountOwner = new User(
					UserRoleId = portalRole.Id,
					ProfileId = profileSA.Id,
					Username = 'uniqumusernametestTESTtest2@test.com',
					Alias = 'batman',
					Email = 'bruce.wayne@wayneenterprises.com',
					EmailEncodingKey = 'UTF-8',
					FirstName = 'BruceBruce',
					LastName = 'WayneWayne',
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US',
					TimeZoneSidKey = 'America/Chicago'
			);
		Database.insert(portalAccountOwner);

	}

	public static final String EMPTY_LIST = '[]';

	@isTest
	private static void testSelfRegisterController() {
		String extraFieldsJSON = getJSONWithValues();
		String extraFieldsWithoutValueJSON = getJSONWithoutValues();
		List<Account> acctList = createTestAccounts();

		SelfRegisterTradeAllyWrapper tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			'test',
			'test',
			false,
			'test',
			acctList,
            true
		);

		String tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);
		SelfRegisterTradeAllyController tradeAllyController = new SelfRegisterTradeAllyController();

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			null,
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			null,
			'test',
			false,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			null,
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			null,
			'test',
			false,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);
	

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsJSON,
			'test',
			false,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);

		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsWithoutValueJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);
		

		SelfRegisterTradeAllyWrapper tradeAllyWrapperRegCodeCheck = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'test',
			'testUser11111111307@email.com',
			'test',
			'test',
			'',
			'test',
			extraFieldsJSON,
			'test',
			true,
			'',
			acctList,
            true

		);
		String tradeAllyWrapperJSONRegCodeCheck = JSON.serialize(tradeAllyWrapperRegCodeCheck);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSONRegCodeCheck);

		tradeAllyWrapperRegCodeCheck = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'test',
			'testUser11111111307@email.com',
			'test',
			'test',
			'',
			'test',
			extraFieldsJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);

		tradeAllyWrapperJSONRegCodeCheck = JSON.serialize(tradeAllyWrapperRegCodeCheck);
		SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSONRegCodeCheck);

		tradeAllyWrapperRegCodeCheck = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'test',
			'testUser11111111307@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);

		tradeAllyWrapperJSONRegCodeCheck = JSON.serialize(tradeAllyWrapperRegCodeCheck);
		String result = SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSONRegCodeCheck);
//		System.assert(result = null);

		tradeAllyWrapperRegCodeCheck = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'test',
			'testUser11111111307@email.com',
			'test',
			'test',
			null,
			'test',
			extraFieldsJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);

		tradeAllyWrapperJSONRegCodeCheck = JSON.serialize(tradeAllyWrapperRegCodeCheck);
		result = SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSONRegCodeCheck);
		System.assert(result != null);

		tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'test',
			'testUser11111111307@email.com',
			'test',
			'test',
			String.valueOf(acctList[1].Id),
			'test',
			extraFieldsJSON,
			'test',
			true,
			'test',
			acctList,
            true

		);

		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		result = SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSON);
		System.assert(result != null);
	}
    
    @isTest
	private static void testSelfRegisterControllerWithRegCode() {
		String extraFieldsJSON = getJSONWithValues();
		String extraFieldsWithoutValueJSON = getJSONWithoutValues();
		List<Account> acctList = createTestAccountsWithRegCode();
        List<Account> al = [Select Registration_code__c from account where name = 'test'];
        System.debug('al[0].Registration_code__c ^^^^^'+al[0].Registration_code__c);
		SelfRegisterTradeAllyWrapper tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'',
			'',
			String.valueOf(acctList[0].Id),
			'test',
			'test',
			'test',
			false,
			al[0].Registration_code__c,
			acctList,
            true
		);

		String tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		String result = SelfRegisterTradeAllyController.selfRegisterWithRegCode(tradeAllyWrapperJSON, false);
        
        tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsJSON,
			'test',
			false,
			al[0].Registration_code__c,
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		result = SelfRegisterTradeAllyController.selfRegisterWithRegCode(tradeAllyWrapperJSON, false);
        
        tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsWithoutValueJSON,
			'test',
			false,
			al[0].Registration_code__c,
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		result = SelfRegisterTradeAllyController.selfRegisterWithRegCode(tradeAllyWrapperJSON, false);

        tradeAllyWrapper = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'test',
			'test',
            'testCompanyType',
			'1111111111',
			'test@email.com',
			'test',
			'test',
			String.valueOf(acctList[0].Id),
			'test',
			extraFieldsJSON,
			'test',
			false,
			'test',
			acctList,
            true

		);
		tradeAllyWrapperJSON = JSON.serialize(tradeAllyWrapper);
		result = SelfRegisterTradeAllyController.selfRegisterWithRegCode(tradeAllyWrapperJSON, false);
        
        System.assert(result != null);
    }

	@isTest
	private static void testSelfRegisterControllerMethods() {
		String extraFields = SelfRegisterTradeAllyController.getExtraFieldsFromFieldSet('test');
		System.assert(extraFields == EMPTY_LIST);
		String result = SelfRegisterTradeAllyController.setExperienceId('test');
		System.assert(result != null);
	}

	@isTest
	private static void testSelfRegisterControllerDuplicateAccounts() {
		Test.startTest();
		Trade_Ally_Owner_Settings__c newSettings = new Trade_Ally_Owner_Settings__c(
				Name = 'Default Trade Ally Owner Username',
				Default_Trade_Ally_Owner_Username__c = 'uniqumusernametestTESTtest2@test.com'
		);
		insert newSettings;
		Test.stopTest();
		String extraFieldsJSON = getJSONWithValues();
		String extraFieldsWithoutValueJSON = getJSONWithoutValues();
		List<Account> acctList = createTestAccounts();

		SelfRegisterTradeAllyWrapper tradeAllyWrapperEmptyDuplicateAccounts = new SelfRegisterTradeAllyWrapper(
			'test',
			'test',
			'test',
			'testCompanyCity1',
			'testCompanyState1',
            'testCompanyType',
			'test',
			'testUser11111111307@email.com',
			'test',
			'test',
			'',
			'test',
			extraFieldsJSON,
			'test',
			true,
			'',
			acctList,
            true
		);
		String tradeAllyWrapperJSONEmptyDuplicateAccounts = JSON.serialize(tradeAllyWrapperEmptyDuplicateAccounts);
        System.debug('-------'+tradeAllyWrapperJSONEmptyDuplicateAccounts);
		String response = SelfRegisterTradeAllyController.selfRegister(tradeAllyWrapperJSONEmptyDuplicateAccounts);
		System.debug('response-------------'+response);
		String result = SelfRegisterTradeAllyController.declineAllTradeAllyDuplicates(tradeAllyWrapperJSONEmptyDuplicateAccounts);
		System.assert(result == null);
	}

	private static String getJSONWithValues() {
        String acceptTCPath = Constants.NAMESPACE + 'Accept_TC__c';
		String extraFieldsJSON = '[{"value":"Account","type":"STRING","required":false,"label":"Company Name","fieldPath":"CompanyName","dbRequired":false},';
		extraFieldsJSON += '{"value":"","type":"STRING","required":false,"label":"Title","fieldPath":"Title","dbRequired":false},';
        extraFieldsJSON += '{"value":"Y","type":"STRING","required":false,"label":"Accept TC","fieldPath":"'+acceptTCPath+'","dbRequired":false}]';
		return extraFieldsJSON;
	}

	private static String getJSONWithoutValues() {
        String acceptTCPath = Constants.NAMESPACE + 'Accept_TC__c';
		String extraFieldsJSON = '[{"value":"","type":"STRING","required":false,"label":"Company Name","fieldPath":"CompanyName","dbRequired":false},';
		extraFieldsJSON += '{"value":"","type":"STRING","required":false,"label":"Title","fieldPath":"Title","dbRequired":false},';
        extraFieldsJSON += '{"value":"","type":"STRING","required":false,"label":"Accept TC","fieldPath":"'+acceptTCPath+'","dbRequired":false}]';
		return extraFieldsJSON;
	}

	private static List<Account> createTestAccounts() {
		List<Account> acctList = new List<Account>{
			new Account(
				Name = 'test'
			),
			new Account(
				Name = 'test2',
				User_Limit__c = 0
			),
			new Account(
				Name = 'test3'
			)
		};
		insert acctList;
		
		List<Contact> contactsList = new List<Contact>{
			new Contact(
				Lastname = 'test',
				Level__c = '1'
			)
		};
		insert contactsList;
		return acctList;
	}
    
    private static List<Account> createTestAccountsWithRegCode() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
		List<Account> acctList = new List<Account>{
			new Account(
				Name = 'test',
                Registration_Code__c = 'test',
                RecordTypeId = recordTypeId
			),
			new Account(
				Name = 'test2',
				User_Limit__c = 0,
                Registration_Code__c = 'test2',
                RecordTypeId = recordTypeId
			),
			new Account(
				Name = 'test3',
                Registration_Code__c = 'test3',
                RecordTypeId = recordTypeId
			)
		};
		insert acctList;
		
		List<Contact> contactsList = new List<Contact>{
			new Contact(
				Lastname = 'test',
				Level__c = '1'
			)
		};
		insert contactsList;
		return acctList;
	}

	@IsTest
	public static void ifAccountWithRegistrationCodeExistsTest(){
		Boolean result = SelfRegisterTradeAllyController.ifAccountWithRegistrationCodeExists('');
	System.assertEquals(false, result);
	}

	@IsTest
	public static void getPicklistInfoTest(){
		List<Map<String, String>> result = SelfRegisterTradeAllyController.getPicklistInfo('Account', 'Name', 'firstLabel', 'firstValue');
		System.assert(result != null);
	}

@IsTest
	public static void createReachedOverLimitUserData(){
	String contactFirstname = 'contactFirstname';
	String contactLastname = 'contactLastname';
	Id accountOwnerId;
	Account newAccount = new Account(
			Name = 'accountOwnerId'
	);
	insert newAccount;
	accountOwnerId = newAccount.Id;
		SelfRegisterTradeAllyController.createReachedOverLimitUserData(contactFirstname, contactLastname, accountOwnerId);
	List<Account> accounts = [
			SELECT Id
			FROM Account
	];
	List<String> emailAdresses = new List<String>{'test@gmail.com', 'test2@gmail.com', 'tes3t@gmail.com'};
	String subject = 'subject';
	String textOfTheMessage = 'textOfTheMessage';
	Test.startTest();
	SelfRegisterTradeAllyController.sendEmail(emailAdresses, subject, textOfTheMessage);
	Test.stopTest();
			System.assert(accounts != null);
	}

}