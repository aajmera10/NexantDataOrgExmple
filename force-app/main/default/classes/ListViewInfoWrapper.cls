public with sharing class ListViewInfoWrapper {

    @AuraEnabled public List<List<FieldInfoWrapper>> listOfWrappedRecords {get;set;}
    @AuraEnabled public List<ShortFieldInfoWrapper> listOfFieldsInfo {get;set;}
    @AuraEnabled public List<String> listOfFilters {get;set;}

    public ListViewInfoWrapper(
        String searchText, 
        String sortOrder, 
        String sortField, 
        String sObjectName,
        String fieldSetName,
        String recordTypeName, 
		String filterName
    ) {
        List<Schema.FieldSetMember> fieldsFromFS = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fieldSets.getMap().get(fieldSetName).getFields();
        //SObjectType.Account.fieldSets.List_View_Fields.getFields();
        List<sObject> listOfRecords = prepareListOfRecords(
            searchText, 
            sortOrder, 
            sortField, 
            fieldsFromFS,
            sObjectName,
            recordTypeName,
			filterName
        );
        listOfWrappedRecords = new List<List<FieldInfoWrapper>>();
        for (sObject record : listOfRecords) {
            listOfWrappedRecords.add(
                FieldsInfoUtility.prepareListOfWrappedFieldsInfo(
                    fieldsFromFS,
                    record
                )
            );
        }
		if (sObjectName == Constants.REFERRAL) {
			listOfFilters = new List<String>{
				Constants.REFERRAL_FILTER_ALL,
				Constants.REFERRAL_FILTER_RV,
				Constants.REFERRAL_FILTER_ER,
				Constants.REFERRAL_FILTER_CAR,
				Constants.REFERRAL_FILTER_CCR,
				Constants.REFERRAL_FILTER_CR
			};
		}
    }

    private List<sObject> prepareListOfRecords(
        String searchText, 
        String sortOrder, 
        String sortField, 
        List<Schema.FieldSetMember> fieldsFromFS, 
        String sObjectName,
        String recordTypeName, 
		String filterName
    ) {
        listOfFieldsInfo = new List<ShortFieldInfoWrapper>();
        String whereCondition = '';
        String fieldName;
        String query = 'SELECT Id';
		List<String> fieldsToCheck = new List<String>{'Id'};
        for (Schema.FieldSetMember f : fieldsFromFS) {
            fieldName = f.getFieldPath();
            query += ', ' + fieldName;
			fieldsToCheck.add(fieldName);
            listOfFieldsInfo.add(
                new ShortFieldInfoWrapper(
                    fieldName,
                    f.getLabel()
                )
            );
            whereCondition = getSmalWhereCondition(whereCondition, fieldName, searchText, f);
            if (f.getType().name() == 'REFERENCE') {
                if (fieldName.endsWithIgnoreCase('__c')) {
                    fieldName = fieldName.removeEndIgnoreCase('c') + 'r.Name';
                } else if (fieldName.endsWithIgnoreCase('id')) {
                    fieldName = fieldName.removeEndIgnoreCase('id') + '.Name';
                }
                query += ', ' + fieldName;
                whereCondition = getSmalWhereCondition(whereCondition, fieldName, searchText, f);
            }
        }
        query += ' FROM ' + sObjectName + ' WHERE ';
        if (searchText != null && searchText.trim() != '') {
            query += '(' + whereCondition.removeEnd(' OR ') + ') AND ';
        }
        if (recordTypeName != null) {
            query += 'RecordTypeId = \'' + getRecordTypeId(recordTypeName) + '\' AND ';//'Trade Ally'
        }
		if (filterName != null) {
			query += implementSelectedFilter(sObjectName,filterName);
		}
        query = query.removeEnd(' AND ');
        query = query.removeEnd(' WHERE ');
        if (sortField == null || sortField.trim() == '') {
            sortField = 'Name';
        }
        if (sortOrder == null || sortOrder.trim() == '') {
            sortOrder = 'ASC';
        }
        query += ' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS LAST';
        /*if (sortField != 'Name') {
            query += ', Name ASC';
        }*/
        System.debug(query);
		List<sObject> listOfAccounts = new List<sObject>();
		if (ESAPI.securityUtils().isAuthorizedToView(sObjectName,fieldsToCheck)) {
			listOfAccounts = Database.query(query);
		}
		return listOfAccounts;
    }

	private String implementSelectedFilter(String sObjectName, String filterName) {
		String additionalConditions = '';
		if (sObjectName == Constants.REFERRAL) {
			if (filterName == Constants.REFERRAL_FILTER_RV) {
				additionalConditions += 'LastViewedDate != null';
			} else if (filterName == Constants.REFERRAL_FILTER_ER) {
				additionalConditions += 'Referral_Status__c = \'Expired\'';
			} else if (filterName == Constants.REFERRAL_FILTER_CAR) {
				additionalConditions += '(Referral_Status__c = \'Created\' OR Referral_Status__c = \'Assigned\')';
			} else if (filterName == Constants.REFERRAL_FILTER_CCR) {
				additionalConditions += 'Referral_Status__c = \'Customer Contacted\'';
			} else if (filterName == Constants.REFERRAL_FILTER_CR) {
				additionalConditions += 'Referral_Status__c = \'Converted\'';
			}
		}
		return additionalConditions;
	}

    private String getSmalWhereCondition(String whereCondition, String fieldName, String searchText, Schema.FieldSetMember f) {
        if (searchText != null && searchText.trim() != '') {
            System.debug(fieldName + ' ' + f.getType());
            if (
                f.getType() == Schema.DisplayType.String ||
                f.getType() == Schema.DisplayType.Picklist ||
                f.getType() == Schema.DisplayType.EMAIL ||
                f.getType() == Schema.DisplayType.URL ||
                f.getType() == Schema.DisplayType.COMBOBOX ||
                f.getType() == Schema.DisplayType.Phone
            ) {
                whereCondition += String.escapeSingleQuotes(fieldName) + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' OR ';
            } else if (
                (
                    f.getType() == Schema.DisplayType.Currency || 
                    f.getType() == Schema.DisplayType.PERCENT || 
                    f.getType() == Schema.DisplayType.INTEGER ||
                    f.getType() == Schema.DisplayType.Double 
                ) &&
                searchText.isNumeric()
            ) {
                whereCondition += String.escapeSingleQuotes(fieldName) + ' = ' + String.escapeSingleQuotes(searchText) + ' OR ';
            }
        }
        return whereCondition;
    }

    private Id getRecordTypeId(String recordTypeName) {
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
    public class ShortFieldInfoWrapper {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String label {get;set;}

        public ShortFieldInfoWrapper(String name, String label) {
            this.name = name;
            this.label = label;
        }
    }
}