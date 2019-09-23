({
	doInit : function (component, event, helper) {
		helper.loadAllData(component);
	},

	handleClick : function (component, event, helper) {
		// for old api
		//var selectedItem = event.source.get('v.label');
		var selectedItem = event.getSource().get('v.label');
		console.log(selectedItem);
		var allInfo = component.get("v.allInfo");
		if (selectedItem == 'Home') {
			helper.navigationByLink(component,'/');
		} else if (selectedItem == 'My Profile') {
			helper.navigationByLink(component,'/profile/'+allInfo.userId);
		} else if (selectedItem == 'My Settings') {
			helper.navigationByLink(component,'/settings/'+allInfo.userId);
		} else if (selectedItem == 'My Account') {
			helper.navigationToRecord(component,allInfo.accountId);
		} else if (selectedItem == 'My Subscription') {
			helper.navigationByLink(component,'/subscription');
		} else if (selectedItem == 'Contact Support') {
			helper.navigationByLink(component,'/contactsupport');
		} else if (selectedItem == 'Logout') {
			var communityName = window.location.toString().split('/')[3];
			window.location.replace("/"+communityName+"/secur/logout.jsp");
		}
	}
})