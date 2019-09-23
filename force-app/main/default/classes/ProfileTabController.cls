public with sharing class ProfileTabController {
	
	@AuraEnabled
	public static ProfileTabInfoWrapper prepareAllInfo() {
		return new ProfileTabInfoWrapper();
	}
}