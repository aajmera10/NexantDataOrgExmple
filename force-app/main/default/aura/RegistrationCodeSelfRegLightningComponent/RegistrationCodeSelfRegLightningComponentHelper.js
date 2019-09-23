({

    //--- Standard Functions ---//

    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid': 'e.c:setExpId'
    },

    // Additional parameters for registration:
    // - registrationCode
    // - companyBillingCity
    // - companyBillingState
    // - companyPhoneNumber
    handleSelfRegister: function(component, event, selfRegisterTradeAllyWrapper) {
        var approvalForSubUser = component.get('v.approvalForSubUser');
        var action = component.get("c.selfRegisterWithRegCode");
        action.setParams({
            'selfRegisterTradeAllyWrapperJSON': JSON.stringify(selfRegisterTradeAllyWrapper),
            'approvalForSubUser' : approvalForSubUser
        });
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.setRegistrationStatus(component, response.getReturnValue());
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
        }));
        $A.enqueueAction(action);
    },

    getExtraFields: function(component) {
        var action = component.get("c.getExtraFieldsFromFieldSet");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                var parsedExtraFields = JSON.parse(rtnValue);
                if (rtnValue !== null) {
                    component.set('v.extraFields', parsedExtraFields);
                }
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
        }));
        $A.enqueueAction(action);
    },

    setBrandingCookie: function(component) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({
                expId: expId
            });
            action.setCallback(this, function(a) {});
            $A.enqueueAction(action);
        }
    },

    handleGoogleRecaptchaPassed: function(component, event) {
		var wasGoogleRecaptchaPassed = event.getParam("wasGoogleRecaptchaPassed");
		
		if (wasGoogleRecaptchaPassed !== undefined) {
			component.set('v.wasGoogleRecaptchaPassed', wasGoogleRecaptchaPassed);
		}
    },

    getUrlParameter: function(parameterName) {
        var pageUrl = decodeURIComponent(window.location.search.substring(1));
        var urlVariables = pageUrl.split('&');
        for (var i = 0; i < urlVariables.length; i++) {
            var parameterNameFromUrl = urlVariables[i].split('=');
            if (parameterNameFromUrl[0] === parameterName) {
                return parameterNameFromUrl[1] === undefined ? true : parameterNameFromUrl[1];
            }
        }
    },

    checkIfStringIsInJSONFormat: function(text) {
        if (typeof text !== "string") {
            return false;
        }
        try {
            JSON.parse(text);
            return true;
        } catch (ex) {
            return false;
        }
    },

	//Get available business type values based on the picklist values
    getAvailableBusinessTypes: function(component) {
        // Load values from Location picklist values
        var getPicklistInfoAction = component.get('c.getPicklistInfo');
        getPicklistInfoAction.setParams({
            'objectName': 'Application__c',
            'fieldName': 'Business_Types__c',
            'firstLabel': 'Application Types',
            'firstValue': null
        });
        getPicklistInfoAction.setCallback(this, $A.getCallback(function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.availableBusinessTypes', response.getReturnValue());
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
        }));
        $A.enqueueAction(getPicklistInfoAction);
    },

    setRegistrationStatus: function(component, responseValue) {
        //Check if text message that should be displayed to user was generated
        if (responseValue && !this.checkIfStringIsInJSONFormat(responseValue)) {
            component.set("v.errorMessage", responseValue);
            component.set("v.showError", true);
            component.set('v.selfRegisterTradeAllyWrapper', null);
        } else if (this.checkIfStringIsInJSONFormat(responseValue)) {
            component.set('v.selfRegisterTradeAllyWrapper', JSON.parse(responseValue));
        }
    },

    showToast: function(type, message, title) {
        var showToast = $A.get("e.force:showToast");
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