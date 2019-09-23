public with sharing class RecaptchaLightningComponentController {

	@AuraEnabled
	public static String getNamespace() {
		return Constants.NAMESPACE;
	}
}