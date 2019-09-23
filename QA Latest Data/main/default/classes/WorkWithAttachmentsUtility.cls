public with sharing class WorkWithAttachmentsUtility {

	public static Id saveTheChunk(
		Id parentId,
		String fileName,
		String base64Data,
		String contentType,
		String fileId,
		String description
	) {
		Id duplicateId = validateUniqueAttachment(parentId, fileName);
		Boolean rewriteAll = false;
		/*if ((fileId == null || fileId.trim() == '') && duplicateId != null) {
			fileId = duplicateId;
			rewriteAll = true;
		}*/
		if (fileId == null || fileId.trim() == '') {
			fileId = saveTheFile(parentId, fileName, base64Data, contentType, description);
		} else {
			appendToFile(fileId, base64Data, rewriteAll);
		}
		return Id.valueOf(fileId);
	}

	private static Id validateUniqueAttachment(Id parentId, String fileName) {
		/*System.debug(parentId);
		System.debug(fileName);
		System.debug(Constants.SET_OF_UNIQUE_ATTACHMENTS);
		System.debug(fileName);
		System.debug(Constants.SET_OF_UNIQUE_ATTACHMENTS.contains(fileName));*/
		Id attachmentId;
		if (Constants.SET_OF_UNIQUE_ATTACHMENTS.contains(fileName)) {
			List<Attachment> listOfOldAttachments = new List<Attachment>();
			if (ESAPI.securityUtils().isAuthorizedToView('Attachment',new List<String>{'Id'})) {
				listOfOldAttachments = [
					SELECT	Id
					FROM	Attachment
					WHERE
							parentId = :parentId AND
							Name = :fileName
				];
			}
			System.debug(listOfOldAttachments);
			//delete listOfOldAttachments;
			if (!listOfOldAttachments.isEmpty()) {
				attachmentId = listOfOldAttachments[0].Id;
			}
		}
		return attachmentId;
	}

	private static Id saveTheFile(
		Id parentId,
		String fileName,
		String base64Data,
		String contentType,
		String description
	) {
		Id idToReturn;
		base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

		Attachment a = new Attachment();
		a.parentId = parentId;
		a.Body = EncodingUtil.base64Decode(base64Data);
		a.Name = fileName;
		a.ContentType = contentType;
		a.Description = description;
		ESAPI.securityUtils().validatedInsert(new List<Attachment>{a});
		idToReturn = a.Id;

		System.debug('saveTheFile');
		return idToReturn;
	}

	private static void appendToFile(Id fileId, String base64Data, Boolean rewriteAll) {
		base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
		String existingBody = '';
		Attachment a;
		if (ESAPI.securityUtils().isAuthorizedToView('Attachment',new List<String>{'Id','Body'})) {
			a = [
				SELECT
						Id,
						Body
				FROM	Attachment
				WHERE	Id =: fileId
			];
		}
		/*if (!rewriteAll) {
			existingBody = EncodingUtil.base64Encode(a.Body);
			a.OwnerId = UserInfo.getUserId();
		}*/
		a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
		ESAPI.securityUtils().validatedUpdate(new List<Attachment>{a});
	}
}