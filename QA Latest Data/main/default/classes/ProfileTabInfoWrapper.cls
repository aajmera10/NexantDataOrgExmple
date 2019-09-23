public with sharing class ProfileTabInfoWrapper {

	//@AuraEnabled public User u {get;set;}
	//@AuraEnabled public List<OfficesWrapper> allAccountsInfo {get;set;}

	//@AuraEnabled public List<FieldInfoWrapper> currentProfile {get;set;}
	
//	public ProfileTabInfoWrapper() {
//		u = StartApplicationController.getCurrentUserInfo();
//		prepareListOfOffices();
//	}

//	private void prepareListOfOffices() {
//		Id mainOfficeId = u.Contact.Account.Primary_Office__c == null ? u.Contact.AccountId : u.Contact.Account.Primary_Office__c;
//		Set<Id> setOfAccountIds = new Set<Id>{u.Contact.AccountId};
//		if (u.Contact.Account.Primary_Office__c != null) {
//			setOfAccountIds.add(u.Contact.Account.Primary_Office__c);
//		}
//		List<Account> allAccounts = [
//			SELECT
//					Id,
//					Name,
//					AccountNumber
//			FROM	Account
//			WHERE
//					Id IN: setOfAccountIds OR
//					Primary_Office__c IN: setOfAccountIds
//			LIMIT	50000
//		];
//
//		/*List<Contact> allContacts = [
//			SELECT
//						Id,
//						Name,
//						AccountId,
//						Account.Name,
//						(
//							SELECT	Name
//							FROM	Attachments
//							WHERE	Name =: Constants.PRIMARY_CONTACT_IMAGE
//						)
//			FROM		Contact
//			WHERE
//						AccountId IN: setOfAccountIds OR
//						Account.Primary_Office__c IN: setOfAccountIds
//			ORDER BY	Account.Name
//		];*/
//		List<Contact> allContacts = [
//			SELECT
//						Id,
//						Name,
//						AccountId,
//						(
//							SELECT	Name
//							FROM	Attachments
//							WHERE	Name =: Constants.PRIMARY_CONTACT_IMAGE
//						)
//			FROM		Contact
//			WHERE		AccountId IN: allAccounts
//			ORDER BY	Account.Name
//		];
//
//		Map<Id,Account> mapOfAccounts = new Map<Id,Account>(allAccounts);
//		Map<Id,OfficesWrapper> mapOfOffices = new Map<Id,OfficesWrapper>();
//		OfficesWrapper tempOffice;
//		for (Contact c : allContacts) {
//			tempOffice = mapOfOffices.get(c.AccountId);
//			if (tempOffice == null) {
//				tempOffice = new OfficesWrapper(
//					mapOfAccounts.get(c.AccountId),
//					mainOfficeId == c.AccountId
//				);
//			}
//			tempOffice.reps.add(c);
//			mapOfOffices.put(
//				c.AccountId,
//				tempOffice
//			);
//		}
//		allAccountsInfo = mapOfOffices.values();
//	}

	/*public class OfficesWrapper {
		@AuraEnabled public Account office {get;set;}
		@AuraEnabled public List<Contact> reps {get;set;}
		@AuraEnabled public Boolean isPrimary {get;set;}

		public OfficesWrapper(Account office, Boolean isPrimary) {
			this.office = office;
			reps = new List<Contact>();
			this.isPrimary = isPrimary;
		}
	}*/
}