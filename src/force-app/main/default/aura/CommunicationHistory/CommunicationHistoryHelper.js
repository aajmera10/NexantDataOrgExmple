({
    showToast: function (type, message, title) {
        var showToast = $A.get("e.force:showToast");
        //console.log('showToast ', showToast);
        showToast.setParams({
            mode: 'pester',
            type: type,
            title: title,
            message: message,
            duration: '5000'
        });
        showToast.fire();
    }
})