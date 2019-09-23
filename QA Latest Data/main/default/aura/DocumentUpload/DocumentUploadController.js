({
	/**
	 * [TODO] When data is loaded, compare the expiry date with the application setting.
	 */
	handleLoad: function(component, event, helper) {
		/*var recordId = component.get('v.objectRecordID');
		var payload = event.getParams().records[recordId]['fields'];
		if (payload['Expiry_Date__c']) {
			var expiryDate = payload['Expiry_Date__c']['value'];
		}*/
    },

	/**
	 * When form is submitted, the form is no longer in draft mode and should not be allowed to be "closed"
	 */
    handleSubmit: function(component, event, helper) {
		component.set('v.showSpinner', true);
		component.set('v.isDraft', false); // once the form is submitted, it is no longer a draft and not closable
    },

    handleError: function(component, event, helper) {
        // errors are handled by lightning:inputField and lightning:messages
        // so this just hides the spinner
        component.set('v.showSpinner', false);
    },

	/**
	 * When record was created successfully, take the file ID with it and create:
	 * - ContentDocumentLink between those files and this record id
	 * - Create Trade_Ally_License__c record
	 *   - When this record is created successfully, create ContentDocumentLink for those records as well.
	 */
    handleSuccess: function(component, event, helper) {
		var params = event.getParams();
		var recordId = params.id;
		var applicationId = component.get('v.applicationID');
		component.set("v.objectRecordID", recordId);
		component.find('notificationArea').showToast({
			'variant': 'success',
			'title': helper.objectApiNameToCommonName(component) + ' is created!' // TODO: change "created" to "updated" if this is just editing an existing record
		});
		component.set('v.showSpinner', false);
		component.set('v.saved', true);
		component.set('v.editable', false);
		component.set('v.fileUploadable', true);
		Promise.all([
			helper.createApplicationDocumentJunctionObjectPromise(component, applicationId, recordId, component.get('v.objectApiName'))
		]).then(function(result){
			// TODO: does the user need to know that the document is created and linked to the application?
		}).catch(function(err){
			// TODO: handle this error in the future?
		});
    },

	/**
	 * Destory this component and clean up the related information, including:
	 * - Remove all files (fileID) that are attached to this record.
	 * - Remove the License__c records
	 */
	destroy: function(component, event, helper) {
		component.destroy();
	},

	/**
	 * Invoke this call when the record ID is injected
	 *  - get all related files
	 */
	doInit: function(component, event, helper) {
		Promise.all([
			helper.getRelatedFilesPromise(component)
		]).then(function(results){
			if (component.get('v.objectRecordID')) {
				component.set('v.isDraft', false);
				component.set('v.editable', true);
				if (results[0].length > 0){
					component.set('v.fileUploadable', false);
				} else {
					component.set('v.fileUploadable', true);
				}
				component.set('v.attachedFileIDs', results[0]);
			}
		}).catch(function(err) {
		});
	},

	/**
	 * When the file is uploaded, add them to the list of files:
	 * -- display them in  filecards
	 * -- trigger onAttachedFileIDsChange
	 */
	handleFileUpload: function (component, event, helper) {
		var files = event.getParam('files');
		component.set('v.attachedFileID', files[0].documentId);
		var files = event.getParam('files');
		var fileIds = component.get('v.attachedFileIDs');
		if (!fileIds) {
			fileIds = [];
		}
		files.forEach(function(file) {
			fileIds.push(file.documentId);
		});
		component.set('v.attachedFileIDs', fileIds);
		Promise.all([
			helper.associateFilesWithApplicationPromise(component)
		]).then(function(result) {
			component.set('v.fileUploadable', false); // Only allow one file per record
		}).catch(function(err) {
		});
	}
})