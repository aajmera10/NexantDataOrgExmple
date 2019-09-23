({
	doInit : function (component, event, helper) {
		helper.prepareListOfReferrals(component, helper);
	},

	findReferrals : function (component, event, helper) {
		helper.prepareListOfReferrals(component, helper);
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
		helper.prepareListOfReferrals(component, helper);
	},

	selectAnotherFilter : function (component, event, helper) {

	}
})