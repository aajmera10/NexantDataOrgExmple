public without sharing class SelfRegisterTradeAllyUtility {

	// Check if the username can be used for a new user registration
	public static Boolean ifUsernameExists(String username) {
		System.debug('ifUsernameExists is run');
		Boolean result = false;
		User user = new User();
		user.FirstName = 'any';
		user.LastName = 'any';
		user.Alias = 'any';
		user.EMail = 'any@email.com';
		user.Username = username;
		user.CommunityNickname = username;
		user.LocaleSidKey = 'en_US';
		user.LanguageLocaleKey = 'en_US';
		user.EmailEncodingKey = 'UTF-8';
		user.TimeZoneSidKey = 'America/Los_Angeles';
		/*Profile p = new Profile();
		if (ESAPI.securityUtils().isAuthorizedToView('Profile',new List<String>{'Id','Name'})) {
			p = [
				SELECT 	Id, 
						Name 
				FROM 	Profile 
				WHERE 	Name = 'Standard User' 
				LIMIT 	1
			];
		}
		System.debug(p);*/
		user.ProfileId = UserInfo.getProfileId();
		Savepoint sp = Database.setSavepoint();
		try {
			insert user;
			//ESAPI.securityUtils().validatedInsert(new List<User>{user});
		} catch (DmlException ex) {
			if (ex.getDmlStatusCode(0) == StatusCode.DUPLICATE_USERNAME.name()) {
				result = true;
			}
		} finally {
			Database.rollback(sp);
		}
		return result;
	}

}