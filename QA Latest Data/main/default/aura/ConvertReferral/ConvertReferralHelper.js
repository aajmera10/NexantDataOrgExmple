({
	prepareStatusInformation : function(component, helper) {
        var action = component.get("c.getRecordStatus");
		//console.log('recordId ',component.get("v.recordId"));
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var convertationNotAvailable = response.getReturnValue();
                //console.log(convertationNotAvailable);
                component.set("v.convertationNotAvailable",convertationNotAvailable);
            } else if (status === "INCOMPLETE") {
                this.showToast(component, event, helper, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            this.showToast(
								component, 
								event, 
								helper, 
								'error', 
								errors[0].message, 
								'Error'
							);
                        }
                    }
                } else {
                    this.showToast(
						component, 
						event, 
						helper, 
						'error',
						$A.get("$Label.c.Internal_server_error"), 
						'Error'
					);
                }
            }
        });
        $A.enqueueAction(action);
    },

	startConvertation : function(component, helper) {
        var action = component.get("c.startReferralConvertation");
		//console.log('recordId ',component.get("v.recordId"));
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var referralStatus = response.getReturnValue();
                //console.log(referralStatus);
				component.set("v.convertationNotAvailable",true);
				$A.get('e.force:refreshView').fire();
				$A.get("e.force:closeQuickAction").fire();
                //component.set("v.referralStatus", referralStatus);
            } else if (status === "INCOMPLETE") {
                this.showToast(component, event, helper, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            this.showToast(
								component, 
								event, 
								helper, 
								'error', 
								errors[0].message, 
								'Error'
							);
                        }
                    }
                } else {
                    this.showToast(
						component, 
						event, 
						helper, 
						'error',
						$A.get("$Label.c.Internal_server_error"), 
						'Error'
					);
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, type, message, title) {
        var showToast = $A.get("e.force:showToast");
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