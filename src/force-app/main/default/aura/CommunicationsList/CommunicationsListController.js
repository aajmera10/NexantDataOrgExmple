({
	startPagination : function(component, event, helper) {
		var startIndex = 0;
		var numOfRecordsDisplayed = component.get("v.numberOfRecords");
		var allRecords = component.get("v.allRecords");
		var maxEndPosition =  allRecords.length - 1;
		helper.implementPagination(component, startIndex, numOfRecordsDisplayed, maxEndPosition, allRecords);
		helper.setCurrentPageNumber(component, 1);
		helper.setLastPageNumber(
			component, 
			Math.ceil(
				allRecords.length/numOfRecordsDisplayed
			)
		);
	},

	showNextRecords : function(component, event, helper) {
		var startIndex = component.get("v.currentStartIndex");
		var numOfRecordsDisplayed = component.get("v.numberOfRecords");
		var allRecords = component.get("v.allRecords");
		var maxEndPosition =  allRecords.length - 1;
		startIndex = startIndex + numOfRecordsDisplayed;
		helper.implementPagination(component, startIndex, numOfRecordsDisplayed, maxEndPosition, allRecords);
		helper.incrementPageNumber(component);
	},

	showPreviousRecords : function(component, event, helper) {
		var startIndex = component.get("v.currentStartIndex");
		var numOfRecordsDisplayed = component.get("v.numberOfRecords");
		var allRecords = component.get("v.allRecords");
		var maxEndPosition =  allRecords.length - 1;
		startIndex = startIndex - numOfRecordsDisplayed;
		helper.implementPagination(component, startIndex, numOfRecordsDisplayed, maxEndPosition, allRecords);
		helper.decreasePageNumber(component);

	},

	showLastRecords : function(component, event, helper) {
		var numOfRecordsDisplayed = component.get("v.numberOfRecords");
		var allRecords = component.get("v.allRecords");
		var maxEndPosition =  allRecords.length - 1;
		var startIndex = maxEndPosition - numOfRecordsDisplayed;
		helper.implementPagination(component, startIndex, numOfRecordsDisplayed, maxEndPosition, allRecords);
		helper.setCurrentPageNumber(
		component, 
			Math.ceil(
				allRecords.length/numOfRecordsDisplayed
			)
		);
	},

	sortRecordsList : function(component, event, helper) {
		var sortByField = event.target.dataset.value;
		component.set('v.sort', sortByField);
		helper.sortRecords(
			component,
			helper, 
			sortByField
		);
		var startPaginationAction = component.get('c.startPagination');
        $A.enqueueAction(startPaginationAction);
	}

})