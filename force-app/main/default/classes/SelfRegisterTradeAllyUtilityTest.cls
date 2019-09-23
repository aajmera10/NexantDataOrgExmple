@isTest
private class SelfRegisterTradeAllyUtilityTest {
    @testSetup static void setup() {
        // Create an account
        Account acct = new Account(Name='Test Account');
        acct.external_Id__c = '1';
        insert acct;
        // Create a contact
        Contact contact = new Contact();
        contact.Lastname ='test';
        contact.Level__c = 'Primary';
        contact.AccountId = acct.id;
        insert contact;
        //Create a user
        Profile profile = [SELECT Id FROM Profile WHERE Name='Custom Customer Community Plus']; 
        User user = new User(Alias = 'aliasTst', Email='opatzke@nexant.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = profile.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
        user.ContactId = contact.Id;
        insert user;
    }
    
    // Test
    @isTest static void testException(){
        try{
            SelfRegisterTradeAllyUtility.ifUsernameExists('testuser@testorg.com');
        } catch(DMLException e) {
            System.assertEquals(e.getDmlStatusCode(0), StatusCode.DUPLICATE_USERNAME.name());
        }
    }
}