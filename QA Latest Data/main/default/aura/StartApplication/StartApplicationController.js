({
	
    doInit: function(component, event, helper) {
		helper.showSpinner(component);
		//var recordId = component.get("v.recordId");
		//var applicationId = component.get("v.applicationId");
		if (!component.get("v.applicationId")) {
			component.set(
				"v.applicationId",
				component.get("v.recordId")
			);
		}
        helper.prepareAllInformation(component);
    },

	// The default action when save and continue button is clicked
    saveAndContinue: function(component, event, helper) {
		helper.showSpinner(component);
        var sectionNumber = event.target.dataset.section;
		var errorMessageTemplate = component.get('v.documentUploadErrorMessage');
        
		var hasValidNumberOfFiles = false;
		if (sectionNumber === '6') {
			var numberOfInsurances = component.get('v.allInfoWrapper.listOfInsurancesFields').length;
			var numberOfFiles = component.get('v.insuranceFileIds').length;
			if (numberOfInsurances === numberOfFiles) {
				hasValidNumberOfFiles = true;
			} else {
				var objectName = 'insurance';
				var ObjectName = 'Insurance';
				var numberOfRecords = numberOfInsurances;
				var message = errorMessageTemplate.replace(/{objectName}/g, objectName).replace(/{ObjectName}/g, ObjectName).replace(/{numberOfRecords}/g, numberOfRecords);
				helper.showToast(component, 'error', message, 'Error');
			}
		} else if (sectionNumber === '7') {
			var numberOfLicenses = component.get('v.allInfoWrapper.listOfLicensesFields').length;
			var numberOfFiles = component.get('v.licenseFileIds').length;
			if (numberOfLicenses === numberOfFiles) {
				hasValidNumberOfFiles = true;
			} else {
				var objectName = 'license';
				var ObjectName = 'License';
				var numberOfRecords = numberOfLicenses;
				var message = errorMessageTemplate.replace(/{objectName}/g, objectName).replace(/{ObjectName}/g, ObjectName).replace(/{numberOfRecords}/g, numberOfRecords);
				helper.showToast(component, 'error', message, 'Error');

			}
		} else if (sectionNumber === '8') {
			/*if (component.get('v.certificationFileIds').length === component.get('v.allInfoWrapper.listOfCertificationsFields').length) {
				hasValidNumberOfFiles = true;
			} else {
				helper.showToast(component, 'error', $A.get("$Label.c.Minimum_Certifications"), 'Error');
			}*/
			hasValidNumberOfFiles = true; // Certification does not require files to be attached.
		} else if (sectionNumber === '9') {
			var numberOfTaxes = component.get('v.allInfoWrapper.listOfTaxFields').length;
			var numberOfFiles = component.get('v.taxFileIds').length;
			if (numberOfTaxes === numberOfFiles) {
				hasValidNumberOfFiles = true;
			} else {
				var objectName = 'tax';
				var ObjectName = 'Tax';
				var numberOfRecords = numberOfTaxes;
				var message = errorMessageTemplate.replace(/{objectName}/g, objectName).replace(/{ObjectName}/g, ObjectName).replace(/{numberOfRecords}/g, numberOfRecords);
				helper.showToast(component, 'error', message, 'Error');
			}
		} else if (sectionNumber === '10') {
			var numberOfOtherDocs = component.get('v.allInfoWrapper.listOfOtherFields').length;
			var numberOfFiles = component.get('v.otherFileIds').length;
			if (numberOfOtherDocs === numberOfFiles) {
				hasValidNumberOfFiles = true;
			} else {
				var objectName = 'other document';
				var ObjectName = 'Other Document';
				var numberOfRecords = numberOfOtherDocs;
				var otherDocUploadErrMsg = component.get('v.otherDocumentUploadErrorMessage');
				var message = otherDocUploadErrMsg.replace(/{objectName}/g, objectName).replace(/{ObjectName}/g, ObjectName).replace(/{numberOfRecords}/g, numberOfRecords);
				helper.showToast(component, 'error', message, 'Error');

			}
		} else {
			hasValidNumberOfFiles = true;
		}
		
		if (hasValidNumberOfFiles) {
			helper.savePartOfChanges(component, event, sectionNumber);
		}
    },

	/**
	 * Save this function for Phase 2 implementation
	 */
	addNewLicense: function(component, event, helper) {
		$A.createComponent(
			'c:LicenseFileUpload', 
			{
				"ApplicationID": component.get('v.allInfoWrapper.applicationId')
			}, 
			function(newComp, status, errorMessage) {
				if (status === 'SUCCESS') {
					var body = component.get('v.body');
					body.push(newComp);
					component.set('v.body', body);
				}
			}
		);
	},

	/**
	 * When file is uploaded, add the returned ID to the corresponding arrays.
	 * Functions below should be refactored in the future
	 */
	handleLicenseFileUpload: function (component, event, helper) {
		helper.cleanupFileUpload(component, event, 'license');
	},

	handleInsuranceFileUpload: function (component, event, helper) {
		helper.cleanupFileUpload(component, event, 'insurance');
	},

	handleCertificationFileUpload: function (component, event, helper) {
		helper.cleanupFileUpload(component, event, 'certification');
	},

	handleTaxFileUpload: function (component, event, helper) {
		helper.cleanupFileUpload(component, event, 'tax');
	},

	handleOtherFileUpload: function (component, event, helper) {
		helper.cleanupFileUpload(component, event, 'other');
	},

    uploadNewAttachment: function(component, event, helper) {
		helper.showSpinner(component);
        var elementPosition = event.target.dataset.position;
        var sectionNumber = event.target.dataset.section;
        var allInfo = component.get("v.allInfoWrapper");
        var elementId;
        var attachmentName;
        var parentId;
        /*if (sectionNumber === '2') {
            elementId = helper.constants.PRIMARY_CONTACT_IMAGE_ID;
            attachmentName = helper.constants.PRIMARY_CONTACT_IMAGE;
            parentId = allInfo.primaryContactId;
        } else*/ if (sectionNumber === '6') {
            elementId = helper.constants.INSURANCE_ID;
            parentId = allInfo.listOfInsurancesFields[elementPosition][0].recordId;
        } else if (sectionNumber === '7') {
            elementId = helper.constants.LICENSE_ID;
            parentId = allInfo.listOfLicensesFields[elementPosition][0].recordId;
        } else if (sectionNumber === '8') {
            elementId = helper.constants.CERTIFICATION_ID;
            parentId = allInfo.listOfCertificationsFields[elementPosition][0].recordId;
        } else if (sectionNumber === '9') {
            elementId = helper.constants.TAX_ID;
            parentId = allInfo.listOfTaxFields[elementPosition][0].recordId;
        } else if (sectionNumber === '10') {
            elementId = helper.constants.OTHER_ID;
            parentId = allInfo.listOfOtherFields[elementPosition][0].recordId;
        }
        var fileInputElement = component.find(elementId);
        var fileInput;
        if (fileInputElement.length) {
            fileInput = component.find(elementId)[elementPosition].getElement(); //'uploaded_file'
        } else {
            fileInput = component.find(elementId).getElement();
        }
        if (!fileInput || !fileInput.files.length) {
            // alert("File should be uploaded.");
            helper.showToast(component, 'error', 'File should be uploaded', '');
            return;
        }
        if (parentId === undefined || parentId.trim() === '') {
            // alert("Record should be created beforce files uploading.");
            helper.showToast(component, 'error', 'Record should be created before files uploading', '');
            return;
        }
        if (attachmentName === undefined || attachmentName.trim() === '') {
            attachmentName = fileInput.files[0].name;
        }
        helper.uploadAttachment(
            component,
            attachmentName,
            parentId,
            elementId,
            sectionNumber,
            elementPosition
        );
    },

	/**
	 * YHOU: do not touch this code as it creates object records for License, insurnace, certifications, tax, other document and returns the IDs, which is essential to document upload
	 */
    addNewReference: function(component, event, helper) {
		helper.showSpinner(component);
        var allInfoWrapper = component.get("v.allInfoWrapper");
        var sectionNumber = event.target.dataset.section;
        if (sectionNumber === '4') {
            allInfoWrapper.listOfTradeAllyReferencesFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultTradeAllyReference))
            );
        } else if (sectionNumber === '5') {
            allInfoWrapper.listOfTradeAllyTradeReferencesFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultTradeAllyReference))
            );
        } else if (sectionNumber === '6') {
            allInfoWrapper.listOfInsurancesFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultInsurance))
            );
        } else if (sectionNumber === '7') {
            allInfoWrapper.listOfLicensesFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultLicense))
            );
        } else if (sectionNumber === '8') {
            allInfoWrapper.listOfCertificationsFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultCertification))
            );
        } else if (sectionNumber === '9') {
            allInfoWrapper.listOfTaxFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultTax))
            );
        } else if (sectionNumber === '10') {
            allInfoWrapper.listOfOtherFields.push(
                JSON.parse(JSON.stringify(allInfoWrapper.defaultOther))
            );
        }
        component.set("v.allInfoWrapper", allInfoWrapper);
		helper.hideSpinner(component);
    },

	/**
	 * Delete a dynamically created object record, such as insurance, license, certification, tax, and other doc.
	 */
    removeReference: function(component, event, helper) {
		helper.showSpinner(component);
        var allInfoWrapper = component.get("v.allInfoWrapper");
        var elementPosition = event.target.dataset.position;
        var sectionNumber = event.target.dataset.section;
        var tempListFields;
        if (sectionNumber === '4') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfTradeAllyReferencesFields));
        } else if (sectionNumber === '5') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfTradeAllyTradeReferencesFields));
        } else if (sectionNumber === '6') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfInsurancesFields));
        } else if (sectionNumber === '7') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfLicensesFields));
        } else if (sectionNumber === '8') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfCertificationsFields));
        } else if (sectionNumber === '9') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfTaxFields));
        } else if (sectionNumber === '10') {
            tempListFields = JSON.parse(JSON.stringify(allInfoWrapper.listOfOtherFields));
        }

		// TODO: what's the purpose of this IF check?
        if (
			(
				tempListFields.length > allInfoWrapper.numberOfCR && // CR: customer reference
				sectionNumber === '4'
			) ||
			(
				tempListFields.length > allInfoWrapper.numberOfTR && // TR: trade reference
				sectionNumber === '5'
			) ||
			(
				tempListFields.length > allInfoWrapper.numberOfInsurances && 
				sectionNumber === '6'
			) ||
			(
				tempListFields.length > allInfoWrapper.numberOfLicenses && 
				sectionNumber === '7'
			) ||
			(
				tempListFields.length > allInfoWrapper.numberOfCertifications && 
				sectionNumber === '8'
			) ||
			(
				tempListFields.length > allInfoWrapper.numberOfTaxDocs && 
				sectionNumber === '9'
			) ||
			(
				tempListFields.length > allInfoWrapper.numberOfOtherDocs && 
				sectionNumber === '10'
			) ||
			(
				sectionNumber !== '4' &&
				sectionNumber !== '5' &&
				sectionNumber !== '6' &&
				sectionNumber !== '7' &&
				sectionNumber !== '8' &&
				sectionNumber !== '9' &&
				sectionNumber !== '10'
			)
		) {
            var newListOfFields = [];
            var recordIdToDelete;
            for (var i = 0; i < tempListFields.length; i++) {
                if (i.toString() !== elementPosition) {
                    newListOfFields.push(
                        JSON.parse(JSON.stringify(tempListFields[i]))
                    );
                } else if (tempListFields[i][0].recordId !== undefined) {
                    recordIdToDelete = JSON.parse(JSON.stringify(tempListFields[i][0])).recordId;
					//console.log('recordIdToDelete ',recordIdToDelete);
					//console.log('sectionNumber ',sectionNumber);
                    if (sectionNumber === '4') {
                        allInfoWrapper.listOfTradeAllyReferencesIdsToDelete.push(
                            recordIdToDelete
                        );
                    } else if (sectionNumber === '5') {
                        allInfoWrapper.listOfTradeAllyCustomReferencesIdsToDelete.push(
                            recordIdToDelete
                        );
                    } else if (sectionNumber === '6') {
                        allInfoWrapper.listOfInsurancesIdsToDelete.push(
                            recordIdToDelete
                        );
                    } else if (sectionNumber === '7') {
                        allInfoWrapper.listOfLicensesIdsToDelete.push(
                            recordIdToDelete
                        );
                    } else if (sectionNumber === '8') {
                        allInfoWrapper.listOfCertificationsIdsToDelete.push(
                            recordIdToDelete
                        );
                    } else if (sectionNumber === '9') {
                        allInfoWrapper.listOfTaxIdsToDelete.push(
                            recordIdToDelete
                        );
                    } else if (sectionNumber === '10') {
                        allInfoWrapper.listOfOtherIdsToDelete.push(
                            recordIdToDelete
                        );
                    }
                }
            }
            if (sectionNumber === '4') {
                allInfoWrapper.listOfTradeAllyReferencesFields = newListOfFields;
            } else if (sectionNumber === '5') {
                allInfoWrapper.listOfTradeAllyTradeReferencesFields = newListOfFields;
            } else if (sectionNumber === '6') {
                allInfoWrapper.listOfInsurancesFields = newListOfFields;
            } else if (sectionNumber === '7') {
                allInfoWrapper.listOfLicensesFields = newListOfFields;
            } else if (sectionNumber === '8') {
                allInfoWrapper.listOfCertificationsFields = newListOfFields;
            } else if (sectionNumber === '9') {
                allInfoWrapper.listOfTaxFields = newListOfFields;
            } else if (sectionNumber === '10') {
                allInfoWrapper.listOfOtherFields = newListOfFields;
            }
            //console.log(allInfoWrapper.listOfTradeAllyReferencesIdsToDelete);
            component.set("v.allInfoWrapper", allInfoWrapper);
        }
		helper.hideSpinner(component);
    },

    changeTab: function(component, event, helper) {
		helper.showSpinner(component);
        var isTab = component.get('v.isTab');
        if(!isTab){
            component.set('v.isTab', true);
            var index = component.get('v.activeTab');
            var str = 'tab-' + index;
            var subStr = 'tab-scoped-' + index;
            var tab = component.find(str);
            var subTab = component.find(subStr);
            var activeTab = event.target.parentNode;
            var newIndex = activeTab.getAttribute('data-index');
            var newSubStr = 'tab-scoped-' + newIndex;
            var newSubTab = component.find(newSubStr);
            $A.util.addClass(tab, 'selected');
            $A.util.removeClass(tab, 'slds-is-active');
            $A.util.removeClass(tab, 'selected');
            $A.util.removeClass(subTab, 'slds-show');
            $A.util.addClass(subTab, 'slds-hide');
            component.set('v.activeTab', newIndex);
            $A.util.addClass(activeTab, 'slds-is-active');
            $A.util.removeClass(newSubTab, 'slds-hide');
            $A.util.addClass(newSubTab, 'slds-show');
            component.set('v.isTab', false);
        }
		helper.hideSpinner(component);
    },

    testPrint: function(component,event,helper){  
        //window.print();
        var appId = component.get("v.applicationId");
        var accId = component.get("v.tradeAllyId");
        var urlString = window.location.href;
        var baseURL = '';
        if(urlString.indexOf("/s/")>=0) {
            baseURL = urlString.substring(0, urlString.indexOf("/s/")) + "/apex/TradeAllyApplicationsPDFPage";
        }
        else
        {
            baseURL= "/apex/TradeAllyApplicationsPDFPage";
        }
        
        if (appId!=undefined)
        {
            baseURL += '?applicationId=' + appId 
            if (accId !=undefined)
            {
                baseURL += '&accountId=' + accId
            }
        }
        window.open(baseURL);
    },

	downloadDocument : function(component, event, helper){
		var sendDataProc = component.get("v.sendData");
		var dataToSend = document.getElementById('startContainer').innerHTML; //this is data you want to send for PDF generation
		//console.log(document.getElementById('startContainer').innerHTML);
		
		//invoke vf page js method
		sendDataProc(dataToSend, function(){
			//handle callback
		});
	}
})