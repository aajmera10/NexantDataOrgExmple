public with sharing class TradeAllySearchController {

	@AuraEnabled
	public static List<TradeAllyWrapper> searchForTradeAllies(Id selectedSpecialtyId, String sectors) {
		System.debug(selectedSpecialtyId);
		System.debug(sectors);
		List<Id> tradeAllyIdList = getTradeAllyIdList(selectedSpecialtyId);
		return createTradeAllyWrapper(getAllTradeAllies(tradeAllyIdList, true, sectors));
	}

	@AuraEnabled
	public static List<TradeAllyWrapper> getSelectedTradeallies(Id referralId) {
		
		List<Id> tradeAllyIdList = getTradeAllyIdListRelatedToReferral(referralId);
		return createTradeAllyWrapper(getAllTradeAllies(tradeAllyIdList, false, ''));
	
	}

	@AuraEnabled
	public static void createTradeAllyReferralRelation(
		String selectedAccounts, 
		Id refRecordId
	)  {
		System.debug('selectedAccounts= ' + selectedAccounts);
		System.debug('refRecordId= ' + refRecordId);

		List<TradeAllyWrapper> tradeAllyAccounts = (List<TradeAllyWrapper>) JSON.deserialize(
			selectedAccounts, 
			List<TradeAllyWrapper>.class
		);
		List<Trade_Ally_Referral__c> tradeAlliesReferallsToInsertList = new List<Trade_Ally_Referral__c>();
		Trade_Ally_Referral__c newTradeAlliesReferall;
		
		
		for (TradeAllyWrapper tradeAllyWr : tradeAllyAccounts) {
			newTradeAlliesReferall = new Trade_Ally_Referral__c();
			newTradeAlliesReferall.Referral__c = refRecordId;
			newTradeAlliesReferall.Trade_Ally__c = tradeAllyWr.tradeAlly.Id;
			newTradeAlliesReferall.Referral_Status__c = 'Assigned';
			tradeAlliesReferallsToInsertList.add(newTradeAlliesReferall);
		}
		
		ESAPI.securityUtils().validatedInsert(tradeAlliesReferallsToInsertList);
	}

	private static List<TradeAllyWrapper> createTradeAllyWrapper(List<Account> accountsList) {
		Set<Id> userIdSet = new Set<Id>();
		List<TradeAllyWrapper> tradeAllyWrappersList = new List<TradeAllyWrapper>();
		TradeAllyWrapper currentWrapper;
		
		System.debug(accountsList);
		for (Account acct : accountsList) {
			userIdSet.add(acct.OwnerId);
		}
		System.debug(userIdSet);
		List<User> usersList = [
								SELECT Name,
									   MobilePhone,
									   Longitude,
									   Latitude,
									   SenderEmail
								FROM   User
								WHERE  Id IN : userIdSet
							  ];

		Map<ID, User> userMap = new Map<ID, User>(usersList)
		;
		for (Account acct : accountsList) {
			currentWrapper = new TradeAllyWrapper(false, acct, userMap.get(acct.OwnerId));
			tradeAllyWrappersList.add(currentWrapper);
		}

		return tradeAllyWrappersList;
	}

	private static List<Account> getAllTradeAllies(List<Id> tradeAllyIdList, Boolean getTradeAllyifIdListIsEmpty, String sectors) {
		List<Account> allTradeAllies = new List<Account>();
		String queryString = 'SELECT Id, OwnerId, Name, Billing_Address_Latitude__c, Billing_Address_Longitude__c, Number_Of_Referrals__c, Date_Of_Last_Referral__c FROM Account ';
		if (ESAPI.securityUtils().isAuthorizedToView('Account',new List<String>{'Id','Name'})) {
			
			System.debug(tradeAllyIdList);
			if (!getTradeAllyifIdListIsEmpty || (tradeAllyIdList != null && !tradeAllyIdList.isEmpty())) {
				queryString += 'WHERE Id IN : tradeAllyIdList ';
				if (sectors != null && !String.isBlank(sectors)) {
					queryString += 'AND Sectors__c =: sectors ';
				}
			} else {
				if (sectors != null && !String.isBlank(sectors)) {
					queryString += 'Where Sectors__c =: sectors ';
				}
			} 
			queryString += 'LIMIT 50000';
			
			System.debug(queryString);
			return Database.query(queryString);
		}
		return null;		
	}

	public class TradeAllyWrapper {
		@AuraEnabled public Boolean isSelected {get;set;}
		@AuraEnabled public Account tradeAlly {get;set;}
		@AuraEnabled public User user {get;set;}
		@AuraEnabled public Double distance {get;set;}

		public TradeAllyWrapper(Boolean selected, Account acct, User user) {
			this.isSelected = selected;
			this.tradeAlly = acct;
			this.user = user;
			Location acctLocation = Location.newInstance(acct.Billing_Address_Latitude__c,acct.Billing_Address_Longitude__c);
			System.debug(user);
			Location userLocation = Location.newInstance(user.Latitude, user.Longitude);
			this.distance = Location.getDistance(acctLocation, userLocation, 'mi');
		}
		
	
	}
	
	@AuraEnabled
	public static Map<String, String> getSpecialtyNameOptions() {
		Map<String, String> specialtyNameOptions = new Map<String, String> ();

		if (ESAPI.securityUtils().isAuthorizedToView(
		                                             'Specialty__c',
		                                             new List<String> {
			                                            'Id',
			                                            'Name'
		                                             })) {
			List<Specialty__c> specialtyList = [
													SELECT Id,
														   Name
													FROM Specialty__c
													LIMIT 50000
												];

			for (Specialty__c currentSpecialty : specialtyList) {
				specialtyNameOptions.put(currentSpecialty.Name, (String) currentSpecialty.Id);
			}

			return specialtyNameOptions;
		} else {
			return null;
		}
	}

	@AuraEnabled
	public static Map<String, String> getSectorsOptions() {
		Map<String, String> sectorsOptions = new Map<String, String> ();
		Schema.DescribeFieldResult fieldResult = Account.Sectors__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

		for( Schema.PicklistEntry pickListVal : ple){
			sectorsOptions.put(pickListVal.getLabel(),pickListVal.getLabel());
		}
		
		return sectorsOptions;  
	}

	public static List<Id> getTradeAllyIdList(Id selectedSpecialtyId) {
		try {
			List<Id> tradeAllyIdList = new  List<Id>();
			
			List<Trade_Ally_Specialty__c> tradeAllySpecialtyList = [
																		SELECT Trade_Ally__c
																		FROM   Trade_Ally_Specialty__c
																		WHERE  Specialty__c =: selectedSpecialtyId
																	];

			for (Trade_Ally_Specialty__c currentTradeAllySpecialty: tradeAllySpecialtyList) {
				tradeAllyIdList.add(currentTradeAllySpecialty.Trade_Ally__c);
			}

			return tradeAllyIdList;
		
		} catch (Exception e) {
			return null;
		}
	}

	
	public static List<Id> getTradeAllyIdListRelatedToReferral(Id referralId) {
		try {
			List<Id> tradeAllyIdList = new  List<Id>();
			
			List<Trade_Ally_Referral__c> tradeAllySpecialtyList = [
																		SELECT Trade_Ally__c
																		FROM   Trade_Ally_Referral__c
																		WHERE  Referral__c =: referralId
																	];

			for (Trade_Ally_Referral__c currentTradeAllySpecialty: tradeAllySpecialtyList) {
				tradeAllyIdList.add(currentTradeAllySpecialty.Trade_Ally__c);
			}

			return tradeAllyIdList;
		
		} catch (Exception e) {
			return null;
		}
	}


}