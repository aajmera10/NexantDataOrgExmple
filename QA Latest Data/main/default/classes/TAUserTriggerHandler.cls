public with sharing class TAUserTriggerHandler {
	
	public static void setCorrectLevels(List<Contact> listOfNewContacts) {
		Map<Id,List<Contact>> mapOfContactsByTradeAlly = new Map<Id,List<Contact>>();
		List<Contact> tempContactsList;
		for (Contact c : listOfNewContacts) {
			if (c.AccountId != null) {
				tempContactsList = mapOfContactsByTradeAlly.get(c.AccountId);
				if (tempContactsList == null) {
					tempContactsList = new List<Contact>();
				}
				tempContactsList.add(c);
				mapOfContactsByTradeAlly.put(
					c.AccountId,
					tempContactsList
				);
			}
		}
		Id taRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Constants.TRADE_ALLY_RECORD_TYPE_NAME).getRecordTypeId();
		List<Account> listOfTradeAllies = [
			SELECT
					Id,
					(
						SELECT	Id
						FROM	Contacts
						WHERE	Level__c = 'Primary'
					)
			FROM	Account
			WHERE
					Id IN: mapOfContactsByTradeAlly.keySet() AND
					RecordTypeId =: taRecordTypeId
		];
		if (!listOfTradeAllies.isEmpty()) {
			Boolean isPrimary;
			for (Account tradeAlly : listOfTradeAllies) {
				isPrimary = tradeAlly.Contacts.isEmpty();
				for (Contact c : mapOfContactsByTradeAlly.get(tradeAlly.Id)) {
					c.Level__c = 'Secondary';
					if (isPrimary) {
						isPrimary = false;
						c.Level__c = 'Primary';
					}
				}
			}
		}
	}
    
    // populate contact field 'Contact Approver'
    public static void populateContactFields(List<Contact> conList) {
        
        List<User> primaryUserContacts  = new List<User>();
        
        Set<Id> accIdsSet = new Set<Id>();
        Map<Id, User> accConMap = new Map<Id, User>();
        
        for (Contact conObj : conList) {
            if(conObj.AccountId != Null) {
                accIdsSet.add(conObj.AccountId);
            }
        }
        if(
            ESAPI.securityUtils().isAuthorizedToView(
                'User', 
                new List<String>{
                    'Id',
                        'AccountId',
                        'Contact.'+Constants.NAMESPACE+'Level__c'
                        }
            )
        ) {
            String query = 'SELECT Id, Contact.Name, Contact.AccountId, AccountId,' + 'Contact.'+Constants.NAMESPACE+'Level__c' +
                ' FROM User WHERE Contact.AccountId IN :accIdsSet AND '+ 'Contact.'+Constants.NAMESPACE+'Level__c = \'Primary\'' ;
            //System.debug('query--'+query);
            primaryUserContacts = Database.query(query);
        }
        
        for (User userObj : primaryUserContacts) {
            if(userObj.AccountId != Null){
                accConMap.put(userObj.AccountId, userObj); 
            }
        }
        for (Contact contactObj : conList) {
            if(accConMap.containsKey(contactObj.AccountId)) {
                contactObj.Contact_Approver__c = accConMap.get(contactObj.AccountId).Id;
            }
        }
    }
}