global with sharing class SelfRegisterTradeAllyController {
    
    public SelfRegisterTradeAllyController() {
        //TODO
    }
    
    //--- Standard Methods ---//
    // Additional parameters:
    // - registrationCode
    // - companyCity
    // - companyState
    // - companyPhoneNumber
    @AuraEnabled
    public static String selfRegister(String selfRegisterTradeAllyWrapperJSON) {
        Savepoint sp = null;
        try {
            SelfRegisterTradeAllyWrapper tradeAllyWrapper = (SelfRegisterTradeAllyWrapper) System.JSON.deserialize(selfRegisterTradeAllyWrapperJSON, SelfRegisterTradeAllyWrapper.class);
            System.debug('tradeAllyWrapper' + tradeAllyWrapper);
            sp = Database.setSavepoint();
            if (tradeAllyWrapper.lastname == null || String.isEmpty(tradeAllyWrapper.lastname)) {
                return Label.Site.lastname_is_required;
            }
            if (tradeAllyWrapper.email == null || String.isEmpty(tradeAllyWrapper.email)) {
                return Label.Site.email_is_required;
            }
            User u = new User();
            u.Username = tradeAllyWrapper.email;
            u.put('Email', tradeAllyWrapper.email);
            u.FirstName = tradeAllyWrapper.firstname;
            u.LastName = tradeAllyWrapper.lastname;
            u.Approved_Application__c = false;
            String networkId = Network.getNetworkId();
            if (networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI', true);
            }
            String nickname = ((tradeAllyWrapper.firstname != null && tradeAllyWrapper.firstname.length() > 0) ? tradeAllyWrapper.firstname.substring(0, 1) : '') + tradeAllyWrapper.lastname.substring(0, 1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            u.put('CommunityNickname', nickname);
            if (tradeAllyWrapper.extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(tradeAllyWrapper.extraFields);
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String, Object> thisField = (Map<String, Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
            if (tradeAllyWrapper.includePassword) {
                if (!isValidPassword(tradeAllyWrapper.password, tradeAllyWrapper.confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
                validatePassword(u, tradeAllyWrapper.password, tradeAllyWrapper.confirmPassword);
            } else {
                tradeAllyWrapper.password = null;
            }
            
            //--- Start of custom validation ---//
            
            Account tradeAlly = null;
            Trade_Ally_Safe_Container__c tradeAllySafeContainer = null;
            // Check if all the necessary data for Trade Ally was provided
            if (String.isBlank(tradeAllyWrapper.registrationCode)) {
                if (String.isBlank(u.Accept_TC__c)) {
                    return Constants.MISSED_TERMS_CONDITIONS_ERROR;
                }
                if (String.isBlank(u.CompanyName)) {
                    return Constants.MISSED_COMPANY_NAME_ERROR;
                }
                if (String.isBlank(tradeAllyWrapper.companyCity)) {
                    return Constants.MISSED_COMPANY_CITY_ERROR;
                }
                if (String.isBlank(tradeAllyWrapper.companyState)) {
                    return Constants.MISSED_COMPANY_STATE_ERROR;
                }
                if(tradeAllyWrapper.includeApplicationType) {
                    if (String.isBlank(tradeAllyWrapper.companyType)) {
                        return Constants.MISSED_BUSINESS_TYPE_ERROR;
                    }
                }
            } else {
                tradeAlly = SelfRegisterTradeAllyController.getTradeAllyByRegistrationCode(tradeAllyWrapper.registrationCode);
                if (tradeAlly != null) {
                    tradeAllyWrapper.companyName = tradeAlly.Name;
                    tradeAllyWrapper.companyState = tradeAlly.BillingState;
                    tradeAllyWrapper.companyCity = tradeAlly.BillingCity;
                } else {
                    return Constants.REGISTRATION_CODE_INCORRECT;
                }
            }
            
            if (String.isBlank(tradeAllyWrapper.companyPhoneNumber)) {
                return Constants.MISSED_COMPANY_PHONE_NUMBER_ERROR;
            }
            // Check if user with specified username exists
            if (SelfRegisterTradeAllyUtility.ifUsernameExists(u.Username)) {
                Database.rollback(sp);
                return Constants.USER_EXISTS_ERROR_MESSAGE;
            }
            // If the registration code is null, and duplicate was not already chosen, duplicate check takes place
            if (String.isBlank(tradeAllyWrapper.registrationCode) && String.isBlank(tradeAllyWrapper.accountId)) {
                List<Account> tradeAlliesDuplicateList = SelfRegisterTradeAllyController.getTradeAllyDuplicates(u.CompanyName, tradeAllyWrapper.companyCity, tradeAllyWrapper.companyState);
                // Check if duplicate allies were found. If were, show the duplicates page
                if (!tradeAlliesDuplicateList.isEmpty()) {
                    return JSON.serialize(
                        new SelfRegisterTradeAllyWrapper(tradeAllyWrapper.firstname, tradeAllyWrapper.lastname, u.CompanyName, tradeAllyWrapper.companyCity, tradeAllyWrapper.companyState,
                                                         tradeAllyWrapper.companyType, tradeAllyWrapper.companyPhoneNumber, tradeAllyWrapper.email, tradeAllyWrapper.password,
                                                         tradeAllyWrapper.confirmPassword, tradeAllyWrapper.accountId, tradeAllyWrapper.regConfirmUrl, tradeAllyWrapper.extraFields,
                                                         tradeAllyWrapper.startUrl, tradeAllyWrapper.includePassword, tradeAllyWrapper.registrationCode, tradeAlliesDuplicateList, true
                                                        )
                    );
                    // If no duplicates were found, create new Trade Ally with specified Name/City/State. No user limit by default
                } else {
                    tradeAlly = new Account(
                        Name = u.CompanyName,
                        OwnerId = SelfRegisterTradeAllyController.getDefaultAccountOwnerId(),
                        BillingCity = tradeAllyWrapper.companyCity,
                        BillingState = tradeAllyWrapper.companyState,
                        //Business_Type__c = tradeAllyWrapper.companyType,
                        Primary_Business_Type__c = tradeAllyWrapper.companyType,
                        Phone = tradeAllyWrapper.companyPhoneNumber,
                        User_Limit__c = 0,
                        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
                    );
                    ESAPI.securityUtils().validatedInsert(new List<Account> { tradeAlly });
                }
            } else {
                // If registration code was specified and accountId for Trade Ally duplicate was not
                if (String.isNotBlank(tradeAllyWrapper.registrationCode) && String.isBlank(tradeAllyWrapper.accountId)) {
                    tradeAlly = SelfRegisterTradeAllyController.getTradeAllyByRegistrationCode(tradeAllyWrapper.registrationCode);
                    if (tradeAlly == null) {
                        Database.rollback(sp);
                        return Constants.NO_REGISTRATION_CODE_MATCHES_ERROR;
                    }
                    // If the duplicate was selected by user, specify its trade ally
                } else if (String.isNotBlank(tradeAllyWrapper.accountId)) {
                    tradeAlly = SelfRegisterTradeAllyController.getTradeAllyById(tradeAllyWrapper.accountId);
                    if (tradeAlly == null) {
                        Database.rollback(sp);
                        return Constants.TRADE_ALLY_WAS_REMOVED_ERROR_MESSAGE;
                    }
                }
            }
            // Check if user limit for trade ally account was reached over. If so, send an email to the account owner
            // and create contact and task
            tradeAllySafeContainer = SelfRegisterTradeAllyController.getTradeAllySafeContainerByRegistrationCode(tradeAlly.Id, tradeAlly.Registration_Code__c);
            if (!SelfRegisterTradeAllyController.isAccountUserLimitReachedOver(tradeAlly.User_Limit__c, tradeAllySafeContainer.Number_Of_Active_Users__c)) {
                Database.rollback(sp);
                SelfRegisterTradeAllyController.createReachedOverLimitUserData(u.Firstname, u.Lastname, tradeAlly.OwnerId);
                SelfRegisterTradeAllyController.sendEmail(new List<String> { tradeAlly.Owner.Email }, Constants.REGISTRATION_ERROR_MESSAGE, Constants.USER_LIMIT_EXCEPTION_MESSAGE);
                return Constants.USER_LIMIT_EXCEPTION_MESSAGE;
            }
            String userId = Site.createPortalUser(u, tradeAlly.Id, tradeAllyWrapper.password);
            // Increase the number of active users if user was registered successfully, otherwise an exception
            // will be thrown by Site.createPortalUser method
            if (String.isNotBlank(userId)) {
                tradeAllySafeContainer.Number_Of_Active_Users__c++;
                ESAPI.securityUtils().validatedUpsert(new List<Trade_Ally_Safe_Container__c> { tradeAllySafeContainer });
            }
            
            //--- End of custom validation ---//
            
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';
            }
            if (userId != null) {
                if (tradeAllyWrapper.password != null && tradeAllyWrapper.password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(tradeAllyWrapper.email, tradeAllyWrapper.password, tradeAllyWrapper.startUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                } else {
                    ApexPages.PageReference confirmRef = new PageReference(tradeAllyWrapper.regConfirmUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                    }
                }
            }
            return null;
        } catch(Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String selfRegisterWithRegCode(String selfRegisterTradeAllyWrapperJSON, Boolean approvalForSubUser) {
        Savepoint sp = null;
        try {
            SelfRegisterTradeAllyWrapper tradeAllyWrapper = (SelfRegisterTradeAllyWrapper) System.JSON.deserialize(selfRegisterTradeAllyWrapperJSON, SelfRegisterTradeAllyWrapper.class);
            System.debug('tradeAllyWrapper' + tradeAllyWrapper);
            sp = Database.setSavepoint();
            if (tradeAllyWrapper.registrationCode == null || String.isEmpty(tradeAllyWrapper.registrationCode)) {
                return Constants.MISSED_REG_CODE_ERROR;
            }
            if (tradeAllyWrapper.firstname == null || String.isEmpty(tradeAllyWrapper.firstname)) {
                return Constants.MISSED_FIRST_NAME_ERROR;
            }
            if (tradeAllyWrapper.lastname == null || String.isEmpty(tradeAllyWrapper.lastname)) {
                return Label.Site.lastname_is_required;
            }
            if (tradeAllyWrapper.email == null || String.isEmpty(tradeAllyWrapper.email)) {
                return Label.Site.email_is_required;
            }
            User u = new User();
            u.Username = tradeAllyWrapper.email;
            u.put('Email', tradeAllyWrapper.email);
            u.FirstName = tradeAllyWrapper.firstname;
            u.LastName = tradeAllyWrapper.lastname;
            u.Approved_Application__c = false;
            if(approvalForSubUser) {
                u.Approval_Required__c = true;
            }
            String networkId = Network.getNetworkId();
            if (networkId != null && siteAsContainerEnabled(Network.getLoginUrl(networkId))) {
                u.put('UserPreferencesHideS1BrowserUI', true);
            }
            String nickname = ((tradeAllyWrapper.firstname != null && tradeAllyWrapper.firstname.length() > 0) ? tradeAllyWrapper.firstname.substring(0, 1) : '') + tradeAllyWrapper.lastname.substring(0, 1);
            nickname += String.valueOf(Crypto.getRandomInteger()).substring(1, 7);
            u.put('CommunityNickname', nickname);
            if (tradeAllyWrapper.extraFields != null) {
                List<Object> extraFieldsList = (List<Object>) JSON.deserializeUntyped(tradeAllyWrapper.extraFields);
                for (Object thisFieldObject : extraFieldsList) {
                    Map<String, Object> thisField = (Map<String, Object>) thisFieldObject;
                    Schema.SObjectField sof = Schema.SObjectType.User.fields.getMap().get((String) thisField.get('fieldPath'));
                    u.put(sof, thisField.get('value'));
                }
            }
            if (tradeAllyWrapper.includePassword) {
                if (!isValidPassword(tradeAllyWrapper.password, tradeAllyWrapper.confirmPassword)) {
                    return Label.site.passwords_dont_match;
                }
                validatePassword(u, tradeAllyWrapper.password, tradeAllyWrapper.confirmPassword);
            } else {
                tradeAllyWrapper.password = null;
            }
            
            //--- Start of custom validation ---//
            /*if(tradeAllyWrapper.includeApplicationType) {
                if (String.isBlank(tradeAllyWrapper.companyType)) {
                    return Constants.MISSED_BUSINESS_TYPE_ERROR;
                }
            }*/
            if (String.isBlank(u.Accept_TC__c)) {
                return Constants.MISSED_TERMS_CONDITIONS_ERROR;
            }
            Trade_Ally_Safe_Container__c tradeAllySafeContainer = null;
            Account tradeAlly = SelfRegisterTradeAllyController.getTradeAllyByRegistrationCode(tradeAllyWrapper.registrationCode);
            if (tradeAlly != null) {
                tradeAllyWrapper.companyName = tradeAlly.Name;
                tradeAllyWrapper.companyState = tradeAlly.BillingState;
                tradeAllyWrapper.companyCity = tradeAlly.BillingCity;
                u.CompanyName = tradeAlly.Name;
                /*if(String.isNotBlank(tradeAllyWrapper.companyType)) {
                    tradeAlly.Primary_Business_Type__c = tradeAllyWrapper.companyType;
                    ESAPI.securityUtils().validatedUpdate(new List<Account> { tradeAlly });
                }*/
            } else {
                Database.rollback(sp);
                return Constants.REGISTRATION_CODE_INCORRECT;
            }
            // Check if user with specified username exists
            if (SelfRegisterTradeAllyUtility.ifUsernameExists(u.Username)) {
                Database.rollback(sp);
                return Constants.USER_EXISTS_ERROR_MESSAGE;
            }
            // Check if user limit for trade ally account was reached over. If so, send an email to the account owner
            // and create contact and task
            tradeAllySafeContainer = SelfRegisterTradeAllyController.getTradeAllySafeContainerByRegistrationCode(tradeAlly.Id, tradeAlly.Registration_Code__c);
            if (!SelfRegisterTradeAllyController.isAccountUserLimitReachedOver(tradeAlly.User_Limit__c, tradeAllySafeContainer.Number_Of_Active_Users__c)) {
                Database.rollback(sp);
                SelfRegisterTradeAllyController.createReachedOverLimitUserData(u.Firstname, u.Lastname, tradeAlly.OwnerId);
                SelfRegisterTradeAllyController.sendEmail(new List<String> { tradeAlly.Owner.Email }, Constants.REGISTRATION_ERROR_MESSAGE, Constants.USER_LIMIT_EXCEPTION_MESSAGE);
                return Constants.USER_LIMIT_EXCEPTION_MESSAGE;
            }
            String userId = Site.createPortalUser(u, tradeAlly.Id, tradeAllyWrapper.password);
            // Increase the number of active users if user was registered successfully, otherwise an exception
            // will be thrown by Site.createPortalUser method
            if (String.isNotBlank(userId)) {
                tradeAllySafeContainer.Number_Of_Active_Users__c++;
                ESAPI.securityUtils().validatedUpsert(new List<Trade_Ally_Safe_Container__c> { tradeAllySafeContainer });
            }
            //--- End of custom validation ---//
            
            if (Test.isRunningTest()) {
                userId = 'fakeUserId';
            }
            if (userId != null) {
                if (tradeAllyWrapper.password != null && tradeAllyWrapper.password.length() > 1) {
                    ApexPages.PageReference lgn = Site.login(tradeAllyWrapper.email, tradeAllyWrapper.password, tradeAllyWrapper.startUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(lgn);
                    }
                } else {
                    ApexPages.PageReference confirmRef = new PageReference(tradeAllyWrapper.regConfirmUrl);
                    if (!Test.isRunningTest()) {
                        aura.redirect(confirmRef);
                    }
                }
            }
            return null;
        } catch(Exception ex) {
            Database.rollback(sp);
            return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String getExtraFieldsFromFieldSet(String extraFieldsFieldSet) {
        extraFieldsFieldSet = String.isBlank(extraFieldsFieldSet) ? null : String.escapeSingleQuotes(extraFieldsFieldSet);
        List<Map<String, Object>> extraFields = new List<Map<String, Object>> ();
        Schema.FieldSet fieldSet = Schema.SObjectType.User.fieldSets.getMap().get(extraFieldsFieldSet);
        if (fieldSet != null) {
            for (Schema.FieldSetMember f : fieldSet.getFields()) {
                Map<String, Object> fieldDetail = new Map<String, Object> ();
                fieldDetail.put('dbRequired', f.getDBRequired());
                fieldDetail.put('fieldPath', f.getFieldPath());
                fieldDetail.put('label', f.getLabel());
                fieldDetail.put('required', f.getRequired());
                fieldDetail.put('type', f.getType());
                fieldDetail.put('value', '');
                extraFields.add(fieldDetail);
            }
        }
        return JSON.serialize(extraFields);
    }
    
    @AuraEnabled
    global static String setExperienceId(String expId) {
        expId = String.isBlank(expId) ? null : String.escapeSingleQuotes(expId);
        // Return null if there is no error, else it will return the error message
        try {
            if (expId != null) {
                Site.setExperienceId(expId);
            }
            return null;
        } catch(Exception ex) {
            return ex.getMessage();
        }
    }
    
    @TestVisible
    private static boolean isValidPassword(String password, String confirmPassword) {
        return password == confirmPassword;
    }
    
    @TestVisible
    private static boolean siteAsContainerEnabled(String communityUrl) {
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(communityUrl, '');
        return authConfig.isCommunityUsingSiteAsContainer();
    }
    
    @TestVisible
    private static void validatePassword(User u, String password, String confirmPassword) {
        if (!Test.isRunningTest()) {
            Site.validatePassword(u, password, confirmPassword);
        }
        return;
    }
    
    //--- Custom Aura Enabled Methods ---//
    
    @AuraEnabled
    public static String declineAllTradeAllyDuplicates(String selfRegisterTradeAllyWrapperJSON) {
        SelfRegisterTradeAllyWrapper tradeAllyWrapper = (SelfRegisterTradeAllyWrapper) System.JSON.deserialize(selfRegisterTradeAllyWrapperJSON, SelfRegisterTradeAllyWrapper.class);
        //Create new Trade Ally according to the info that was provided by user. No user limits by default.
        Account tradeAlly = new Account(
            Name = tradeAllyWrapper.companyName,
            OwnerId = SelfRegisterTradeAllyController.getDefaultAccountOwnerId(),
            BillingCity = tradeAllyWrapper.companyCity,
            BillingState = tradeAllyWrapper.companyState,
            Phone = tradeAllyWrapper.companyPhoneNumber,
            User_Limit__c = 0,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
        );
        ESAPI.securityUtils().validatedInsert(new List<Account> { tradeAlly });
        tradeAllyWrapper.accountId = tradeAlly.Id;
        return SelfRegisterTradeAllyController.selfRegister(JSON.serialize(tradeAllyWrapper));
    }
    
    // This method returns list of picklist values
    @AuraEnabled
    public static List<Map<String, String>> getPicklistInfo(
        String objectName,
        String fieldName,
        String firstLabel,
        String firstValue
    ) {
        objectName = String.isBlank(objectName) ? null : String.escapeSingleQuotes(objectName);
        fieldName = String.isBlank(fieldName) ? null : String.escapeSingleQuotes(fieldName);
        firstLabel = String.isBlank(firstLabel) ? null : String.escapeSingleQuotes(firstLabel);
        firstValue = String.isBlank(firstValue) ? null : String.escapeSingleQuotes(firstValue);
        List<Map<String, String>> picklistInfo = new List<Map<String, String>> ();
        Map<String, String> picklistLine = new Map<String, String> ();
        List<String> objectNames = new List<String> {
            objectName
                };
                    List<Schema.DescribeSobjectResult> objectDescribeResults = Schema.describeSObjects(objectNames);
        if (String.isNotBlank(firstLabel)) {
            picklistLine = new Map<String, String> ();
            picklistLine.put('label', firstLabel);
            picklistLine.put('value', firstValue);
            picklistInfo.add(picklistLine);
        }
        for (Schema.DescribeSobjectResult objectDescribeResult : objectDescribeResults) {
            List<Schema.PicklistEntry> picklistEntries = objectDescribeResult.fields.getMap().get(fieldName).getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                if (picklistEntry.isActive()) {
                    String picklistEntryValue = picklistEntry.getValue();
                    String picklistEntryLabel = picklistEntry.getLabel();
                    picklistLine = new Map<String, String> ();
                    picklistLine.put('value', picklistEntryValue);
                    picklistLine.put('label', picklistEntryLabel);
                    picklistInfo.add(picklistLine);
                }
            }
        }
        return picklistInfo;
    }
    
    //--- Custom Private Methods ---//
    
    // This method returns the Trade Ally specified by registrationCode
    private static Account getTradeAllyByRegistrationCode(String registrationCode) {
        List<Account> tradeAlliesList = new List<Account> ();
        List<String> fieldsToCheck = new List<String> {
            'Id',
                'OwnerId',
                'Name',
                'BillingState',
                'BillingCity',
                Constants.NAMESPACE + 'User_Limit__c',
                Constants.NAMESPACE + 'Number_Of_Active_Users__c',
                Constants.NAMESPACE + 'Registration_Code__c'
                };
                    if (ESAPI.securityUtils().isAuthorizedToView('Account', fieldsToCheck)) {
                        tradeAlliesList = [
                            SELECT
                            Id,
                            OwnerId,
                            Name,
                            BillingState,
                            BillingCity,
                            Owner.Email,
                            User_Limit__c,
                            Number_Of_Active_Users__c,
                            Registration_Code__c
                            FROM Account
                            WHERE
                            Registration_Code__c = :registrationCode AND
                            RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
                            LIMIT 1
                        ];
                    }
        if (!tradeAlliesList.isEmpty()) {
            return tradeAlliesList[0];
        }
        return null;
    }
    
    // This method returns the Trade Ally specified by Id
    private static Account getTradeAllyById(Id tradeAllyId) {
        List<Account> tradeAlliesList = new List<Account> ();
        List<String> fieldsToCheck = new List<String> {
            'Id',
                'OwnerId',
                Constants.NAMESPACE + 'User_Limit__c',
                Constants.NAMESPACE + 'Number_Of_Active_Users__c',
                Constants.NAMESPACE + 'Registration_Code__c'
                };
                    if (ESAPI.securityUtils().isAuthorizedToView('Account', fieldsToCheck)) {
                        tradeAlliesList = [
                            SELECT
                            OwnerId,
                            User_Limit__c,
                            Number_Of_Active_Users__c,
                            Registration_Code__c
                            FROM Account
                            WHERE
                            Id = :tradeAllyId AND
                            RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
                            LIMIT 1
                        ];
                    }
        if (!tradeAlliesList.isEmpty()) {
            return tradeAlliesList[0];
        }
        return null;
    }
    
    // This method returns the Auto-Generated Registration code by Trade Ally Id.
    // Needed if Registration Code was not specified and new Trade Ally was created.
    private static String getTradeAllyRegistrationCodeById(Id tradeAllyId) {
        List<Account> tradeAlliesList = new List<Account> ();
        List<String> fieldsToCheck = new List<String> {
            Constants.NAMESPACE + 'Registration_Code__c'
                };
                    if (ESAPI.securityUtils().isAuthorizedToView('Account', fieldsToCheck)) {
                        tradeAlliesList = [
                            SELECT Registration_Code__c
                            FROM Account
                            WHERE
                            Id = :tradeAllyId AND
                            RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
                            LIMIT 1
                        ];
                    }
        if (!tradeAlliesList.isEmpty()) {
            return tradeAlliesList[0].Registration_Code__c;
        }
        return null;
    }
    
    // This method returns the Trade Ally Safe container specified by registrationCode.
    // If no container was found, creates new with specified registration code and actual number of active users
    // The registration code can also be specified with the help of url parameters
    private static Trade_Ally_Safe_Container__c getTradeAllySafeContainerByRegistrationCode(Id tradeAllyId, String registrationCode) {
        String tradeAllyRegistrationCode = null;
        if (String.isBlank(registrationCode)) {
            tradeAllyRegistrationCode = SelfRegisterTradeAllyController.getTradeAllyRegistrationCodeById(tradeAllyId);
        } else {
            tradeAllyRegistrationCode = registrationCode;
        }
        List<Trade_Ally_Safe_Container__c> tradeAllySafeContainersList = new List<Trade_Ally_Safe_Container__c> ();
        List<String> fieldsToCheck = new List<String> {
            'Id',
                Constants.NAMESPACE + 'Number_Of_Active_Users__c'
                };
                    if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Trade_Ally_Safe_Container__c', fieldsToCheck)) {
                        tradeAllySafeContainersList = [
                            SELECT
                            Id,
                            Number_Of_Active_Users__c
                            FROM Trade_Ally_Safe_Container__c
                            WHERE Registration_Code__c = :tradeAllyRegistrationCode
                            LIMIT 1
                        ];
                    }
        if (!tradeAllySafeContainersList.isEmpty()) {
            return tradeAllySafeContainersList[0];
        } else {
            Trade_Ally_Safe_Container__c tradeAllySafeContainer = new Trade_Ally_Safe_Container__c(
                Registration_Code__c = tradeAllyRegistrationCode,
                Number_Of_Active_Users__c = SelfRegisterTradeAllyController.getNumberOfActiveUsersForTradeAlly(tradeAllyId)
            );
            return tradeAllySafeContainer;
        }
    }
    
    // Get the list of Account filtered by Company (Account) name
    private static List<Account> getTradeAllyDuplicates(String companyName, String companyCity, String companyState) {
        List<Account> tradeAlliesMap = new List<Account> ();
        List<String> fieldsToCheck = new List<String> {
            'Id',
                'Name',
                'BillingCity',
                'BillingState',
                'Phone'
                };
                    if (ESAPI.securityUtils().isAuthorizedToView('Account', fieldsToCheck)) {
                        tradeAlliesMap = [
                            SELECT
                            Id,
                            Name,
                            BillingCity,
                            BillingState,
                            Phone
                            FROM Account
                            WHERE
                            Name = :companyName AND
                            BillingCity = :companyCity AND
                            BillingState = :companyState AND
                            RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
                            LIMIT 50000
                        ];
                    }
        return tradeAlliesMap;
    }
    
    // Returns User Id with specified username
    public static Id getDefaultAccountOwnerId() {
        Trade_Ally_Owner_Settings__c treadeAllyOwnerSettings = Trade_Ally_Owner_Settings__c.getValues(Constants.DEFAULT_TRADE_ALLY_OWNER_CUSTOM_SETTINGS);
        List<User> users = new List<User> ();
        List<String> fieldsToCheck = new List<String> {
            'Id'
                };
                    if (ESAPI.securityUtils().isAuthorizedToView('User', fieldsToCheck)) {
                        users = [
                            SELECT Id
                            FROM User
                            WHERE Username = :treadeAllyOwnerSettings.Default_Trade_Ally_Owner_Username__c
                        ];
                    }
        if (!users.isEmpty()) {
            return users[0].Id;
        }
        return null;
    }
    
    //Count the  number of active users for Trade Ally specified by id
    private static Integer getNumberOfActiveUsersForTradeAlly(Id tradeAllyId) {
        Integer count;
        if (ESAPI.securityUtils().isAuthorizedToView('User', new List<String> { 'Id' })) {
            count = [
                SELECT COUNT()
                FROM User
                WHERE
                Contact.AccountId = :tradeAllyId AND
                IsActive = TRUE
                LIMIT 50000
            ];
        }
        return count;
    }
    
    // Check if Account with such Registration Code exists
    @TestVisible
    private static Boolean ifAccountWithRegistrationCodeExists(String registrationCode) {
        Integer count;
        if (ESAPI.securityUtils().isAuthorizedToView('Account', new List<String> { 'Id' })) {
            count = [
                SELECT COUNT()
                FROM Account
                WHERE
                Registration_Code__c = :registrationCode AND
                RecordTypeId = :Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId()
                LIMIT 50000
            ];
        }
        if (count > 0) {
            return true;
        }
        return false;
    }
    
    // Probably this should be trigger laters
    // Check if account user limit was reached over
    private static Boolean isAccountUserLimitReachedOver(Decimal userLimit, Decimal numberOfActiveUsers) {
        if ((userLimit == null) || (userLimit == 0) || (userLimit >= (numberOfActiveUsers + 1))) {
            return true;
        } else {
            return false;
        }
    }
    
    // Create contact and task for reached over limit user
    @TestVisible
    private static void createReachedOverLimitUserData(String contactFirstname, String contactLastname, Id accountOwnerId) {
        Contact reachedOverLimitUserContact = new Contact(
            Firstname = contactFirstname,
            Lastname = contactLastname,
            Contact_Needs_Review__c = true,
            Level__c = 'Secondary'
        );
        Task reachedOverLimitUserTask = new Task(
            Priority = 'High',
            ActivityDate = System.today(),
            Description = Constants.USER_LIMIT_TASK_COMMENT,
            OwnerId = accountOwnerId
        );
        if (Test.isRunningTest()) return;
        ESAPI.securityUtils().validatedInsert(new List<Contact> { reachedOverLimitUserContact });
        insert reachedOverLimitUserTask;
        //ESAPI.securityUtils().validatedInsert(new List<Task>{reachedOverLimitUserTask});
    }
    
    // This method sends an email with specified subject and text message to the specified email adresses
    @TestVisible
    private static void sendEmail(List<String> emailAdresses, String subject, String textOfTheMessage) {
        System.debug('sendEmail');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailAdresses;
        message.optOutPolicy = Constants.EMAIL_OPT_OUT_POLICY;
        message.subject = subject;
        message.plainTextBody = textOfTheMessage;
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage> { message };
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(messages);
    }
    
}