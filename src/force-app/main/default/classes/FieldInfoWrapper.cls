public with sharing class FieldInfoWrapper {

	@AuraEnabled public String label {get;set;}
	@AuraEnabled public String name {get;set;}
	@AuraEnabled public String type {get;set;}
	//@AuraEnabled public Object value {get;set;}
	@AuraEnabled public String value {get;set;}
	@AuraEnabled public Boolean valueBoolean {get;set;}
	@AuraEnabled public Decimal valueNumber {get;set;}
	@AuraEnabled public Date valueDate {get;set;}
	@AuraEnabled public DateTime valueDateTime {get;set;}

	@AuraEnabled public String recordId {get;set;}

	@AuraEnabled public String displayValue {get;set;}
	
	@AuraEnabled public Boolean available {get;set;}
	@AuraEnabled public Boolean editable {get;set;}
	@AuraEnabled public Boolean required {get;set;}
	@AuraEnabled public String sObjectType {get;set;}
	@AuraEnabled public String parentObjectType {get;set;}
	@AuraEnabled public List<PickListWrapper> picklistValues {get;set;}
	
	@AuraEnabled public Boolean wasUpdated {get;set;}
	@AuraEnabled public Boolean isValid {get;set;}
	@AuraEnabled public Boolean isZipCode {get;set;}

	@AuraEnabled public String recordName {get;set;}
    @AuraEnabled public Boolean showRequiredFields {get;set;}

	public FieldInfoWrapper(String label) {
		this.available = false;
		this.type = 'ATTACHMENT';
		this.label = label;
		this.editable = false;
		this.wasUpdated = false;
		this.isValid = true;
		this.isZipCode = false;
        this.showRequiredFields = true;
	}

	public FieldInfoWrapper(
		List<sObject> listOfRecordsForPicklist,
		String label,
		String sObjectJunctionType,
		Id tradeAllyId,
		String junctionFieldName
	) {
		this.recordId = tradeAllyId;
		this.type = 'MULTIPICKLIST';
		this.available = true;
		this.editable = true;
		this.sObjectType = sObjectJunctionType + ' special';
		this.label = label;
		String query = 'SELECT Id, ' + Constants.NAMESPACE + String.escapeSingleQuotes(junctionFieldName) + ' FROM ' + 
				Constants.NAMESPACE + String.escapeSingleQuotes(sObjectJunctionType) + 
				' WHERE ' + Constants.NAMESPACE +  'Trade_Ally__c =: tradeAllyId LIMIT 50000';
		Map<String,String> mapOfJunctionById = new Map<String,String>();
		List<String> fieldsToCheck = new List<String>{'Id',String.escapeSingleQuotes(Constants.NAMESPACE + junctionFieldName)};
		if (ESAPI.securityUtils().isAuthorizedToView(String.escapeSingleQuotes(Constants.NAMESPACE + sObjectJunctionType),fieldsToCheck)) {
			for (sObject o : Database.query(query)) {
				mapOfJunctionById.put(
					String.valueOf(o.get(junctionFieldName)),
					String.valueOf(o.get('Id'))
				);
			}
		}
		picklistValues = new List<PickListWrapper>();
		String sObjectId;
		for (sObject o : listOfRecordsForPicklist) {
			sObjectId = String.valueOf(o.get('Id'));
			picklistValues.add(
				new PickListWrapper(
					sObjectId,
					String.valueOf(o.get('Name')),
					mapOfJunctionById.containsKey(sObjectId),
					mapOfJunctionById.get(sObjectId)
				)
			);
		}
		this.wasUpdated = false;
		this.isValid = true;
		this.isZipCode = false;
	}

	public FieldInfoWrapper(
		String sObjectType,
		String sObjectJunctionType,
		Id tradeAllyId,
		String label,
		String junctionFieldName
	) {
		this.recordId = tradeAllyId;
		this.type = 'MULTIPICKLIST';
		this.available = true;
		this.editable = true;
		this.sObjectType = sObjectJunctionType + ' special';
		this.label = label;
		String query = 'SELECT Id, Name FROM ' + Constants.NAMESPACE + String.escapeSingleQuotes(sObjectType) + ' ORDER BY Name ASC LIMIT 50000';
		List<sObject> listOfRecordsForPicklist = new List<sObject>();
		List<String> fieldsToCheck = new List<String>{'Id','Name'};
		if (ESAPI.securityUtils().isAuthorizedToView(String.escapeSingleQuotes(Constants.NAMESPACE + junctionFieldName),fieldsToCheck)) {
			listOfRecordsForPicklist = Database.query(query);
		}
		query = 'SELECT Id, ' + Constants.NAMESPACE + String.escapeSingleQuotes(junctionFieldName) + ' FROM ' + 
				Constants.NAMESPACE + String.escapeSingleQuotes(sObjectJunctionType) + 
				' WHERE ' + Constants.NAMESPACE +  'Trade_Ally__c =: tradeAllyId LIMIT 50000';
		Map<String,String> mapOfJunctionById = new Map<String,String>();
		fieldsToCheck = new List<String>{'Id',String.escapeSingleQuotes(Constants.NAMESPACE + junctionFieldName)};
		if (ESAPI.securityUtils().isAuthorizedToView(String.escapeSingleQuotes(Constants.NAMESPACE + sObjectJunctionType),fieldsToCheck)) {
			for (sObject o : Database.query(query)) {
				mapOfJunctionById.put(
					String.valueOf(o.get(junctionFieldName)),
					String.valueOf(o.get('Id'))
				);
			}
		}
        this.wasUpdated = false;
		this.isValid = true;
		this.isZipCode = false;
        //Applies when there is only one value defined for picklist - value selected by default
        Boolean picklistValueSelected = null;
        if(listOfRecordsForPicklist.size() == 1) {
            picklistValueSelected = true;
            this.wasUpdated = true; //This ensures that the junction objects for that type are created.
        }
		picklistValues = new List<PickListWrapper>();
		String sObjectId;
		for (sObject o : listOfRecordsForPicklist) {
			sObjectId = String.valueOf(o.get('Id'));
			picklistValues.add(
				new PickListWrapper(
					sObjectId,
					String.valueOf(o.get('Name')),
					picklistValueSelected == null ? mapOfJunctionById.containsKey(sObjectId):picklistValueSelected,
					mapOfJunctionById.get(sObjectId)
				)
			);
		}
	}

	public FieldInfoWrapper(
		String fieldName,
		Schema.FieldSetMember f,
		sObject record,
		Schema.DescribeFieldResult fieldDescribe,
		String sObjectType
	) {
		this.isValid = true;
		this.isZipCode = false;
		this.recordId = record.Id;
		this.sObjectType = sObjectType;
		this.label = f.getLabel();
		this.name = fieldName;//f.getFieldPath();
		this.type = f.getType().name();
		if (fieldDescribe.getType() == Schema.DisplayType.TEXTAREA && fieldDescribe.isHtmlFormatted()) {
			this.type = 'RICHTEXTAREA';
		}
		if (sObjectType != 'Task')
			this.recordName = (String)record.get('Name');
		this.available = fieldDescribe != null ? fieldDescribe.isAccessible() : true;
		//this.value = record.get(this.name);
		this.editable = fieldDescribe != null ? fieldDescribe.isUpdateable() : false;//isCreateable
		this.required = (f.getRequired() || f.getDBRequired());
		this.picklistValues = new List<PickListWrapper>();
		prepareAdditionalInformation(fieldDescribe,record);
		if (this.type == 'STRING' && fieldName.contains('PostalCode')) {
			this.isZipCode = true;
		}
	}

	private void prepareAdditionalInformation(Schema.DescribeFieldResult fieldDescribe, sObject record) {
		Object displayValue;
		Object value;
		List<String> parentList = name.split('\\.');
		if (fieldDescribe == null || parentList.size() > 1) {
			try {
				displayValue = record.getSobject(parentList[0]).get(parentList[1]);
			} catch (Exception e) {
				displayValue = null;
			}
		} else						
			displayValue = record.get(name);
		//this.value = String.valueOf(displayValue);
		value = displayValue;
		this.value = String.valueOf(value);

		System.debug(displayValue + ' ' + parentList + ' ' + name);

		//if (parentList.size() == 1) {
		if (type == 'DATE' || type == 'DATETIME') {
			DateTime dateTimeField = (DateTime) displayValue;
			if (dateTimeField != null) {
				if (type == 'DATE') {
					this.displayValue = dateTimeField.formatGMT('EEE MMM dd YYYY');
					this.valueDate = Date.valueOf(value);
				} else {
					this.displayValue = dateTimeField.format('EEE MMM dd hh:mm a YYYY');
					this.valueDateTime = Datetime.valueOf(value);
				}
			}
		} else if (type == 'REFERENCE') {
			if (name == 'RecordTypeId')
				type = 'STRING';
			
			
			if (record != null) {
				if (parentList.size() > 1) {
					String tempName = parentList[1].removeEndIgnoreCase('id');
					if (tempName.endsWithIgnoreCase('__c')) {
						tempName = tempName.removeEndIgnoreCase('c') + 'r';
					}
					displayValue = record.getSobject(parentList[0]).getSobject(tempName).get('Name');
					label = label.removeEndIgnoreCase('id').trim();
				} else {
					if (name.endsWithIgnoreCase('__c') && record.getSobject(name.removeEndIgnoreCase('c') + 'r') != null) {
						displayValue = record.getSobject(name.removeEndIgnoreCase('c') + 'r').get('Name');
					} else if (name.endsWithIgnoreCase('id') && record.getSobject(name.removeEndIgnoreCase('id')) != null) {
						displayValue = record.getSobject(name.removeEndIgnoreCase('id')).get('Name');
						label = label.removeEndIgnoreCase('id').trim();
					}
				}
			}
			
			
			/*if (name.endsWithIgnoreCase('__c') && record != null && displayValue != null) {
				displayValue = record.getSobject(name.removeEndIgnoreCase('c') + 'r').get('Name');
			} else if (name.endsWithIgnoreCase('id')) {
				if (record != null) {
					if (fieldDescribe == null || parentList.size() > 1) {
						
					} else {
					if (
						displayValue != null &&  record.getSobject(name.removeEndIgnoreCase('id')) != null) {
						displayValue = record.getSobject(name.removeEndIgnoreCase('id')).get('Name');
					}
				}
				label = label.removeEndIgnoreCase('id').trim();
			}*/
			if (fieldDescribe != null) {
				List<Schema.SObjectType> referenceList = fieldDescribe.getReferenceTo();
				if (!referenceList.isEmpty()) {
					String parent = String.valueOf(referenceList[referenceList.size() - 1]);
					if (parent == 'Group')
						parent = 'User';
					this.parentObjectType = parent;
				}
			}
		} else if ((type == 'PICKLIST' || type == 'COMBOBOX' || type == 'MULTIPICKLIST') && fieldDescribe != null) {// || type == 'MULTIPICKLIST_CHECKBOX'
			Set<String> setOfSelectedValues = new Set<String>();
			if (this.value != null && String.valueOf(this.value).trim() != '') {
				setOfSelectedValues = new Set<String>(
					String.valueOf(this.value).split(';')
				);
			}
			for (Schema.PicklistEntry ple : fieldDescribe.getPicklistValues()) {
				picklistValues.add(
					new PickListWrapper(
						ple.getValue(),
						ple.getLabel(),
						setOfSelectedValues.contains(ple.getValue()),
						null
					)
				);
			}
		} else if ((type == 'PERCENT' || type == 'CURRENCY' || type == 'DOUBLE' || type == 'INTEGER') && value != null) {
			this.valueNumber = Double.valueOf(value);
		} else if (type == 'BOOLEAN') {
			this.valueBoolean = false;
			if (value != null) {
				this.valueBoolean = Boolean.valueOf(value);
			}
		}
		//}
		this.displayValue = String.valueOf(displayValue);
	}

	public class PickListWrapper {
		@AuraEnabled public String value {get;set;}
		@AuraEnabled public String label {get;set;}
		@AuraEnabled public Boolean selected {get;set;}
		@AuraEnabled public String parentId {get;set;}

		public PickListWrapper(String value, String label, Boolean selected, String parentId) {
			this.value = value;
			this.label = label;
			this.selected = selected;
			this.parentId = parentId;
		}
	}
}