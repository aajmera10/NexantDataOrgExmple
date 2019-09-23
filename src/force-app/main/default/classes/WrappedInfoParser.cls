public with sharing class WrappedInfoParser {

	public static List<FieldInfoWrapper> listOfSpecialFields {get;set;}

	public static List<List<sObject>> parseWrapperToFields(
		Map<Id,sObject> mapOfRecords, 
		List<List<FieldInfoWrapper>> wrappedInfo,
		Id accountId,
		String referenceType
	) {
		List<sObject> recordsToCreate = new List<sObject>();
		List<sObject> recordsToUpdate = new List<sObject>();
		String recordId;
		sObject tempRecord;
		sObject newRecord;
		for (List<FieldInfoWrapper> listOfInfo : wrappedInfo) {
			if (!listOfInfo.isEmpty()) {
				recordId = listOfInfo[0].recordId;
				if (mapOfRecords.get(recordId) == null) {
					tempRecord = Schema.getGlobalDescribe().get(listOfInfo[0].sObjectType).newSObject();
					if (listOfInfo[0].sObjectType == Constants.NAMESPACE + Constants.TRADE_ALLY_REFERENCE) {
						tempRecord.put(
							'Trade_Ally__c',
							accountId
						);
					}
					if (referenceType != null) {
						tempRecord.put(
							'Reference_Type__c',
							referenceType
						);
					}
					newRecord = parseWrapperToFields(
						tempRecord,
						listOfInfo
					);
					if (newRecord != null) {
						recordsToCreate.add(
							newRecord
						);
					}
				} else {
					tempRecord = mapOfRecords.get(recordId);
					newRecord = parseWrapperToFields(
						tempRecord,
						listOfInfo
					);
					if (newRecord != null) {
						recordsToUpdate.add(
							newRecord
						);
					}
				}
			}
		}

		return new List<List<sObject>>{recordsToCreate,recordsToUpdate};
	}

	public static sObject parseWrapperToFields(sObject record, List<FieldInfoWrapper> wrappedInfo) {
		Boolean wasUpdated = false;
		String type;
		String multipicklistValue;
		for (FieldInfoWrapper wrappedField : wrappedInfo) {
			System.debug(wrappedField.wasUpdated);
			if (
				(
					wrappedField.wasUpdated != null && 
					wrappedField.wasUpdated
				) ||
				wrappedField.sObjectType == Constants.NAMESPACE + Constants.OBJECT_APPLICATION ||
				wrappedField.sObjectType == Constants.TASK_OBJECT ||
				wrappedField.sObjectType == Constants.TRADE_ALLY ||
				wrappedField.sObjectType == Constants.TRADE_ALLY_USER
			) {
				wasUpdated = true;
				if (wrappedField.available && wrappedField.editable) {
					type = wrappedField.type;
					if (
						type == 'REFERENCE' || 
						type == 'STRING' || 
						type == 'EMAIL' || 
						type == 'PHONE' || 
						type == 'URL' || 
						type == 'TEXTAREA' || 
						type == 'RICHTEXTAREA' || 
						type == 'PICKLIST' || 
						type == 'COMBOBOX'
					) {
						record.put(
							wrappedField.name,
							wrappedField.value
						);
					} else if (type == 'DATETIME') {
						record.put(
							wrappedField.name,
							wrappedField.valueDateTime
						);
					} else if (type == 'DATE') {
						record.put(
							wrappedField.name,
							wrappedField.valueDate
						);
					} else if (type == 'BOOLEAN') {
						record.put(
							wrappedField.name,
							wrappedField.valueBoolean
						);
					} else if (
						type == 'INTEGER'
					) {
                        System.debug('type '+type);
						record.put(
							wrappedField.name,
							(Integer)wrappedField.valueNumber
						);
					} else if (
						type == 'CURRENCY' || 
						type == 'DOUBLE' || 
						type == 'PERCENT'
					) {
                        System.debug('type '+type);
						record.put(
							wrappedField.name,
							wrappedField.valueNumber
						);
					} else if (type == 'MULTIPICKLIST') {
						if (wrappedField.sObjectType.contains(' special')) {
							addItemToListOfSpecialFields(wrappedField);
						} else {
							multipicklistValue = '';
							for (FieldInfoWrapper.PickListWrapper picklistRecord : wrappedField.picklistValues) {
								System.debug(picklistRecord.label + ' ' + picklistRecord.label + ' ' + picklistRecord.selected);
								if (picklistRecord.selected) {
									multipicklistValue += picklistRecord.value + ';';
								}
							}
							record.put(
								wrappedField.name,
								multipicklistValue
							);
						}
					}
				}
			}
		}
		if (!wasUpdated) {
			record = null;
		}
		return record;
	}

	@TestVisible
	private static void addItemToListOfSpecialFields(FieldInfoWrapper wrappedField) {
		if (listOfSpecialFields == null) {
			listOfSpecialFields = new List<FieldInfoWrapper>();
		}
		listOfSpecialFields.add(wrappedField);
	}

	public static void workWithSpesialFields() {
		List<sObject> listOfRecordsToCreate;
		Set<String> setOfIdsToDelete;
		String typeOfObject;
		sObject tempRecord;
		if (listOfSpecialFields != null) {
			for (FieldInfoWrapper wrappedField : listOfSpecialFields) {
				listOfRecordsToCreate = new List<sObject>();
				setOfIdsToDelete = new Set<String>();
				typeOfObject = wrappedField.sObjectType.split(' special')[0];
				System.debug(wrappedField.sObjectType);
				System.debug(typeOfObject);
				for (FieldInfoWrapper.PickListWrapper picklistRecord : wrappedField.picklistValues) {
					if (!picklistRecord.selected && picklistRecord.parentId != null) {
						setOfIdsToDelete.add(picklistRecord.parentId);
					} else if (picklistRecord.selected && picklistRecord.parentId == null) {
						tempRecord = Schema.getGlobalDescribe().get(Constants.NAMESPACE + typeOfObject).newSObject();
						tempRecord.put(
							Constants.MAP_OF_FIRST_SPECIAL_FIELDS.get(typeOfObject),
							wrappedField.recordId
						);
						tempRecord.put(
							Constants.MAP_OF_SECOND_SPECIAL_FIELDS.get(typeOfObject),
							picklistRecord.value
						);
						listOfRecordsToCreate.add(tempRecord);
					}
				}
				sObjectUtility.deleteListOfRecordsByIds(
					setOfIdsToDelete,
					typeOfObject,
					false,
					null
				);
				ESAPI.securityUtils().validatedInsert(listOfRecordsToCreate);
			}
		}
	}
}