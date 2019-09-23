({
    constants : {
        'MAX_FILE_SIZE': 25000000,//4500000
        'CHUNK_SIZE': 950000,
        //'PRIMARY_CONTACT_IMAGE': 'Primary Contact Image',
        //'PRIMARY_CONTACT_IMAGE_ID': 'uploaded_contact_image',
        'INSURANCE_ID': 'insurance_att',
        'LICENSE_ID': 'license_att',
        'CERTIFICATION_ID': 'certification_att',
		'TAX_ID': 'tax_att',
		'OTHER_ID': 'other_att',
        'NEW_ATTACHEMNT': 'New file selected'
    },

	/**
	 * Adding a file to a list of files for future deletion
	 */
	addFileToDelete: function (component, fileID) {
		var fileIds = component.get('v.filesToDelete');
		if (!fileIds) {
			fileIds = [];
		}
		fileIds.push(fileID);
		component.set('v.filesToDelete', fileIds);
	},

    prepareAllInformation : function(component) {
        var action = component.get("c.getAllInfoWrapper");
        action.setParams({
            applicationId: component.get("v.applicationId"), 
			tradeAllyId : component.get("v.tradeAllyId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allInfo = response.getReturnValue();
				component.set(
					"v.appNotExists", 
					(
						allInfo.appNotExists ||
						( component.get("v.tradeAllyId") && allInfo.isCommunityUser)
					)
				);
                component.set("v.isValidUser", allInfo.isValidUser);
                component.set("v.allInfoWrapper", allInfo);

				// initialize uploaded files and the number of files. For phase 1, each object can have one file only.
				// In phase 2, this may change and this initialization will have to be refactored.
				if (allInfo.insuranceFiles) {
					component.set('v.insuranceFileIds', Object.values(allInfo.insuranceFiles));
					component.set('v.insuranceCount', Object.values(allInfo.insuranceFiles).length);
				}
				if (allInfo.licenseFiles) {
					component.set('v.licenseFileIds', Object.values(allInfo.licenseFiles));
					component.set('v.licenseCount', Object.values(allInfo.licenseFiles).length);
				}
				if (allInfo.certificationFiles) {
					component.set('v.certificationFileIds', Object.values(allInfo.certificationFiles));
					component.set('v.certificationCount', Object.values(allInfo.certificationFiles).length);
				}
				if (allInfo.taxFiles) {
					component.set('v.taxFileIds', Object.values(allInfo.taxFiles));
					component.set('v.taxCount', Object.values(allInfo.taxFiles).length);
				}
				if (allInfo.otherFiles) {
					component.set('v.otherFileIds', Object.values(allInfo.otherFiles));
					component.set('v.otherCount', Object.values(allInfo.otherFiles).length);
				}
            } else if (state === "INCOMPLETE") {
                this.showToast(component, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        this.showToast(component, 'error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                    }
                                }
                            }
                            this.showToast(component, 'error', errors[i].message, 'Error');
                        }
                    }
                }
                else {
                    this.showToast(component, 'error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
			this.hideSpinner(component);
        });
        $A.enqueueAction(action);
    },

	reviewWrappedFields : function(wrappedFields) {
		var isValid = true;
		for (var i = 0; i < wrappedFields.length; i++) {
			if (wrappedFields[i].isValid == false) {
				isValid = false;
				break;
			}
			if (
				wrappedFields[i].required == true &&
				(
					(
						(
							wrappedFields[i].type == 'REFERENCE' || 
							wrappedFields[i].type == 'STRING' || 
							wrappedFields[i].type == 'EMAIL' || 
							wrappedFields[i].type == 'PHONE' || 
							wrappedFields[i].type == 'URL' || 
							wrappedFields[i].type == 'TEXTAREA' || 
							wrappedFields[i].type == 'RICHTEXTAREA' || 
							wrappedFields[i].type == 'PICKLIST' || 
							wrappedFields[i].type == 'COMBOBOX'
						) &&
						!wrappedFields[i].value
					) ||
					(
						wrappedFields[i].type == 'DATETIME' &&
						!wrappedFields[i].valueDateTime
					) ||
					(
						wrappedFields[i].type == 'DATE' &&
						!wrappedFields[i].valueDate
					) ||
					(
						wrappedFields[i].type == 'BOOLEAN' &&
						(
							!wrappedFields[i].valueBoolean ||
							wrappedFields[i].valueBoolean == false
						)
					) ||
					(
						(
							wrappedFields[i].type == 'INTEGER' || 
							wrappedFields[i].type == 'CURRENCY' || 
							wrappedFields[i].type == 'DOUBLE' || 
							wrappedFields[i].type == 'PERCENT'
						) &&
						!wrappedFields[i].valueNumber
					)
				)
			) {
				isValid = false;
				break;
			}
		}
		return isValid;
	},

	reviewWrappedListOfFields : function(wrappedListOfFields) {
		var isValid = true;
		for (var m = 0; m < wrappedListOfFields.length; m++) {
			isValid = this.reviewWrappedFields(wrappedListOfFields[m]);
			if (isValid == false) {
				break;
			}
		}
		return isValid;
	},

	validateUpdatedFields : function(allInfoWrapper,sectionNumber) {
		var isValid = true;
		if (sectionNumber === 1) {
			isValid = this.reviewWrappedFields(allInfoWrapper.listOfTradeAllyFields);
		} else if (sectionNumber === 2) {
			isValid = this.reviewWrappedFields(allInfoWrapper.listOfContactFields);
			if (isValid) {
				isValid = this.reviewWrappedFields(allInfoWrapper.listOfTradeAllyBACIFields);
			}
		} else if (sectionNumber === 3) {
			isValid = this.reviewWrappedFields(allInfoWrapper.listOfTradeAllyPPFields);
		} else if (sectionNumber === 4) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfTradeAllyReferencesFields);
		} else if (sectionNumber === 5) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfTradeAllyTradeReferencesFields);
		} else if (sectionNumber === 6) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfInsurancesFields);
		} else if (sectionNumber === 7) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfLicensesFields);
		} else if (sectionNumber === 8) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfCertificationsFields);
		} else if (sectionNumber === 9) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfTaxFields);
		} else if (sectionNumber === 10) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfOtherFields);
		} else if (sectionNumber === 11) {
			isValid = this.reviewWrappedListOfFields(allInfoWrapper.listOfTradeAllyDemographicFields);
		} else if (sectionNumber === 12) {
			isValid = this.reviewWrappedFields(allInfoWrapper.listOfApplicationFields);
		}
		return isValid;
	},

	reviewCRForNumberOfRecords : function(wrappedFields) {
		var numberOfRecords = 0;
		if (wrappedFields && wrappedFields.length > 0 && wrappedFields[0].recordId) {
			numberOfRecords = 1;
		}
		return numberOfRecords;
	},

	reviewCRListForNumberOfRecords : function(wrappedListOfFields,minimumNumber) {
		var numberOfRecords = 0;
		if (wrappedListOfFields.length) {
			for (var h = 0; h < wrappedListOfFields.length; h++) {
				numberOfRecords += this.reviewCRForNumberOfRecords(wrappedListOfFields[h]);
			}
		}
		return (numberOfRecords >= minimumNumber);
	},

	checkNumberOfCR : function(allInfoWrapper) {
		var enoughCR = true;
		if(allInfoWrapper.tab4Visible == true) {
			enoughCR = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfTradeAllyReferencesFields, allInfoWrapper.numberOfCR);
		}
		if (enoughCR && allInfoWrapper.tab5Visible == true) {
			enoughCR = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfTradeAllyTradeReferencesFields, allInfoWrapper.numberOfTR);
		}
		return enoughCR;
	},
	
	checkNumberOfInsurances : function(component, allInfoWrapper) {
		var enoughInsurances = true;
		if(allInfoWrapper.tab6Visible == true) {
			// enoughInsurances = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfInsurancesFields, allInfoWrapper.numberOfInsurances);
			enoughInsurances = component.get('v.insuranceCount') >= allInfoWrapper.numberOfInsurances;
		}
		return enoughInsurances;
	},

	checkNumberOfLicenses : function(component, allInfoWrapper) {
		var enoughLicenses = true;
		if(allInfoWrapper.tab7Visible == true) {
			// enoughLicenses = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfLicensesFields, allInfoWrapper.numberOfLicenses);
			enoughLicenses = component.get('v.licenseCount') >= allInfoWrapper.numberOfLicenses;
		}
		return enoughLicenses;
	},

	checkNumberOfCertifications : function(component, allInfoWrapper) {
		var enoughCertifications = true;
		if(allInfoWrapper.tab8Visible == true) {
			// enoughCertifications = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfCertificationsFields, allInfoWrapper.numberOfCertifications);
			enoughCertifications = component.get('v.certificationCount') >= allInfoWrapper.numberOfCertifications;
		}
		return enoughCertifications;
	},

	checkNumberOfDocs : function(component, allInfoWrapper) {
		var enoughDocs = true;
		if(allInfoWrapper.tab9Visible == true) {
			// enoughDocs = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfTaxFields, allInfoWrapper.numberOfTaxDocs);
			enoughDocs = component.get('v.taxCount') >= allInfoWrapper.numberOfTaxDocs;
		}
		if (enoughDocs && allInfoWrapper.tab10Visible == true) {
			// enoughDocs = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfOtherFields, allInfoWrapper.numberOfOtherDocs);
			enoughDocs = component.get('v.otherCount') >= allInfoWrapper.numberOfOtherDocs;
		}
		return enoughDocs;
	},
	
    savePartOfChanges : function(component, event, sectionNumber) {
        var allInfoWrapper = component.get("v.allInfoWrapper");

		var validUpdate = this.validateUpdatedFields(allInfoWrapper,parseInt(sectionNumber,10));
		if (validUpdate) {
			// console.log('sectionNumber ',sectionNumber);
			var enoughCR = true;
			var enoughDocs = true;
			var enoughInsurances = true;
			var enoughLicenses = true;
			var enoughCertifications = true;

			// final step validation
			if (sectionNumber === '12') {
				enoughCR = this.checkNumberOfCR(allInfoWrapper);
				enoughDocs = this.checkNumberOfDocs(component, allInfoWrapper);
				enoughInsurances = this.checkNumberOfInsurances(component, allInfoWrapper);
				enoughLicenses = this.checkNumberOfLicenses(component, allInfoWrapper);
				enoughCertifications = this.checkNumberOfCertifications(component, allInfoWrapper);
			}

			if (enoughCR && enoughDocs && enoughInsurances && enoughLicenses && enoughCertifications) {
				// console.log(JSON.parse(JSON.stringify(allInfoWrapper)));
				var action = component.get("c.savePartOfInfo");
				action.setParams({
					informationString: JSON.stringify(allInfoWrapper),
					sectionNumber: sectionNumber
				});
				action.setCallback(this, function(response) {
					var state = response.getState();
					if (state === "SUCCESS") {
						// logic to show pop up window for subscription
						if (!component.get('v.allInfoWrapper.isSubscribed')) {
							var index = component.get('v.activeTab');
							if (index === '12') {
								this.createSubscriptionPopUp(component);
							}
						}

						var listOfIds = response.getReturnValue();
						if (sectionNumber === '12') {
							if (listOfIds.length) {
								component.set('v.isApplicationSubmitted', true);
							}
							this.hideSpinner(component);
						} else if (listOfIds !== null && listOfIds.length > 0) {
							if (sectionNumber === '6') {
								this.cleanupInsuranceFileUpload(component, listOfIds);
							} else if (sectionNumber === '7') {
								this.cleanupLicenseFileUpload(component, listOfIds); //the list of IDs are the list of objects, such as insurance, cert, license, tax, other doc ID, etc.
							} else if (sectionNumber === '8') {
								this.cleanupCertificationFileUpload(component, listOfIds);
							} else if (sectionNumber === '9') {
								this.cleanupTaxFileUpload(component, listOfIds);
							} else if (sectionNumber === '10') {
								this.cleanupOtherFileUpload(component, listOfIds);
							}
							this.goNextTab(component, event);
						} else {
							this.resetUpdatedFields(component,parseInt(sectionNumber,10),event);
						}
						// TODO: removing this condition check will remove the blocking spinner...
						if (sectionNumber !== '4' && sectionNumber !== '5' && sectionNumber !== '6' && sectionNumber !== '7' && sectionNumber !== '8' && sectionNumber !== '9' && sectionNumber !== '10') {
							//logic to switch on next tab
							this.goNextTab(component, event);
							//If all info was saved, the application will be submitted and the success window will be displayed
							this.showToast(component, 'success', 'Changes saved successfully', 'Success');
						}
						this.hideSpinner(component);
					}
					else if (state === "INCOMPLETE") {
						this.showToast(component, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
						this.hideSpinner(component);
					}
					else if (state === "ERROR") {
						var errors = response.getError();
						if (errors) {
							if (errors.length > 0) {
								for (var i = 0; i < errors.length; i++) {
									if (errors[0].pageErrors) {
										if (errors[0].pageErrors.length > 0) {
											for (var j = 0; j < errors[i].pageErrors.length; j++) {
												this.showToast(component, 'error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
											}
										}
									}
									this.showToast(component, 'error', errors[i].message, 'Error');
								}
							}
						}
						else {
							this.showToast(component, 'error', $A.get("$Label.c.Internal_server_error"), 'Error');
						}
						this.hideSpinner(component);
					}
				});
				$A.enqueueAction(action);
			} else {
				if(!enoughCR)
					this.showToast(component, 'error', $A.get("$Label.c.Minimum_References"), 'Error');
				if(!enoughInsurances)
					this.showToast(component, 'error', $A.get("$Label.c.Minimum_Insurances"), 'Error');
				if(!enoughLicenses)
					this.showToast(component, 'error', $A.get("$Label.c.Minimum_Licenses"), 'Error');
				if(!enoughCertifications)
					this.showToast(component, 'error', $A.get("$Label.c.Minimum_Certifications"), 'Error');
				if(!enoughDocs)
					this.showToast(component, 'error', $A.get("$Label.c.Minimum_Docs"), 'Error');
			}
		} else {
			this.showToast(component, 'error', $A.get("$Label.c.Valid_Data_and_Required_Fields"), 'Error');
		}
    },

	/**
	 * cleanupFileUpload performs following tasks:
	 * 1. update the corresponding sections' files with a list of files IDs
	 * 2. disable the upload button once the file is uploaded
	 * 3. if the user is editing an existing application, uploading a new file will replace the existing file by index
	 */
	cleanupFileUpload: function (component, event, section) {
		var uploadButtonID = event.getSource().get('v.id');
		var index = parseInt(uploadButtonID.replace(section + "_upload_btn_", ""));
		var files = event.getParam('files');
		var fileIdsAttr = 'v.' + section + 'FileIds';
		var fileIds = component.get(fileIdsAttr);
		if (!fileIds) {
			fileIds = [];
		}

		var filesToDelete = component.get('v.filesToDelete');
		if (!filesToDelete) {
			filesToDelete = [];
		}
		files.forEach(function(file) {
			if (index + 1 > fileIds.length) {
				fileIds.push(file.documentId);
			} else {
				var currentDocId = fileIds[index];
				fileIds[index] = (file.documentId);
				filesToDelete.push(currentDocId);
			}
		});
		component.set(fileIdsAttr, fileIds);
		component.set('v.filesToDelete', filesToDelete);
		event.getSource().set('v.disabled', true);
	},

	/**
	 * DeleteFilePromise returns a promise that can be resolved. True means records were deleted successfully, false means 
	 * failure.
	 */
	deleteFilesPromise: function(component) {
		var action = component.get('c.serverDeleteFilesByIDs');
		var fileIDs = component.get('v.filesToDelete');
		action.setParams({
			fileIds: fileIDs
		});
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state === 'SUCCESS') {
					component.set('v.filesToDelete', []); // once the file is deleted, reset the queue.
					resolve(response.getReturnValue());
				} else if (state === 'ERROR') {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * saveObjectAndFilesPromise 
	 */
	saveObjectsAndFilesPromise: function(component, objectType, objectIDs) {
		var objectname = objectType; // the original object name value: insurance, certification, license, tax, and other
		var objectName = objectType.charAt(0).toUpperCase() + objectType.slice(1); // Insurance, Certification, License, Tax, and Other
		var files = component.get('v.' + objectname + 'FileIds');
		var objectField = objectname + 'Ids';
		var action = component.get('c.save' + objectName + 'AndFiles');
		var params = {
			appId: component.get('v.allInfoWrapper.applicationId'),
			fileIds: files
		};
		params[objectField] = objectIDs;
		action.setParams(params);
		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response){
				var state = response.getState();
				if (state === 'SUCCESS') {
					// when the file and update objects are successfully stored in Salesforce, update the client-side's data (count of objects)
					// The count of object will be used for checking if the required number of files are included in the application during application submit (tab 12)
					// This part will likely be refactored to accommondate changes in phase 2
					var countAttr = 'v.' + objectname + 'Count';
					component.set(countAttr, objectIDs.length); 
					resolve(response.getReturnValue());
				} else if (state === 'ERROR') {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},

	/**
	 * cleanupLicenseFiles, including:
	 * 1) create license object and associate them with this application
	 * 2) rename those files with a prefix 
	 */
	cleanupLicenseFileUpload: function(component, objectIDs) {
		var filesToDelete = component.get('v.filesToDelete');
		Promise.all([
			this.saveObjectsAndFilesPromise(component, 'license', objectIDs),
			this.deleteFilesPromise(component)
		]).then(function(results){
			// if results[0] is false, then an error occurred in the back end
			// if results[1] is false, then an error occurred in the back end
		}).catch(function(err){
		});
	},

	cleanupInsuranceFileUpload: function(component, objectIDs) {
		var filesToDelete = component.get('v.filesToDelete');
		Promise.all([
			this.saveObjectsAndFilesPromise(component, 'insurance', objectIDs),
			this.deleteFilesPromise(component)
		]).then(function(results){
			// if results[0] is false, then an error occurred in the back end
			// if results[1] is false, then an error occurred in the back end
		}).catch(function(err){
		});
	},

	cleanupCertificationFileUpload: function(component, objectIDs) {
		var filesToDelete = component.get('v.filesToDelete');
		Promise.all([
			this.saveObjectsAndFilesPromise(component, 'certification', objectIDs),
			this.deleteFilesPromise(component)
		]).then(function(results){
			// if results[0] is false, then an error occurred in the back end
			// if results[1] is false, then an error occurred in the back end
		}).catch(function(err){
		});
	},

	cleanupTaxFileUpload: function (component, objectIDs) {
		var filesToDelete = component.get('v.filesToDelete');
		Promise.all([
			this.saveObjectsAndFilesPromise(component, 'tax', objectIDs),
			this.deleteFilesPromise(component)
		]).then(function(results){
			// if results[0] is false, then an error occurred in the back end
			// if results[1] is false, then an error occurred in the back end
		}).catch(function(err){
		});
	},

	cleanupOtherFileUpload: function(component, objectIDs) {
		var filesToDelete = component.get('v.filesToDelete');
		Promise.all([
			this.saveObjectsAndFilesPromise(component, 'other', objectIDs),
			this.deleteFilesPromise(component)
		]).then(function(results){
			// if results[0] is false, then an error occurred in the back end
			// if results[1] is false, then an error occurred in the back end
		}).catch(function(err){
		});
	},

	resetUpdatedFields : function(component,sectionNumber,event) {
		if (
			sectionNumber === 4 ||
			sectionNumber === 5 ||
			sectionNumber === 6 ||
			sectionNumber === 7 ||
			sectionNumber === 8 ||
			sectionNumber === 9 ||
			sectionNumber === 10
		) {
			this.loadPartOfData(component,sectionNumber,event);
		} else {
			var allInfoWrapper = component.get("v.allInfoWrapper");
			if (sectionNumber === 1) {
				for (var i = 0; i < allInfoWrapper.listOfTradeAllyFields.length; i++) {
					allInfoWrapper.listOfTradeAllyFields[i].wasUpdated = false;
				}
			} else if (sectionNumber === 2) {
				for (i = 0; i < allInfoWrapper.listOfContactFields.length; i++) {
					allInfoWrapper.listOfContactFields[i].wasUpdated = false;
				}
				for (i = 0; i < allInfoWrapper.listOfTradeAllyBACIFields.length; i++) {
					allInfoWrapper.listOfTradeAllyBACIFields[i].wasUpdated = false;
				}
			} else if (sectionNumber === 3) {
				for (i = 0; i < allInfoWrapper.listOfTradeAllyPPFields.length; i++) {
					allInfoWrapper.listOfTradeAllyPPFields[i].wasUpdated = false;
				}
			} else if (sectionNumber === 11) {
				for (i = 0; i < allInfoWrapper.listOfTradeAllyDemographicFields.length; i++) {
					allInfoWrapper.listOfTradeAllyDemographicFields[i].wasUpdated = false;
				}
			}
			component.set('v.allInfoWrapper', allInfoWrapper);
			this.hideSpinner(component);
		}
	},

	loadPartOfData : function(component,sectionNumber,event) {
		var action = component.get("c.getPartOfData");
		//console.log('sectionNumber ',sectionNumber);
        action.setParams({
            applicationId : component.get("v.applicationId"),
			sectionNumber : sectionNumber
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tempListOfFields = response.getReturnValue();
				//console.log('tempListOfFields ',tempListOfFields);
				//console.log('sectionNumber ',sectionNumber);
				var enoughCR = true;
				var allInfoWrapper = component.get("v.allInfoWrapper");
                if (sectionNumber === 4) {
					allInfoWrapper.listOfTradeAllyReferencesFields = tempListOfFields;
					allInfoWrapper.listOfTradeAllyReferencesIdsToDelete = [];
					enoughCR = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfTradeAllyReferencesFields,allInfoWrapper.numberOfCR);
				} else if (sectionNumber === 5) {
					allInfoWrapper.listOfTradeAllyTradeReferencesFields = tempListOfFields;
					allInfoWrapper.listOfTradeAllyCustomReferencesIdsToDelete = [];
					enoughCR = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfTradeAllyTradeReferencesFields,allInfoWrapper.numberOfTR);
				} else if (sectionNumber === 6) {
					allInfoWrapper.listOfInsurancesFields = tempListOfFields;
					allInfoWrapper.listOfInsurancesIdsToDelete = [];
					enoughCR = this.checkNumberOfInsurances(allInfoWrapper);
				} else if (sectionNumber === 7) {
					allInfoWrapper.listOfLicensesFields = tempListOfFields;
					allInfoWrapper.listOfLicensesIdsToDelete = [];
					enoughCR = this.checkNumberOfLicenses(allInfoWrapper);
				} else if (sectionNumber === 8) {
					allInfoWrapper.listOfCertificationsFields = tempListOfFields;
					allInfoWrapper.listOfCertificationsIdsToDelete = [];
					enoughCR = this.checkNumberOfCertifications(allInfoWrapper);
				} else if (sectionNumber === 9) {
					allInfoWrapper.listOfTaxFields = tempListOfFields;
					allInfoWrapper.listOfTaxIdsToDelete = [];
					enoughCR = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfTaxFields,allInfoWrapper.numberOfTaxDocs);
				} else if (sectionNumber === 10) {
					allInfoWrapper.listOfOtherFields = tempListOfFields;
					allInfoWrapper.listOfOtherIdsToDelete = [];
					enoughCR = this.reviewCRListForNumberOfRecords(allInfoWrapper.listOfOtherFields,allInfoWrapper.numberOfOtherDocs);
				}
				component.set("v.allInfoWrapper", allInfoWrapper);
				if (sectionNumber === 4 || sectionNumber === 5 || sectionNumber === 6 || sectionNumber === 7 || sectionNumber === 8 || sectionNumber === 9 || sectionNumber === 10) {
					//console.log('enoughCR ',enoughCR);
					if (enoughCR) {
						this.goNextTab(component, event);
						this.showToast(component, 'success', 'Changes saved successfully', 'Success');
					} else {
						this.showToast(component, 'error', 'Minimum number is not reached', 'Error');
					}
				}
				//console.log('allInfoWrapper ',allInfoWrapper);
            } else if (state === "INCOMPLETE") {
                this.showToast(component, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors.length > 0) {
                        for (var i = 0; i < errors.length; i++) {
                            if (errors[0].pageErrors) {
                                if (errors[0].pageErrors.length > 0) {
                                    for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                        this.showToast(component, 'error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                    }
                                }
                            }
                            this.showToast(component, 'error', errors[i].message, 'Error');
                        }
                    }
                }
                else {
                    this.showToast(component, 'error', $A.get("$Label.c.Internal_server_error"), 'Error');
                }
            }
			this.hideSpinner(component);
        });
        $A.enqueueAction(action);
	},

    createSubscriptionPopUp: function (component) {
        var applicationId = component.get('v.allInfoWrapper.applicationId');
        $A.createComponent(
            'c:SubscriptionPopUp',
            {
                "applicationId" : applicationId
            },
            function(newComponent, state, errorMessage) {
                if (state === 'SUCCESS') {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                    component.set("v.allInfoWrapper.isSubscribed", true);
                }
                else if (state === "INCOMPLETE") {
                    this.showToast(component, 'error', $A.get("$Label.c.Status_incomplete"), 'Error');
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors.length > 0) {
                            for (var i = 0; i < errors.length; i++) {
                                if (errors[0].pageErrors) {
                                    if (errors[0].pageErrors.length > 0) {
                                        for (var j = 0; j < errors[i].pageErrors.length; j++) {
                                            this.showToast(component, 'error', 'Internal server error: ' + errors[i].pageErrors[j].message, 'Error');
                                        }
                                    }
                                }
                                this.showToast(component, 'error', errors[i].message, 'Error');
                            }
                        }
                    }
                    else {
                        this.showToast(component, 'error', $A.get("$Label.c.Internal_server_error"), 'Error');
                    }
                }
            }
		);
		this.hideSpinner(component);
    },

    goNextTab : function (component, event) {
		var allInfoWrapper = component.get("v.allInfoWrapper");
        var isTab = component.get('v.isTab');
        if (!isTab) {
            component.set('v.isTab', true);
            var index = component.get('v.activeTab');
            var str = 'tab-' + index;
            var subStr = 'tab-scoped-' + index;
            var tab = component.find(str);
            var subTab = component.find(subStr);
            var newIndex = Number(event.target.getAttribute('data-section')) + 1;
			if(newIndex == 3 && allInfoWrapper.tab3Visible == false) {
				newIndex = 4;
			}
			if(newIndex == 4 && allInfoWrapper.tab4Visible == false) {
				newIndex = 5;
			}
			if(newIndex == 5 && allInfoWrapper.tab5Visible == false) {
				newIndex = 6;
			}
			if(newIndex == 6 && allInfoWrapper.tab6Visible == false) {
				newIndex = 7;
			}
			if(newIndex == 7 && allInfoWrapper.tab7Visible == false) {
				newIndex = 8;
			}
			if(newIndex == 8 && allInfoWrapper.tab8Visible == false) {
				newIndex = 9;
			}
			if(newIndex == 9 && allInfoWrapper.tab9Visible == false) {
				newIndex = 10;
			}
			if(newIndex == 10 && allInfoWrapper.tab10Visible == false) {
				newIndex = 11;
			}
			if(newIndex == 11 && allInfoWrapper.tab11Visible == false) {
				newIndex = 12;
			}

            var activeTab = component.find("tab-" + newIndex);
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
            window.scrollTo(0, 0);
        }
    },

    showToast: function (component, type, message, title) {
        var showToast = $A.get("e.force:showToast");
        // console.log('showToast ', showToast);
        showToast.setParams({
            mode: 'pester',
            type: type,
            title: title,
            message: message,
            duration: '5000'
        });
        showToast.fire();
		this.hideSpinner(component);
    },

	showSpinner : function(component) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component){  
       component.set("v.Spinner", false);
    }
})