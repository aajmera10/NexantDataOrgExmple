({
    init: function (component, event, helper) {
        helper.doInit(component);
    },
    
    
    handleClick: function (component, event, helper) {
        var currentEvent = component.get('v.event'); 
        var eventAttendeesValues = component.get('v.event.Event_Attendees__r');
        var selected = component.get('v.selectedContacts');
        console.log('selected  '+selected.toString());
        var registered = [];
        var newAttendees = [];
        var deleteAttendees = [];
        //Check if any attendees exist for this event, if none exist, then all selected are new attendees
        if($A.util.isUndefinedOrNull(eventAttendeesValues)) {
            selected.forEach(function(reg)  {
                newAttendees.push(reg);
            });
        } else {
            //Attendees exist for this event, check which ones are already registered, which ones are new and which ones need to be removed
            eventAttendeesValues.forEach(function(eventAttendeesValue)  {
                if($A.util.isUndefinedOrNull(eventAttendeesValue.Attendee_Contact__r) || $A.util.isUndefinedOrNull(eventAttendeesValue.Attendee_Contact__r.Id)) {
                    //do nothing
                } else {
                    var contactId = eventAttendeesValue.Attendee_Contact__r.Id;
                    console.log('contactId  '+contactId);
                    if(component.get('v.contactIds').indexOf(contactId) > -1) {
                        registered.push(contactId);
                    }
                }
            });
            registered.forEach(function(reg)  {
                if(selected.indexOf(reg) < 0)//to check if each individual element of array is present in selected contacts
                    deleteAttendees.push(reg);
            });
            selected.forEach(function(reg)  {
                if(registered.indexOf(reg) < 0)//to check if each individual element of array is present in registered contacts
                    newAttendees.push(reg);
            });
        }
        if(newAttendees.length == 0 && deleteAttendees.length == 0) {
            helper.showToast('info', 'No change in selected attendees!', 'Information');
        } else {
            var newCount = currentEvent.Attendees_Enrolled__c + newAttendees.length - deleteAttendees.length;
            if(newCount > currentEvent.Maximum_Attendees__c) {
                helper.showToast('error', 'Maximum Attendees reached');
            } else {
                helper.handleUpdate(component,newAttendees,deleteAttendees);
            }
        }
    },
    
    changeSection: function (component, event, helper) {
        var isChecked = component.get('v.isChecked');
        var cmpEvent = $A.get("e.c:HideAdditionSection");
        cmpEvent.fire();
        if (isChecked) {
            component.set('v.isChecked', false);
        }
        else {
            component.set('v.isChecked', true);
        }
    },
    
    HideAdditionSection: function (component, event, helper) {
        component.set('v.isChecked', false);
    },
    
    openPopUp: function (component, event, helper) {
        component.set('v.ModalIsOpened', true);
        
    },
    
    clousePopUp: function (component, event, helper) {
        component.set('v.ModalIsOpened', false);
    },
    
})