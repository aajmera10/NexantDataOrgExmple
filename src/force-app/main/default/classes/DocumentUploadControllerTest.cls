@IsTest 
private class DocumentUploadControllerTest {
	@IsTest
	private static void testServerGetLicenseFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetLicenseFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetInsuranceFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetInsuranceFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetCertificationFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetCertificationFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetTaxFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetTaxFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetOtherDocumentFieldSet() {
		List<Object> fieldSets = DocumentUploadController.serverGetOtherDocumentFieldSet();
		System.assert(fieldSets != null);
		System.assert(fieldSets.size() > 0);
	}

	@IsTest
	private static void testServerGetExistingRecords() {
		String applicationId;
		List<SObject> output;

		// has applicationId and objectType
		// TODO: there is no easy way of creating mock Application__c, User, and Account :( 

		// has applicationId, but invalid objectType
		output = DocumentUploadController.serverGetExistingRecords('', 'Random_Type__c');
		System.assert(output == null);

		// has objectType, but no applicationId
		output = DocumentUploadController.serverGetExistingRecords('', 'License__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Insurance__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Certification__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Tax__c');
		output = DocumentUploadController.serverGetExistingRecords('', 'Other_Document__c');

		// has no valid argument
		output = DocumentUploadController.serverGetExistingRecords('', '');
		System.assert(output == null);
	}

	@IsTest
	private static void testServerGetRelatedDocuments() {
		List<String> output;

		// invalid recordId results in null
		output = DocumentUploadController.serverGetRelatedDocuments(null);
		System.assert(output == null);

		output = DocumentUploadController.serverGetRelatedDocuments('');
		System.assert(output == null);

		// valid recordId
		License__c obj = new License__c(Type__c='ABC');
		insert obj;
		output = DocumentUploadController.serverGetRelatedDocuments(obj.Id);
		System.assert(output != null); 
	}
}