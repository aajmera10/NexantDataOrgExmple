public with sharing class ReferralsListController {

	@AuraEnabled
	public static ListViewInfoWrapper getListOfReferrals(
		String referralSearchText, 
		String sortOrder, 
		String sortField, 
		String filterName
	) {
		return new ListViewInfoWrapper(
			String.isBlank(referralSearchText) ? null : String.escapeSingleQuotes(referralSearchText), 
			String.isBlank(sortOrder) ? null : String.escapeSingleQuotes(sortOrder), 
			String.isBlank(sortField) ? null : String.escapeSingleQuotes(sortField),
			Constants.NAMESPACE + 'Referral__c',
			Constants.NAMESPACE + 'List_View_Fields',
			null,
			String.isBlank(filterName) ? null : String.escapeSingleQuotes(filterName)
		);
	}
}