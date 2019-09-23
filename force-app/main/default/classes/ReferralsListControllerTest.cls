@IsTest
public with sharing class ReferralsListControllerTest {
	@IsTest
	public static void ReferralsListControllerTest() {
		String referralSearchText = 'referralSearchText';
		String sortOrder = 'ASC';
		String sortField = 'Name';
		String filterName = 'filterName';
		ListViewInfoWrapper newListViewInfoWrapper = ReferralsListController.getListOfReferrals(referralSearchText, sortOrder, sortField, filterName);
		System.assert(newListViewInfoWrapper != null);
	}
}