({
	
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({
            "qsToEvent": helper.qsToEventMap
        }).fire();
        $A.get("e.siteforce:registerQueryEventMap").setParams({
            "qsToEvent": helper.qsToEventMap2
        }).fire();
        component.set('v.extraFields', helper.getExtraFields(component));
        //component.set('v.registrationCode', helper.getUrlParameter('RegistrationCode'));
        helper.getAvailableBusinessTypes(component);
    },

    handleSelfRegister: function(component, event, helper) {
        // Check if Google Recaptcha was solved
        var wasGoogleRecaptchaPassed = component.get('v.wasGoogleRecaptchaPassed');
        var wasRecaptchaIncluded = component.get('v.includeRecaptcha');
		//console.log(component.get('v.wasGoogleRecaptchaPassed'));
        if (wasGoogleRecaptchaPassed || !wasRecaptchaIncluded) {
            var selfRegisterTradeAllyWrapper = {
                'accountId': component.get("v.accountId"),
                'regConfirmUrl': component.get("v.regConfirmUrl"),
                'firstname': component.find("firstname").get("v.value"),
                'lastname': component.find("lastname").get("v.value"),
                'email': component.find("email").get("v.value"),
                'includePassword': component.get("v.includePasswordField"),
                'password': component.find("password").get("v.value"),
                'confirmPassword': component.find("confirmPassword").get("v.value"),
                'extraFields': JSON.stringify(component.get("v.extraFields")),
                'startUrl': decodeURIComponent(component.get('v.startUrl')),
				'companyType': component.get('v.companyBusinessType'),
                'registrationCode': component.get('v.registrationCode'),
                'includeApplicationType': component.get('v.includeApplicationType')
            };
            helper.handleSelfRegister(component, event, selfRegisterTradeAllyWrapper);
        } else {
            component.set("v.errorMessage", $A.get("$Label.c.Application_Recaptcha_Error"));
            component.set("v.showError", true);
        }
    },

    setStartUrl: function(component, event, helper) {
        var startUrl = event.getParam('startURL');
        if (startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },

    setExpId: function(component, event, helper) {
        var expId = event.getParam('expid');
        if (expId) {
            component.set("v.expid", expId);
        }
        helper.setBrandingCookie(component);
    },

    onKeyUp: function(component, event, helper) {
        if (event.getParam('keyCode') === 13) {
            helper.handleSelfRegister(component, event);
        }
    },
    
    //--- Custom Functions ---//
    handleGoogleRecaptchaPassed: function(component, event, helper) {
        helper.handleGoogleRecaptchaPassed(component, event);
    }
})