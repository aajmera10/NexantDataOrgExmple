({
	loadSpecialtyNameOptions: function(component) {
		var action = component.get("c.getSpecialtyNameOptions");
		action.setCallback(this, function(response) {
            
			var state = response.getState();
			if (state === "SUCCESS") {
				var specialtyNameMap = response.getReturnValue();
				var options = [];
				
				options.push({
							'value': null,
							'key': 'Select Option'
						});
				for (var key in specialtyNameMap) {
					if (specialtyNameMap.hasOwnProperty(key)) {
						options.push({
							'value': specialtyNameMap[key],
							'key': key
						});
					}
				}
			
				console.log(options);
				component.set("v.specialtyOptions", options);
			} 
		});
        
		$A.enqueueAction(action);
       
	},

	loadSectorsOptions: function(component) {
		var action = component.get("c.getSectorsOptions");
		action.setCallback(this, function(response) {
            
			var state = response.getState();
			if (state === "SUCCESS") {
				var sectorsMap = response.getReturnValue();
				var options = [];
				
				options.push({
							'value': null,
							'key': 'Select Option'
						});
				for (var key in sectorsMap) {
					if (sectorsMap.hasOwnProperty(key)) {
						options.push({
							'value': sectorsMap[key],
							'key': key
						});
					}
				}
			
				console.log(options);
				component.set("v.sectorsOptions", options);
			} 
		});
        
		$A.enqueueAction(action);
       
	},

	getSelectedTradealliesList: function(component) {
		var action = component.get("c.getSelectedTradeallies");
		action.setParams({
			referralId : component.get('v.recordId'),
		});

		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var selectedTradeAllies = response.getReturnValue();
				component.set("v.selectedTradeAllies", selectedTradeAllies);
			} 
		});
        
		$A.enqueueAction(action);
	},
})