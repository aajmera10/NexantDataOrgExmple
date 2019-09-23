({
	doInit : function (component, event, helper) {
		//console.log('doInit is run');
		helper.prepareAllAlertsInfo(component, true);
	},

	selectAnotherFilter : function (component, event, helper) {
		helper.selectListOfRecordsToDisplay(component);
	},

	deleteAlert : function (component, event, helper) {
		var alertPosition = event.target.dataset.position;
		var listOfAlerts = component.get("v.listOfAlerts");
		var newList = [];
		var alertIdTodelete;
		for (var i = 0; i < listOfAlerts.length; i++) {
			if (alertPosition !== i.toString())
				newList.push(JSON.parse(JSON.stringify(listOfAlerts[i])));
			else
				alertIdTodelete = listOfAlerts[i].alert.Id;
		}
		component.set("v.listOfAlerts", newList);
		//console.log(alertIdTodelete);
		helper.deleteRecord(component, alertIdTodelete);
	},

	/*selectAlertForReview : function (component, event, helper) {
		console.log(event.getSource().get('v.name'));//.getElement().name
	},*/

	toggleActive : function (component, event, helper) {
		var shortListOfAlerts = JSON.parse(JSON.stringify(component.get("v.shortListOfAlerts")));
		//console.log(event.getSource().get('v.name'));
		var checkboxPosition = parseInt(event.getSource().get('v.name'),10);//.getElement().name
		//var newListOfAlerts = JSON.parse(JSON.stringify(listOfAlerts));
		var isChecked = event.getSource().get('v.value');//.getElement().checked;
		//console.log(listOfAlerts);
		//console.log(checkboxPosition);
		//console.log(listOfAlerts[checkboxPosition]);
		//var recordId = newListOfAlerts[checkboxPosition].alert.Id;
		var recordId = shortListOfAlerts[checkboxPosition].alert.Id;
		//console.log(recordId,' ',isChecked);
		helper.updateAlertAtivation(component, recordId,isChecked);
	},

	openFirst : function (component, event, helper) {
		component.set("v.pageNumber", 1);
		helper.implementPagination(component,1);
	},

	openPrevious : function (component, event, helper) {
		var pageNumber = component.get("v.pageNumber");
		component.set("v.pageNumber", pageNumber - 1);
		helper.implementPagination(component,pageNumber - 1);
	},

	openLast : function (component, event, helper) {
		var maxPages = component.get("v.maxPages");
		component.set("v.pageNumber", maxPages);
		helper.implementPagination(component,maxPages);
	},

	openNext : function (component, event, helper) {
		var pageNumber = component.get("v.pageNumber");
		component.set("v.pageNumber", pageNumber + 1);
		helper.implementPagination(component,pageNumber + 1);
	},

	selectPage : function (component, event, helper) {
		var pageNumber = component.get("v.pageNumber");
		var maxPages = component.get("v.maxPages");
		//console.log('pageNumber ',pageNumber);
		if (pageNumber < 1) {
			pageNumber = 1;
		} else if (pageNumber > maxPages) {
			pageNumber = maxPages;
		}
		//console.log('pageNumber ',pageNumber);
		component.set("v.pageNumber", pageNumber);
		helper.implementPagination(component,pageNumber);
	},

	alert: function (component, event, helper) {
		//console.log('clicked');

	}
})