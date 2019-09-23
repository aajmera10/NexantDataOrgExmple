({
    setCommunicationCreation: function (component) {
        var communicationCard = component.find('communicationCard');
        $A.util.removeClass(
            communicationCard,
            'newCommunicationCardHidden'
        );
        setNewCommunication(component);
    },

    cancelCommunicationCreation: function (component) {
        var communicationCard = component.find('communicationCard');
        $A.util.addClass(
            communicationCard,
            'newCommunicationCardHidden'
        );

    },

	saveCommunication : function(component) {
		var action = component.get("c.createNewCommunication");
        action.setParams(
			{
				communication : JSON.stringify(component.get("v.newCommunication"))
			}
		);
        action.setCallback(this, function(response) {
            var state = response.getState();
			console.log('state= ', state);

            if (state === "SUCCESS") {
              
            } else {
                console.log('Unable to load data');
            }
        });

	    $A.enqueueAction(action);
		
	},

    loadTypeOptions : function(component) {
		var action = component.get("c.prepareTaskFieldOptionsInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var taskOptions = response.getReturnValue();
				component.set(
					"v.taskTypeOptions", 
					taskOptions.listOfTaskTypeOptions
				);
				component.set(
					"v.taskSubjectOptions", 
					taskOptions.listOfTaskSubjectOptions
				);
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
                                        this.showToast('error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
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
    },

    setNewCommunication: function (component) {
        component.set(
            "v.newCommunication",
            {}
        );
    },

	setNewCommunication : function(component) {
		var subjectValues = component.get("v.taskSubjectOptions");
		var types = component.get("v.taskTypeOptions");
		var defaultSubject = null;
		var defaultType = null;

		if (subjectValues.length > 0)
			defaultSubject = subjectValues[0].value;
		if (types.length > 0)
			defaultType = types[0].value;

		component.set(
			"v.newCommunication", 
			{
				Type : defaultType, 
				Subject : defaultSubject
			}
		);
	},

	resetFormValues : function(component) {
		var lookups = [
			component.find("contactWhoId"), 
			component.find("accountWhatId"), 
			component.find("ownerId")
		];
		lookups.forEach(
			function(lookupElement) {
				lookupElement.set(
					"v.name", 
					null
				);
				lookupElement.set(
					"v.options", 
					null
				);
			}
		);
	},

	displayAddCommunicationForm : function(component) {
		$A.util.removeClass(
			component.find('communicationCard'), 
			'newCommunicationCardHidden'
		);
	},

	hideCommunicationForm : function(component) {
		$A.util.addClass(
			component.find('communicationCard'), 
			'newCommunicationCardHidden'
		);
	},

    showToast: function (type, message, title) {
        var showToast = $A.get("e.force:showToast");
        console.log('showToast ', showToast);
        showToast.setParams({
            mode: 'pester',
            type: type,
            title: title,
            message: message,
            duration: '5000'
        });
        showToast.fire();
    }

})