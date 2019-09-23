public with sharing class RelatedRecordsOnChangeTriggerHandler {

	public static void reviewUpdateRecords(
		List<sObject> listOfNewRecords, 
		Map<Id,sObject> mapOfOldRecords,
		String typeOfSObject
	) {
		Map<Id,Boolean> mapOfValidDateById = new Map<Id,Boolean>();
		Date today = Date.today();
		Date newExpiryDate;
		for (sObject newRecord : listOfNewRecords) {
			newExpiryDate = (Date)newRecord.get(Constants.NAMESPACE + 'Expiry_Date__c');
			if (
				mapOfOldRecords == null || 
				(Date)mapOfOldRecords.get((Id)newRecord.get('Id')).get(Constants.NAMESPACE + 'Expiry_Date__c') != newExpiryDate
			) {
				mapOfValidDateById.put(
					(Id)newRecord.get('Id'),
					(newExpiryDate > today)
				);
			}
		}
		Set<Id> setOfIds = mapOfValidDateById.keySet();
		String query = 'SELECT Id, ' + Constants.NAMESPACE + 'Is_Active__c, ' + 
						Constants.NAMESPACE + String.escapeSingleQuotes(typeOfSObject.removeStart('Trade_Ally_')) + 
						' FROM ' + Constants.NAMESPACE + typeOfSObject + 
						' WHERE ' + Constants.NAMESPACE + 
						String.escapeSingleQuotes(typeOfSObject.removeStart('Trade_Ally_')) + ' IN: setOfIds';
		List<sObject> listOfRecordsToUpdate = new List<sObject>();
		Id tempRecordId;
		System.debug(query);
		List<String> fieldsToCheck = new List<String>{
			'Id',
			Constants.NAMESPACE + 'Is_Active__c',
			Constants.NAMESPACE + String.escapeSingleQuotes(typeOfSObject.removeStart('Trade_Ally_'))
		};
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + String.escapeSingleQuotes(typeOfSObject),fieldsToCheck)) {
			for (sObject obj : Database.query(query)) {
				tempRecordId = (Id)obj.get(Constants.NAMESPACE + typeOfSObject.removeStart('Trade_Ally_'));
				if ((Boolean)obj.get(Constants.NAMESPACE + 'Is_Active__c') != mapOfValidDateById.get(tempRecordId)) {
					obj.put(
						Constants.NAMESPACE + 'Is_Active__c',
						mapOfValidDateById.get(tempRecordId)
					);
					listOfRecordsToUpdate.add(obj);
				}
			}
		}
		ESAPI.securityUtils().validatedUpdate(listOfRecordsToUpdate);
	}

	public static void reviewUpdateJunctionRecords(
		List<sObject> listOfNewRecords,
		String typeOfSObject
	) {
		Set<Id> setOfIds = new Set<Id>();
		for (sObject newRecord : listOfNewRecords) {
			setOfIds.add(
				(Id)newRecord.get(typeOfSObject)
			);
		}

		String query = 'SELECT Id, ' + Constants.NAMESPACE + 'Expiry_Date__c FROM ' + Constants.NAMESPACE +  
						String.escapeSingleQuotes(typeOfSObject) + ' WHERE Id IN: setOfIds';
		List<sObject> listOfParentRecords = new List<sObject>();
		List<String> fieldsToCheck = new List<String>{'Id',Constants.NAMESPACE + 'Expiry_Date__c'};
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + String.escapeSingleQuotes(typeOfSObject),fieldsToCheck)) {
			listOfParentRecords = Database.query(query);
		}
		Map<Id,sObject> mapOfParentRecords = new Map<Id,sObject>(listOfParentRecords);
		Date newExpiryDate;
		Date today = Date.today();
		for (sObject newRecord : listOfNewRecords) {
			newExpiryDate = (Date)mapOfParentRecords.get(
				(Id)newRecord.get(Constants.NAMESPACE + String.escapeSingleQuotes(typeOfSObject))
			).get(Constants.NAMESPACE + 'Expiry_Date__c');
			newRecord.put(
				Constants.NAMESPACE + 'Is_Active__c',
				newExpiryDate == null ? false : newExpiryDate > today
			);
		}
	}
}