// this class is used   to update the contact owner for community user
public with sharing class ContactDomain {

 public static void setOwner(List<Contact> newList) {
     
Profile userProfile = [Select Name from Profile where Id =: userinfo.getProfileid() ];
String pname = userProfile.name;
     string userName =  userInfo.getUserId();
		System.debug('profile name::::'+pname);
   		System.debug('username name::::'+userInfo.getUserId());

    	if(pname == 'Custom Customer Community Plus' || (pname == 'Custom Community Profile'))  {
        
            Id theOwnerId;

        
            User u = [SELECT Account.OwnerId, Account.Owner.IsActive FROM User WHERE Id = :UserInfo.getUserId()];
            if (u.Account.Owner.IsActive) {
                theOwnerId = u.Account.OwnerId;
                system.debug('theOwnerIdtheOwnerIdtheOwnerId:::'+theOwnerId);
            } else {
                List<User> users = [SELECT Id FROM User WHERE IsActive = true AND UserType = 'Standard' LIMIT 1];
                if (!users.isEmpty()) {
                    theOwnerId = users[0].Id;
                }
            }

            if (theOwnerId == null) {
                // Throw exception here.
            }

            for (Contact con : newList) {
                con.OwnerId = theOwnerId;
                system.debug('con.OwnerId con.OwnerId con.OwnerId '+con.OwnerId );
            }
        }
    }
}