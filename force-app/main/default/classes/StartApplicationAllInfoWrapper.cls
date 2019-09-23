public with sharing class StartApplicationAllInfoWrapper {

	@AuraEnabled public User u {get;set;}
	@AuraEnabled public Id accountId {get;set;}

	//@AuraEnabled 
	private Application__c app {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> listOfApplicationFields {get;set;}

	//@AuraEnabled 
	private Account tradeAlly {get;set;}
	private Demographic__c applicantInfo {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> listOfTradeAllyFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> listOfTradeAllyBACIFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> listOfTradeAllyPPFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> listOfTradeAllyDemographicFields {get;set;}
		
	//@AuraEnabled 
	//private Contact primaryContact {get;set;}
	@AuraEnabled public String primaryContactId {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> listOfContactFields {get;set;}
		
	@AuraEnabled public List<List<FieldInfoWrapper>> listOfTradeAllyReferencesFields {get;set;}
	@AuraEnabled public List<List<FieldInfoWrapper>> listOfTradeAllyTradeReferencesFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> defaultTradeAllyReference {get;set;}
	@AuraEnabled public List<String> listOfTradeAllyReferencesIdsToDelete {get;set;}
	@AuraEnabled public List<String> listOfTradeAllyCustomReferencesIdsToDelete {get;set;}

	@AuraEnabled public List<List<FieldInfoWrapper>> listOfInsurancesFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> defaultInsurance {get;set;}
	@AuraEnabled public List<String> listOfInsurancesIdsToDelete {get;set;}
	@AuraEnabled public Map<String, String> insuranceFiles {get; Set;} // key is the insurance obj ID, value is the file ID
	
	@AuraEnabled public List<List<FieldInfoWrapper>> listOfLicensesFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> defaultLicense {get;set;}
	@AuraEnabled public List<String> listOfLicensesIdsToDelete {get;set;}
	@AuraEnabled public Map<String, String> licenseFiles { get; Set; } // key is the license obj ID, value is the file ID
	
	@AuraEnabled public List<List<FieldInfoWrapper>> listOfCertificationsFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> defaultCertification {get;set;}
	@AuraEnabled public List<String> listOfCertificationsIdsToDelete {get;set;}
	@AuraEnabled public Map<String, String> certificationFiles { get; set; } // key is the certification obj ID, value is the file ID

	@AuraEnabled public List<List<FieldInfoWrapper>> listOfTaxFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> defaultTax {get;set;}
	@AuraEnabled public List<String> listOfTaxIdsToDelete {get;set;}
	@AuraEnabled public Map<String, String> taxFiles { get; Set; } // key is the tax object ID, value is the file ID

	@AuraEnabled public List<List<FieldInfoWrapper>> listOfOtherFields {get;set;}
	@AuraEnabled public List<FieldInfoWrapper> defaultOther {get;set;}
	@AuraEnabled public List<String> listOfOtherIdsToDelete {get;set;}
	@AuraEnabled public Map<String, String> otherFiles { get; Set; } // key is the tax object ID, value is the file ID
	
	@AuraEnabled public String applicationId {get;set;}

	@AuraEnabled public Integer numberOfCR {get;set;}
	@AuraEnabled public Integer numberOfTR {get;set;}
	@AuraEnabled public Integer numberOfTaxDocs {get;set;}
	@AuraEnabled public Integer numberOfOtherDocs {get;set;}
	@AuraEnabled public Integer numberOfInsurances {get;set;}
	@AuraEnabled public Integer numberOfLicenses {get;set;}
	@AuraEnabled public Integer numberOfCertifications {get;set;}
    
    public static Trade_Ally_Type_Application_Stages_map__mdt applicationStages;
    public static Account accountTradeAlly;

	@AuraEnabled public Boolean tab3Visible {get;set;}
	@AuraEnabled public Boolean tab4Visible {get;set;}
	@AuraEnabled public Boolean tab5Visible {get;set;}
	@AuraEnabled public Boolean tab6Visible {get;set;}
	@AuraEnabled public Boolean tab7Visible {get;set;}
	@AuraEnabled public Boolean tab8Visible {get;set;}
	@AuraEnabled public Boolean tab9Visible {get;set;}
	@AuraEnabled public Boolean tab10Visible {get;set;}
	@AuraEnabled public Boolean tab11Visible {get;set;}

	@AuraEnabled public Boolean editMode {get;set;}

	//variable added to show pop up window with subscription suggestion
	@AuraEnabled public Boolean isSubscribed {get;set;}
	
	@AuraEnabled public Boolean isValidUser {get;set;}
	@AuraEnabled public Boolean isCommunityUser {get;set;}

	private Boolean isSeparateAccountId;
	@AuraEnabled public Boolean appNotExists {get;set;}

	public StartApplicationAllInfoWrapper(
		User u, 
		String applicationId, 
		String tradeAllyId, 
		Boolean editMode
	) {
		Application_Settings__c tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_CUSTOMER_REFERENCES);
		numberOfCR = 3;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfCR = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_TRADE_REFERENCES);
		numberOfTR = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfTR = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_TAX_DOCS);
		numberOfTaxDocs = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfTaxDocs = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_OTHER_DOCS);
		numberOfOtherDocs = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfOtherDocs = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_INSURANCES);
		numberOfInsurances = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfInsurances = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_LICENSES);
		numberOfLicenses = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfLicenses = Integer.valueOf(tempSetting.Value__c);
		}

		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_CERTIFICATIONS);
		numberOfCertifications = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfCertifications = Integer.valueOf(tempSetting.Value__c);
		}

		this.applicationId = validateApplicationId(applicationId);
		this.u = u;
		this.accountId = tradeAllyId;
		findTradeAllyId();
		isSeparateAccountId = (accountId != null);
		if (!isSeparateAccountId) {
			accountId = u.Contact.AccountId;
		}
		isCommunityUser = (u.Contact.AccountId != null);
		isValidUser = (accountId != null);
		if (isValidUser) {
			prepareAppData(accountId);
			this.editMode = editMode;
		}

		if (applicationStages == null){
			getApplicationStagesByTradeAllyType(accountId);
		}
		Boolean certificationsTab = applicationStages.Certifications__c;
        Boolean customerReferencesTab = applicationStages.Customer_References__c;
        Boolean insuranceInformationTab = applicationStages.Insurance_Information__c;
        Boolean licenseInformationTab = applicationStages.License_Information__c;
        Boolean programParticipationTab = applicationStages.Program_Participation__c;
        Boolean tradeReferencesTab = applicationStages.Trade_References__c;
		Boolean taxDocumentsTab = applicationStages.Tax_Documents__c;
		Boolean otherDocumentsTab = applicationStages.Other_Documents__c;
		Boolean demographicsTab = applicationStages.Demographics__c;

		tab3Visible = true;
		tab4Visible = true;
		tab5Visible = true;
		tab6Visible = true;
		tab7Visible = true;
		tab8Visible = true;
		tab9Visible = true;
		tab10Visible = true;
		tab11Visible = true;
		if (applicationStages != null) {
			if(!programParticipationTab) {
				tab3Visible = false;
			}
			if(!customerReferencesTab) {
				tab4Visible = false;
			}
			if(!tradeReferencesTab) {
				tab5Visible = false;
			}
			if(!insuranceInformationTab) {
				tab6Visible = false;
			}
			if(!licenseInformationTab) {
				tab7Visible = false;
			}
			if(!certificationsTab) {
				tab8Visible = false;
			}
			if(!taxDocumentsTab) {
				tab9Visible = false;
			}
			if(!otherDocumentsTab) {
				tab10Visible = false;
			}
			if(!demographicsTab) {
				tab11Visible = false;
			}
		}
	}

	public StartApplicationAllInfoWrapper(
		User u, 
		String applicationId, 
		String tradeAllyId
	) {
		Application_Settings__c tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_CUSTOMER_REFERENCES);
		numberOfCR = 3;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfCR = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_TRADE_REFERENCES);
		numberOfTR = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfTR = Integer.valueOf(tempSetting.Value__c);
		}
        tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_TAX_DOCS);
		numberOfTaxDocs = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfTaxDocs = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_OTHER_DOCS);
		numberOfOtherDocs = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfOtherDocs = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_INSURANCES);
		numberOfInsurances = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfInsurances = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_CERTIFICATIONS);
		numberOfCertifications = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfCertifications = Integer.valueOf(tempSetting.Value__c);
		}
		tempSetting = Application_Settings__c.getValues(Constants.NUMBER_OF_LICENSES);
		numberOfLicenses = 0;
		if (tempSetting != null && tempSetting.Value__c != null && tempSetting.Value__c.isNumeric()) {
			numberOfLicenses = Integer.valueOf(tempSetting.Value__c);
		}

		this.applicationId = validateApplicationId(applicationId);
		this.u = u;
		this.accountId = tradeAllyId;
		findTradeAllyId();
		isSeparateAccountId = (accountId != null);
		if (!isSeparateAccountId) {
			accountId = u.Contact.AccountId;
		}
		isCommunityUser = (u.Contact.AccountId != null);
		isValidUser = (accountId != null);
		if (isValidUser) {
			prepareAppData(accountId);
			if (!appNotExists) {
				prepareTradeAlly(accountId);
				prepareContactData(accountId);
				prepareTradeAllyReferenceData(accountId);
				prepareInsuranceData(accountId);
				prepareLicenseData(accountId);
				prepareCertificationData(accountId);
				prepareTaxData(accountId);
				prepareOtherData(accountId);
				prepareDemographicData(accountId);
			}
		}

        if(applicationStages == null){
			getApplicationStagesByTradeAllyType(accountId);
		}
        System.debug('applicationStages--'+applicationStages);
        Boolean certificationsTab = applicationStages.Certifications__c;
        Boolean customerReferencesTab = applicationStages.Customer_References__c;
        Boolean insuranceInformationTab = applicationStages.Insurance_Information__c;
        Boolean licenseInformationTab = applicationStages.License_Information__c;
        Boolean programParticipationTab = applicationStages.Program_Participation__c;
        Boolean tradeReferencesTab = applicationStages.Trade_References__c;
		Boolean taxDocumentsTab = applicationStages.Tax_Documents__c;
		Boolean otherDocumentsTab = applicationStages.Other_Documents__c;
		Boolean demographicsTab = applicationStages.Demographics__c;
		//Application_Settings__c tabsHideSetting = Application_Settings__c.getValues(Constants.HIDE_TABS);
		tab3Visible = true;
		tab4Visible = true;
		tab5Visible = true;
		tab6Visible = true;
		tab7Visible = true;
		tab8Visible = true;
		tab9Visible = true;
		tab10Visible = true;
		tab11Visible = true;
		if (applicationStages != null) {
			if(!programParticipationTab) {
				tab3Visible = false;
			}
			if(!customerReferencesTab) {
				tab4Visible = false;
			}
			if(!tradeReferencesTab) {
				tab5Visible = false;
			}
			if(!insuranceInformationTab) {
				tab6Visible = false;
			}
			if(!licenseInformationTab) {
				tab7Visible = false;
			}
			if(!certificationsTab) {
				tab8Visible = false;
			}
			if(!taxDocumentsTab) {
				tab9Visible = false;
			}
			if(!otherDocumentsTab) {
				tab10Visible = false;
			}
			if(!demographicsTab) {
				tab11Visible = false;
			}
		}
	}

	private String validateApplicationId(String appId) {
		if (
			appId == null ||
			appId.trim() == '' ||
			Id.valueOf(appId).getSObjectType().getDescribe().getName() != Constants.NAMESPACE + Constants.OBJECT_APPLICATION
		)
			appId = null;
		return appId;
	}

	private void findTradeAllyId() {
		if (accountId == null && applicationId != null) {
			List<Application__c> apps = [
				SELECT	Trade_Ally__c
				FROM	Application__c
				WHERE	Id =: applicationId
			];
			if (!apps.isEmpty())
				accountId = apps[0].Trade_Ally__c;
		}
	}

	private void prepareAppData(Id accountId) {
		System.debug('Preparing Application Data');
		listOfApplicationFields = new List<FieldInfoWrapper>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Application__c.FieldSets.Start_Application_Fields.getFields();
		app = sObjectUtility.getApplication(accountId,fieldsFromFS,applicationId);
		appNotExists = true;
		if (!(isSeparateAccountId && app.Id == null)) {
			appNotExists = false;
			if (app.Id == null) {
				app.Trade_Ally_User__c = u.ContactId;
				ESAPI.securityUtils().validatedInsert(new List<Application__c>{app});
                app = sObjectUtility.getApplication(accountId,fieldsFromFS,applicationId);
			}
			applicationId = app.Id;
			editMode = (
				app.Application_Status__c == Constants.INACTIVE_STATUS || 
				app.Application_Status__c == Constants.PENDING_STATUS
			);
			listOfApplicationFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
				fieldsFromFS,
				app
			);
			if (isCommunityUser) {
				for (FieldInfoWrapper info : listOfApplicationFields) {
					if (
						info.name == Constants.NAMESPACE + 'Terms_And_Conditions__r.' + Constants.NAMESPACE + 'Text__c'
					) {//TC_Accepted_Agreed__c
						info.editable = false;
						info.label = 'Terms and Conditions';
					}
				}
			}
			// logic to implement subscription window
			isSubscribed = getSubscriptionStatus(accountId);
		}
	}

	private Boolean getSubscriptionStatus(Id accountId) {
		Boolean isSubscribed = false;
		List<Trade_Ally_Subscription__c> tradeAllySubscriptionsList = new List<Trade_Ally_Subscription__c>();
		if (
			ESAPI.securityUtils().isAuthorizedToView(
				Constants.NAMESPACE + 'Trade_Ally_Subscription__c',
				new List<String>{
					'Id',
					Constants.NAMESPACE + 'Subscription_Status__c'
				}
			)
		) {
			tradeAllySubscriptionsList = [
				SELECT
						Id,
						Subscription_Status__c
				FROM    Trade_Ally_Subscription__c
				WHERE   Account__c =: accountId
			];
		}
		for (Integer i = 0, j = tradeAllySubscriptionsList.size(); i < j; i++) {
			if (tradeAllySubscriptionsList[i].Subscription_Status__c == 'Active') {
				isSubscribed = true;
			}
		}
		return isSubscribed;
	}

	private void prepareTradeAlly(Id accountId) {
		tradeAlly = sObjectUtility.getTradeAlly(accountId);
		prepareTradeAllyData(accountId);
	}

	private void prepareTradeAllyData(Id accountId) {
		listOfTradeAllyFields = new List<FieldInfoWrapper>();
		listOfTradeAllyFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			sObjectUtility.accountCOFields,
			tradeAlly
		);

		listOfTradeAllyBACIFields = new List<FieldInfoWrapper>();
		listOfTradeAllyBACIFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			sObjectUtility.accountBACIFields,
			tradeAlly
		);

		listOfTradeAllyPPFields = new List<FieldInfoWrapper>();
		listOfTradeAllyPPFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			sObjectUtility.accountPPFields,
			tradeAlly
		);
		addConstantFieldsToPPSection(accountId);
	}

	private void addConstantFieldsToPPSection(Id accountId) {

		listOfTradeAllyPPFields.addAll(getSectorDependentSpecialties());

		/*listOfTradeAllyPPFields.add(
			new FieldInfoWrapper(
				Constants.SPECIALITY,
				Constants.TRADE_ALLY_SPECIALITY,
				accountId,
				Constants.SPECIALITY_SPECIAL_LABEL,
				Constants.SPECIALITY_SPECIAL_FIELD
			)
		);*/
		
		listOfTradeAllyPPFields.add(
			new FieldInfoWrapper(
				Constants.TERRITORY,
				Constants.TERRITORY_ASSIGNMENT,
				accountId,
				Constants.TERRITORY_SPECIAL_LABEL,
				Constants.TERRITORY_SPECIAL_FIELD
			)
		);
	}

	private List<FieldInfoWrapper> getSectorDependentSpecialties() {
		List<FieldInfoWrapper> fieldWrapperList = new List<FieldInfoWrapper>();
		List<Specialty__c> listOfRecordsForPicklist = new List<Specialty__c>();
		String query = 'SELECT Id, Name, Sector__c FROM ' + Constants.NAMESPACE + String.escapeSingleQuotes(Constants.SPECIALITY) + ' ORDER BY Name ASC LIMIT 50000';
		List<String> fieldsToCheck = new List<String>{'Id','Name', 'Sector__c'};
		if (ESAPI.securityUtils().isAuthorizedToView(String.escapeSingleQuotes(Constants.NAMESPACE + Constants.SPECIALITY),fieldsToCheck)) {
			listOfRecordsForPicklist = Database.query(query);
		}
		Map<String, List<Specialty__c>> specMap = new Map<String, List<Specialty__c>>();
		for(Specialty__c s:listOfRecordsForPicklist) {
			String sector = s.Sector__c;
			if(sector != null) {
				/*String[] sectors = s.Sectors__c.split(';');
				for(String sector: sectors) {*/
					if(specMap.get(sector) == null) {
						List<Specialty__c> specList = new List<Specialty__c>();
						specList.add(s);
						specMap.put(sector,specList);
					} else {
						specMap.get(sector).add(s);
					}
				//}
			}
		}
		System.debug('specMap---------------'+specMap);
		for(String sector:specMap.keySet()) {
			List<sObject> specList = specMap.get(sector);
			fieldWrapperList.add(new FieldInfoWrapper(specList,sector,Constants.TRADE_ALLY_SPECIALITY,accountId,Constants.SPECIALITY_SPECIAL_FIELD));
		}
		System.debug('fieldWrapperList-----------'+fieldWrapperList);
		return fieldWrapperList;
	}

	private void prepareContactData(Id accountId) {
		Contact primaryContact = sObjectUtility.getPrimaryContact(accountId);
		listOfContactFields = new List<FieldInfoWrapper>();
		listOfContactFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			sObjectUtility.contactBACIFields,
			primaryContact
		);
		/*String attachmentName = '';
		if (!primaryContact.Attachments.isEmpty()) {
			attachmentName = Constants.PRIMARY_CONTACT_IMAGE;
		}
		listOfContactFields.add(
			new FieldInfoWrapper(
				attachmentName
			)
		);*/
		this.primaryContactId = primaryContact.Id;
	}

	public void prepareTradeAllyReferenceData(Id accountId) {
		listOfTradeAllyReferencesIdsToDelete = new List<String>();
		listOfTradeAllyCustomReferencesIdsToDelete = new List<String>();
		listOfTradeAllyReferencesFields = new List<List<FieldInfoWrapper>>();
		listOfTradeAllyTradeReferencesFields = new List<List<FieldInfoWrapper>>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Trade_Ally_Reference__c.FieldSets.Start_Application_CR.getFields();

		defaultTradeAllyReference = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			fieldsFromFS,
			new Trade_Ally_Reference__c()
		);

		List<Trade_Ally_Reference__c> listOfAvailableTradeAllyReferences = sObjectUtility.getTradeAllyReferences(accountId,fieldsFromFS);
		List<FieldInfoWrapper> tempListOfFields;// = new List<FieldInfoWrapper>();
		for (Trade_Ally_Reference__c tar : listOfAvailableTradeAllyReferences) {
			tempListOfFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
				fieldsFromFS,
				tar
			);
			if (tar.Reference_Type__c == Constants.CUSTOMER_REFERENCE) {
				listOfTradeAllyReferencesFields.add(
					tempListOfFields
				);
			} else {
				listOfTradeAllyTradeReferencesFields.add(
					tempListOfFields
				);
			}
		}
		if (editMode) {
			while (listOfTradeAllyReferencesFields.size() < numberOfCR) {
				listOfTradeAllyReferencesFields.add(
					defaultTradeAllyReference
				);
			}
			while (listOfTradeAllyTradeReferencesFields.size() < numberOfTR) {
				listOfTradeAllyTradeReferencesFields.add(
					defaultTradeAllyReference
				);
			}
		}
	}

	public void prepareTaxData(Id accountId) {
		listOfTaxIdsToDelete = new List<String>();
		listOfTaxFields = new List<List<FieldInfoWrapper>>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Tax__c.FieldSets.Start_Application_TI.getFields();
			
		defaultTax = prepareDefaultList(
			fieldsFromFS,
			true,
			new Tax__c()
		);

		List<Tax__c> listOfAvailableTaxes = (List<Tax__c>)sObjectUtility.getListOfSObjectsByType(
			//accountId,
			fieldsFromFS,
			applicationId,
			Constants.TAX
		);

		if (this.taxFiles == null) {
			this.taxFiles = new Map<String, String>();
		}
		for (Tax__c eachTax: listOfAvailableTaxes) {
			List<ContentDocumentLink> searchResults = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :eachTax.Id LIMIT 1];
			if (searchResults != null && searchResults.size() > 0) {
				this.taxFiles.put(eachTax.Id, searchResults.get(0).ContentDocumentId);
			}
		}

		for (Tax__c tax : listOfAvailableTaxes) {
			listOfTaxFields.add(
				prepareDefaultList(
					fieldsFromFS,
					true,
					tax
				)
			);
		}
		if (editMode) {
			while (listOfTaxFields.size() < numberOfTaxDocs) {
				listOfTaxFields.add(
					defaultTax
				);
			}
		}
	}

	public void prepareOtherData(Id accountId) {
		listOfOtherIdsToDelete = new List<String>();
		listOfOtherFields = new List<List<FieldInfoWrapper>>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Other_Document__c.FieldSets.Start_Application_OD.getFields();
			
		defaultOther = prepareDefaultList(
			fieldsFromFS,
			true,
			new Other_Document__c()
		);

		List<Other_Document__c> listOfAvailableOtherDocs = (List<Other_Document__c>)sObjectUtility.getListOfSObjectsByType(
			//accountId,
			fieldsFromFS,
			applicationId,
			Constants.OTHER
		);

		if (this.otherFiles == null) {
			this.otherFiles = new Map<String, String>();
		}
		for (Other_Document__c eachOtherDoc: listOfAvailableOtherDocs) {
			List<ContentDocumentLink> searchResults = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :eachOtherDoc.Id LIMIT 1];
			if (searchResults != null && searchResults.size() > 0) {
				this.otherFiles.put(eachOtherDoc.Id, searchResults.get(0).ContentDocumentId);
			}
		}

		for (Other_Document__c other : listOfAvailableOtherDocs) {
			listOfOtherFields.add(
				prepareDefaultList(
					fieldsFromFS,
					true,
					other
				)
			);
		}
		if (editMode) {
			while (listOfOtherFields.size() < numberOfOtherDocs) {
				listOfOtherFields.add(
					defaultOther
				);
			}
		}
	}

	public void prepareDemographicData(Id accountId) {
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Demographic__c.FieldSets.Start_Application_AI.getFields();
		listOfTradeAllyDemographicFields = new List<FieldInfoWrapper>();
		applicantInfo = sObjectUtility.getApplicantInfo(accountId,fieldsFromFS,applicationId);
		if (applicantInfo.Id == null) {
				ESAPI.securityUtils().validatedInsert(new List<Demographic__c>{applicantInfo});
		}
		listOfTradeAllyDemographicFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			fieldsFromFS,
			applicantInfo
		);
	}

	public void prepareInsuranceData(Id accountId) {
		listOfInsurancesIdsToDelete = new List<String>();
		listOfInsurancesFields = new List<List<FieldInfoWrapper>>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Insurance__c.FieldSets.Start_Application_II.getFields();
			
		defaultInsurance = prepareDefaultList(
			fieldsFromFS,
			true,
			new Insurance__c()
		);

		List<Insurance__c> listOfAvailableInsurances = (List<Insurance__c>)sObjectUtility.getListOfSObjectsByType(
			//accountId,
			fieldsFromFS,
			applicationId,
			Constants.INCURANCE
		);

		// populate insurance files, if any
		if (this.insuranceFiles == null) {
			this.insuranceFiles = new Map<String, String>();
		}
		for (Insurance__c eachInsurance: listOfAvailableInsurances) {
			List<ContentDocumentLink> searchResults = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :eachInsurance.Id LIMIT 1];
			if (searchResults != null && searchResults.size() > 0) {
				this.insuranceFiles.put(eachInsurance.Id, searchResults.get(0).ContentDocumentId);
			}
		}

		for (Insurance__c insurance : listOfAvailableInsurances) {
			listOfInsurancesFields.add(
				prepareDefaultList(
					fieldsFromFS,
					true,
					insurance
				)
			);
		}
		
		// get the insurance


		if (editMode) {
			while (listOfInsurancesFields.size() < numberOfInsurances) {
				listOfInsurancesFields.add(
					defaultInsurance
				);
			}
		}
	}

	public void prepareLicenseData(Id accountId) {
		System.debug('Prepare License Data');
		listOfLicensesIdsToDelete = new List<String>();
		listOfLicensesFields = new List<List<FieldInfoWrapper>>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.License__c.FieldSets.Start_Application_LI.getFields();
			
		defaultLicense = prepareDefaultList(
			fieldsFromFS,
			true,
			new License__c()
		);

		List<License__c> listOfAvailableLicenses = (List<License__c>)sObjectUtility.getListOfSObjectsByType(
			//accountId,
			fieldsFromFS,
			applicationId,
			Constants.LICENSE
		);

		if (this.licenseFiles == null) {
			this.licenseFiles = new Map<String, String>();
		}
		for (License__c eachLicense: listOfAvailableLicenses) {
			List<ContentDocumentLink> searchResults = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :eachLicense.Id LIMIT 1];
			if (searchResults != null && searchResults.size() > 0) {
				this.licenseFiles.put(eachLicense.Id, searchResults.get(0).ContentDocumentId);
			}
		}
		System.debug('License Files: ' + this.licenseFiles);

		for (License__c license : listOfAvailableLicenses) {
			listOfLicensesFields.add(
				prepareDefaultList(
					fieldsFromFS,
					true,
					license
				)
			);
		}
		System.debug('listOfLicensesFields--------'+listOfLicensesFields);
		if (editMode) {
			while (listOfLicensesFields.size() < numberOfLicenses) {
				listOfLicensesFields.add(
					defaultLicense
				);
			}
		}
	}

	public void prepareCertificationData(Id accountId) {
		listOfCertificationsIdsToDelete = new List<String>();
		listOfCertificationsFields = new List<List<FieldInfoWrapper>>();
		List<Schema.FieldSetMember> fieldsFromFS = SObjectType.Certification__c.FieldSets.Start_Application_C.getFields();
		defaultCertification = prepareDefaultList(
			fieldsFromFS,
			true,
			new Certification__c()
		);

		List<Certification__c> listOfAvailableCertifications = (List<Certification__c>)sObjectUtility.getListOfSObjectsByType(
			//accountId,
			fieldsFromFS,
			applicationId,
			Constants.CERTIFICATION
		);

		if (this.certificationFiles == null) {
			this.certificationFiles = new Map<String, String>();
		}
		for (Certification__c eachCert: listOfAvailableCertifications) {
			List<ContentDocumentLink> searchResults = [SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId = :eachCert.Id LIMIT 1];
			if (searchResults != null && searchResults.size() > 0) {
				this.certificationFiles.put(eachCert.Id, searchResults.get(0).ContentDocumentId);
			}
		}

		for (Certification__c certification : listOfAvailableCertifications) {
			listOfCertificationsFields.add(
				prepareDefaultList(
					fieldsFromFS,
					true,
					certification
				)
			);
		}
		if (editMode) {
			while (listOfCertificationsFields.size() < numberOfCertifications) {
				listOfCertificationsFields.add(
					defaultCertification
				);
			}
		}
	}
    
    private static void getApplicationStagesByTradeAllyType(String accountId) {
        system.debug('accountId--'+accountId);
		if(applicationStages != null) return;
		List<Trade_Ally_Type_Application_Stages_map__mdt> applicationStagesObjects;
        List<Account> accountTradeAllyObject;
        if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Trade_Ally_Type_Application_Stages_map__mdt', new List<String>{
            'Id', Constants.NAMESPACE + 'Certifications__c', Constants.NAMESPACE + 'Customer_References__c', Constants.NAMESPACE + 'Application_Type__c',
                Constants.NAMESPACE + 'Insurance_Information__c', Constants.NAMESPACE + 'License_Information__c', 
                Constants.NAMESPACE + 'Program_Participation__c', Constants.NAMESPACE + 'Trade_References__c', 
                Constants.NAMESPACE + 'Tax_Documents__c', Constants.NAMESPACE + 'Other_Documents__c', Constants.NAMESPACE + 'Demographics__c'
                })) {
            accountTradeAllyObject = [
                SELECT 
                		Primary_Business_Type__c
                FROM	Account
                WHERE	Id =: accountId
            ];
            String primaryBusinessType = null;
            if(accountTradeAllyObject.size() > 0){
                accountTradeAlly = accountTradeAllyObject[0];
                primaryBusinessType = accountTradeAlly.Primary_Business_Type__c;
            }
            //Applies when there is none or only one application type defined for a utility
			if(primaryBusinessType == null) {
				applicationStagesObjects = [
					SELECT 
						Id,
						Certifications__c,
						Customer_References__c,
                		Insurance_Information__c,
                		License_Information__c,
                		Program_Participation__c,
                		Trade_References__c,
						Tax_Documents__c,
						Other_Documents__c,
						Demographics__c
                    FROM	Trade_Ally_Type_Application_Stages_map__mdt
                    LIMIT	1
				];
                if(applicationStagesObjects.size() > 0) {
                    applicationStages = applicationStagesObjects[0];
                } else {
                    applicationStages = new Trade_Ally_Type_Application_Stages_map__mdt(
                            Certifications__c = true,
                            Customer_References__c = true,
                            Insurance_Information__c = true,
                            License_Information__c = true,
                            Program_Participation__c = true,
                            Trade_References__c = true,
                            Tax_Documents__c = true,
                            Other_Documents__c = true,
                            Demographics__c = true
                    );
                }
				return;
			}
			applicationStagesObjects = [
				SELECT 
						Id,
						Certifications__c,
						Customer_References__c,
                		Insurance_Information__c,
                		License_Information__c,
                		Program_Participation__c,
                		Trade_References__c,
						Tax_Documents__c,
						Other_Documents__c,
						Demographics__c
				FROM	Trade_Ally_Type_Application_Stages_map__mdt
                WHERE	Application_Type__c =: primaryBusinessType
				LIMIT	50000
			];
		}
		if(applicationStagesObjects.size() > 0) {
			applicationStages = applicationStagesObjects[0];
		}
	}

	public List<FieldInfoWrapper> prepareDefaultList(
		List<Schema.FieldSetMember> fieldsFromFS, 
		Boolean withAttachment,
		sObject record
	) {
		List<FieldInfoWrapper> tempListOfFields = FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
			fieldsFromFS,
			record
		);
		if (withAttachment) {
			FieldInfoWrapper attachmentWrapper = new FieldInfoWrapper('');
			/*attachmentWrapper.sObjectType = String.valueOf(record.getSObjectType());
			Object recid =  record.get('Id');
			Object recName =  record.get('Name');
			if(recid != null)
				attachmentWrapper.recordId = String.valueOf(recid);
			if(recName != null)
				attachmentWrapper.recordName = String.valueOf(recName);*/
			tempListOfFields.add(attachmentWrapper);
		}
		System.debug('tempListOfFields----'+tempListOfFields);
		return tempListOfFields;
	}
}