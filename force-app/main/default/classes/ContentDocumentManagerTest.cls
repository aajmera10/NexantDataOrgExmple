@IsTest 
private class ContentDocumentManagerTest {
	private static ContentDocument createContentDocument(String title, String path, String version) {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = title,
            PathOnClient = path,
            VersionData = Blob.valueOf(version),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
 
        // Test INSERT
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionInsert.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
		return documents.get(0);
    }

	@IsTest
	private static void testCreateContentDocumentLink() {
		ContentDocument doc = createContentDocument('Test Title', 'Test.jpg', 'Test Version');

		License__c license = new License__c(Type__c='Test');
		insert license;

		ContentDocumentLink link = ContentDocumentManager.createContentDocumentLink(license.Id, doc.Id);
		System.assertNotEquals(link, null);
		delete link;
		delete doc;
		delete license;
	}

	@IsTest
	private static void testCreateContentDocumentLinks() {
		ContentDocument doc1 = createContentDocument('Title 1', 'Path1.jpg', 'Test Version 1');

		List<Id> docIDs = new List<Id>{doc1.Id};
		License__c license = new License__c(Type__c='Test 2');
		insert license;

		List<ContentDocumentLink> links = ContentDocumentManager.createContentDocumentLinks(license.Id, docIDs);
		System.assertNotEquals(links, null);
		System.assertEquals(docIDs.size(), links.size());
		delete links;
		delete license;
		delete doc1;
	}
}