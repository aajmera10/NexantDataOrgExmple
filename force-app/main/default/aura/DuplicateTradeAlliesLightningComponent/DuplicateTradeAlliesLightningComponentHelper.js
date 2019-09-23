({

    //Fire an event that will be handled in SelfRegister page to start registering with selected account
    selectTradeAllyDuplicate: function(component, event) {
        var tradeAllyDuplicateId = event.getSource().get('v.value');
        var selfRegisterTradeAllyWrapper = component.get('v.selfRegisterTradeAllyWrapper');
        var selectTradeAllyDuplicateEvent = $A.get('e.c:SelectTradeAllyDuplicateEvent');
        selfRegisterTradeAllyWrapper.accountId = tradeAllyDuplicateId;
        selectTradeAllyDuplicateEvent.setParams({
            'selfRegisterTradeAllyWrapper': selfRegisterTradeAllyWrapper
        });
        selectTradeAllyDuplicateEvent.fire();
    },

    //Fire an event that will be handled in SelfRegister page to start registering with a new account
    declineAllTradeAllyDuplicates: function(component, event) {
        var selfRegisterTradeAllyWrapper = component.get('v.selfRegisterTradeAllyWrapper');
        var declineAllTradeAllyDuplicatesEvent = $A.get('e.c:DeclineAllTradeAllyDuplicatesEvent');
        declineAllTradeAllyDuplicatesEvent.setParams({
            'selfRegisterTradeAllyWrapper': selfRegisterTradeAllyWrapper
        });
        declineAllTradeAllyDuplicatesEvent.fire();
    }

})