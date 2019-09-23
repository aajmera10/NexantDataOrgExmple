({

    doInit: function(component) {

		var action = component.get("c.getNamespace");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var namespace = response.getReturnValue();
				component.set("v.namespace",namespace);
            }
        });
        $A.enqueueAction(action);
		
        var vfOrigin = component.get('v.domainUrl');
        window.addEventListener("message", function(event) {
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }
            var wasGoogleRecaptchaPassedEvent = $A.get('e.c:WasGoogleRecaptchaPassedEvent');
            // Handle the event when the Captcha was solved successfully
            if (event.data === 'Unlock') {
                wasGoogleRecaptchaPassedEvent.setParams({
                    'wasGoogleRecaptchaPassed': true
                });
            }
            // Handle the event whet the Captcha was expired
            if (event.data === 'Expired') {
                wasGoogleRecaptchaPassedEvent.setParams({
                    'wasGoogleRecaptchaPassed': false
                });
            }
            wasGoogleRecaptchaPassedEvent.fire();
        }, false);
    }
})