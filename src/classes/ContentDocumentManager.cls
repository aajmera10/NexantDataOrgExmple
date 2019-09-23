/**
 * ContentDocumentManager provides utitlity functions for managing ContentDocument and ContentDocumentLink
 */
public class ContentDocumentManager  {

	/**
	 * Create a ContentDocumentLink record in Salesforce that allows the file to be associated with the record.
	 * If an existing record exists between the file and the record, then the existing record will be returned
	 * and no additional record will be created.
	 *
	 * @param recordId -- the object record that the file will be associated with
	 * @param fileId -- an existing file in Salesforce org. This can be obtained from file upload. File Id usually start with 069
	 */
	public static ContentDocumentLink createContentDocumentLink(Id recordId, Id fileId) {
		// Check if there is an existing link
		List<ContentDocumentLink> searchResults = [SELECT
														ID, 
														ContentDocumentId, 
														LinkedEntityId, 
														ShareType 
													FROM ContentDocumentLink
													WHERE ContentDocumentId = :fileId AND LinkedEntityId = :recordId
													LIMIT 1
												];
		if (searchResults != null && searchResults.size() == 1) {
			return searchResults.get(0);
		}

		// Executing code below means no existing record is found between the recordID and fileId
		ContentDocumentLink docLink;
		docLink = new ContentDocumentLink();
		docLink.ContentDocumentId = fileId;
		docLink.LinkedEntityId = recordId;
		docLink.ShareType = 'I'; // inferred permission. See sfore_api_objects_contentdocumentlink.htm
		try {
			insert docLink;
			return docLink;
		} catch (Exception e) {
			System.debug('[EXCEPTION] associating file with record: ' + e);
			return null;
		}
	}

	/**
	 * Create a list of ContentDocumentLinks in Salesforce.
	 * If link(s) exists between a file ID and the record ID, the link will not be create.
	 */
	public static List<ContentDocumentLink> createContentDocumentLinks(Id recordId, Id [] fileIds) {
		List<ContentDocumentLink> newLinks = new List<ContentDocumentLink> ();
		for (Id each: fileIds) {
			// check if there is an existing link
			List<ContentDocumentLink> searchResults = [SELECT
														ID, 
														ContentDocumentId, 
														LinkedEntityId, 
														ShareType 
													FROM ContentDocumentLink
													WHERE ContentDocumentId = :each AND LinkedEntityId = :recordId
													LIMIT 1
												];
			if (searchResults != null && searchResults.size() == 1) {
				newLinks.add(searchResults.get(0));
			} else {
				ContentDocumentLink docLink;
				docLink = new ContentDocumentLink();
				docLink.ContentDocumentId = each;
				docLink.LinkedEntityId = recordId;
				docLink.ShareType = 'I'; 
				newLinks.add(docLink);
			}
		}
		try {
			upsert newLinks;
			return newLinks;
		} catch (Exception e) {
			System.debug('[Exception] ' + e);
			return null;
		}
	}
}