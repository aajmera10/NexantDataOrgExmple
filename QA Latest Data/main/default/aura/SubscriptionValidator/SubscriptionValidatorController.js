({
	doInit : function (component, event, helper) {
		var myInterval = window.setInterval(
			$A.getCallback(function() {
				helper.startListenerH(component,myInterval);
			}), 60000
		);
	},

	reloadPage : function (component, event, helper) {
		component.set('v.showPopup',false);
		//$A.get('e.force:refreshView').fire();
		location.reload();
	}
})