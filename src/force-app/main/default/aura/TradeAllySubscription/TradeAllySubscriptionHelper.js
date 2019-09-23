({
    doInit: function (component) {
        var action = component.get('c.getInitData');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var userState = response.getReturnValue()[0];
                if (!userState) {
                    this.showToast('error', 'Current user have not account', 'Error');
                }
                else {
                    var communityDomain = response.getReturnValue()[4];
                    var products = response.getReturnValue()[2];
                    var plans = response.getReturnValue()[3];
                    var subscription = response.getReturnValue()[1];
                    component.set('v.subscription', subscription);
                    component.set('v.communityDomain', communityDomain);
                    var productsList = [];
                    for (var i = 0; i < products.length; i++) {
                        var tempPrice;
                        var interval;
                        var planId;
                        for (var j = 0; j < plans.length; j++) {
                            if(plans[j].product === products[i].id) {
                                tempPrice = plans[j].amount / 100;
                                if (plans[j].interval) {
                                    interval = plans[j].interval;
                                }
                                if (plans[j].id) {
                                    planId = plans[j].id;
                                }
                            }
                                }
                        var description = '';
                        if(products[i].metadata.description) {
                            description = products[i].metadata.description.split(", ");
                        }
                        var pricePerInterval = tempPrice + '$ ' + 'per ' + interval;
                        if(tempPrice === 0){
                            pricePerInterval ='free'
                        }
                        var product = {
                            name: products[i].name,
                            id: products[i].id,
                            description: description,
                            price: tempPrice,
                            interval: interval,
                            pricePerInterval: pricePerInterval,
                            planId:planId,
                        };
                       productsList.push(product);
                    }
                    component.set('v.products', productsList);
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
                                    for (j = 0; j < errors[i].pageErrors.length; j++) {
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