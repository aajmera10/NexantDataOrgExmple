({
    refreshOptions : function(component) {
        var self = this;
        var action = component.get("c.searchData");
        var searchString = component.get("v.name");
        
		var strObject = component.get("v.object");
		if (strObject.indexOf("TaxRate") > -1 )
			strObject = "User";
		action.setParams({
            "strInputData": searchString,
            "strObject": strObject
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();//JSON.parse(response.getReturnValue());
                //console.log(result);

                var options = [];
                var needToSelectNew = true;
                var value = component.get("v.value");

                if (result !== undefined && result !== 'undefined') {
                    result.forEach(function(element, index, array) {
                        var option = {};//new Object();
                        option.value = element.Id;
                        option.label = element.Name;
                        options.push(option);
                        if (value === element.Id) {
                            needToSelectNew = false;
                        }
                    });
                }

                component.set("v.options", options);

                if (needToSelectNew === true && options.length > 0) {
                    component.set("v.value", options[0].value);
                    component.set("v.textToShow", options[0].label);
                    component.set("v.name", options[0].label);
                }

                if (component.find("default_show") !== undefined)
                    $A.util.addClass(component.find("default_show").getElement(), "hidden_div");
                if (component.find("normal_show") !== undefined)
                    $A.util.removeClass(component.find("normal_show").getElement(), "hidden_div");
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
        }));
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