({
    doInit: function (component, event, helper) {
        var action = component.get("c.getCommunicationHistoryResults");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var communicationRecords = response.getReturnValue();
                // console.log('communicationRecords ', communicationRecords);
                component.set(
                    "v.communications",
                    communicationRecords
                );
            }
            else if (state === "INCOMPLETE") {
                helper.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        helper.showToast('error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                    }
                                }
                            }
                            helper.showToast('error', errors[i].message, 'Error');
                        }
                    }
                }
                else {
                    helper.showToast('error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
        });

        $A.enqueueAction(action);
    }
})