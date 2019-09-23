({
    handleForgotPassword: function (component, event, helper) {
        helper.handleForgotPassword(component);
    },
    
    onKeyUp: function(component, event, helper){
    //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleForgotPassword(component);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component);
    },

    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();
    }
})