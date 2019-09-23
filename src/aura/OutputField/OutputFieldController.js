({
	openDetailsPage : function(component, event, helper) {
		var navEvt = $A.get("e.force:navigateToSObject");
        var oneField = component.get('v.oneField');
		var recordId;
		if (oneField.type === 'REFERENCE') {
			recordId = oneField.value;
		} else {
			recordId = oneField.recordId;
		}
		//console.log('recordId ',recordId);
        navEvt.setParams({
			"recordId" : recordId
        });
        navEvt.fire();
	}
})