({
	doInit: function(component, event, helper) {
		Promise.all([
			helper.getFieldSetPromise(component),
			helper.getExistingRecordsPromise(component)
		]).then(function(result) {
			var fileTypesLiteral = component.get('v.acceptableFileTypes');
			component.set('v.acceptableFileTypes', JSON.parse(fileTypesLiteral.split(',')));
		}).catch(function(error) {
			console.log('Error: ' + JSON.stringify(error));
		});

		// Update namespace
		if (component.get('v.hasNameSpace')) {
			component.set('v.namespace', 'Nexant__');
		}
	},
	
	/**
	 * add a new DocumentUpload component to allow user enter more entries.
	 */
	addNewRecord: function(component, event, helper) {
		$A.createComponent(
			'c:DocumentUpload', 
			{
				"acceptableFileLabel": component.get('v.acceptableFileLabel'),
				"acceptableFileTypes": component.get('v.acceptableFileTypes'),
				"applicationID": component.get('v.applicationID'),
				"columns": component.get('v.columns'),
				"objectApiName": component.get('v.namespace') + component.get('v.objectApiName'),
				"fields": component.get('v.fields'),
				"editable": true,
				"isDraft": true,
				"mode": 'edit'
			}, 
			function(newComp, status, errorMessage) {
				if (status === 'SUCCESS') {
					var body = component.get('v.body');
					body.push(newComp);
					component.set('v.body', body);
				}
			}
		);
	}
})