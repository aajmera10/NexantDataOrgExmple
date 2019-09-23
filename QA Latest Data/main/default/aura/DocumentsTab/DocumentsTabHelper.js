({
	/**
	 * Get the ID of current application
	 */
	getApplicationIdPromise: function(component) {
		var action = component.get('c.getApplicationId');
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else {
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * Get application stage meta data
	 */
	getApplicationSettingMetaPromise: function(component) {
		var action = component.get('c.serverGetApplicationStageMap');
		action.setParams({
			applicationId: component.get('v.applicationId')
		});
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	
	/**
	 * TODO: simplify this part. keep security-related settings only
	 */
	prepareAllInformation : function(component) {
        var action = component.get("c.getAllInfoWrapper");
        action.setParams({
            applicationId : component.get("v.applicationId"), 
			tradeAllyId : component.get("v.tradeAllyId"),
			urlPathPrefix : component.get("v.urlPathPrefix")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allInfo = response.getReturnValue();
                //console.log(allInfo);
				component.set(
					"v.appNotExists", 
					(
						allInfo.appNotExists ||
						(
							component.get("v.tradeAllyId") &&
							allInfo.isCommunityUser
						)
					)
				);
				// component.set("v.isValidUser", allInfo.isValidUser);
				component.set("v.isValidUser", true);
				component.set("v.allInfoWrapper", allInfo);
            } else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            } else if (state === "ERROR") {
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
    }
})