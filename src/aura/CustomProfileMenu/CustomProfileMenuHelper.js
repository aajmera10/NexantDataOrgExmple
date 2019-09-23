({
	loadAllData : function (component) {
		var action = component.get("c.prepareProfileMenuData");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allInfo = response.getReturnValue();
				//console.log(allInfo);
				component.set("v.allInfo",allInfo);
            }
        });
        $A.enqueueAction(action);
	},

	navigationByLink : function (component, url) {
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            "isredirect": true
        });
        urlEvent.fire();
	},

	navigationToRecord : function (component, recordId) {
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
			"recordId" : recordId
        });
        navEvt.fire();
	},
})