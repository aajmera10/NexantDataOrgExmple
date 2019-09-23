({
    activateStandardSubscription: function (component) {
        var action = component.get("c.activateStandardSubscription");
        action.setParams({
            applicationId: component.get("v.applicationId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var serverStatus = response.getReturnValue();
                var status = 'success';
                if (serverStatus.indexOf('error') + 1) {
                    status = 'error';
                }
                var header = status.charAt(0).toUpperCase() + status.slice(1);
                this.showToast(status, serverStatus, header);
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