trigger TAUserSelfRegistration on User (before insert)  {
    if (Trigger.isBefore) {
        for (User u : Trigger.new) {
            if(u.Approval_Required__c == true) {
                Profile p = [select id from profile where name =: Constants.RESTRICTED_PROFILE_NAME];
                u.ProfileId = p.Id;
            }
        }
    }
}