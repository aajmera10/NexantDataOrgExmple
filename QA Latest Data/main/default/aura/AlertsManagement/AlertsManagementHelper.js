({
    prepareAllAlertsInfo: function (component, resetPage) {
        var action = component.get("c.prepareAllAlertsInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allInfo = response.getReturnValue();
                //console.log(allInfo);
                component.set("v.allAlertsInfoWrapper", allInfo);
                this.selectListOfRecordsToDisplay(component, resetPage)
            }
            else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        this.showToast('error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                    }
                                }
                            }
                            this.showToast('error', errors[i].message, 'Error');
                        }
                    }
                }
                else {
                    this.showToast('error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    selectListOfRecordsToDisplay: function (component, resetPage) {
        var allAlertsInfoWrapper = component.get("v.allAlertsInfoWrapper");
        var activeFilter = component.get("v.activeFilter");
        var listOfAlerts = [];
        if (allAlertsInfoWrapper[activeFilter]) {
            listOfAlerts = JSON.parse(JSON.stringify(allAlertsInfoWrapper[activeFilter]));
        }
        component.set("v.listOfAlerts", listOfAlerts);
        var recordsOnThePage = component.get("v.recordsOnThePage");
        var fullPages = parseInt(Math.floor(listOfAlerts.length / recordsOnThePage), 10);
        var additionalPages = 0;
        if (listOfAlerts.length % recordsOnThePage > 0) {
            additionalPages = 1;
        }
        var maxPages = fullPages + additionalPages;
        component.set("v.maxPages", maxPages);
        if (resetPage === true) {
            component.set("v.pageNumber", 1);
        } else {
            var pageNumber = component.get("v.pageNumber");
            if (pageNumber > maxPages) {
                component.set("v.pageNumber", maxPages);
            }
        }
        this.implementPagination(component, 1);
    },

    implementPagination: function (component, pageNumber) {
        pageNumber--;
        var listOfAlerts = component.get("v.listOfAlerts");
        var recordsOnThePage = component.get("v.recordsOnThePage");
        var startPosition = recordsOnThePage * pageNumber;
        var endPosition = startPosition + recordsOnThePage;
        if (endPosition > listOfAlerts.length) {
            endPosition = listOfAlerts.length;
        }
        var shortListOfAlerts = [];
        for (var i = startPosition; i < endPosition; i++) {
            shortListOfAlerts.push(JSON.parse(JSON.stringify(listOfAlerts[i])));
        }
        component.set("v.shortListOfAlerts", shortListOfAlerts);
    },

    updateAlertAtivation: function (component, recordIdJS, isActiveJS) {
        var action = component.get("c.updateAlertStatus");
        action.setParams({
            recordId: recordIdJS,
            isActive: isActiveJS
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            /*if (state === "SUCCESS") {
                console.log('Updated data');
            } else */
            if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        this.showToast('error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                    }
                                }
                            }
                            this.showToast('error', errors[i].message, 'Error');
                        }
                    }
                }
                else {
                    this.showToast('error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    deleteRecord: function (component, recordIdJS) {
        var action = component.get("c.deleteSelectedAlert");
        action.setParams({
            recordId: recordIdJS
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.prepareAllAlertsInfo(component, false);
                //console.log('Deleted data');
            }
            else if (state === "INCOMPLETE") {
                this.showToast('error', $A.get("$Label.c.Status_incomplete"), 'Error');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        this.showToast('error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                    }
                                }
                            }
                            this.showToast('error', errors[i].message, 'Error');
                        }
                    }
                }
                else {
                    this.showToast('error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
        });
        $A.enqueueAction(action);
    },

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