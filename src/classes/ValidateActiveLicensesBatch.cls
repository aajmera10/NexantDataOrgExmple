global class ValidateActiveLicensesBatch implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		Date today = Date.today();
		String query = 'SELECT Id, ' + Constants.NAMESPACE + 'License__r.' + 
						Constants.NAMESPACE + 'Expiry_Date__c, ' +
						Constants.NAMESPACE + 'Is_Active__c FROM ' +
						Constants.NAMESPACE + 'Trade_Ally_License__c ' +
						'WHERE ' + Constants.NAMESPACE + 'Is_Active__c = true AND ' +
						Constants.NAMESPACE + 'License__r.' + 
						Constants.NAMESPACE + 'Expiry_Date__c >= today';
		Database.QueryLocator ql;
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				Constants.NAMESPACE + 'Trade_Ally_License__c',
				new List<String>{
					'Id',
					Constants.NAMESPACE + 'License__c',
					Constants.NAMESPACE + 'Is_Active__c'
				}
			) &&
			ESAPI.securityUtils().isAuthorizedToView(
				Constants.NAMESPACE + 'License__c',
				new List<String>{
					Constants.NAMESPACE + 'Expiry_Date__c'
				}
			)
		) {
			ql = Database.getQueryLocator(query);
		}
		return ql;
	}

   	global void execute(Database.BatchableContext context, List<Trade_Ally_License__c> scope) {
		for (Trade_Ally_License__c tradeAllyLicense : scope) {
			tradeAllyLicense.Is_Active__c = false;
		}
		ESAPI.securityUtils().validatedUpdate(scope);
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
}