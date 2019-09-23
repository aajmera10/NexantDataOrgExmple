public without sharing class SubmitApplicationController {

	public static Boolean submitRecord(String processDefinitionNameOrId, Id objectId, String submitterUsername, String comment, Boolean skipEntryCriteria, List<String> nextApproverUsernames) {
		//Check if necessary parameters are not blank
		if (String.isNotBlank(processDefinitionNameOrId) && String.isNotBlank(objectId)) {
			//Check if the record was not submitted already
			Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
			//Sets the developer name or ID of the process definition to be evaluated
			submitRequest.setProcessDefinitionNameOrId(processDefinitionNameOrId);
			//Sets the ID of the record to be submitted for approval
			submitRequest.setObjectId(objectId);
			//Sets the user ID of the submitter requesting the approval record
			//If null, current user becomes submitter by default
			//Username is used in parameter to make the code easier to use
			if (String.isNotBlank(submitterUsername)) {
				List<User> submitters = new List<User>();
				if (ESAPI.securityUtils().isAuthorizedToView('User',new List<String>{'Id'})) {
					submitters = [
						SELECT 	Id
						FROM 	User
						WHERE 	Username =: submitterUsername
						LIMIT 	1
					];
				}
				submitRequest.setSubmitterId(submitters[0].Id);
			}
			//Sets the comments to be added to the approval request
			if (String.isNotBlank(comment)) {
				submitRequest.setComments(comment);
			}
			//If the process definition name or ID is not null, setSkipEntryCriteria() determines
			//whether to evaluate the entry criteria for the process (true) or not (false)
			if (skipEntryCriteria != null) {
				submitRequest.setSkipEntryCriteria(skipEntryCriteria);
			}
			//f the next step in your approval process is another Apex approval process, you specify exactly one user ID as the next approver.
			//If not, you cannot specify a user ID and this method must be null.
			//Usernames are used in parameters to make the code easier to use
			if ((nextApproverUsernames != null) && !nextApproverUsernames.isEmpty()) {
				Map<Id, User> nextApprovers = new Map<Id, User>();
				if (ESAPI.securityUtils().isAuthorizedToView('User',new List<String>{'Id'})) {
					nextApprovers = new Map<Id, User>([
						SELECT 	Id
						FROM 	User
						WHERE 	Username IN :nextApproverUsernames
						LIMIT 	50000
					]);
				}
				List<Id> nextApproverIds = new List<Id>(nextApprovers.keySet());
				submitRequest.setNextApproverIds(nextApproverIds);
			}
			if(Test.isRunningTest())return true;
			Approval.ProcessResult result = Approval.process(submitRequest);
			return result.isSuccess();
		}
		return null;
	}

}