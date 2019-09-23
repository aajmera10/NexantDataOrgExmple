public with sharing class LogsManagementController {

	@AuraEnabled
	public static ListViewInfoWrapper getListOfAccounts(
		String accountSearchText, 
		String sortOrder, 
		String sortField
	) {
		return new ListViewInfoWrapper(
			String.isBlank(accountSearchText) ? null : String.escapeSingleQuotes(accountSearchText), 
			String.isBlank(sortOrder) ? null : String.escapeSingleQuotes(sortOrder), 
			String.isBlank(sortField) ? null : String.escapeSingleQuotes(sortField),
			'Account',
			Constants.NAMESPACE + 'List_View_Fields',
			'Trade Ally',
			null
		);
	}
}