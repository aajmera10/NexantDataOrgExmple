@IsTest
private class PdfDataDisplayControllerTest {
	@IsTest
	static void testBehavior() {
		PdfDataDisplayController newPdfDataDisplayController = new PdfDataDisplayController();
		System.assert(newPdfDataDisplayController.PDFData != null);
	}

	@IsTest
	static void downloadPDFtest() {
		PdfDataDisplayController newPdfDataDisplayController = new PdfDataDisplayController();
		PageReference newPageReference = newPdfDataDisplayController.downloadPDF();
		System.assert(newPageReference != null);
	}


}