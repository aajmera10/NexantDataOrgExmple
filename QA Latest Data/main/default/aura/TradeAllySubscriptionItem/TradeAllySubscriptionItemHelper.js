({
    createSubscription: function (component, token) {
        var action = component.get('c.createSubscription');
        var product = component.get('v.product');
        var subscription = component.get('v.subscription');
        action.setParams({
            "token": token,
            "productName": product.name,
            "currentPlanId": product.planId,
            "currentPlanInterval": product.interval,
            "productAmount": product.price.toString(),
            "serializedSubscription": JSON.stringify(subscription)
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var allInfo = response.getReturnValue();
                var resultStatusList = allInfo[0];
				console.log('allInfo ',allInfo);
                for (var i = 0; i < resultStatusList.length; i++) {
                    var resultStatus = resultStatusList[i];
                    var status = 'success';
                    if (resultStatus.indexOf('error') + 1) {
                        status = 'error';
                    }
                    var header = status.charAt(0).toUpperCase() + status.slice(1);
                    this.showToast(status, resultStatusList[i], header);
                }
                component.set('v.subscription', response.getReturnValue()[1]);
            } else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            } else if (state === "ERROR") {
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

    showToast: function (type, toastMessage, title) {
        var lexOrigin = window.location.href;
        var message={
            typeOfMessage: "EventFromVF",
            mode: 'pester',
            type: type,
            title: title,
            message: toastMessage,
            duration: '5000'
        };
        parent.postMessage(message, lexOrigin);
    }
})