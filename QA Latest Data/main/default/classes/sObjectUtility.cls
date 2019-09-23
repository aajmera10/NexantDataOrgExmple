public with sharing class sObjectUtility {

	public static List<Schema.FieldSetMember> accountCOFields {
		get {
			if (accountCOFields == null) {
				accountCOFields = SObjectType.Account.FieldSets.Start_Application_Company_Info.getFields();
			}
			return accountCOFields;
		}
		set;
	}

	public static List<Schema.FieldSetMember> accountBACIFields {
		get {
			if (accountBACIFields == null) {
				accountBACIFields = SObjectType.Account.FieldSets.Start_Application_BA_CI.getFields();
			}
			return accountBACIFields;
		}
		set;
	}

	public static List<Schema.FieldSetMember> accountPPFields {
		get {
			if (accountPPFields == null) {
				accountPPFields = SObjectType.Account.FieldSets.Start_Application_PP.getFields();
			}
			return accountPPFields;
		}
		set;
	}

	public static List<Schema.FieldSetMember> contactBACIFields {
		get {
			if (contactBACIFields == null) {
				contactBACIFields = SObjectType.Contact.FieldSets.Start_Application_BA_CI.getFields();
			}
			return contactBACIFields;
		}
		set;
	}

	/*private static Id getRecordTypeId(String recordTypeName) {
		return Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
	}

	public static List<Account> getTradeAllies(List<Schema.FieldSetMember> fields, String accountSearchText) {
		String query = 'SELECT Id';
		query += FieldsInfoUtility.populateFieldsForQUERY(FieldsInfoUtility.prepareSetOfFieldsForQUERY(fields));
		query += ' FROM Account WHERE ';
		if (accountSearchText != null && accountSearchText.trim() != '') {
			query += '(' + FieldsInfoUtility.prepareWhereConditions(fields, accountSearchText) + ') AND ';
		}
		query += 'RecordTypeId = \'' + getRecordTypeId('Trade Ally') + '\'';
		System.debug(query);
		return Database.query(query);
	}*/

	public static Account getTradeAlly(String accountId) {
		System.debug('accountId' + accountId);
		String query = 'SELECT Id';
		Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(accountCOFields);
		setOfFields.addAll(FieldsInfoUtility.prepareSetOfFieldsForQUERY(accountBACIFields));
		setOfFields.addAll(FieldsInfoUtility.prepareSetOfFieldsForQUERY(accountPPFields));
		query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
		query += ' FROM Account WHERE Id = \'' + accountId + '\'';
		List<Account> listOfAvailableTradeAllies = new List<Account>();
		if (ESAPI.securityUtils().isAuthorizedToView('Account',new List<String>(setOfFields))) {
			listOfAvailableTradeAllies = Database.query(query);
		}
		Account tradeAlly = new Account();
		if (!listOfAvailableTradeAllies.isEmpty()) {
			tradeAlly = listOfAvailableTradeAllies[0];
		}
		return tradeAlly;
	}

	public static Contact getPrimaryContact(String accountId) {//String contactId
		String query = 'SELECT Id';
		//query += FieldsInfoUtility.populateFieldsForQUERY(sObjectUtility.contactBACIFields);
		Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(
			sObjectUtility.contactBACIFields
		);
		query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
		query += ', (SELECT Name FROM Attachments WHERE Name = \'' + Constants.PRIMARY_CONTACT_IMAGE + '\' ORDER BY CreatedDate DESC) ' +
				'FROM Contact WHERE AccountId = \'' + accountId + '\' AND ' + Constants.NAMESPACE + 'Level__c = \'Primary\'';
		List<Contact> listOfAvailableTradeAllies = new List<Contact>();
		if (
			ESAPI.securityUtils().isAuthorizedToView('Contact',new List<String>(setOfFields)) &&
			ESAPI.securityUtils().isAuthorizedToView('Attachment',new List<String>{'Name'})
		) {
			listOfAvailableTradeAllies = Database.query(query);
		}
		Contact primaryContact = new Contact();
		if (!listOfAvailableTradeAllies.isEmpty()) {
			primaryContact = listOfAvailableTradeAllies[0];
		}
		return primaryContact;
	}

	public static List<sObject> getListOfRecordsByCondition(String sObjectType, String whereCondition, List<Schema.FieldSetMember> fieldsFromFS) {
		String query = 'SELECT Id';
		Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(
			fieldsFromFS
		);
		query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
		query += ' FROM ' + sObjectType + ' WHERE ' + whereCondition;
		List<sObject> listOfRecordsByCondition = new List<sObject>();
		if (ESAPI.securityUtils().isAuthorizedToView(sObjectType,new List<String>(setOfFields))) {
			listOfRecordsByCondition = Database.query(query);
		}
		return listOfRecordsByCondition;
	}

	public static List<Trade_Ally_Reference__c> getTradeAllyReferences(String accountId, List<Schema.FieldSetMember> fieldsFromFS) {
		String query = 'SELECT Id';
		Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(fieldsFromFS);
		setOfFields.add(Constants.NAMESPACE + 'Reference_Type__c');
		setOfFields.add('Name');
		query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
		query += ' FROM ' + Constants.NAMESPACE + 'Trade_Ally_Reference__c WHERE ' + Constants.NAMESPACE + 
				'Trade_Ally__c = \'' + accountId + '\' ORDER BY CreatedDate ASC';
		List<Trade_Ally_Reference__c> tradeAllyReferences = new List<Trade_Ally_Reference__c>();
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Trade_Ally_Reference__c',new List<String>(setOfFields))) {
			tradeAllyReferences = Database.query(query);
		}
		return tradeAllyReferences;
	}

	public static List<sObject> getListOfSObjectsByType(
		//String accountId, 
		List<Schema.FieldSetMember> fieldsFromFS, 
		String applicationId,
		String sObjectTypeSTR
	) {
		List<sObject> listOfSObjects = new List<sObject>();
		if (applicationId != null && applicationId.trim() != '') {// || accountId != null
			String query = 'SELECT Id, ' + Constants.NAMESPACE + 'Application__c, ' +
							Constants.NAMESPACE + 'Trade_Ally__c, ' +
							Constants.NAMESPACE + sObjectTypeSTR +
							' FROM ' + Constants.NAMESPACE + 'Trade_Ally_' + sObjectTypeSTR + ' WHERE ';
			query += Constants.NAMESPACE + 'Application__c = \'' + applicationId + '\'';
			List<sObject> listOfTASObjects = new List<sObject>();
			List<String> fieldsToCheck = new List<String>{
				'Id',
				Constants.NAMESPACE + 'Application__c',
				Constants.NAMESPACE + 'Trade_Ally__c',
				Constants.NAMESPACE + sObjectTypeSTR
			};
			if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Trade_Ally_' + sObjectTypeSTR,fieldsToCheck)) {
				listOfTASObjects = Database.query(query);
			}
			System.debug('listOfTASObjects----------'+listOfTASObjects);
			if (!listOfTASObjects.isEmpty()) {
				Set<Id> setOfIds = new Set<Id>();
				for (sObject so : listOfTASObjects) {
					setOfIds.add((Id)so.get(Constants.NAMESPACE + sObjectTypeSTR));
				}
				query = 'SELECT Id';
				Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(fieldsFromFS);
				setOfFields.add('Name');
				query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
				query += ' FROM ' + Constants.NAMESPACE + sObjectTypeSTR + ' WHERE Id IN: setOfIds ORDER BY CreatedDate ASC';
				if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + sObjectTypeSTR,new List<String>(setOfFields))) {
					listOfSObjects = Database.query(query);
				}
			}
		}
		System.debug('listOfSObjects------------'+listOfSObjects);
		return listOfSObjects;
	}

	public static List<sObject> prepareListOfTradeAllyRelatedObjects(
		List<sObject> listOfRecords,
		String accountId, 
		String applicationId,
		String sObjectTypeSTR
	) {
		List<sObject> listOfTARelatedRecords = new List<sObject>();
		sObject tempRecord;
		for (sObject so : listOfRecords) {
			tempRecord = Schema.getGlobalDescribe().get(Constants.NAMESPACE + 'Trade_Ally_'+sObjectTypeSTR).newSObject();
			tempRecord.put(Constants.NAMESPACE + 'Application__c',applicationId);
			tempRecord.put(Constants.NAMESPACE + 'Trade_Ally__c',accountId);
			tempRecord.put(sObjectTypeSTR,(Id)so.get('Id'));
			listOfTARelatedRecords.add(tempRecord);
		}
		System.debug(listOfTARelatedRecords);
		return listOfTARelatedRecords;
	}

	public static Application__c getApplication(String accountId, List<Schema.FieldSetMember> fieldsFromFS, String applicationId) {
		List<Account> listAccounts = [SELECT Id, Primary_Business_Type__c from Account where Id =: accountId];
		Application__c app = new Application__c(
			Trade_Ally__c = accountId,
			Application_Status__c = 'Inactive',
			Business_Types__c = listAccounts[0].Primary_Business_Type__c,
			TC_Accepted_Agreed__c = false
		);
        System.debug('sobjectUtility accountId-----------'+accountId);
        System.debug('sobjectUtility applicationId-----------'+applicationId);
		String query = 'SELECT Id, ownerId';//, Application_Status__c
		Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(fieldsFromFS);
		setOfFields.add(Constants.NAMESPACE + 'Application_Status__c');
		setOfFields.add(Constants.NAMESPACE + 'TC_Accepted_Agreed__c');
		query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
		query += ' FROM ' + Constants.NAMESPACE + 'Application__c WHERE ';
		if (applicationId != null && applicationId.trim() != '') {
			query += 'Id = \'' + applicationId + '\'';
		} else {
			query += Constants.NAMESPACE + 'Trade_Ally__c = \'' + accountId + '\'';
		}
        System.debug('sobjectUtility query--------'+query);
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Application__c',new List<String>(setOfFields))) {
			List<Application__c> listOfAvailableApplications = ApplicationHelper.getApplication(query);
            System.debug('-------Authorized to view Application, got the list: '+listOfAvailableApplications);
            if (!listOfAvailableApplications.isEmpty()) {
				app = listOfAvailableApplications[0];
			}
            Id loggedInUserId = UserInfo.getUserId();
            if(loggedInUserId != null && app.ownerId != null && !app.OwnerId.equals(loggedInUserId)) {
                List<User> users = [Select id, contact.AccountId from user where id =: loggedInUserId];
                Id loggedInUserAcctId = users[0].contact.AccountId;
                if(loggedInUserAcctId != null && loggedInUserAcctId.equals(accountId)) {
                    ApplicationHelper.changeOwnership(loggedInUserId, app);
                }
            }
        } else {
            System.debug('NOT authorized to view Application--------');
        }
        System.debug('Returning app-------'+app);
		return app;
	}

	public static Demographic__c getApplicantInfo(String accountId, List<Schema.FieldSetMember> fieldsFromFS, String applicationId) {
		Demographic__c applicantInfo = new Demographic__c(
			Trade_Ally__c = accountId,
			Application__c = applicationId
		);
		String query = 'SELECT Id';
		Set<String> setOfFields = FieldsInfoUtility.prepareSetOfFieldsForQUERY(fieldsFromFS);
		query += FieldsInfoUtility.populateFieldsForQUERY(setOfFields);
		query += ' FROM ' + Constants.NAMESPACE + 'Demographic__c WHERE ';
		if (applicationId != null && applicationId.trim() != '') {
			query += Constants.NAMESPACE + 'Application__c = \'' + applicationId + '\'';
		} else {
			query += Constants.NAMESPACE + 'Trade_Ally__c = \'' + accountId + '\'';
		}

		List<Demographic__c> listOfAvailableDemographics = new List<Demographic__c>();
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Demographic__c',new List<String>(setOfFields))) {
			listOfAvailableDemographics = Database.query(query);
		}
		if (!listOfAvailableDemographics.isEmpty()) {
			applicantInfo = listOfAvailableDemographics[0];
		}
		return applicantInfo;
	}

	public static void deleteListOfRecordsByIds(
		Set<String> setOfIds, 
		String sObjectTypeStr, 
		Boolean isTARelated,
		String applicationId
	) {
		String query = 'SELECT Id FROM ';
		String sObjectName;
		if (isTARelated) {
			sObjectName = Constants.NAMESPACE + 'Trade_Ally_' + sObjectTypeStr;
			query += sObjectName + ' WHERE ' + sObjectTypeStr + ' IN: setOfIds AND ' + 
					Constants.NAMESPACE + 'Application__c =: applicationId';
		} else {
			sObjectName = Constants.NAMESPACE + sObjectTypeStr;
			query += sObjectName + ' WHERE Id IN: setOfIds';
		}
		if (ESAPI.securityUtils().isAuthorizedToView(sObjectName,new List<String>{'Id'})) {
			ESAPI.securityUtils().validatedDelete(Database.query(query));
		}
	}
}