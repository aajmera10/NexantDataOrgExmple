({
	
	doInit : function(component, event, helper) {
		console.log('recordId:', component.get('v.recordId'));
        helper.loadSpecialtyNameOptions(component);
        helper.loadSectorsOptions(component);
		helper.getSelectedTradealliesList(component);
	},

	searchForTradeAlly : function(component, event, helper) {
		var selectedSpecialtyId = component.get('v.selectedSpecialtyId');
		var selectedSectors = component.get('v.selectedSectors');
		var action = component.get("c.searchForTradeAllies");
        
		if (selectedSpecialtyId === '') {
			selectedSpecialtyId = null;
		}
		
		if (selectedSectors === '') {
			selectedSectors = null;
		}
		
		console.log(selectedSectors);
		action.setParams({
			selectedSpecialtyId : selectedSpecialtyId,
			sectors : selectedSectors
		});

		action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tradeAllies = response.getReturnValue();
				//console.log('tradeAllies ', tradeAllies);
				component.set(
					"v.availableTradeAllies", 
					tradeAllies
				);
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
            }
        });

        $A.enqueueAction(action);
	},

	selectTradeAllies : function(component, event, helper) {
		console.log('selectTradeAllies');
		var tradeAllies = component.get("v.availableTradeAllies");
		var selectedTradeAllies = component.get("v.selectedTradeAllies");

		for (var i = 0; i < tradeAllies.length; i++) {
			if (tradeAllies[i].isSelected) {
				var isContained = false;
				for (var j = 0; j < selectedTradeAllies.length; j++) {
					if (selectedTradeAllies[j].tradeAlly.Id == tradeAllies[i].tradeAlly.Id ) {
						isContained = true;
						break;
					}
				}
				if (!isContained) {
					selectedTradeAllies.push(tradeAllies[i]);
				}
			}
		}

		component.set("v.selectedTradeAllies", selectedTradeAllies);
	},

	createTradeAlliesReferralRelation : function(component, event, helper) {
		var referralId =  component.get("v.recordId");
		var selectedTradeAllies = component.get("v.selectedTradeAllies");
		//console.log('referralId= ',referralId);
		//console.log('selectedTradeAllies= ', selectedTradeAllies);

		if (referralId) {
			var action = component.get("c.createTradeAllyReferralRelation");
			action.setParams(
				{
					refRecordId : referralId,
					selectedAccounts : JSON.stringify(selectedTradeAllies)
				}
			);
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === "SUCCESS") {
					helper.getSelectedTradealliesList(component);
				} /*else if (state === "INCOMPLETE") {
				} else if (state === "ERROR") {
				}*/
			});

			$A.enqueueAction(action);
		}
	},

	handleSpecialtyOptionsChange: function(component, event, helper) {
		var selectedSpecialtyId = component.get('v.selectedSpecialtyId');
		console.log('selectedSpecialtyId: ',selectedSpecialtyId);
		this.searchForTradeAlly(component, event, helper);
    },


})