({
	goToEditMode : function (component, event, helper) {
		var defaultAccountId = component.get("v.defaultAccountId");
		//console.log('defaultAccountId ',defaultAccountId);
		helper.prepareNewLogInfo(component, defaultAccountId);
	},

	saveNewLog : function (component, event, helper) {
		//console.log(component.get("v.wrappedLogInfo"));
		helper.saveLog(component);
	},
})