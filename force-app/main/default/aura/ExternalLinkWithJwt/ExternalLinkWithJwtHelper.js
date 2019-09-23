({
    showToast: function (component, type, message, title) {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            mode: 'pester',
            type: type,
            title: title,
            message: message,
            duration: '5000'
        });
        showToast.fire();
		this.hideSpinner(component);
    },
    
    gotoURL : function (component, event, urlAddress) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": urlAddress
        });
        urlEvent.fire();
    },

	showSpinner : function(component) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component){  
       component.set("v.Spinner", false);
    },
    
    getExternalLink : function(component, event) {
        var action = component.get("c.getLink");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var urlAddress = response.getReturnValue();
                this.hideSpinner(component);
                this.gotoURL(component, event, urlAddress);
            }
            else if (state === "INCOMPLETE") {
                this.showToast(component, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
                else if (state === "ERROR") {
                    this.showToast(component, 'error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
        });
        $A.enqueueAction(action);
    }
})