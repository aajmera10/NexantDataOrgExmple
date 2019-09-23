public with sharing class DocumentsTabController {

	private static Id accountId;
	private static User u;
	private static StartApplicationAllInfoWrapper info;

	public static String urlPrefix {get;set;}

	@AuraEnabled
	public static SmallInfoWrapper getAllInfoWrapper(
		String applicationId, 
		String tradeAllyId,
		String urlPathPrefix
	) {
		urlPrefix = String.isBlank(urlPathPrefix) ? '' : String.escapeSingleQuotes(urlPathPrefix).trim().replace('/','');
		List<SectionInfoWrapper> listOfAllInfo = new List<SectionInfoWrapper>();
		//System.debug(URL.getSalesforceBaseUrl().toExternalForm());
		//System.debug('#####' + ConnectApi.Communities.getCommunities().communities[0].urlPathPrefix);
		prepareBasicData(
			String.isBlank(applicationId) ? null : String.escapeSingleQuotes(applicationId),
			String.isBlank(tradeAllyId) ? null : String.escapeSingleQuotes(tradeAllyId)
		);
		
		if (info.isValidUser) {
			listOfAllInfo.add(prepareInsurances());
			listOfAllInfo.add(prepareLicenses());
			listOfAllInfo.add(prepareCertifications());
			//listOfAllInfo.add(prepareReferrals());
			//listOfAllInfo.add(prepareProjectTypes());

			Set<Id> setOfParentIds = new Set<Id>();
			for (SectionInfoWrapper info : listOfAllInfo) {
				setOfParentIds.addAll(info.getSetOfParentIds());
			}
			Map<Id,List<Attachment>> mapOfGroupedAttachments = getMapOfGroupedAttachments(setOfParentIds);
		
			for (SectionInfoWrapper info : listOfAllInfo) {
				info.prepareMapOfConvertedInfo(mapOfGroupedAttachments);
			}
		}

		return new SmallInfoWrapper(
			info.applicationId,
			accountId,
			listOfAllInfo,
			prepareListOfAttachments(),
			info.isValidUser,
			info.isCommunityUser,
			info.appNotExists
		);
	}

	private static Map<Id,List<Attachment>> getMapOfGroupedAttachments(Set<Id> setOfParentIds) {
		List<Attachment> listOfAllAttachments = new List<Attachment>();
		List<String> fieldsToCheck = new List<String>{'Id','Name','Description','ParentId'};
		if (ESAPI.securityUtils().isAuthorizedToView('Attachment',fieldsToCheck)) {
			listOfAllAttachments = [
				SELECT	
						Id,
						Name,
						Description,
						ParentId
				FROM	Attachment
				WHERE	ParentId IN: setOfParentIds
			];
		}
		Map<Id,List<Attachment>> mapOfGroupedAttachments = new Map<Id,List<Attachment>>();
		List<Attachment> tempList;
		for (Attachment a : listOfAllAttachments) {
			tempList = mapOfGroupedAttachments.get(a.ParentId);
			if (tempList == null) {
				tempList = new List<Attachment>();
			}
			tempList.add(a);
			mapOfGroupedAttachments.put(
				a.ParentId,
				tempList
			);
		}
		return mapOfGroupedAttachments;
	}

	private static void prepareBasicData(String applicationId, String tradeAllyId) {
		u = StartApplicationController.getCurrentUserInfo();
		accountId = u.Contact.AccountId;
		if (tradeAllyId != null) {
			accountId = tradeAllyId;
		}
		List<List<FieldInfoWrapper>> tempListOfFields;
		info = new StartApplicationAllInfoWrapper(
			u,
			applicationId,
			tradeAllyId,
			false
		);
	}

	private static SectionInfoWrapper prepareInsurances() {
		// Insurance
		info.prepareInsuranceData(accountId);
		List<List<FieldInfoWrapper>> tempListOfFields = new List<List<FieldInfoWrapper>>(info.listOfInsurancesFields);
		tempListOfFields.add(info.defaultInsurance);
		return new SectionInfoWrapper(
			'Insurance',
			tempListOfFields
		);
	}

	private static SectionInfoWrapper prepareLicenses() {
		// License
		info.prepareLicenseData(accountId);
		List<List<FieldInfoWrapper>> tempListOfFields = new List<List<FieldInfoWrapper>>(info.listOfLicensesFields);
		tempListOfFields.add(info.defaultLicense);
		return new SectionInfoWrapper(
			'License',
			tempListOfFields
		);
	}

	private static SectionInfoWrapper prepareCertifications() {
		// Certification
		info.prepareCertificationData(accountId);
		List<List<FieldInfoWrapper>> tempListOfFields = new List<List<FieldInfoWrapper>>(info.listOfCertificationsFields);
		tempListOfFields.add(info.defaultCertification);
		return new SectionInfoWrapper(
			'Certification',
			tempListOfFields
		);
	}

	private static List<AttachmentWrapper> prepareListOfAttachments() {
		List<Attachment> listOfAttachments = new List<Attachment>();
		List<String> fieldsToCheck = new List<String>{'Id','Name','Description'};
		if (ESAPI.securityUtils().isAuthorizedToView('Attachment',fieldsToCheck)) {
			listOfAttachments = [
				SELECT
							Id,
							Name,
							Description
				FROM		Attachment
				WHERE		ParentId =: accountId
				ORDER BY	CreatedDate ASC
			];
		}
		List<AttachmentWrapper> listOfWrappedattachments = new List<AttachmentWrapper>();
		for (Attachment a : listOfAttachments) {
			listOfWrappedattachments.add(new AttachmentWrapper(a));
		}
		return listOfWrappedattachments;
	}

	@AuraEnabled
	public static String createNewRecord(
		String wrappedInfoSTR, 
		String accountId, 
		String applicationId
	) {
		SectionInfoWrapper allInfoWrapper = (SectionInfoWrapper)JSON.deserialize(wrappedInfoSTR,SectionInfoWrapper.class);
		String sObjectName = allInfoWrapper.sectionName + '__c';
		sObject sObjectToInsert = WrappedInfoParser.parseWrapperToFields(
			Schema.getGlobalDescribe().get(Constants.NAMESPACE + sObjectName).newSObject(),
			allInfoWrapper.getListOfInfoToCreate()//listOfFields[allInfoWrapper.listOfFields.size() - 1]
		);
		System.debug(sObjectToInsert);
		List<sObject> listOfNewRecords = new List<sObject>{sObjectToInsert};
		ESAPI.securityUtils().validatedInsert(listOfNewRecords);
		ESAPI.securityUtils().validatedInsert(
			sObjectUtility.prepareListOfTradeAllyRelatedObjects(
				listOfNewRecords,
				String.isBlank(accountId) ? null : String.escapeSingleQuotes(accountId),
				String.isBlank(applicationId) ? null : String.escapeSingleQuotes(applicationId),
				sObjectName
			)
		);
		return (String)listOfNewRecords[0].get('Id');
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
	public static Id getApplicationId() {
		User currentUser = StartApplicationController.getCurrentUserInfo();
		List<Application__c> apps = [SELECT ID FROM Application__c Where OwnerId = :currentUser.Id];
		if (apps != null && apps.size() > 0) {
			return apps.get(0).Id;
		}
		return null;
	}

	@AuraEnabled
	public static Map<String,Application_Settings__c> serverGetApplicationSettings() {
		return Application_Settings__c.getAll();
	}

	@AuraEnabled
	public static List<Application_Settings__c> serverGetDocumentRequirements() {
		Application_Settings__c certification = Application_Settings__c.getAll().get('Number of Certifications');
		Application_Settings__c insurance = Application_Settings__c.getAll().get('Number of Certifications');
		Application_Settings__c license = Application_Settings__c.getAll().get('Number of Certifications');
		Application_Settings__c otherDocument = Application_Settings__c.getAll().get('Number of Other Documents');
		Application_Settings__c tax = Application_Settings__c.getAll().get('Number of Tax Documents');
		List<Application_Settings__c> settings = new List<Application_Settings__c>{
			certification,
			insurance,
			license,
			otherDocument,
			tax
		};
		return settings;
	}

	@AuraEnabled
	public static Trade_Ally_Type_Application_Stages_map__mdt serverGetApplicationStageMap(Id applicationId) {
		System.debug('ApplicationID: ' + applicationId);
		if (applicationId == null) {
			return null;
		}
		Application__c userApp = [SELECT Id, Business_Types__c, CreatedById FROM Application__c WHERE Id = :applicationId LIMIT 1];
		if (userApp == null || userApp.Id == null) {
			return null;
		}

		if (!ESAPI.securityUtils().isAuthorizedToView(
				Constants.NAMESPACE + 'Trade_Ally_Type_Application_Stages_map__mdt', new List<String>{
					'Id', 
					Constants.NAMESPACE + 'Customer_References__c',
					Constants.NAMESPACE + 'Trade_References__c', 
					Constants.NAMESPACE + 'Application_Type__c',
					Constants.NAMESPACE + 'Demographics__c',
					Constants.NAMESPACE + 'Program_Participation__c',
					Constants.NAMESPACE + 'Insurance_Information__c',
					Constants.NAMESPACE + 'License_Information__c', 
					Constants.NAMESPACE + 'Certifications__c',
					Constants.NAMESPACE + 'Tax_Documents__c',
					Constants.NAMESPACE + 'Other_Documents__c'
                })) {
			return null;
		}
		List<Trade_Ally_Type_Application_Stages_map__mdt> meta = [ SELECT 
																ID,
																Application_Type__c,
																Certifications__c,
																Insurance_Information__c,
																License_Information__c,
																Other_Documents__c,
																Tax_Documents__c
															FROM 
																Trade_Ally_Type_Application_Stages_map__mdt 
															WHERE Application_Type__c = :userApp.Business_Types__c
														];
		if (meta != null && meta.size() > 0) {
			return meta.get(0);
		}
		return null;
	}

	@AuraEnabled
	public static List<License__c> serverGetLicenses() {
		User currentUser = StartApplicationController.getCurrentUserInfo();
		List<License__c> results = [SELECT Id FROM License__c WHERE CreatedById = :currentUser.Id];
		return results;
	}

	public class SmallInfoWrapper {
		@AuraEnabled public Boolean isValidUser {get;set;}
		@AuraEnabled public Boolean isCommunityUser {get;set;}
		@AuraEnabled public Boolean appNotExists {get;set;}
		@AuraEnabled public String applicationId {get;set;}
		@AuraEnabled public String accountId {get;set;}
		@AuraEnabled public List<SectionInfoWrapper> sections {get;set;}
		@AuraEnabled public List<AttachmentWrapper> attachments {get;set;}

		public SmallInfoWrapper(
			String applicationId, 
			String accountId, 
			List<SectionInfoWrapper> sections,
			List<AttachmentWrapper> attachments,
			Boolean isValidUser,
			Boolean isCommunityUser,
			Boolean appNotExists
		) {
			this.applicationId = applicationId;
			this.accountId = accountId;
			this.sections = sections;
			this.attachments = attachments;
			this.isValidUser = isValidUser;
			this.isCommunityUser = isCommunityUser;
			this.appNotExists = appNotExists;
		}
	}

	public class SectionInfoWrapper {
		@AuraEnabled public String sectionName {get;set;}
		private List<List<FieldInfoWrapper>> listOfFields {get;set;}
		@AuraEnabled public List<SubSectionInfoWrapper> listOfFieldsConverted {get;set;}
		private Set<Id> setOfParentIds;

		public SectionInfoWrapper(String sectionName,List<List<FieldInfoWrapper>> listOfFields) {
			this.sectionName = sectionName;
			this.listOfFields = listOfFields;
		}

		public Set<Id> getSetOfParentIds() {
			if (setOfParentIds == null) {
				setOfParentIds = new Set<Id>();
				for (List<FieldInfoWrapper> recordInfo : listOfFields) {
					if (!recordInfo.isEmpty()) {
						setOfParentIds.add(recordInfo[0].recordId);
					}
				}
			}
			return setOfParentIds;
		}

		public void prepareMapOfConvertedInfo(Map<Id,List<Attachment>> mapOfGroupedAttachments) {
			listOfFieldsConverted = new List<SubSectionInfoWrapper>();
			for (List<FieldInfoWrapper> recordInfo : listOfFields) {
				if (!recordInfo.isEmpty()) {
					listOfFieldsConverted.add(
						new SubSectionInfoWrapper(
							recordInfo,
							mapOfGroupedAttachments.get(recordInfo[0].recordId)
						)
					);
				}
			}
		}

		public List<FieldInfoWrapper> getListOfInfoToCreate() {
			List<FieldInfoWrapper> result = new List<FieldInfoWrapper>();
			if (listOfFieldsConverted != null) {
				result.addAll(
					listOfFieldsConverted[listOfFieldsConverted.size() - 1].listOfFields
				);
			}
			return result;
		}
	}

	public class SubSectionInfoWrapper {
		@AuraEnabled public List<FieldInfoWrapper> listOfFields {get;set;}
		@AuraEnabled public List<AttachmentWrapper> listOfAttachments {get;set;}

		public SubSectionInfoWrapper(List<FieldInfoWrapper> listOfFields, List<Attachment> listOfAttachments) {
			this.listOfFields = listOfFields;
			this.listOfAttachments = new List<AttachmentWrapper>();
			if (listOfAttachments != null) {
				for (Attachment a : listOfAttachments) {
					this.listOfAttachments.add(
						new AttachmentWrapper(a)
					);
				}
			}
		}
	}

	public class AttachmentWrapper {
		@AuraEnabled public String name {get;set;}
		@AuraEnabled public String attURL {get;set;}
		@AuraEnabled public String description {get;set;}

		public AttachmentWrapper(Attachment a) {
			name = a.Name;
			attURL = '/' + DocumentsTabController.urlPrefix + Constants.ATT_TEXT + a.Id;
			description = a.Description;
		}
	}
}