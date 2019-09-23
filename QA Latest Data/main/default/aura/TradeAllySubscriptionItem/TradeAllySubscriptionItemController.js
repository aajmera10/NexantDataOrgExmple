({
    init: function (component, event, helper) {
        var subscriptionId = component.get('v.product').id;
        var activeSubscriptionId = component.get('v.activeSubscriptionId');
        if(subscriptionId === activeSubscriptionId ) {
            var token = component.get('v.stripeToken');
            if (token) {
                helper.createSubscription(component, token);
            }
        }
    },

    openSubscribtion: function (component, event, helper) {
        var myEvent = $A.get("e.c:OpenStripeForm");
        var subscriptionId = component.get('v.product').id;
        myEvent.setParams({
            subscriptionId : subscriptionId
        });
        myEvent.fire();
    },

    closedSubscribtion: function (component, event, helper) {
        component.set("v.isSubmit", false);
    },

})