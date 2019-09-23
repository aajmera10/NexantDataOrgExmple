({
	prepareListOfAccounts : function(component) {
        var action = component.get("c.getListOfAccounts");
        action.setParams({
            accountSearchText : component.get("v.accountSearchText"),
			sortOrder : component.get('v.sortOrder'),
			sortField : component.get('v.sortField')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tradeAlliesData = response.getReturnValue();
				//console.log('tradeAlliesData ',tradeAlliesData);
				component.set("v.tradeAlliesData", tradeAlliesData);
            }
            else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
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
        });
        $A.enqueueAction(action);
    },

    showToast: function (type, message, title) {
        var showToast = $A.get("e.force:showToast");
        //console.log('showToast ', showToast);
        showToast.setParams({
            mode: 'pester',
            type: type,
            title: title,
            message: message,
            duration: '5000'
        });
        showToast.fire();
    },

	/*prepareNewLogInfo : function(component, selectedAccountId) {
		console.log('selectedAccountId ',selectedAccountId);
        var action = component.get("c.getWrappedLogInfo");
        action.setParams({
            accountId : selectedAccountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrappedLogInfo = response.getReturnValue();
				console.log('wrappedLogInfo ',wrappedLogInfo);
				component.set("v.wrappedLogInfo", wrappedLogInfo);
				component.set("v.isTradeAlliesView", false);
            } else {
                console.log('Unable to load data');
            }
        });
        $A.enqueueAction(action);
    },

	saveLog : function(component) {
        var action = component.get("c.createNewLog");
        action.setParams({
            wrappedLogInfoJSON : JSON.stringify(component.get("v.wrappedLogInfo"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				var defaultAccountId = component.get("v.defaultAccountId");
				console.log('defaultAccountId ',defaultAccountId);
				if (defaultAccountId) {
					this.prepareNewLogInfo(component,defaultAccountId);
				} else {
					component.set("v.isTradeAlliesView", true);
					component.set("v.wrappedLogInfo", undefined);
				}
                console.log('Success');
            } else {
                console.log('Unable to load data');
            }
        });
        $A.enqueueAction(action);
    },*/
})