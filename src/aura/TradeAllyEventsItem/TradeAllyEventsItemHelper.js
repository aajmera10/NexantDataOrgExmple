({
    doInit: function (component) {
        var currentEvent = component.get('v.event');
        if(!currentEvent.Address__c) currentEvent.Address__c = '... ';
        if(!currentEvent.City__c) currentEvent.City__c = '... ';
        if(!currentEvent.State__c) currentEvent.State__c = '... ';
        if(!currentEvent.Zip_Code__c) currentEvent.Zip_Code__c = '... ';
        this.getComponentInfo(component);
    },
    
    showToast: function (type, message, title) {
        var showToast = $A.get("e.force:showToast");
        //console.log('showToast ', showToast);
        showToast.setParams({
            mode: 'pester',
            type: type,
            title: title,
            message: message,
            duration: '5000' 
        });
        showToast.fire();
    },
    
    getComponentInfo : function (component){
        try{
            var event = component.get('v.event');
            console.log(JSON.stringify(event));
            var action = component.get("c.getComponentInfo");
            action.setParams({
                eventId : event.Id 
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    var fieldStateValue = component.get('v.event.State__c');
                    component.set('v.state', returnValue.stateValues[fieldStateValue.toLowerCase()]);
                    component.set('v.compObj', returnValue);
                    var companyContacts = returnValue.companyContacts;
                    var options = [];
                    var tempContactIds = [];
                    companyContacts.forEach(function(companyContact)  {
                        options.push({ value: companyContact.Id, label: companyContact.Name});
                        tempContactIds.push(companyContact.Id);
                    });
                    component.set('v.contacts', options);
                    component.set('v.contactIds', tempContactIds);
                    var eventAttendeesValues = component.get('v.event.Event_Attendees__r');
                    var existing = [];
                    eventAttendeesValues.forEach(function(eventAttendeesValue)  {
                        if($A.util.isUndefinedOrNull(eventAttendeesValue.Attendee_Contact__r) || $A.util.isUndefinedOrNull(eventAttendeesValue.Attendee_Contact__r.Id)) {
                            //do nothing
                        } else {
                                if(tempContactIds.indexOf(eventAttendeesValue.Attendee_Contact__r.Id) > -1) {
                                    existing.push(eventAttendeesValue.Attendee_Contact__r.Id);
                                }
                        }
                    });
                    component.set('v.selectedContacts', existing);
                }
                else if (state === "INCOMPLETE") {
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
                
            });
            
            $A.enqueueAction(action);
            
        }catch(excp){
            console.log(excp);
        }
    },
    
    handleUpdate: function (component, newAttendees, deleteAttendees) {
        console.log('deleteAttendees helper '+deleteAttendees.toString());
        console.log('newAttendees helper '+newAttendees.toString());
        var action = component.get('c.updateAttendees');
        var event = component.get('v.event');
        action.setParams({
            eventId: event.Id,
            newAttendees: newAttendees,
            deleteAttendees: deleteAttendees
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var name = component.get('v.event.Name');
                var message = "";
                if(newAttendees.length > 0) {
                    message = newAttendees.length+' new attendee(s) registered ';
                }
                if(deleteAttendees.length > 0) {
                    message += deleteAttendees.length+' attendee(s) deleted';
                }
                this.showToast('success', message, 'Registered');
            }
            else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors.length > 0) {
                            for (var i = 0; i < errors.length; i++) {
                                if (errors[0].pageErrors) {
                                    if (errors[0].pageErrors.length > 0) {
                                        for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                            showToast('error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                        }
                                    }
                                }
                                this.showToast('error', errors[i].message, 'Error');
                            }
                        }
                    }
                    else {
                        this.showToast('error', $A.get("$Label.c.Internal_server_error"), 'Error');
                    }
                }
        });
        $A.enqueueAction(action);
        $A.get("e.c:ReInitData").fire();
        this.doInit(component);
    }
})