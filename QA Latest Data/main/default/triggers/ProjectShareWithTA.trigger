trigger ProjectShareWithTA on Project__c (after insert, after update) {
    // Create a new list of sharing objects for Project
    List<Project__Share> projectShrs  = new List<Project__Share>();
    if(trigger.isInsert) {
        List<String> partnerIdList = new List<String>();
        Map<Id, List<String>> projectIdPartnersMap = new Map<Id, List<String>>();
        List<Project__c> newProjects = trigger.new;
        //Get a list of all partner ids for all the projects
        for(Project__c project : trigger.new) {
            String partners = project.partners__c;
            if(partners == null)
                continue;
            String[] partnerIds = partners.split(';');
            partnerIdList.addAll(partnerIds);
            projectIdPartnersMap.put(project.id, partnerIds);
        }
        //Create junction objects for TA Project association
		ProjectTriggerHandler.createTAProjectJunctions(projectIdPartnersMap, partnerIdList);
        //We have the list of partner ids, now issue a select to get all the users for all the projects' partner ids
        List<User> tradeAllyUsersList = [SELECT Id, Name, Partner_Id__c FROM User WHERE
                                         Contact.Account.External_Id__c IN: partnerIdList AND IsActive = TRUE];
        //We have the list of all users, now iterate and create share objects
        for(User user : tradeAllyUsersList) {
            for(Id projectId : projectIdPartnersMap.keySet()) {
                List<String> partnerListFromMap = projectIdPartnersMap.get(projectId);
                if(partnerListFromMap.contains(user.Partner_Id__c)) {
                    // Instantiate the sharing objects
                    Project__Share tradeAllyShr = new Project__Share();
                    // Set the ID of record being shared
                    tradeAllyShr.ParentId = projectId;
                    // Set the ID of user or group being granted access
                    tradeAllyShr.UserOrGroupId = user.Id;
                    // Set the access level
                    tradeAllyShr.AccessLevel = 'read';
                    // Set the Apex sharing reason
                    tradeAllyShr.RowCause = Schema.Project__Share.RowCause.Manual;
                    // Add objects to list for insert
                    projectShrs.add(tradeAllyShr);
                }
            }
        }
    }
    if(trigger.isUpdate) {
        List<Project__c> newProjects = trigger.new;
        List<Id> projectIdDeleteList = new List<Id>();
        List<String> partnerIdList = new List<String>();
        Map<Id, List<String>> projectIdPartnersMap = new Map<Id, List<String>>();
        for(Project__c project : newProjects){
            String oldPartners = Trigger.oldMap.get(project.Id).partners__c;
            String newPartners = project.partners__c;
            if(oldPartners != newPartners) {
                projectIdDeleteList.add(project.Id);
            }
        }
        List<Project__Share> sharesToDelete = [SELECT Id FROM Project__Share WHERE ParentId IN: projectIdDeleteList AND RowCause = 'Manual'];
        if(!sharesToDelete.isEmpty()){
            Database.Delete(sharesToDelete, false);
        }
        for(Project__c project : newProjects) {
            if(projectIdDeleteList.contains(project.Id)) {
                String newPartners = project.partners__c;
                if(newPartners == null)
                    continue;
                String[] newPartnerIds = newPartners.split(';');
                partnerIdList.addAll(newPartnerIds);
                projectIdPartnersMap.put(project.id, newPartnerIds);
            }
        }
        //Update junction objects for TA Project association
		ProjectTriggerHandler.updateTAProjectJunctions(projectIdPartnersMap, partnerIdList, projectIdDeleteList);
        //Get the list of users
        List<User> tradeAllyUsersList = [SELECT Id, Name, Partner_Id__c FROM User WHERE
                                         Contact.Account.External_Id__c IN: partnerIdList AND IsActive = TRUE];
        //We have the list of all users, now iterate and create share objects
        for(User user : tradeAllyUsersList) {
            for(Id projectId : projectIdPartnersMap.keySet()) {
                List<String> partnerListFromMap = projectIdPartnersMap.get(projectId);
                if(partnerListFromMap.contains(user.Partner_Id__c)) {
                    // Instantiate the sharing objects
                    Project__Share tradeAllyShr = new Project__Share();
                    // Set the ID of record being shared
                    tradeAllyShr.ParentId = projectId;
                    // Set the ID of user or group being granted access
                    tradeAllyShr.UserOrGroupId = user.Id;
                    // Set the access level
                    tradeAllyShr.AccessLevel = 'read';
                    // Set the Apex sharing reason
                    tradeAllyShr.RowCause = Schema.Project__Share.RowCause.Manual;
                    // Add objects to list for insert
                    projectShrs.add(tradeAllyShr);
                }
            }
        }
    }
    // Insert sharing records and capture save result 
    // The false parameter allows for partial processing if multiple records are passed 
    // into the operation
    if(!projectShrs.isEmpty()) {
        Database.SaveResult[] lsr = Database.insert(projectShrs,false);
        // Create counter
        Integer i=0;
        // Process the save results
        for(Database.SaveResult sr : lsr){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default 
                // access level are not allowed. 
                // These sharing records are not required and thus an insert exception is 
                // acceptable. 
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level.
                    //trigger.newMap.get(projectShrs[i].ParentId).addError('Unable to grant sharing access due to following exception: '+ err.getMessage());
					//Commented the error throwing part above, as it interferes with the ESB sync
					System.debug('Error encountered during project share: '+err.getMessage());
                }
            }
            i++;
        }
    }
}