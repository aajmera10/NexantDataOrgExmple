({
    init: function (component, event, helper) {
        helper.doInit(component);
    },

    checkButtonHandler: function (component, event, helper) {
        helper.checkExistingGroups(component);
    },

    hideDetails: function (component, event, helper) {
        component.set('v.countOfExistingGroups', 0);
        component.set('v.existingGroupsNames', null);
        component.set('v.groupsNotChecked', true);
    },

    createGroups: function (component, event, helper) {
        var countOfExistingGroups = component.get('v.countOfExistingGroups');
        var currentCommunityName = component.get('v.currentCommunityName');
        if(countOfExistingGroups === 3){
            helper.showToast('error', 'This community already has required groups', 'Error');
        }
        else if(!currentCommunityName){
            helper.showToast('error', 'Choose valid community', 'Error');
        }
        else{
            helper.createMissedGroups(component);
        }
    },

})