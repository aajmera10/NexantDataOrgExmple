({
	/**
	 * Reduce the object name to a common name, for example:
	 *  - Convert License__c to License
	 *  - Convert Other_Document__c to OtherDocument
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

	/**
	 * Retrieve all the field set of the specified object. v.objectApiName must be provided.
	 */
	getFieldSetPromise: function(component) {
		if (!component.get('v.objectApiName')) {
			return new Promise(function(resolve, reject) {
				reject('Object API name is not specified');
			});
		}
		var endpoint = 'c.serverGet' + this.objectApiNameToCommonName(component) + 'FieldSet';
		var action = component.get(endpoint);
		return new Promise(function(resolve, reject){
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					component.set('v.fields', response.getReturnValue());
				} else if (state === 'ERROR') {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * Get the existing records that are related to the application.
	 */ 
	getExistingRecordsPromise: function(component) {
		var action = component.get('c.serverGetExistingRecords');
		action.setParams({
			'applicationId': component.get('v.applicationID'),
			'objectType' : component.get('v.objectApiName')
		});
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					var records = response.getReturnValue();
					component.set('v.records', records);
					resolve(response.getReturnValue());
				} else if (state === 'ERROR') {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	}
})