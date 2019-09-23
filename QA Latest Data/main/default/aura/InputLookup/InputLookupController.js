({
    doInit : function(component) {
		component.set("v.searchIconURL", $A.get('$Resource.searchIcon'));
		var value = component.get("v.value");
		//console.log(JSON.parse(JSON.stringify(value)));
		var textToShow = component.get("v.textToShow");
		//console.log(JSON.parse(JSON.stringify(textToShow)));
		var options = component.get("v.options");
		//console.log(JSON.parse(JSON.stringify(options)));

		if (value) {
			options = [];
			var option = {};//new Object();
            option.value = value;
            option.label = textToShow;
            options.push(option);
			component.set("v.options",options);
			component.set("v.name",textToShow);
		}
    },
	
	handleInit : function(component, event, helper) {
		component.set('v.isList',true);
        helper.refreshOptions(component);
		component.set("v.wasUpdated",true);
    },

    handleValueChange : function(component, event) {
		//console.log(event.target.childNodes);
		var childNodes = event.target.childNodes;
		for (var i = 0; i < childNodes.length; i++) {
			if (childNodes[i].selected) {
				//console.log(childNodes[i].value);
				component.set("v.value", childNodes[i].value);
				component.set("v.textToShow", childNodes[i].label);
				component.set("v.name", childNodes[i].label);
				break;
			}
		}
		component.set("v.wasUpdated",true);
    },

	selectValue : function(component, event) {
		//console.log('event.target value',  event.target.dataset.value);
		//console.log('event.target label',  event.target.dataset.label);

		var recordId = event.target.dataset.value;
		var recordName = event.target.dataset.label;

		component.set(
			"v.value", 
			recordId
		);
		component.set(
			"v.textToShow", 
			recordName
		);
		component.set(
			"v.name", 
			recordName
		);
		component.set(
			"v.options", 
			[]
		);
		
	}
})