({
    init: function (component, event, helper) {
        helper.activateStandardSubscription(component);
    },

    stayStandard: function (component) {
        component.destroy();
    }
})