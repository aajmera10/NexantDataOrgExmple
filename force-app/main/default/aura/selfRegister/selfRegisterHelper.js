({

    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid': 'e.c:setExpId'
    },

    handleSelfRegister: function(component) {
        var accountId = component.get("v.accountId");
        var regConfirmUrl = component.get("v.regConfirmUrl");
        var firstname = component.find("firstname").get("v.value");
        var lastname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var includePassword = component.get("v.includePasswordField");
        var password = component.find("password").get("v.value");
        var confirmPassword = component.find("confirmPassword").get("v.value");
        var action = component.get("c.selfRegister");
        var extraFields = JSON.stringify(component.get("v.extraFields")); // somehow apex controllers refuse to deal with list of maps
        var startUrl = component.get("v.startUrl");
        startUrl = decodeURIComponent(startUrl);
        action.setParams({
            firstname: firstname,
            lastname: lastname,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            accountId: accountId,
            regConfirmUrl: regConfirmUrl,
            extraFields: extraFields,
            startUrl: startUrl,
            includePassword: includePassword
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set("v.errorMessage", rtnValue);
                    component.set("v.showError", true);
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
        //$A.enqueueAction(action);
    },

    getExtraFields: function(component) {
        var action = component.get("c.getExtraFields");
        action.setParam("extraFieldsFieldSet", component.get("v.extraFieldsFieldSet"));
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set('v.extraFields', rtnValue);
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
    }
    
})