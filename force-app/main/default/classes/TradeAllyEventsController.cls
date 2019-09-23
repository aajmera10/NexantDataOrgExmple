global with sharing class TradeAllyEventsController {
    @AuraEnabled
	public static List<Contact> getListOfAllCompanyContacts() {
		Id currentUserAccountId = StartApplicationController.getCurrentUserInfo().Contact.AccountId;
		List<Contact> listOfAllCompanyContacts = new List<Contact>();
		List<String> fieldsToCheck = new List<String>{'Id'};
		if (ESAPI.securityUtils().isAuthorizedToView('Contact',fieldsToCheck)) {
			listOfAllCompanyContacts = [
				SELECT	Id, Name
				FROM	Contact
				WHERE	Contact.AccountId =: currentUserAccountId
			];
		}
		return listOfAllCompanyContacts;
	}

	@AuraEnabled
	public static List<Object> getInitData() {
		List<Object> initData = new List<Object>();
		List<Trade_Ally_Event__c> eventsList = getEvents();
		initData.add(eventsList);
		Boolean isAdminProfile = getIsAdminProfile();
		initData.add(isAdminProfile);
		return initData;
	}

	@AuraEnabled
	public static List<Trade_Ally_Event__c> getEvents() {
		List<Trade_Ally_Event__c> eventsList = new List<Trade_Ally_Event__c>();
		List<String> fieldsToCheck = new List<String>{
			'Id',
			'Name',
			Constants.NAMESPACE + 'Event_Topic__c',
			Constants.NAMESPACE + 'Specialty__c',
			Constants.NAMESPACE + 'Event_Series__c',
			Constants.NAMESPACE + 'Presenter_Name__c',
			Constants.NAMESPACE + 'Address__c',
			Constants.NAMESPACE + 'City__c',
			Constants.NAMESPACE + 'State__c',
			Constants.NAMESPACE + 'Zip_Code__c',
			Constants.NAMESPACE + 'Subject__c',
			Constants.NAMESPACE + 'Date__c',
			Constants.NAMESPACE + 'Time__c',
			Constants.NAMESPACE + 'To__c',
			Constants.NAMESPACE + 'Event_Type__c',
			Constants.NAMESPACE + 'Maximum_Attendees__c',
			Constants.NAMESPACE + 'Attendees_Enrolled__c',
			Constants.NAMESPACE + 'Spots_Remaining__c'
		};
		if (
			ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Trade_Ally_Event__c',fieldsToCheck) &&
			ESAPI.securityUtils().isAuthorizedToView(
				Constants.NAMESPACE + 'Event_Attendee__c',
				new List<String>{
					Constants.NAMESPACE + 'Attendee_Contact__c',
					Constants.NAMESPACE + 'Email__c',
					Constants.NAMESPACE + 'Phone_Number__c',
					Constants.NAMESPACE + 'Attendee_Name__c'
				}
			) &&
			ESAPI.securityUtils().isAuthorizedToView(
				'Contact',
				new List<String>{
                    'Id',
                    'Name',
					'LastName',
					'FirstName',
					'Email',
					'Phone'
				}
			)
		) {
			eventsList = [
				SELECT 
						Name,
						Event_Topic__c,
						Specialty__r.Name,
						Event_Series__c,
						Presenter_Name__c,
						Address__c,
						City__c,
						State__c,
						Zip_Code__c,
						Subject__c,
						Date__c,
						Time__c,
						To__c,
						Event_Type__c,
						Maximum_Attendees__c,
						Attendees_Enrolled__c,
						Spots_Remaining__c,
                		(
							SELECT	
									Id,
                            		Attendee_Contact__r.Id,
                            		Attendee_Contact__r.Name,
									Attendee_Contact__r.LastName,
									Attendee_Contact__r.FirstName,
									Attendee_Contact__r.Email,
									Attendee_Contact__r.Phone,
									Email__c,
									Phone_Number__c,
									Attendee_Contact__c
							FROM	Event_Attendees__r
						)
				FROM	Trade_Ally_Event__c
				WHERE	Date__c >= TODAY
			];
		}
		return eventsList;
	}
    
    @AuraEnabled
	public static void updateAttendees(String eventId, List<Id> newAttendees, List<Id> deleteAttendees) {
        System.debug('newAttendees '+newAttendees);
        System.debug('deleteAttendees '+deleteAttendees);
        eventId = String.isBlank(eventId) ? null : String.escapeSingleQuotes(eventId);
        //Create new Event_Attendee__c junctions objects
        if(newAttendees != null && newAttendees.size() > 0) {
            List<Event_Attendee__c> newInserts = new List<Event_Attendee__c>();
            for(Id contactId : newAttendees) {
                Event_Attendee__c newEventAttendee = new Event_Attendee__c();
                newEventAttendee.Attendee_Contact__c = contactId;
                newEventAttendee.Trade_Ally_Event__c = eventId;
                newInserts.add(newEventAttendee);
            }
            ESAPI.securityUtils().validatedInsert(newInserts);
        }
        //Remove existing Event_Attendee__c junctions objects
        if(deleteAttendees != null && deleteAttendees.size() > 0) {
            List<Event_Attendee__c> deleteList = new List<Event_Attendee__c>();
            if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Event_Attendee__c',new List<String>{'Id'})) {
                deleteList = [
                    SELECT	Id
                    FROM	Event_Attendee__c
                    WHERE 
                            Attendee_Contact__c IN: deleteAttendees AND
                            Trade_Ally_Event__c =: eventId
                ];
            }
            System.debug('deleteList ' + deleteList);
            ESAPI.securityUtils().validatedDelete(deleteList);
        }
    }
    
    @AuraEnabled
    public static ComponentDetail getComponentInfo(String eventId) {
        ComponentDetail compDetail = new ComponentDetail();
        compDetail.stateValues = getStateValues();
        compDetail.companyContacts = getListOfAllCompanyContacts();
        
        List<Trade_Ally_Event__c> tradeAllys = [SELECT Id, Date__c, Time__c, To__c, Time_Zone__c FROM Trade_Ally_Event__c WHERE Id = :eventId];
        if(tradeAllys[0].Time__c != null) {
            Datetime myDateTime = Datetime.newInstance(System.today(), tradeAllys[0].Time__c);
            compDetail.timeObj = myDateTime.format('h:mm a');
        }
        if(tradeAllys[0].To__c != null) {
            Datetime myDateTime = Datetime.newInstance(System.today(), tradeAllys[0].To__c);
            compDetail.toTimeObj = myDateTime.format('h:mm a');
        }
        
        return compDetail;
    }
    
    static Map<String, String> getStateValues (){
        Map<String, String> pickListValuesMap= new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Trade_Ally_Event__c.State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesMap.put(pickListVal.getValue().toLowerCase(), pickListVal.getLabel());
        }     
        return pickListValuesMap;
    }
	@AuraEnabled
	public static Boolean getIsAdminProfile() {
		Profile profileRecord;
		if (ESAPI.securityUtils().isAuthorizedToView('Profile',new List<String>{'Name','PermissionsModifyAllData'})) {
			profileRecord = [
				SELECT 
						Name,
						PermissionsModifyAllData
				FROM	Profile
				WHERE	Id = :UserInfo.getProfileId()
			];
		}
		if (profileRecord != null && profileRecord.PermissionsModifyAllData) {
			return true;
		}
		return false;
	}
    
    public class ComponentDetail{
        @auraEnabled
        public  Map<String, String> stateValues;
        @auraEnabled
        public String toTimeObj {get; set;}
        @auraEnabled
        public List<Contact> companyContacts {get; set;}
        @auraEnabled
        public String timeObj {get; set;}
        
        public ComponentDetail(){
            stateValues = new Map<String, String>();
        }
    }

}