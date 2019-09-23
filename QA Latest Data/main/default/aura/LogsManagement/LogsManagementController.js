({
	doInit : function (component, event, helper) {
		/*var defaultAccountId = component.get("v.defaultAccountId");
		console.log('defaultAccountId ',defaultAccountId);
		if (defaultAccountId) {
			component.set("v.isTradeAlliesView", false);
			component.set("v.selectedTradeAllyName","New Task");
			helper.prepareNewLogInfo(component,defaultAccountId);
		} else {*/
		helper.prepareListOfAccounts(component);
		//}
	},

	findAccounts : function (component, event, helper) {
		helper.prepareListOfAccounts(component);
	},

	changeSorting : function (component, event, helper) {
		var fieldName = event.target.dataset.fname;
		var sortField = component.get('v.sortField');
		var sortOrder = component.get('v.sortOrder');
		if (fieldName === sortField) {
			if (sortOrder === 'ASC') {
				sortOrder = 'DESC';
			} else {
				sortOrder = 'ASC';
			}
		} else {
			sortField = fieldName;
			sortOrder = 'ASC';
		}
		component.set('v.sortField',sortField);
		component.set('v.sortOrder',sortOrder);
		helper.prepareListOfAccounts(component);
	},

	/*selectTradeAlly : function (component, event, helper) {
		var position = event.target.dataset.position;
		var listOfTradeAllies = JSON.parse(JSON.stringify(component.get("v.listOfTradeAllies")));
		component.set("v.selectedTradeAllyName",listOfTradeAllies[position].Name);
		helper.prepareNewLogInfo(component,listOfTradeAllies[position].Id);
	},

	cancelSelection : function (component, event, helper) {
		component.set("v.isTradeAlliesView", true);
	},

	saveNewLog : function (component, event, helper) {
		console.log(component.get("v.wrappedLogInfo"));
		//console.log(JSON.parse(JSON.stringify(component.get("v.wrappedLogInfo"))));
		helper.saveLog(component);
	},*/
})