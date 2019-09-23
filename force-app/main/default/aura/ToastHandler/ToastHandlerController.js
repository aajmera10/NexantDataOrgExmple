({
    init: function (component, event, helper) {
        window.addEventListener("message", function (event) {
            if ((event.data.type) && (event.data.typeOfMessage === 'EventFromVF')) {
                var toastEvent = $A.get('e.force:showToast');
                var eventMode = ESAPI.encoder().SFDC_HTMLENCODE(event.data.mode);
                var eventType = ESAPI.encoder().SFDC_HTMLENCODE(event.data.type);
                var eventTitle = ESAPI.encoder().SFDC_HTMLENCODE(event.data.title);
                var eventMessage = ESAPI.encoder().SFDC_HTMLENCODE(event.data.message);
                
                toastEvent.setParams({
                    mode: eventMode,
                    type: eventType,
                    title: eventTitle,
                    message: eventMessage,
                    duration: '5000'
                });
                toastEvent.fire();
            }
        }, false);
    }
})