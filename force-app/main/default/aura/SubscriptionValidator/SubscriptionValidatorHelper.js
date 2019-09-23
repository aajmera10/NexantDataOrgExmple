({
	startListenerH : function (component,myInterval) {
		var action = component.get('c.isSubscriptionFinished');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var status = response.getReturnValue();
				var subscriptionWasStarted = component.get('v.subscriptionWasStarted');
				//console.log('status ',status,' subscriptionWasStarted ',subscriptionWasStarted,' ',myInterval);
				if (status === 1) {
					component.set('v.subscriptionWasStarted',true);
					//console.log('waiting');
				} else if (status == 2 && subscriptionWasStarted === true) {
					component.set('v.showPopup',true);
					//console.log('finished');
					clearInterval(myInterval);
				} else {
					//console.log('stop');
					clearInterval(myInterval);
				}
            }
        }));
        $A.enqueueAction(action);
	}
})