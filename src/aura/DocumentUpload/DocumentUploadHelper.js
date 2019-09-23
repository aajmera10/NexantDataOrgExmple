({
	/**
	 * Convert object API name to plain word that can be used to find server-side endpoint.
	 * This function removes underscore (_), namespace (Nexant__), and custom object suffix (__c) and
	 * remove all white spaces ( ).
	 */
	objectApiNameToCommonName: function(component) {
		var objectApiName = component.get('v.objectApiName');
		var objectCommonName = objectApiName.replace('__c', ''); // remove __c from object

		// Remove namespace before removing other underscores
		if (objectCommonName.indexOf('Nexant__') !== -1) {
			objectCommonName = objectCommonName.replace('Nexant__', '');
		}
		objectCommonName = objectCommonName.replace(/_/g, ''); // remove underscores
		
		return objectCommonName;
	},

	getFieldSetPromise: function(component) {
		var action = component.get('c.serverGet' + this.objectApiNameToCommonName(component) + 'FieldSet');
		return new Promise(function(resolve, reject){
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					component.set('v.fields', JSON.stringify(response.getReturnValue()));
				} else if (state === 'ERROR') {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},

	getExistingRecordsPromise: function (component) {
		var controllerMethod = 'c.serverGet' + this.objectApiNameToCommonName(component) + 's';
		var action = component.get(controllerMethod);
		
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response);
				} else if (state === 'ERROR') {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * Fetch files that are related to the current object (objectRecordID). This only works if there is an existing record.
	 */
	getRelatedFilesPromise: function(component) {
		var action = component.get('c.serverGetRelatedDocuments');
		action.setParams({
			recordId: component.get('v.objectRecordID')
		});
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					var files = response.getReturnValue();
					resolve(response.getReturnValue());
				} else if (state === 'ERROR') {
					reject(response);
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * When files are uploaded, they were associated with the base objects. Those files must be associated with the application
	 * via ContentDocumentLink so they can be visible in the application object.
	 */
	associateFilesWithApplicationPromise: function(component) {
		var action = component.get('c.serverAssociateFilesWithApplicationId');
		action.setParams({
			applicationId: component.get('v.applicationID'),
			fileIds: component.get('v.attachedFileIDs')
		});
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * Call server-side controller to associate application object (applicationId) with base object (recordId) and create a junction object
	 * in force.com. The junction object is Trade_Ally_[Document Type]__c
	 */
	createApplicationDocumentJunctionObjectPromise: function(component, applicationId, recordId, objectApiName) {
		var action = component.get('c.serverCreateApplicationDocumentJunction');
		var objectCommonName = objectApiName.replace('Nexant__', ''); // remove the namespace if any
		action.setParams({
			applicationId: applicationId,
			recordId: recordId,
			objectApiName: objectCommonName
		});
		return new Promise(function(resolve, reject){
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === 'SUCCESS') {
					resolve(response.getReturnValue());
				} else if (state === 'INCOMPLETE') {
					reject(response.getReturnValue());
				} else if (state === 'ERROR') {
					reject(response.getReturnValue());
				}
			});
			$A.enqueueAction(action);
		});
	}
})