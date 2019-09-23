@IsTest
public with sharing class LoginTradeAllyControllerTest {
	@TestSetup
	public static void testSetup() {
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
		List<Account> accountList = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			Account portalAccount = new Account(
					Name = 'TestAccount' + i,
					OwnerId = portalAccountOwnerList[i].Id,
					RecordTypeId = tradeAllyRecordTypeId
			);
			accountList.add(portalAccount);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert accountList;
		}
		List<Contact> contactList = new List<Contact>();
		for (Account account : accountList) {
			Contact contact = new Contact(
					FirstName = 'Test ' + account.Name,
					LastName = 'McTesty ' + account.Name,
					AccountId = account.Id,
					Email = account.Name + System.now().millisecond() + 'test@test.com',
					Level__c = 'Tier 1'
			);
			contactList.add(contact);
		}
		System.runAs(portalAccountOwnerList[0]) {
			insert contactList;
		}
		Profile portalProfile = [
				SELECT
						Id
				FROM Profile
				WHERE Name = 'Customer Community Plus User'
				LIMIT 1
		];
		List<User> userList = new List<User>();
		for (Integer i = 0; i < 10; i++) {
			User user = new User(
					Username = i + System.now().millisecond() + 'test12345@test.com',
					ContactId = contactList[i].Id,
					ProfileId = portalProfile.Id,
					Alias = 'test123' + i,
					Email = i + 'test12345@test.com',
					EmailEncodingKey = 'UTF-8',
					LastName = 'McTestyMcTesty' + i,
					CommunityNickname = 'test12345' + i,
					TimeZoneSidKey = 'America/Los_Angeles',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US'
			);
			userList.add(user);
		}
        System.runAs(portalAccountOwnerList[0]) {
                insert userList;
        }

	}


	@IsTest
	public static void getAuthConfigTest() {
		Auth.AuthConfiguration authConfiguration = LoginTradeAllyController.getAuthConfig();
		System.assert(authConfiguration != null);
	}


	@IsTest
	public static void getForgotPasswordUrlTest() {
		String authConfiguration = LoginTradeAllyController.getForgotPasswordUrl();
		System.debug(authConfiguration);
		System.assert(authConfiguration == null);
	}


	@IsTest
	public static void getSelfRegistrationUrlTest() {
		String authConfiguration = LoginTradeAllyController.getSelfRegistrationUrl();
		System.debug(authConfiguration);
		System.assert(authConfiguration == null);
	}

@IsTest
	public static void getIsSelfRegistrationEnabledTest() {
		Boolean authConfiguration = LoginTradeAllyController.getIsSelfRegistrationEnabled();
		System.debug(authConfiguration);
		System.assert(authConfiguration == false);
	}

@IsTest
	public static void getIsUsernamePasswordEnabledTest() {
		Boolean authConfiguration = LoginTradeAllyController.getIsUsernamePasswordEnabled();
		System.debug(authConfiguration);
		System.assert(authConfiguration == true);
	}

@IsTest
	public static void loginTest() {
	List<User> users = [
			SELECT Id,
					Username
			FROM User
			WHERE IsActive = TRUE
	];

	String authConfiguration = LoginTradeAllyController.login(users[0].Username, 'password', 'startUrl');
		System.debug(authConfiguration);
		System.assert(authConfiguration != null);
		System.assertEquals('Argument 1 cannot be null', authConfiguration);
	}



	@IsTest
	public static void setExperienceIdlTest() {
		String experienceId = 'experienceId';
		String authConfiguration = LoginTradeAllyController.setExperienceId(experienceId);
		System.assertEquals('This method can be invoked only from within a community.', authConfiguration);
	}







}