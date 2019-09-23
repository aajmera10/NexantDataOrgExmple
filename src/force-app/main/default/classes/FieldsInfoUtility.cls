public with sharing class FieldsInfoUtility {

	private static Map<String,Schema.DescribeSObjectResult> mapOfSObjectDescribe = new Map<String,Schema.DescribeSObjectResult>();
	private static Map<String,Map<String,Schema.SObjectField>> mapOfFieldsBySObjectName = new Map<String,Map<String,Schema.SObjectField>>();

	/*public static String prepareWhereConditions(List<Schema.FieldSetMember> fieldsFromFS, String searchText) {
		String whereCondition = '';
		String fieldName;
		for (Schema.FieldSetMember f : fieldsFromFS) {
			if (searchText != null && searchText.trim() != '') {
				fieldName = f.getFieldPath();
				if (f.getType() == Schema.DisplayType.String) {
					whereCondition += String.escapeSingleQuotes(fieldName) + ' LIKE \'%' + String.escapeSingleQuotes(searchText) + '%\' OR ';
				} else if (
					(
						f.getType() == Schema.DisplayType.Double || 
						f.getType() == Schema.DisplayType.Currency
					) &&
					searchText.isNumeric()
				) {
					whereCondition += String.escapeSingleQuotes(fieldName) + ' = ' + String.escapeSingleQuotes(searchText) + ' OR ';
				}
			}
		}
		return whereCondition.removeEnd(' OR ');
	}*/

	public static Set<String> prepareSetOfFieldsForQUERY(List<Schema.FieldSetMember> fieldsFromFS) {
		Set<String> setOfFields = new Set<String>{'Name'};
		String fieldName;
		for (Schema.FieldSetMember f : fieldsFromFS) {
			fieldName = f.getFieldPath();
			setOfFields.add(fieldName);
			if (f.getType().name() == 'REFERENCE') {
				if (fieldName.endsWithIgnoreCase('__c')) {
					fieldName = fieldName.removeEndIgnoreCase('c') + 'r.Name';
				} else if (fieldName.endsWithIgnoreCase('id')) {
					fieldName = fieldName.removeEndIgnoreCase('id') + '.Name';
				}
				setOfFields.add(fieldName);
			}
		}
		return setOfFields;
	}

	public static String populateFieldsForQUERY(Set<String> fieldsToAdd) {
		String query = '';
		for (String fieldName : fieldsToAdd) {
			query += ', ' + fieldName;
		}
		return query;
	}

	/*public static String populateFieldsForQUERY(List<Schema.FieldSetMember> fieldsFromFS, Set<String> fieldsToAdd) {
		String query = '';
		String fieldName;
		for (String fieldName : fieldsToAdd) {
			query += ', ' + fieldName;
		}
		for (Schema.FieldSetMember f : fieldsFromFS) {
			fieldName = f.getFieldPath();
			if (!fieldsToAdd.contains(fieldName)) {
				query += ', ' + fieldName;
			}
			if (f.getType().name() == 'REFERENCE') {
				if (fieldName.endsWithIgnoreCase('__c')) {
					query += ', ' + fieldName.removeEndIgnoreCase('c') + 'r.Name';
				} else if (fieldName.endsWithIgnoreCase('id')) {
					query += ', ' + fieldName.removeEndIgnoreCase('id') + '.Name';
				}
			}
		}
		return query;
	}*/

	public static List<FieldInfoWrapper> prepareListOfWrappedFieldsInfo(
		List<Schema.FieldSetMember> fieldsFromFS,
		sObject record
	) {
		List<FieldInfoWrapper> listOfApplicationFields = new List<FieldInfoWrapper>();
		String objectName = record.getSObjectType().getDescribe().getName();
		Map<String,Schema.SObjectField> mapOfFieldsBySObjectName = getMapOfFieldsBySObjectName(objectName);
		Schema.DescribeFieldResult fieldDescribe;
		String fieldName;
		Boolean parentField;
		FieldInfoWrapper tempFieldInfo;
		for (Schema.FieldSetMember f : fieldsFromFS) {
			fieldName = f.getFieldPath();
			parentField = fieldName.contains('.');
			if (!parentField)
				fieldDescribe = mapOfFieldsBySObjectName.get(fieldName).getDescribe();
			if (parentField || fieldDescribe.isAccessible()) {
				listOfApplicationFields.add(
					new FieldInfoWrapper(
						fieldName,
						f,
						record,
						fieldDescribe,
						objectName
					)
				);
			}
		}
		return listOfApplicationFields;
	}

	private static Map<String,Schema.SObjectField> getMapOfFieldsBySObjectName(String objectName) {
		if (mapOfFieldsBySObjectName.get(objectName) == null) {
			mapOfFieldsBySObjectName.put(
				objectName,
				prepareMapOfFieldsInfo(
					getSObjectDescribe(
						objectName
					)
				)
			);
		}
		return mapOfFieldsBySObjectName.get(objectName);
	}

	private static Map<String,Schema.SObjectField> prepareMapOfFieldsInfo(Schema.DescribeSObjectResult describeSObjectResultObj) {
		return describeSObjectResultObj.fields.getMap();
	}

	private static Schema.DescribeSObjectResult getSObjectDescribe(String objectName) {
		if (mapOfSObjectDescribe.get(objectName) == null) {
			mapOfSObjectDescribe.put(
				objectName,
				getDescribeSObjectResult(objectName)
			);
		}
		return mapOfSObjectDescribe.get(objectName);
	}

	private static Schema.DescribeSObjectResult getDescribeSObjectResult(String objectName) {
		Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
		Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(objectName);
		return SObjectTypeObj.getDescribe();
	}
}