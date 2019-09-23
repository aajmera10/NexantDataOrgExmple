({
	doInit : function(component, event, helper) {
		// sequentially executing promises as application ID is required for the 2nd promise.
		helper.getApplicationIdPromise(component).then(function(result1) {
			var applicationId = result1;
			var recordId = component.get('v.recordId');

			if (recordId && (applicationId !== recordId)) {
				component.set('v.applicationId', recordId);
			} else {
				component.set('v.applicationId', applicationId);
			}
			helper.getApplicationSettingMetaPromise(component).then(function(result2){
				var stages = result2;
				
				if (JSON.stringify(stages).indexOf('Nexant__') !== -1) {
					component.set('v.hasNameSpace', true);
				} else {
					component.set('v.hasNameSpace', false);
				}

				component.set('v.stageMap', stages);
			});
		});
        helper.prepareAllInformation(component);
    }
})