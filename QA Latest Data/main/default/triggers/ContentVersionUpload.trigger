/**
 * ContentVersionUpload modifies ContentVersion Sharing Privacy to "Private to Record" whenever a file is uploaded or updated.
 * This trigger is created to prevent community users viewing files uploaded by other community members. Given that Sharing Privacy
 * can only be updated by ADMIN user (see https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_contentdocument.htm), 
 * we use this trigger to update the privacy settings of records of ContentVersion.
 */
trigger ContentVersionUpload on ContentVersion (after insert)  {
    if (trigger.isAfter) {
        if (trigger.isInsert) {
			System.debug('ContentVersions are inserted');
			System.debug('Inserted records: ' + Trigger.new);
			// For every new record, add its Id to a set to ensure there is no duplicate
            Set<Id> contentDocumentIdSet = new Set<Id>();
            for (ContentVersion each: Trigger.new) {
                if (each.ContentDocumentId != null) {
                    contentDocumentIdSet.add(each.ContentDocumentId);
                }
            }

			// Query the ContnetVersion that is associated with the ContentDocument 
			// Note: IsLatest is set to true since old version of ContentDocument cannot be updated.
			List<ContentVersion> versions = [ SELECT Id, SharingPrivacy FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdSet AND IsLatest = true ];
            for (ContentVersion each: versions) {
				each.SharingPrivacy = 'P'; // ContentVersion is private to record
            }
            update versions;
        }
    }
}