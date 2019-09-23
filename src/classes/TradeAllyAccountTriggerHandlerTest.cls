@isTest
public class TradeAllyAccountTriggerHandlerTest {
    @isTest
    Static void testAccountTrigger(){
        List<Account> accountsToInsert = new List<Account>();
        //insert account
        Id recordTypeId = Schema.SObjectType.account.getRecordTypeInfosByName().get('Trade Ally').getRecordTypeId();
        Account acc1 = new Account();
        acc1.RecordTypeId = recordTypeId;
        acc1.ParentId = null;
        acc1.Name ='test';
        acc1.put(Constants.NAMESPACE +'Tier_Level__c','Special');
        acc1.put(Constants.NAMESPACE +'Legal_Company_Name__c','test123');
        acc1.put(Constants.NAMESPACE +'Business_Structure__c','General Partnership');
        acc1.put(Constants.NAMESPACE +'President_Owner_of_Company__c','Persident test');
        acc1.put(Constants.NAMESPACE +'Primary_Business_Type__c','Application type test');
        acc1.put(Constants.NAMESPACE +'External_Id__c',null);
        acc1.Fax= '0123';
        acc1.Phone = '0123';
        acc1.Website = 'www.test.com';
        acc1.put(Constants.NAMESPACE +'Consumer_Facing_Lang_Spoke__c','Spanish');
        acc1.put(Constants.NAMESPACE +'Projects_Completed__c',4);
        acc1.put(Constants.NAMESPACE +'Sectors__c','Commercial');
        acc1.put(Constants.NAMESPACE +'Business_Type__c','Contractor');
        acc1.put(Constants.NAMESPACE +'Child_Account_Count__c',null);
        accountsToInsert.add(acc1);
        
        //insert another account
        Account acc2 = new Account();
        acc2.RecordTypeId = recordTypeId;
        acc2.ParentId = null;
        acc2.Name ='test';
        acc2.put(Constants.NAMESPACE +'Tier_Level__c','Special');
        acc2.put(Constants.NAMESPACE +'Legal_Company_Name__c','test123');
        acc2.put(Constants.NAMESPACE +'Business_Structure__c','General Partnership');
        acc2.put(Constants.NAMESPACE +'President_Owner_of_Company__c','Persident test');
        acc2.put(Constants.NAMESPACE +'Primary_Business_Type__c','Application type test');
        acc2.put(Constants.NAMESPACE +'External_Id__c',null);
        acc2.Fax= '0123';
        acc2.Phone = '0123';
        acc2.Website = 'www.test.com';
        acc2.put(Constants.NAMESPACE +'Consumer_Facing_Lang_Spoke__c','Spanish');
        acc2.put(Constants.NAMESPACE +'Projects_Completed__c',4);
        acc2.put(Constants.NAMESPACE +'Sectors__c','Commercial');
        acc2.put(Constants.NAMESPACE +'Business_Type__c','Contractor');
        acc2.put(Constants.NAMESPACE +'Child_Account_Count__c',null);
        accountsToInsert.add(acc2);
        
        if(accountsToInsert.size()>0){
            insert accountsToInsert;
        }
        //insert child Account
        for(integer i=0;i<10;i++){
            Account childAcc = new Account();
            childAcc.RecordTypeId = recordTypeId;
            childAcc.ParentId= acc1.Id;
            childAcc.Name ='test';
            childAcc.put(Constants.NAMESPACE +'Tier_Level__c','Special');
            childAcc.put(Constants.NAMESPACE +'Legal_Company_Name__c','test123');
            childAcc.put(Constants.NAMESPACE +'Business_Structure__c','General Partnership');
            childAcc.put(Constants.NAMESPACE +'President_Owner_of_Company__c','Persident test');
            childAcc.put(Constants.NAMESPACE +'Primary_Business_Type__c','Application type test');
            childAcc.put(Constants.NAMESPACE +'External_Id__c',null);
            childAcc.Fax= '0123';
            childAcc.Phone = '0123';
            childAcc.Website = 'www.test.com';
            childAcc.put(Constants.NAMESPACE +'Consumer_Facing_Lang_Spoke__c','Spanish');
            childAcc.put(Constants.NAMESPACE +'Projects_Completed__c',4);
            childAcc.put(Constants.NAMESPACE +'Sectors__c','Commercial');
            childAcc.put(Constants.NAMESPACE +'Business_Type__c','Contractor');
            childAcc.put(Constants.NAMESPACE +'Child_Account_Count__c',null);
            insert childAcc;
        }
        List<Account> account1 = new List<Account>([SELECT Id,Name,Child_Account_Count__c FROM Account WHERE Name =:'acc1']);
        for(Account accountCountCheck : accountsToInsert){
            if(accountCountCheck.Name == 'acc1'){
                System.assertEquals(10,accountCountCheck.Child_Account_Count__c);
            }
            
        }
        Test.startTest();
        //updating Accounts
        List<Account> accountsToUpdate = new List<Account>([SELECT Id,Name,ParentId FROM Account WHERE ParentId =:acc1.Id]);
        for(Account accountUpdate : accountsToUpdate){
            accountUpdate.ParentId=acc2.Id;
        }
        update accountsToUpdate;
        List<Account> account2 = new List<Account>([SELECT Id,Name,Child_Account_Count__c FROM account WHERE Name =:'acc2']);
        for(Account accountCountCheck1 : account2){
            System.assertEquals(10,accountCountCheck1.Child_Account_Count__c);
        }
        for(Account accountCountCheck2 : account1){
            System.assertEquals(0,accountCountCheck2.Child_Account_Count__c);
        }
        
        //deleteing Account
        List<Account> accountsToDelete = new List<Account>([SELECT Id,Name,ParentId FROM Account WHERE ParentId =:acc2.Id]);
        delete accountsToDelete;
        for(Account accountCountCheck3 : account2){
            System.assertEquals(0,accountCountCheck3.Child_Account_Count__c);
        }
        Test.stopTest();
    }
}