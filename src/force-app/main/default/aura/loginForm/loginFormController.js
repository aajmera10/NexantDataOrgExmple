({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();    
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap2}).fire();
        component.set('v.isUsernamePasswordEnabled', helper.getIsUsernamePasswordEnabled(component));
        component.set("v.isSelfRegistrationEnabled", helper.getIsSelfRegistrationEnabled(component));
        component.set("v.communityForgotPasswordUrl", helper.getCommunityForgotPasswordUrl(component));
        component.set("v.communitySelfRegisterUrl", helper.getCommunitySelfRegisterUrl(component));
    },
    
    handleLogin: function (component, event, helper) {
        helper.handleLogin(component);
    },
    
    setStartUrl: function (component, event) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    
    setExpId: function (component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component);
    },
    
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helper.handleLogin(component);
        }
    },
    
    navigateToForgotPassword: function(component) {
        var forgotPwdUrl = component.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = component.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(component) {
        var selrRegUrl = component.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = component.get("v.selfRegisterUrl");
        }
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    } 
})