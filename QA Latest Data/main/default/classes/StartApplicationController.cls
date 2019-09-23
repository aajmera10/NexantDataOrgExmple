public with sharing class StartApplicationController {
	
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

	@AuraEnabled
	public static StartApplicationAllInfoWrapper getAllInfoWrapper(String applicationId, String tradeAllyId) {
		StartApplicationAllInfoWrapper info = new StartApplicationAllInfoWrapper(
			getCurrentUserInfo(),
			String.isBlank(applicationId) ? null : String.escapeSingleQuotes(applicationId),
			String.isBlank(tradeAllyId) ? null : String.escapeSingleQuotes(tradeAllyId)
		);
		return info;
	}

	/**
	 * Associate one file with one object ID. Return true if succeeds. Return false if exception occurs.
	 */
	@AuraEnabled
	public static Boolean associateFileWithObjectRecord(Id objectId, Id fileId) {
		ContentDocumentLink docLink = new ContentDocumentLink();
		docLink.ContentDocumentId = fileId;
		docLink.LinkedEntityId = objectId;
		docLink.ShareType = 'I'; // inferred permission. See sfore_api_objects_contentdocumentlink.htm
		try {
			insert docLink;
			return true;
		} catch (Exception e) {
			System.debug('[EXCEPTION] associating file with record: ' + e);
			return false;
		}
	}

	/**
	 * Associate multiple files with one object ID. Return true if succeeds. Return false if exception occurs.
	 */
    @AuraEnabled
	public static Boolean associateFilesWithObjectRecord(Id objectId, Id[] fileIds) {
		List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
		for (Id each: fileIds) {
			ContentDocumentLink docLink = new ContentDocumentLink();
			docLink.ContentDocumentId = each;
			docLink.LinkedEntityId = objectId;
			docLink.ShareType = 'I'; 
			docLinks.add(docLink);
		}
		try {
			insert docLinks;
			return true;
		} catch (Exception e) {
			System.debug(e.getStackTraceString());
			return false;
		}
	}

	/**
	 * Associate multiple files with object IDs. Return true if succeeds. Return false if execpetion occurs.
	 * If the length of objectIds and fileIds do not match, the smaller number of the association will be made. 
	 */
	@AuraEnabled
	public static Boolean associateFilesWithObjectRecords(Id[] objectIds, Id[] fileIds) {
		/*if (objectIds.size() != fileIds.size()) {
			return false;
		}*/
		List<ContentDocumentLink> docLinks = new List<ContentDocumentLink>();
		for (Integer i = 0; i < objectIds.size() && i < fileIds.size(); i++) {
			ContentDocumentLink docLink = new ContentDocumentLink();
			docLink.ContentDocumentId = fileIds[i];
			docLink.LinkedEntityId = objectIds[i];
			docLink.ShareType = 'I';

			// In case that the document link between the object and the document, it's not a good idea to create more link object between them. Need 
			List<Id> docCriteria = new Id[]{fileIds[i]};
			List<Id> entityCriteria = new Id[]{objectIds[i]};
			List<ContentDocumentLink> existingLinks = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :docCriteria AND LinkedEntityId IN :entityCriteria];
			if (existingLinks != null && existingLinks.size() == 1) {
				docLink.Id = existingLinks.get(0).Id;
			}
			docLinks.add(docLink);
		}
		try {
			upsert docLinks;
			return true;
		} catch (Exception e) {
			System.debug(e);
			return false;
		}
	}

	/**
	 * Delete files that are related to the specified object. Note that this function deletes all the files provided in fileIds.
	 * Once those files are deleted, their related ContentDocumentLinks will be deleted as well. Be cautious with this function as 
	 * it deletes ALL related links
	 */
	@AuraEnabled
	public static Boolean serverDeleteFilesByIDs(Id[] fileIds) {
		if (fileIds == null) {
			return false;
		}
		List<ContentDocument> docs = [SELECT ID From ContentDocument Where ID IN :fileIds];
		if (docs != null) {
			try {
				delete docs;
				return true;
			} catch (Exception e) {
				System.debug(e);
				return false;
			}
		}
		return false;
	}

	/**
	 * This function does three things:
	 * - associate license with the Application
	 * - associate files with license
	 * TODO: functions below are repetitive and should be refactored in phase 2
	 */
	@AuraEnabled
	public static Boolean saveLicenseAndFiles(Id appId, Id[] licenseIds, Id [] fileIds) {
		if (appId == null || licenseIds == null || fileIds == null) {
			return false;
		}

		// verify the numbers of records and files match
		if (licenseIds.size() != fileIds.size()) {
			return false;
		}
		
		User currentUser = getCurrentUserInfo();
		List<Trade_Ally_License__c> junctions = new List<Trade_Ally_License__c>();
		for (Integer i = 0; i < licenseIds.size(); i++) {
			Trade_Ally_License__c eachLicense = new Trade_Ally_License__c();
			eachLicense.Application__c = appId;
			eachLicense.License__c = licenseIds[i];
			eachLicense.Trade_Ally__c = currentUser.AccountId;
			eachLicense.Is_Active__c = true;

			List<Trade_Ally_License__c> existingJunctions = [SELECT ID FROM Trade_Ally_License__c WHERE Application__c = :appId AND License__c = :licenseIds[i] AND Trade_Ally__c = :currentUser.AccountId LIMIT 1];
			if (existingJunctions != null && existingJunctions.size() == 1) {
				eachLicense.Id = existingJunctions.get(0).Id;
			}
			junctions.add(eachLicense);
		}

		try {
			upsert junctions;
			List<String> junctionIds = new List<String>();
			for (Integer i = 0; i < junctions.size(); i++) {
				junctionIds.add(junctions.get(i).Id);
			}
			return associateFilesWithObjectRecords(junctionIds, fileIds) && associateFilesWithObjectRecords(licenseIds, fileIds);
		} catch (Exception e) {
			return false;
		}
	}

	@AuraEnabled
	public static Boolean saveInsuranceAndFiles (Id appId, Id[] insuranceIds, Id[] fileIds) {
		if (appId == null || insuranceIds == null || fileIds == null) {
			return false;
		}
		// verify that the numbers of object records and files match
		if (insuranceIds.size() != fileIds.size()) {
			return false;
		}

		User currentUser = getCurrentUserInfo();
		List<Trade_Ally_Insurance__c> junctions = new List<Trade_Ally_Insurance__c>();
		for (Integer i = 0; i < insuranceIds.size(); i++) {
			Trade_Ally_Insurance__c eachInsurance = new Trade_Ally_Insurance__c();
			eachInsurance.Application__c = appId;
			eachInsurance.Insurance__c = insuranceIds[i];
			eachInsurance.Trade_Ally__c = currentUser.AccountId;
			eachInsurance.Is_Active__c = true;

			List<Trade_Ally_Insurance__c> existingJunctions = [SELECT ID FROM Trade_Ally_Insurance__c WHERE Application__c = :appId AND Insurance__c = :insuranceIds[i] AND Trade_Ally__c = :currentUser.AccountId LIMIT 1];
			if (existingJunctions != null && existingJunctions.size() == 1) {
				eachInsurance.Id = existingJunctions.get(0).Id;
			}

			junctions.add(eachInsurance);
		}

		try {
			upsert junctions;
			List<String> junctionIds = new List<String>();
			for (Integer i = 0; i < junctions.size(); i++) {
				junctionIds.add(junctions.get(i).Id);
			}
			return associateFilesWithObjectRecords(junctionIds, fileIds) && associateFilesWithObjectRecords(insuranceIds, fileIds);
		} catch (Exception e) {
			System.debug('Trying to save insurance files but got errors: ' + e);
			return false;
		}
	}

	/**
	 * TODO: refactor this function. See details above
	 */
	@AuraEnabled
	public static Boolean saveCertificationAndFiles (Id appId, Id[] certificationIds, Id[] fileIds) {
		// NOTE: certifications do not require files to be associated with them
		
		User currentUser = getCurrentUserInfo();
		List<Trade_Ally_Certification__c> junctions = new List<Trade_Ally_Certification__c>();
		for (Integer i = 0; i < certificationIds.size(); i++) {
			Trade_Ally_Certification__c eachCertificate = new Trade_Ally_Certification__c();
			eachCertificate.Application__c = appId;
			eachCertificate.Certification__c= certificationIds[i];
			eachCertificate.Trade_Ally__c = currentUser.AccountId;
			eachCertificate.Is_Active__c = true;

			List<Trade_Ally_Certification__c> existingJunctions = [SELECT ID FROM Trade_Ally_Certification__c WHERE Application__c = :appId AND Certification__c = :certificationIds[i] AND Trade_Ally__c = :currentUser.AccountId LIMIT 1];
			if (existingJunctions != null && existingJunctions.size() == 1) {
				eachCertificate.Id = existingJunctions.get(0).Id;
			}

			junctions.add(eachCertificate);
		}

		try {
			upsert junctions;
			List<String> junctionIds = new List<String>();
			for (Integer i = 0; i < junctions.size(); i++) {
				junctionIds.add(junctions.get(i).Id);
			}
			return associateFilesWithObjectRecords(junctionIds, fileIds) && associateFilesWithObjectRecords(certificationIds, fileIds);
		} catch (Exception e) {
			System.debug('Trying to save certification files but got errors: ' + e);
			return false;
		}
	}

	/**
	 * TODO: refactor this function. See detail above.
	 */
	@AuraEnabled
	public static Boolean saveTaxAndFiles(Id appId, Id[] taxIds, Id[] fileIds) {
		if (appId == null || taxIds == null || fileIds == null) {
			return false;
		}
		if (taxIds.size() != fileIds.size()) {
			return false;
		}

		User currentuser = getCurrentUserInfo();
		List<Trade_Ally_Tax__c> junctions = new List<Trade_Ally_Tax__c>();
		for (Integer i = 0; i < taxIds.size(); i++) {
			Trade_Ally_Tax__c eachTax = new Trade_Ally_Tax__c();
			eachTax.Application__c = appId;
			eachTax.Tax__c = taxIds[i];
			eachTax.Trade_Ally__c = currentuser.AccountId;

			List<Trade_Ally_Tax__c> existingJunctions = [SELECT ID FROM Trade_Ally_Tax__c WHERE Application__c = :appId AND Tax__c = :taxIds[i] AND Trade_Ally__c = :currentUser.AccountId LIMIT 1];
			if (existingJunctions != null && existingJunctions.size() == 1) {
				eachTax.Id = existingJunctions.get(0).Id;
			}

			junctions.add(eachTax);
		}

		try {
			upsert junctions;
			List<String> junctionIds = new List<String>();
			for (Integer i = 0; i < junctions.size(); i++) {
				junctionIds.add(junctions.get(i).Id);
			}
			return associateFilesWithObjectRecords(junctionIds, fileIds) && associateFilesWithObjectRecords(taxIds, fileIds);
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * TODO: refactor this function
	 */
	@AuraEnabled
	public static Boolean saveOtherAndFiles(Id appId, Id[] otherIds, Id[] fileIds) {
		if (appId == null || otherIds == null || fileIds == null) {
			return false;
		}
		if (otherIds.size() != fileIds.size()) {
			return false;
		}

		User currentUser = getCurrentUserInfo();
		List<Trade_Ally_Other_Document__c> junctions = new List<Trade_Ally_Other_Document__c>();
		for (Integer i = 0; i < otherIds.size(); i++) {
			Trade_Ally_Other_Document__c eachOtherDoc = new Trade_Ally_Other_Document__c();
			eachOtherDoc.Application__c = appId;
			eachOtherDoc.Other_Document__c = otherIds[i];
			eachOtherDoc.Trade_Ally__c = currentUser.AccountId;

			List<Trade_Ally_Other_Document__c> existingJunctions = [SELECT ID FROM Trade_Ally_Other_Document__c WHERE Application__c = :appId AND Other_Document__c = :otherIds[i] AND Trade_Ally__c = :currentUser.AccountId LIMIT 1];
			if (existingJunctions != null && existingJunctions.size() == 1) {
				eachOtherDoc.Id = existingJunctions.get(0).Id;
			}

			junctions.add(eachOtherDoc);
		}

		try {
			upsert junctions;
			List<String> junctionIds = new List<String>();
			for (Integer i = 0; i < junctions.size(); i++) {
				junctionIds.add(junctions.get(i).Id);
			}

			return associateFilesWithObjectRecords(junctionIds, fileIds) && associateFilesWithObjectRecords(otherIds, fileIds);
		} catch (Exception e) {
			return false;
		}
	}

	@AuraEnabled
	public static Id saveTheChunk(
		Id parentId, 
		String fileName, 
		String base64Data, 
		String contentType, 
		String fileId, 
		String description
	) {
		return WorkWithAttachmentsUtility.saveTheChunk(
			String.isBlank(parentId) ? null : String.escapeSingleQuotes(parentId),
			String.isBlank(fileName) ? null : String.escapeSingleQuotes(fileName),
			base64Data,
			String.isBlank(contentType) ? null : String.escapeSingleQuotes(contentType),
			String.isBlank(fileId) ? null : String.escapeSingleQuotes(fileId),
			String.isBlank(description) ? null : String.escapeSingleQuotes(description)
		);
	}

	@AuraEnabled
	public static List<String> savePartOfInfo(String informationString, String sectionNumber) {
		List<String> listOFIds = new List<String>();
		StartApplicationAllInfoWrapper allInfoWrapper = (StartApplicationAllInfoWrapper)JSON.deserialize(informationString,StartApplicationAllInfoWrapper.class);
		Id accountId = allInfoWrapper.accountId;//allInfoWrapper.u.Contact.AccountId;
		String applicationId = allInfoWrapper.applicationId;
		if (sectionNumber == '1') {
			Account tradeAlly = (Account)WrappedInfoParser.parseWrapperToFields(
				sObjectUtility.getTradeAlly(accountId),
				allInfoWrapper.listOfTradeAllyFields
			);
			System.debug(tradeAlly);
			if (tradeAlly != null)
				ESAPI.securityUtils().validatedUpdate(new List<Account>{tradeAlly});
		} else if (sectionNumber == '2') {
			Account tradeAlly = (Account)WrappedInfoParser.parseWrapperToFields(
				sObjectUtility.getTradeAlly(accountId),
				allInfoWrapper.listOfTradeAllyBACIFields
			);
			System.debug(tradeAlly);
			if (tradeAlly != null)
				ESAPI.securityUtils().validatedUpdate(new List<Account>{tradeAlly});
			Contact primaryContact = (Contact)WrappedInfoParser.parseWrapperToFields(
				sObjectUtility.getPrimaryContact(accountId),
				allInfoWrapper.listOfContactFields
			);
			System.debug(primaryContact);
			if (primaryContact != null)
				ESAPI.securityUtils().validatedUpsert(new List<Contact>{primaryContact});
			listOFIds.add(primaryContact.Id);
		} else if (sectionNumber == '3') {
			Account tradeAlly = (Account)WrappedInfoParser.parseWrapperToFields(
				sObjectUtility.getTradeAlly(accountId),
				allInfoWrapper.listOfTradeAllyPPFields
			);
			System.debug(tradeAlly);
			if (tradeAlly != null)
				ESAPI.securityUtils().validatedUpdate(new List<Account>{tradeAlly});
			
			WrappedInfoParser.workWithSpesialFields();
		} else if (sectionNumber == '4') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfTradeAllyReferencesIdsToDelete),
				Constants.TRADE_ALLY_REFERENCE,
				false,
				applicationId
			);
			List<List<Trade_Ally_Reference__c>> listOfAvailableTradeAllyReferences = (List<List<Trade_Ally_Reference__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,Trade_Ally_Reference__c>(
					sObjectUtility.getTradeAllyReferences(
						accountId,
						SObjectType.Trade_Ally_Reference__c.FieldSets.Start_Application_CR.getFields()
					)
				),
				allInfoWrapper.listOfTradeAllyReferencesFields,
				accountId,
				Constants.CUSTOMER_REFERENCE
			);
			System.debug(listOfAvailableTradeAllyReferences);
			for (Trade_Ally_Reference__c tar : listOfAvailableTradeAllyReferences[0]) {
				tar.Trade_Ally__c = accountId;
				tar.Application__c = applicationId;
			}
			ESAPI.securityUtils().validatedInsert(listOfAvailableTradeAllyReferences[0]);
			ESAPI.securityUtils().validatedUpdate(listOfAvailableTradeAllyReferences[1]);
		} else if (sectionNumber == '5') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfTradeAllyCustomReferencesIdsToDelete),
				Constants.TRADE_ALLY_REFERENCE,
				false,
				applicationId
			);
			List<List<Trade_Ally_Reference__c>> listOfAvailableTradeAllyReferences = (List<List<Trade_Ally_Reference__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,Trade_Ally_Reference__c>(
					sObjectUtility.getTradeAllyReferences(
						accountId,
						SObjectType.Trade_Ally_Reference__c.FieldSets.Start_Application_CR.getFields()
					)
				),
				allInfoWrapper.listOfTradeAllyTradeReferencesFields,
				accountId,
				Constants.TRADE_REFERENCE
			);
			System.debug(listOfAvailableTradeAllyReferences);
			for (Trade_Ally_Reference__c tar : listOfAvailableTradeAllyReferences[0]) {
				tar.Trade_Ally__c = accountId;
				tar.Application__c = applicationId;
			}
			ESAPI.securityUtils().validatedInsert(listOfAvailableTradeAllyReferences[0]);
			ESAPI.securityUtils().validatedUpdate(listOfAvailableTradeAllyReferences[1]);
		} else if (sectionNumber == '6') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfInsurancesIdsToDelete),
				Constants.INCURANCE,
				true,
				applicationId
			);
			for (List<FieldInfoWrapper> listOfFields : allInfoWrapper.listOfInsurancesFields) {
				if (
					!listOfFields.isEmpty() && 
					listOfFields[0].recordId != null && 
					listOfFields[0].recordId.trim() != ''
				) {
					listOFIds.add(listOfFields[0].recordId);
				}
			}
			List<List<Insurance__c>> listOfAvailableInsurances = (List<List<Insurance__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,Insurance__c>(
					/*sObjectUtility.getInsurances(
						accountId,
						SObjectType.Insurance__c.FieldSets.Start_Application_II.getFields()
					)*/
					(List<Insurance__c>)sObjectUtility.getListOfSObjectsByType(
						//accountId,
						SObjectType.Insurance__c.FieldSets.Start_Application_II.getFields(),
						applicationId,
						Constants.INCURANCE
					)
				),
				allInfoWrapper.listOfInsurancesFields,
				accountId,
				null
			);
			System.debug(listOfAvailableInsurances);
			ESAPI.securityUtils().validatedInsert(listOfAvailableInsurances[0]);
			for (Insurance__c insurance : listOfAvailableInsurances[0]) {
				listOFIds.add(insurance.Id);
			}
			ESAPI.securityUtils().validatedUpdate(listOfAvailableInsurances[1]);
			/*ESAPI.securityUtils().validatedInsert(
				(List<Trade_Ally_Insurance__c>)sObjectUtility.prepareListOfTradeAllyRelatedObjects(
					listOfAvailableInsurances[0],
					accountId,
					applicationId,
					Constants.INCURANCE
				)
			);*/
		} else if (sectionNumber == '7') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfLicensesIdsToDelete),
				Constants.LICENSE,
				true,
				applicationId
			);
			for (List<FieldInfoWrapper> listOfFields : allInfoWrapper.listOfLicensesFields) {
				if (
					!listOfFields.isEmpty() && 
					listOfFields[0].recordId != null && 
					listOfFields[0].recordId.trim() != ''
				) {
					listOFIds.add(listOfFields[0].recordId);
				}
			}
			List<List<License__c>> listOfAvailableLicenses = (List<List<License__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,License__c>(
					/*sObjectUtility.getLicenses(
						accountId,
						SObjectType.License__c.FieldSets.Start_Application_LI.getFields()
					)*/
					(List<License__c>)sObjectUtility.getListOfSObjectsByType(
						//accountId,
						SObjectType.License__c.FieldSets.Start_Application_LI.getFields(),
						applicationId,
						Constants.LICENSE
					)
				),
				allInfoWrapper.listOfLicensesFields,
				accountId,
				null
			);
			System.debug(listOfAvailableLicenses);
			ESAPI.securityUtils().validatedInsert(listOfAvailableLicenses[0]);
			for (License__c license : listOfAvailableLicenses[0]) {
				listOFIds.add(license.Id);
			}
			ESAPI.securityUtils().validatedUpdate(listOfAvailableLicenses[1]);
			/*ESAPI.securityUtils().validatedInsert(
				(List<Trade_Ally_License__c>)sObjectUtility.prepareListOfTradeAllyRelatedObjects(
					listOfAvailableLicenses[0],
					accountId,
					applicationId,
					Constants.LICENSE
				)
			);*/
		} else if (sectionNumber == '8') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfCertificationsIdsToDelete),
				Constants.CERTIFICATION,
				true,
				applicationId
			);
			for (List<FieldInfoWrapper> listOfFields : allInfoWrapper.listOfCertificationsFields) {
				if (
					!listOfFields.isEmpty() && 
					listOfFields[0].recordId != null && 
					listOfFields[0].recordId.trim() != ''
				) {
					listOFIds.add(listOfFields[0].recordId);
				}
			}
			List<List<Certification__c>> listOfAvailableCertifications = (List<List<Certification__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,Certification__c>(
					/*sObjectUtility.getCertifications(
						accountId,
						SObjectType.Certification__c.FieldSets.Start_Application_C.getFields()
					)*/
					(List<Certification__c>)sObjectUtility.getListOfSObjectsByType(
						//accountId,
						SObjectType.Certification__c.FieldSets.Start_Application_C.getFields(),
						applicationId,
						Constants.CERTIFICATION
					)
				),
				allInfoWrapper.listOfCertificationsFields,
				accountId,
				null
			);
			System.debug(listOfAvailableCertifications);
			ESAPI.securityUtils().validatedInsert(listOfAvailableCertifications[0]);
			for (Certification__c certification : listOfAvailableCertifications[0]) {
				listOFIds.add(certification.Id);
			}
			ESAPI.securityUtils().validatedUpdate(listOfAvailableCertifications[1]);
			/*ESAPI.securityUtils().validatedInsert(
				(List<Trade_Ally_Certification__c>)sObjectUtility.prepareListOfTradeAllyRelatedObjects(
					listOfAvailableCertifications[0],
					accountId,
					applicationId,
					Constants.CERTIFICATION
				)
			);*/
		} else if (sectionNumber == '9') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfTaxIdsToDelete),
				Constants.TAX,
				false,
				applicationId
			);
			for (List<FieldInfoWrapper> listOfFields : allInfoWrapper.listOfTaxFields) {
				if (
					!listOfFields.isEmpty() && 
					listOfFields[0].recordId != null && 
					listOfFields[0].recordId.trim() != ''
				) {
					listOFIds.add(listOfFields[0].recordId);
				}
			}
			List<List<Tax__c>> listOfAvailableTaxes = (List<List<Tax__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,Tax__c>(
					(List<Tax__c>)sObjectUtility.getListOfSObjectsByType(
						SObjectType.Tax__c.FieldSets.Start_Application_TI.getFields(),
						applicationId,
						Constants.TAX
					)
				),
				allInfoWrapper.listOfTaxFields,
				accountId,
				null
			);
			System.debug(listOfAvailableTaxes);
			ESAPI.securityUtils().validatedInsert(listOfAvailableTaxes[0]);
			for (Tax__c tax : listOfAvailableTaxes[0]) {
				listOFIds.add(tax.Id);
			}
			ESAPI.securityUtils().validatedUpdate(listOfAvailableTaxes[1]);
			/*ESAPI.securityUtils().validatedInsert(
				(List<Trade_Ally_Tax__c>)sObjectUtility.prepareListOfTradeAllyRelatedObjects(
					listOfAvailableTaxes[0],
					accountId,
					applicationId,
					Constants.TAX
				)
			);*/
		} else if (sectionNumber == '10') {
			sObjectUtility.deleteListOfRecordsByIds(
				new Set<String>(allInfoWrapper.listOfOtherIdsToDelete),
				Constants.OTHER,
				false,
				applicationId
			);
			for (List<FieldInfoWrapper> listOfFields : allInfoWrapper.listOfOtherFields) {
				if (
					!listOfFields.isEmpty() && 
					listOfFields[0].recordId != null && 
					listOfFields[0].recordId.trim() != ''
				) {
					listOFIds.add(listOfFields[0].recordId);
				}
			}
			List<List<Other_Document__c>> listOfAvailableOtherDocs = (List<List<Other_Document__c>>)WrappedInfoParser.parseWrapperToFields(
				new Map<Id,Other_Document__c>(
					(List<Other_Document__c>)sObjectUtility.getListOfSObjectsByType(
						SObjectType.Other_Document__c.FieldSets.Start_Application_OD.getFields(),
						applicationId,
						Constants.OTHER
					)
				),
				allInfoWrapper.listOfOtherFields,
				accountId,
				null
			);
			System.debug(listOfAvailableOtherDocs);
			ESAPI.securityUtils().validatedInsert(listOfAvailableOtherDocs[0]);
			for (Other_Document__c other : listOfAvailableOtherDocs[0]) {
				listOFIds.add(other.Id);
			}
			ESAPI.securityUtils().validatedUpdate(listOfAvailableOtherDocs[1]);
			/*ESAPI.securityUtils().validatedInsert(
				(List<Trade_Ally_Other_Document__c>)sObjectUtility.prepareListOfTradeAllyRelatedObjects(
					listOfAvailableOtherDocs[0],
					accountId,
					applicationId,
					Constants.OTHER
				)
			);*/
		} else if (sectionNumber == '11') {
			Demographic__c applicantInfo = (Demographic__c)WrappedInfoParser.parseWrapperToFields(
				sObjectUtility.getApplicantInfo(
				accountId,
				SObjectType.Demographic__c.FieldSets.Start_Application_AI.getFields(),
				applicationId
				),
				allInfoWrapper.listOfTradeAllyDemographicFields
			);
			System.debug(applicantInfo);
			if (applicantInfo != null)
				ESAPI.securityUtils().validatedUpdate(new List<Demographic__c>{applicantInfo});
		} else if (sectionNumber == '12') {
			Application__c app = sObjectUtility.getApplication(
			    accountId,
			    SObjectType.Application__c.FieldSets.Start_Application_Fields.getFields(),
				applicationId
			);
			/*if (app.Id == null) {
				app.Application_Status__c = 'Inactive';
			}*/
			app = (Application__c)WrappedInfoParser.parseWrapperToFields(
			    app,
			    allInfoWrapper.listOfApplicationFields
			);
			//Check if the record is not locked
			if (
				app.TC_Accepted_Agreed__c &&
				app != null && 
				app.Application_Status__c != 'Active' && 
				app.Application_Status__c != 'In Review'
			) {
				listOFIds.add(app.Id);
				ESAPI.securityUtils().validatedUpsert(new List<Application__c> {app});
				//Get settings for Approval Process from Custom Settings
				Approval_Processes_Settings__c approvalProcessesSettings = Approval_Processes_Settings__c.getValues(Constants.SUBMIT_APPLICATION_FOR_APPROVAL_SETTINGS);
				SubmitApplicationController.submitRecord(approvalProcessesSettings.Approval_Process_Name__c, app.Id, null, null, true, null);
			}
		}
		return listOFIds;
	}

	@AuraEnabled
	public static List<List<FieldInfoWrapper>> getPartOfData(String applicationId, String sectionNumber) {
		sectionNumber = String.valueOf(sectionNumber);
		User u = getCurrentUserInfo();
		List<List<FieldInfoWrapper>> tempListOfFields;
		StartApplicationAllInfoWrapper info = new StartApplicationAllInfoWrapper(
			u,
			applicationId,
			null,
			true
		);
		Id accountId = info.accountId;//u.Contact.AccountId;
		if (sectionNumber == '4' || sectionNumber == '5') {
			info.prepareTradeAllyReferenceData(accountId);
			if (sectionNumber == '4') {
				tempListOfFields = info.listOfTradeAllyReferencesFields;
			} else {
				tempListOfFields = info.listOfTradeAllyTradeReferencesFields;
			}
		} else if (sectionNumber == '6') {
			info.prepareInsuranceData(accountId);
			tempListOfFields = info.listOfInsurancesFields;
		} else if (sectionNumber == '7') {
			info.prepareLicenseData(accountId);
			tempListOfFields = info.listOfLicensesFields;
		} else if (sectionNumber == '8') {
			info.prepareCertificationData(accountId);
			tempListOfFields = info.listOfCertificationsFields;
		} else if (sectionNumber == '9') {
			info.prepareTaxData(accountId);
			tempListOfFields = info.listOfTaxFields;
		} else if (sectionNumber == '10') {
			info.prepareOtherData(accountId);
			tempListOfFields = info.listOfOtherFields;
		}
		return tempListOfFields;
	}
}