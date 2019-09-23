/**
 * DocumentUploadControlle manages documents that are associated with an application
 */
public with sharing class DocumentUploadController  {
	private static List<Object> tradeAllyReferenceFieldSet;
	private static List<Object> licenseFieldSet;
	private static List<Object> insuranceFieldSet;
	private static List<Object> certificationFieldSet;
	private static List<Object> taxFieldSet;
	private static List<Object> otherDocumentFieldSet;

	public static User getCurrentUserInfo() {
		User currentUser;
		List<String> fieldsToCheck = new List<String>{
			'Id',
			'Name',
			'ContactId'
		};
		if (
			ESAPI.securityUtils().isAuthorizedToView('User',fieldsToCheck) &&
			ESAPI.securityUtils().isAuthorizedToView('Contact',new List<String>{'AccountId'})
		) {
			currentUser = [
				SELECT
						Id,
						Name,
						AccountId,
						ContactId,
						Contact.AccountId
				FROM	User
				WHERE	Id =: UserInfo.getUserId()
				LIMIT	1
			];
		}
		return currentUser;
	}

	/**
	 */
	@AuraEnabled
	public static List<Object> serverGetTradeAllyReferenceFieldSet() {
		if (tradeAllyReferenceFieldSet != null) {
			return tradeAllyReferenceFieldSet;
		}
		Schema.FieldSet fieldSet = Schema.SObjectType.Trade_Ally_Reference__c.fieldSets.getMap().get(Constants.NAMESPACE + 'Start_Application_CR');
		List<String> fields = new List<String>();
		for (Schema.FieldSetMember each: fieldSet.getFields()) {
			fields.add(each.getFieldPath());
		}
		tradeAllyReferenceFieldSet = fields;
		return tradeAllyReferenceFieldSet;
	}
	
	/**
	 * Get the field set defined under API name Start_Application_LI
	 */
	@AuraEnabled
	public static List<Object> serverGetLicenseFieldSet() {
		if (licenseFieldSet != null) {
			return licenseFieldSet;
		}
		Schema.FieldSet fieldSet = Schema.SObjectType.License__c.fieldSets.getMap().get(Constants.NAMESPACE + 'Start_Application_LI');
		List<String> fields = new List<String>();
		for (Schema.FieldSetMember each: fieldSet.getFields()) {
			fields.add(each.getFieldPath());
		}
		licenseFieldSet = fields;
		return licenseFieldSet;
	}

	/**
	 * Get the field set defined under API name Start_Application_II
	 */
	@AuraEnabled
	public static List<Object> serverGetInsuranceFieldSet() {
		if (insuranceFieldSet != null) {
			return insuranceFieldSet;
		}
		Schema.FieldSet fieldSet = Schema.SObjectType.Insurance__c.fieldSets.getMap().get(Constants.NAMESPACE + 'Start_Application_II');
		List<String> fields = new List<String>();
		for (Schema.FieldSetMember each: fieldSet.getFields()) {
			fields.add(each.getFieldPath());
		}
		insuranceFieldSet = fields;
		return insuranceFieldSet;
		
	}

	/**
	 * Get the field set defined under API name Start_Application__C
	 */
	@AuraEnabled
	public static List<Object> serverGetCertificationFieldSet() {
		if (certificationFieldSet != null) {
			return certificationFieldSet;
		}
		Schema.FieldSet fieldSet = Schema.SObjectType.Certification__c.fieldSets.getMap().get(Constants.NAMESPACE + 'Start_Application_C');
		List<String> fields = new List<String>();
		for (Schema.FieldSetMember each: fieldSet.getFields()) {
			fields.add(each.getFieldPath());
		}
		certificationFieldSet = fields;
		return certificationFieldSet;
		
	}

	/**
	 * Get the field set defined under API name Start_Application_TI
	 */
	@AuraEnabled
	public static List<Object> serverGetTaxFieldSet() {
		if (taxFieldSet != null) {
			return taxFieldSet;
		}
		Schema.FieldSet fieldSet = Schema.SObjectType.Tax__c.fieldSets.getMap().get(Constants.NAMESPACE + 'Start_Application_TI');
		List<String> fields = new List<String>();
		for (Schema.FieldSetMember each: fieldSet.getFields()) {
			fields.add(each.getFieldPath());
		}
		taxFieldSet = fields;
		return taxFieldSet;
		
	}

	/**
	 * Get the field set defined under API name Start_Application_OD
	 */
	@AuraEnabled
	public static List<Object> serverGetOtherDocumentFieldSet() {
		if (otherDocumentFieldSet != null) {
			return otherDocumentFieldSet;
		}
		Schema.FieldSet fieldSet = Schema.SObjectType.Other_Document__c.fieldSets.getMap().get(Constants.NAMESPACE + 'Start_Application_OD');
		List<String> fields = new List<String>();
		for (Schema.FieldSetMember each: fieldSet.getFields()) {
			fields.add(each.getFieldPath());
		}
		otherDocumentFieldSet = fields;
		return otherDocumentFieldSet;
	}

	/**
	 * 
	 */
	private static void initializeFieldSets() {
		serverGetCertificationFieldSet();
		serverGetInsuranceFieldSet();
		serverGetLicenseFieldSet();
		serverGetTaxFieldSet();
		serverGetOtherDocumentFieldSet();
	}

	private static Boolean checkFieldSetsInitialized() {
		return (licenseFieldSet != null) && (insuranceFieldSet != null) && (certificationFieldSet != null) && (taxFieldSet != null) && (otherDocumentFieldSet != null);
	}

	/**
	 * TODO: there might be namespace issue with this section
	 * serverGetExistingRecords will get the record that are owned by the current user.
	 * @param objectType: the API name of the record. Only License__c, Insurance__c, Certification__c, Tax__c, and Other_Document__c are allowed
	 * @param applicationId (optional): if this value is not null and empty string, then this function retrieves all records that are related to the 
	 *									specified application ID. Otherwise all records that are under the ownership of the current user will be retrieved.
	 */
	@AuraEnabled
	public static List<SObject> serverGetExistingRecords(String applicationId, String objectType) {
		if (String.isEmpty(applicationId)) {
			return null;
		}

		if (!checkFieldSetsInitialized()) {
			initializeFieldSets();
		}
		User currentUser = StartApplicationController.getCurrentUserInfo();
		string query = 'SELECT ';
		switch on objectType {
			when 'License__c' {
				for (Integer i = 0; i < licenseFieldSet.size() - 1; i++) {
					query = query + ' ' + licenseFieldSet.get(i) + ', ';
				}
				query = query + ' ' + licenseFieldSet.get(licenseFieldSet.size() - 1) + ' FROM ' + objectType;
			}
			when 'Insurance__c' {
				for (Integer i = 0; i < insuranceFieldSet.size() - 1; i++) {
					query = query + ' ' + insuranceFieldSet.get(i) + ', ';
				}
				query = query + ' ' + insuranceFieldSet.get(insuranceFieldSet.size() - 1) + ' FROM ' + objectType;
			}
			when 'Certification__c' { 
				for (Integer i = 0; i < certificationFieldSet.size() - 1; i++) {
					query = query + ' ' + certificationFieldSet.get(i) + ', ';
				}
				query = query + ' ' + certificationFieldSet.get(certificationFieldSet.size() - 1) + ' FROM ' + objectType;	
			} 
			when 'Tax__c' {
				for (Integer i = 0; i < taxFieldSet.size() - 1; i++) {
					query = query + ' ' + taxFieldSet.get(i) + ', ';
				}
				query = query + ' ' + taxFieldSet.get(taxFieldSet.size() - 1) + ' FROM ' + objectType;
			}
			when 'Other_Document__c' {
				for (Integer i = 0; i < otherDocumentFieldSet.size() - 1; i++) {
					query = query + ' ' + otherDocumentFieldSet.get(i) + ', ';
				}
				query = query + ' ' + otherDocumentFieldSet.get(otherDocumentFieldSet.size() - 1) + ' FROM ' + objectType;
			}
			when else {
				// type not supported, return null
				return null;
			}
		}
		//query = query + ' WHERE OwnerId = \'' + currentUser.Id + '\'';

		// add join relation
		query = query + ' WHERE Id IN (SELECT ' + objectType + ' FROM Trade_Ally_' + objectType + ' WHERE Application__c = \'' + applicationId + '\')'; 
		

		query = query + ' ORDER BY CREATEDDATE ASC'; // order the results by create date time in ascending order. TODO: should it be customizable?
		List<SObject> records = Database.query(query);
		return records;
	}

	/**
	 * serverGetRelatedDocumens returns a list of ContentDocuments' IDs which are associated with the recordID through ContentDocumentLink
	 */
	@AuraEnabled
	public static List<String> serverGetRelatedDocuments(String recordId) {
		if (String.isEmpty(recordId)) {
			return null;
		}
		List<ContentDocumentLink> results = [SELECT ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId = :recordId];
		if (results == null) {
			return new List<String>();
		}
		List<String> output = new List<String>();
		for (ContentDocumentLink each: results) {
			output.add(each.ContentDocumentId);
		}
		return output;
	}

	@AuraEnabled
	public static Boolean serverAssociateFilesWithApplicationId(Id applicationId, Id [] fileIds) {
		List<ContentDocumentLink> links = ContentDocumentManager.createContentDocumentLinks(applicationId, fileIds);
		if (links == null) {
			return false;
		}
		return true;
	}

	/**
	 * objectApiName does not contain name space and is identical to the format in dev and qa org.
	 */
	@AuraEnabled
	public static Boolean serverCreateApplicationDocumentJunction(Id applicationId, Id recordId, String objectApiName) {
		User currentUser = getCurrentUserInfo();

		// TODO: check if current user has access to application and record

		String query = ' SELECT ID FROM ' + Constants.NAMESPACE + 'Trade_Ally_' + objectApiName + 
						' WHERE ' + Constants.NAMESPACE + 'Application__c = \'' + applicationId + '\'' + 
						' AND ' + Constants.NAMESPACE + objectApiName + ' = \'' + recordId + '\'';
		List<SObject> searchResults = Database.query(query);
		if (searchResults != null && searchResults.size() > 0) {
			return true;
		}

		String fullObjectApiName = objectApiName;
		if (String.isNotEmpty(Constants.NAMESPACE)) {
			fullObjectApiName = objectApiName.replace(Constants.NAMESPACE, '');
		}
		List<SObject> itemsToInsert = new List<SObject>();
		switch on fullObjectApiName {
			when 'Certification__c'{
				Trade_Ally_Certification__c junction = new Trade_Ally_Certification__c();
				junction.Application__c = applicationId;
				junction.Certification__c = recordId;
				junction.Trade_Ally__c = currentUser.AccountId;
				junction.Is_Active__c = true;
				itemsToInsert.add(junction);
			}
			when 'Insurance__c' {
				Trade_Ally_Insurance__c junction = new Trade_Ally_Insurance__c();
				junction.Application__c = applicationId;
				junction.Insurance__c = recordId;
				junction.Trade_Ally__c = currentUser.AccountId;
				junction.Is_Active__c = true;
				itemsToInsert.add(junction);
			}
			when 'License__c' {
				Trade_Ally_License__c junction = new Trade_Ally_License__c();
				junction.Application__c = applicationId;
				junction.License__c = recordId;
				junction.Trade_Ally__c = currentUser.AccountId;
				junction.Is_Active__c = true;
				itemsToInsert.add(junction);
			}
			when 'Other_Document__c' {
				Trade_Ally_Other_Document__c junction = new Trade_Ally_Other_Document__c();
				junction.Application__c = applicationId;
				junction.Other_Document__c = recordId;
				junction.Trade_Ally__c = currentUser.AccountId;
				itemsToInsert.add(junction);
			}
			when 'Tax__c' {
				Trade_Ally_Tax__c junction = new Trade_Ally_Tax__c();
				junction.Application__c = applicationId;
				junction.Tax__c = recordId;
				junction.Trade_Ally__c = currentuser.AccountId;
				itemsToInsert.add(junction);
			}
			when else {
				return false;
			}
		}
		try {
			ESAPI.securityUtils().validatedInsert(itemsToInsert);
			return true;
		} catch (Exception e) {
			System.debug('Exception caught: ' + e);
		}
		return false;
	}
}