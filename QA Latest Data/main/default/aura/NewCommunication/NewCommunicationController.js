({
	doInit : function(component, event, helper) {
		console.log('doInit');
		helper.loadTypeOptions(component);
	},

	saveNewCommunication : function(component, event, helper) {
		helper.saveCommunication(component);
		helper.hideCommunicationForm(component);
	},

	createCommunication : function(component, event, helper) {
		helper.displayAddCommunicationForm(component);
		helper.setNewCommunication(component);
		helper.resetFormValues(component);
	},

	cancelNewCommunication : function(component, event, helper) {
		helper.hideCommunicationForm(component);
	}

})