({
	prepareNewLogInfo : function(component, selectedAccountId) {
		//console.log('selectedAccountId ',selectedAccountId);
        var action = component.get("c.getWrappedLogInfo");
        action.setParams({
            accountId : selectedAccountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var wrappedLogInfo = response.getReturnValue();
				//console.log('wrappedLogInfo ',wrappedLogInfo);
				component.set("v.wrappedLogInfo", wrappedLogInfo);
				component.set("v.isViewMode", false);
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

	reviewWrappedFields : function(wrappedFields) {
		var isValid = true;
		for (var i = 0; i < wrappedFields.length; i++) {
			if (wrappedFields[i].isValid == false) {
				isValid = false;
				break;
			}
			if (
				wrappedFields[i].required == true &&
				(
					(
						(
							wrappedFields[i].type == 'REFERENCE' || 
							wrappedFields[i].type == 'STRING' || 
							wrappedFields[i].type == 'EMAIL' || 
							wrappedFields[i].type == 'PHONE' || 
							wrappedFields[i].type == 'URL' || 
							wrappedFields[i].type == 'TEXTAREA' || 
							wrappedFields[i].type == 'RICHTEXTAREA' || 
							wrappedFields[i].type == 'PICKLIST' || 
							wrappedFields[i].type == 'COMBOBOX'
						) &&
						!wrappedFields[i].value
					) ||
					(
						wrappedFields[i].type == 'DATETIME' &&
						!wrappedFields[i].valueDateTime
					) ||
					(
						wrappedFields[i].type == 'DATE' &&
						!wrappedFields[i].valueDate
					) ||
					(
						wrappedFields[i].type == 'BOOLEAN' &&
						(
							!wrappedFields[i].valueBoolean ||
							wrappedFields[i].valueBoolean == false
						)
					) ||
					(
						(
							wrappedFields[i].type == 'INTEGER' || 
							wrappedFields[i].type == 'CURRENCY' || 
							wrappedFields[i].type == 'DOUBLE' || 
							wrappedFields[i].type == 'PERCENT'
						) &&
						!wrappedFields[i].valueNumber
					)
				)
			) {
				isValid = false;
				break;
			}
		}
		return isValid;
	},

	saveLog : function(component) {
		var wrappedLogInfo = component.get("v.wrappedLogInfo");
		var validUpdate = this.reviewWrappedFields(wrappedLogInfo.listOfTaskFields);
		if (validUpdate) {
			var action = component.get("c.createNewLog");
			action.setParams({
				wrappedLogInfoJSON : JSON.stringify(wrappedLogInfo)
			});
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					component.set("v.wrappedLogInfo", undefined);
					component.set("v.isViewMode", true);
					//console.log('Success');
					$A.get('e.force:refreshView').fire();
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
		} else {
			this.showToast('error', $A.get("$Label.c.Valid_Data_and_Required_Fields"), 'Error');
		}
    },

    showToast: function (type, message, title) {
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