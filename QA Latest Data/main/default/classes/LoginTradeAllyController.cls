global class LoginTradeAllyController {

	public LoginTradeAllyController() {
		//TODO
	}

	@AuraEnabled
	public static String login(String username, String password, String startUrl) {
		username = String.isBlank(username) ? null : String.escapeSingleQuotes(username);
		startUrl = String.isBlank(startUrl) ? null : String.escapeSingleQuotes(startUrl);
		password = String.isBlank(password) ? null : String.escapeSingleQuotes(password);
		if (!isActiveUsername(username)) {
			return 'User is deactivated';
		}
		try {
			PageReference lgn = Site.login(username, password, startUrl);
			aura.redirect(lgn);
			return null;
		} catch (Exception ex) {
			return ex.getMessage();
		}
	}

	private static Boolean isActiveUsername(String username) {
		List<User> communityUsers = new List<User>();
		if (
			ESAPI.securityUtils().isAuthorizedToView('User',new List<String>{'ContactId'}) &&
			ESAPI.securityUtils().isAuthorizedToView('Contact',new List<String>{'AccountId'}) &&
			ESAPI.securityUtils().isAuthorizedToView('Account',new List<String>{Constants.NAMESPACE + 'Status__c'})
		) {
			communityUsers = [
				SELECT	Contact.Account.Status__c
				FROM	User
				WHERE	Username =: username
			];
		}
		Boolean isActive = true;
		if (!communityUsers.isEmpty() && communityUsers[0].Contact.Account.Status__c != null) {
			isActive = (communityUsers[0].Contact.Account.Status__c != Constants.INACTIVE_STATUS);
		}
		return isActive;
	}

	@AuraEnabled
	public static Boolean getIsUsernamePasswordEnabled() {
		Auth.AuthConfiguration authConfig = getAuthConfig();
		return authConfig.getUsernamePasswordEnabled();
	}

	@AuraEnabled
	public static Boolean getIsSelfRegistrationEnabled() {
		Auth.AuthConfiguration authConfig = getAuthConfig();
		return authConfig.getSelfRegistrationEnabled();
	}

	@AuraEnabled
	public static String getSelfRegistrationUrl() {
		Auth.AuthConfiguration authConfig = getAuthConfig();
		if (authConfig.getSelfRegistrationEnabled()) {
			return authConfig.getSelfRegistrationUrl();
		}
		return null;
	}

	@AuraEnabled
	public static String getForgotPasswordUrl() {
		Auth.AuthConfiguration authConfig = getAuthConfig();
		return authConfig.getForgotPasswordUrl();
	}

	@TestVisible
	private static Auth.AuthConfiguration getAuthConfig() {
		Id networkId = Network.getNetworkId();
		Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId, '');
		return authConfig;
	}

	@AuraEnabled
	global static String setExperienceId(String expId) {
		expId = String.isBlank(expId) ? null : String.escapeSingleQuotes(expId);
		// Return null if there is no error, else it will return the error message
		try {
			if (expId != null) {
				Site.setExperienceId(expId);
			}
			return null;
		} catch (Exception ex) {
			return ex.getMessage();
		}
	}

}