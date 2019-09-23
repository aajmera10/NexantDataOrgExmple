({
    goToSubscription: function (component, event, helper) {
        var currentUrl = window.location.href;
        var ind = currentUrl.indexOf('/s/');
        var cattedStr = currentUrl.substr(0, ind+3);
        var subscriptionUrl = cattedStr + 'subscription';
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": subscriptionUrl
        });
        urlEvent.fire();
    }
})