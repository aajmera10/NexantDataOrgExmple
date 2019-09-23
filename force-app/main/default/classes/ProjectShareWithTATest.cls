@isTest
private class ProjectShareWithTATest {
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
    
    // Test for the manual Share
    @isTest static void testManualShareInsert(){
        User user = [SELECT Id FROM User WHERE UserName='testuser@testorg.com' LIMIT 1];
        // Create new program
        Program__c p = new Program__c();
        p.Name = 'Test Program';
        insert p;
        // Create new project
        Project__c project = new Project__c();
        project.Name_Text__c = 'Test Project';
        project.ProgramLookup__c = p.Id;
        project.Partners__c = '1;';
        Test.startTest();
        insert project;
        Test.stopTest();
        
        // Query job sharing records.
        List<Project__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                       RowCause FROM Project__share WHERE ParentId = :project.Id AND UserOrGroupId= :user.Id];
        // Query junction records.
        List<Trade_Ally_Project__c> junctions = [SELECT Id, Trade_Ally__c FROM Trade_Ally_Project__c WHERE Project__c = :project.Id];
        
        // Test for only one manual share on job.
        System.assertEquals(jShrs.size(), 1, 'Set the object\'s sharing model to Private.');
        // Test attributes of manual share.
        System.assertEquals(jShrs[0].AccessLevel, 'Read');
        System.assertEquals(jShrs[0].RowCause, 'Manual');
        System.assertEquals(jShrs[0].UserOrGroupId, user.Id);
        
        System.assertEquals(junctions.size(), 1);
        System.assert((junctions[0].Trade_Ally__c) != null);
    }
    
    // Test for the manual Share
    @isTest static void testManualShareUpdate(){
        User user = [SELECT Id FROM User WHERE UserName='testuser@testorg.com' LIMIT 1];
        // Create new program
        Program__c p = new Program__c();
        p.Name = 'Test Program';
        insert p;
        // Create new project
        Project__c project = new Project__c();
        project.Name_Text__c = 'Test Project';
        project.ProgramLookup__c = p.Id;
        insert project;
        
        project.Partners__c = '1;';
        Test.startTest();
        update project;
        Test.stopTest();
        
        // Query job sharing records.
        List<Project__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                       RowCause FROM Project__share WHERE ParentId = :project.Id AND UserOrGroupId= :user.Id];
        
        // Query junction records.
        List<Trade_Ally_Project__c> junctions = [SELECT Id, Trade_Ally__c FROM Trade_Ally_Project__c WHERE Project__c = :project.Id];
         
        // Test for only one manual share on job.
        System.assertEquals(jShrs.size(), 1, 'Set the object\'s sharing model to Private.');
        // Test attributes of manual share.
        System.assertEquals(jShrs[0].AccessLevel, 'Read');
        System.assertEquals(jShrs[0].RowCause, 'Manual');
        System.assertEquals(jShrs[0].UserOrGroupId, user.Id);
        
        System.assertEquals(junctions.size(), 1);
        System.assert((junctions[0].Trade_Ally__c) != null);
    }
    
    // Test for the manual Share
    @isTest static void testManualShareUpdateToNull(){
        User user = [SELECT Id FROM User WHERE UserName='testuser@testorg.com' LIMIT 1];
        // Create new program
        Program__c p = new Program__c();
        p.Name = 'Test Program';
        insert p;
        // Create new project
        Project__c project = new Project__c();
        project.Name_Text__c = 'Test Project';
        project.ProgramLookup__c = p.Id;
        project.Partners__c = '1;';
        insert project;
        
        project.Partners__c = null;
        Test.startTest();
        update project;
        Test.stopTest();
        
        // Query job sharing records.
        List<Project__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
                                       RowCause FROM Project__share WHERE ParentId = :project.Id AND UserOrGroupId= :user.Id];
        // Query junction records.
        List<Trade_Ally_Project__c> junctions = [SELECT Id, Trade_Ally__c FROM Trade_Ally_Project__c WHERE Project__c = :project.Id];
        
        // Test for no manual share on project.
        System.assertEquals(jShrs.size(), 0, 'Set the object\'s sharing model to Private.');
        System.assertEquals(junctions.size(), 0);
    }
    
    // Test for the manual Share
    @isTest static void testManualShareException(){
         // Create an account
        Account acct = new Account(Name='Test Exception Account');
        acct.external_Id__c = '10';
        insert acct;
        // Create a contact
        Contact contact = new Contact();
        contact.Lastname ='Exceptiontest';
        contact.Level__c = 'Primary';
        contact.AccountId = acct.id;
        insert contact;
        //Create a user
        Profile profile = [SELECT Id FROM Profile WHERE Name='Custom Community Profile'];
        User user = new User(Alias = 'aliasStd', Email='opatzke@nexant.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = profile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='teststduser@testorg.com');
        user.ContactId = contact.Id;
        insert user;
        // Create new program
        Program__c p = new Program__c();
        p.Name = 'Test Program';
        insert p;
        // Create new project
        Project__c project = new Project__c();
        project.Name_Text__c = 'Test Project';
        project.ProgramLookup__c = p.Id;
        project.Partners__c = '10;';
        try {
            Test.startTest();
            insert project;
            Test.stopTest();
        } catch (Exception error) {
            System.assertEquals(error.getMessage().contains('Unable to grant sharing access'), true);
        }
    }
}