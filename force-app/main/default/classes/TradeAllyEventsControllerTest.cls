@IsTest
private class TradeAllyEventsControllerTest {
	@TestSetup
	static void setupTest() {
        // Create an account
        Account acct = new Account(Name='Test Account');
        acct.external_Id__c = '1';
        insert acct;
        // Create a contact
        Contact contact = new Contact();
        contact.Firstname ='first';
        contact.Lastname ='last';
        contact.Level__c = 'Primary';
        contact.AccountId = acct.id;
        insert contact;
		Trade_Ally_Event__c newEvent = new Trade_Ally_Event__c();
		newEvent.Name = 'TestEvent';
		newEvent.Date__c = Date.today().addDays(1);
		insert newEvent;
		Event_Attendee__c newAttendee = new Event_Attendee__c();
		newAttendee.Attendee_Contact__c = contact.Id;
		newAttendee.Trade_Ally_Event__c = newEvent.Id;
		insert newAttendee;
	}

	@IsTest
	static void getInitDataTest() {
		List<Object> initDataList = TradeAllyEventsController.getInitData();
		List<Trade_Ally_Event__c> eventsList = (List<Trade_Ally_Event__c>) initDataList[0];
		System.assertEquals('TestEvent', eventsList[0].Name);
	}

	@IsTest
	static void getIsAdminProfileTest() {
		Profile currentProfile;
		Boolean userIsAdmin = false;
		currentProfile = [
				SELECT Name,
						PermissionsModifyAllData
				FROM Profile
				WHERE Id = :UserInfo.getProfileId()
		];
		if (currentProfile != null && currentProfile.PermissionsModifyAllData) {
			userIsAdmin = true;
		}
		System.assertEquals(userIsAdmin, TradeAllyEventsController.getIsAdminProfile());
	}
    
    @IsTest
	static void updateAttendeeTest() {
        Trade_Ally_Event__c tradeAllyEvent = [
				SELECT Name, Id,
            	(
						SELECT Id
						FROM Event_Attendees__r
				)
				FROM Trade_Ally_Event__c
				LIMIT 1
		];
        Event_Attendee__c currentAttendee = [
				SELECT Attendee_Contact__c,
						Trade_Ally_Event__c
				FROM Event_Attendee__c
				LIMIT 1
		];
        System.assertEquals(1, tradeAllyEvent.Event_Attendees__r.size());
        List<Id> newAttendees = new List<Id>();
        List<Id> deleteAttendees = new List<Id>();
        newAttendees.add(currentAttendee.Attendee_Contact__c);
        deleteAttendees.add(currentAttendee.Attendee_Contact__c);
        TradeAllyEventsController.updateAttendees(tradeAllyEvent.Id, newAttendees, deleteAttendees);
        tradeAllyEvent = [
				SELECT Name, (
						SELECT Id
						FROM Event_Attendees__r
				)
				FROM Trade_Ally_Event__c
				LIMIT 1
		];
		System.assertEquals(0, tradeAllyEvent.Event_Attendees__r.size());
    }
}