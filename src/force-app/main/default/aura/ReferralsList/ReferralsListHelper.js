({
	prepareListOfReferrals : function(component, helper) {
        var action = component.get("c.getListOfReferrals");
		//console.log(component.get('v.selectedFilter'));
        action.setParams({
            referralSearchText : component.get("v.referralSearchText"),
			sortOrder : component.get('v.sortOrder'),
			sortField : component.get('v.sortField'),
			filterName : component.get('v.selectedFilter')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var referralsData = response.getReturnValue();
				//console.log('referralsData ',referralsData);
				component.set("v.referralsData", referralsData);
            }
            else if (state === "INCOMPLETE") {
                this.showToast(component, event, helper, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            this.showToast(component, event, helper, 'error', errors[0].message, 'Error');
                        }
                    }
                } else {
                    this.showToast(component, event, helper, 'error',$A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, type, message, title) {
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
})