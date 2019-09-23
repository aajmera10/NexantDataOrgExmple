({
    doInit: function (component) {
        var action = component.get('c.getInitData');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.communities', response.getReturnValue()[0]);
                component.set('v.groupsNames', response.getReturnValue()[1]);
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

    checkExistingGroups: function (component) {
        var action = component.get('c.getExistingGroups');
        action.setParams({
            "groupNamesList": component.get('v.groupsNames'),
            "networkName": component.get('v.currentCommunityName')
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var existingGroups = response.getReturnValue();
                var countOfExistingGroups = existingGroups.length;
                component.set('v.countOfExistingGroups', countOfExistingGroups);
                var existingGroupsNames = [];
                for (var i = 0; i < existingGroups.length; i++) {
                    existingGroupsNames.push(existingGroups[i].Name)
                }
                component.set('v.existingGroupsNames', existingGroupsNames);
                if(countOfExistingGroups < 3 && component.get('v.currentCommunityName')) {
                    this.showToast('success', 'This community has not ' + (3 - countOfExistingGroups) + ' groups', 'Success');
                    component.set('v.groupsNotChecked', false);
                }
                else{
                    component.set('v.groupsNotChecked', true);
                }

            }
            else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (i = 0; i < errors.length; i++) {
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

    createMissedGroups: function (component) {
        var action = component.get('c.createChatterGroups');
        action.setParams({
            "networkName": component.get('v.currentCommunityName')
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var countOfInsertedGroups = response.getReturnValue();
                this.checkExistingGroups(component);
                this.showToast('success', countOfInsertedGroups + ' groups successfully created', 'Success');
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

    showToast: function (type, message, title) {
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