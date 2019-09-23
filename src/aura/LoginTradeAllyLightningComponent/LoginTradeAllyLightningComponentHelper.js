({

    qsToEventMap: {
        'startURL': 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid': 'e.c:setExpId'
    },

    handleLogin: function(component) {
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");
        startUrl = decodeURIComponent(startUrl);
        action.setParams({
            username: username,
            password: password,
            startUrl: startUrl
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
        $A.enqueueAction(action);
    },

    getIsUsernamePasswordEnabled: function(component) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set('v.isUsernamePasswordEnabled', rtnValue);
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

    getIsSelfRegistrationEnabled: function(component) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set('v.isSelfRegistrationEnabled', rtnValue);
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

    getCommunityForgotPasswordUrl: function(component) {
        var action = component.get("c.getForgotPasswordUrl");
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set('v.communityForgotPasswordUrl', rtnValue);
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

    getCommunitySelfRegisterUrl: function(component) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rtnValue = response.getReturnValue();
                if (rtnValue !== null) {
                    component.set('v.communitySelfRegisterUrl', rtnValue);
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