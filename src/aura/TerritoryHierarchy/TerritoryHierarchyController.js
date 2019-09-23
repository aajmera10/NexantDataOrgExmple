({
    init: function (component, event, helper) {
        helper.doInit(component);
    },

    handleSelect: function (component, event) {
        var name = event.getParam('name');
        var navEvent = $A.get("e.force:navigateToSObject");
        if(navEvent){
            navEvent.setParams({
                recordId:name,
                slideDevName: "detail"
            });
            navEvent.fire();
        }
    }
})