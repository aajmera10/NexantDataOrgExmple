@isTest
public class TAUserTriggerHandlerTest {
@isTest
    public static void populateContactFieldsTest() {
        
        Account acc = new Account (Name = 'newAcc1');  
        insert acc;
        
        Contact con = new Contact ();
        con.LastName = 'Test';
        con.FirstName = 'demo';
        con.AccountId = acc.Id;
        con.put(Constants.NAMESPACE +'Level__c','Primary');
        insert con;
        
        List<Profile> profileName = new List<Profile>([SELECT Id, Name, UserLicenseId FROM Profile WHERE UserLicenseId  IN (SELECT Id FROM UserLicense WHERE Name ='Customer Community Plus') LIMIT 1]);
        Profile prof = [SELECT Id, Name FROM Profile WHERE Id IN : profileName];
        
        User newUser = new User(profileId = prof.id, username = 'newUser@yahoo.com', email = 'pb@ff.com', emailencodingkey = 'UTF-8', 
                                localesidkey = 'en_US', languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', alias='ComUser',
                                lastname='lastname', contactId = con.id);
        insert newUser;
        
        Contact conObj = new Contact();
        conObj.LastName = 'Test';
        conObj.FirstName = 'demo';
        conObj.AccountId = acc.Id;
        conObj.put(Constants.NAMESPACE +'Level__c','Primary');
        insert conObj;

        String query = 'SELECT Id, ' + Constants.NAMESPACE + 'Contact_Approver__c' + ' FROM Contact WHERE Id =\''+conObj.Id +'\'';
        System.debug('>>query>>'+query);
        conObj = Database.query(query);
        
        System.assertEquals(conObj.get(Constants.NAMESPACE +'Contact_Approver__c'), newUser.Id);
    }
}