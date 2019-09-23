({
	implementPagination : function(component, startIndex, numOfRecordsDisplayed, maxEndPosition, allRecords) {
		var tasksToDisplay = [];
		var endIndex = startIndex + numOfRecordsDisplayed;

		if (endIndex > maxEndPosition) {
			endIndex = maxEndPosition;
			startIndex = endIndex - numOfRecordsDisplayed;
		}

		if (startIndex < 0) {
			startIndex = 0;
			endIndex = startIndex + numOfRecordsDisplayed;
		}

		for (var i = startIndex; i < endIndex; i++) {
			if (allRecords[i] != null)
			tasksToDisplay.push(allRecords[i]);
		}
		
		component.set(
			"v.recordsToDisplay", 
			tasksToDisplay
		);
		component.set(
			"v.currentStartIndex", 
			startIndex
		);
	},

	setCurrentPageNumber : function(component, pageNumber) {
		component.set(
			"v.currentPageNumber", 
			pageNumber
		);
	
	},

	setLastPageNumber : function(component, pageNumber) {
		component.set(
			"v.lastPageNumber", 
			pageNumber
		);
	},

	incrementPageNumber : function(component, pageNumber) {
		pageNumber = component.get("v.currentPageNumber");
		var lastPageNumber = component.get("v.lastPageNumber");
		if (pageNumber < lastPageNumber)
			pageNumber += 1;
		this.setCurrentPageNumber(
			component, 
			pageNumber
		);
	},

	decreasePageNumber  : function(component, pageNumber) {
		pageNumber = component.get("v.currentPageNumber");
		if (pageNumber > 1)
			pageNumber -= 1;
		this.setCurrentPageNumber(
			component, 
			pageNumber
		);
	},

	sortRecords : function(component, helper, sortField) {
		var records = component.get("v.allRecords");
		var isASCOrder = component.get("v.isSortOrderASC");
		var oldSortField =  component.get("v.sortField");

		isASCOrder = sortField === oldSortField ? !isASCOrder : true;

		helper.processSorting(
			helper,
			records, 
			sortField, 
			isASCOrder
		);

		component.set(
			"v.allRecords", 
			records
		);
		component.set(
			"v.isSortOrderASC", 
			isASCOrder
		);
		component.set(
			"v.sortField", 
			sortField
		);

	},

	processSorting : function(helper, recordsArray, sortField, sortOrder) {
		recordsArray.sort(
			function(
				firstCommuncation, 
				secondCommuncation
			)
			{
				var firstValue = helper.getRecordValue(firstCommuncation, sortField);
				var secondValue = helper.getRecordValue(secondCommuncation, sortField);

				if (firstValue === null && secondValue != null) {
					return sortOrder ? -1 : 1;
				}
				if (firstValue != null && secondValue === null) {
					return sortOrder ? 1 : -1;
				}
				if (firstValue < secondValue) {
					return sortOrder ? -1 : 1;
				}
				if (firstValue > secondValue) {
					return sortOrder ? 1 : -1;
				}
				return 0;
			} 
		);
	},

	getRecordValue : function(record, sortField) {
		if (sortField === 'Who' || sortField === 'What') {
			var objectValue =  record[sortField];
			if (objectValue === null)
				return null;
			return record[sortField]['Name'];
		} else {
			return record[sortField];
		}
	}

})