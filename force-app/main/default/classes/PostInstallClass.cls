global class PostInstallClass implements InstallHandler {
	global void onInstall(InstallContext context) {
//		if (context.previousVersion() == null) {
//		}
//		if (context.isUpgrade()) {
//		}
//		if (context.isPush()) {
//		}
		List<Application_Settings__c> listOfSettings = new List<Application_Settings__c>{
			new Application_Settings__c(
				Name = 'Alerts Certification Email',
				Value__c = '45,30,10'
			),
			new Application_Settings__c(
				Name = 'Alerts Certification Show',
				Value__c = '45,30,10'
			),
			new Application_Settings__c(
				Name = 'Alerts Insurance Email',
				Value__c = '45,30,10'
			),
			new Application_Settings__c(
				Name = 'Alerts Insurance Show',
				Value__c = '45,30,10'
			),
			new Application_Settings__c(
				Name = 'Alerts License Email',
				Value__c = '45,30,10'
			),
			new Application_Settings__c(
				Name = 'Alerts License Show',
				Value__c = '45,30,10'
			),
			new Application_Settings__c(
				Name = 'Number of Customer References',
				Value__c = '0'
			),
			new Application_Settings__c(
				Name = 'Number of Trade References',
				Value__c = '3'
			),
			new Application_Settings__c(
				Name = 'Subscribed Profile Name',
				Value__c = ''
			)
		};
		Database.insert(listOfSettings, false);

		List<Approval_Processes_Settings__c> listOfAPSettings = new List<Approval_Processes_Settings__c>{
			new Approval_Processes_Settings__c(
				Name = Constants.SUBMIT_APPLICATION_FOR_APPROVAL_SETTINGS,
				Approval_Process_Name__c = ''
			)
		};
		Database.insert(listOfAPSettings, false);

		List<Trade_Ally_Owner_Settings__c> listOfTAOSettings = new List<Trade_Ally_Owner_Settings__c>{
			new Trade_Ally_Owner_Settings__c(
				Name = Constants.DEFAULT_TRADE_ALLY_OWNER_CUSTOM_SETTINGS,
				Default_Trade_Ally_Owner_Username__c = UserInfo.getUserName()
			)
		};
		Database.insert(listOfTAOSettings, false);
	}

}