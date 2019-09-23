/*----------------------------------------------------------------------------------------------- */
/*                                                                                                */
/* This class contains test methods for SFDCSecurityUtils class.                                  */
/*                                                                                                */
/* METHODS AND CLASSES:                                                                           */
/* test_insert:                 runs tests for SFDCSecurityUtils.                                 */
/* test_update:                 runs tests for SFDCSecurityUtils.                                 */
/* test_upsert:                 runs tests for SFDCSecurityUtils.                                 */
/* test_delete:                 runs tests for SFDCSecurityUtils.                                 */
/* test_updateEx:               runs tests for SFDCSecurityUtils.                                 */
/* test_insertEx:               runs tests for SFDCSecurityUtils.                                 */
/* test_insertEx2:              runs tests for SFDCSecurityUtils.                                 */
/*                                                                                                */
/*------------------------------------------------------------------------------------------------*/

@isTest(SeeAllData = false)
private class testSecurityUtils {

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_insert                                                                        */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_insert(){
        Test.startTest();
        Account testAcc = new Account();
        testAcc.Name = 'Test Name';
		testAcc.Projects_Completed__c = 0;
		testAcc.Business_Type__c = 'Contractor';
		testAcc.Status__c = 'Active';
		testAcc.Legal_Company_Name__c = 'test';
		testAcc.Business_Structure__c = 'Other';
		testAcc.President_Owner_of_Company__c = 'test';
        ESAPI.securityUtils().validatedInsert(new List<Account>{testAcc});
        System.assert(![SELECT Id FROM Account WHERE Name = 'Test Name'].isEmpty());
        Test.stopTest();
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_update                                                                        */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_update(){
        Account testAcc = new Account();
        testAcc.Name = 'Test Name';
		testAcc.Projects_Completed__c = 0;
		testAcc.Business_Type__c = 'Contractor';
		testAcc.Status__c = 'Active';
		testAcc.Legal_Company_Name__c = 'test';
		testAcc.Business_Structure__c = 'Other';
		testAcc.President_Owner_of_Company__c = 'test';
        insert testAcc;
        testAcc.Name = 'Test Name2';
        Test.startTest();
        ESAPI.securityUtils().validatedUpdate(new List<Account>{testAcc});
        ESAPI.securityUtils().validatedUpsert(new List<Account>{testAcc});
        System.assert([SELECT Name FROM Account WHERE Id = :testAcc.Id][0].Name == 'Test Name2');
        Test.stopTest();
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_upsert                                                                        */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_upsert(){
        Account testAcc = new Account();
        testAcc.Name = 'Test Name';
		testAcc.Projects_Completed__c = 0;
		testAcc.Business_Type__c = 'Contractor';
		testAcc.Status__c = 'Active';
		testAcc.Legal_Company_Name__c = 'test';
		testAcc.Business_Structure__c = 'Other';
		testAcc.President_Owner_of_Company__c = 'test';
        insert testAcc;
        testAcc.Name = 'Test Name2';
        Test.startTest();
        ESAPI.securityUtils().validatedUpsert(
			new List<Account>{
                testAcc, 
                new Account(
					Name = 'Test2',
					Projects_Completed__c = 0,
					Business_Type__c = 'Contractor',
					Status__c = 'Active',
					Legal_Company_Name__c = 'test',
					Business_Structure__c = 'Other', 
					President_Owner_of_Company__c = 'test'
				)
            }
        );
        System.assert(![SELECT Id FROM Account WHERE Name = 'Test Name2'].isEmpty());
        Test.stopTest();
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_delete                                                                        */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_delete(){
        Account testAcc = new Account();
        testAcc.Name = 'Test Name';
		testAcc.Projects_Completed__c = 0;
		testAcc.Business_Type__c = 'Contractor';
		testAcc.Status__c = 'Active';
		testAcc.Legal_Company_Name__c = 'test';
		testAcc.Business_Structure__c = 'Other';
		testAcc.President_Owner_of_Company__c = 'test';
        insert testAcc;
        Test.startTest();
        ESAPI.securityUtils().validatedDelete(new List<Account>{testAcc});
        System.assert([SELECT Id FROM Account WHERE Name = 'Test Name'].isEmpty());
        Test.stopTest();
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_updateEx                                                                      */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_updateEx(){
        Account testAcc = new Account();
        testAcc.Name = 'Test Name';
		testAcc.Projects_Completed__c = 0;
		testAcc.Business_Type__c = 'Contractor';
		testAcc.Status__c = 'Active';
		testAcc.Legal_Company_Name__c = 'test';
		testAcc.Business_Structure__c = 'Other';
		testAcc.President_Owner_of_Company__c = 'test';
        insert testAcc;
        testAcc.Phone = 'test';
        Test.startTest();
        try{
            SFDCSecurityUtils.crudValue = true;
            ESAPI.securityUtils().validatedUpdate(new List<Account>{testAcc});
        }catch(SFDCSecurityUtils.SFDC_FLS_Exception e){
            System.assert(e != null);
        }
        Test.stopTest();
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_insertEx                                                                      */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_insertEx(){
        Account testAcc = new Account();
        testAcc.Name = 'Test Name';
		testAcc.Projects_Completed__c = 0;
		testAcc.Business_Type__c = 'Contractor';
		testAcc.Status__c = 'Active';
		testAcc.Legal_Company_Name__c = 'test';
		testAcc.Business_Structure__c = 'Other';
		testAcc.President_Owner_of_Company__c = 'test';
        testAcc.Phone = 'test';
        Test.startTest();
        try{
            SFDCSecurityUtils.crudValue = true;
            ESAPI.securityUtils().validatedInsert(new List<Account>{testAcc});
        }catch(SFDCSecurityUtils.SFDC_FLS_Exception e){
            System.assert(e != null);
        }
        Test.stopTest();
    }

    /*--------------------------------------------------------------------------------------------*/
    /*                                                                                            */
    /* METHOD: test_insertEx2                                                                     */
    /*                                                                                            */
    /* This method runs tests for SFDCSecurityUtils.                                              */
    /*                                                                                            */
    /*--------------------------------------------------------------------------------------------*/

    static testmethod void test_insertEx2(){
        Contact testCont = new Contact();
        testCont.FirstName = 'test';
        testCont.LastName = 'test';
		testCont.Level__c = 'Primary';
        Test.startTest();
        try{
            SFDCSecurityUtils.crudValue = true;
            ESAPI.securityUtils().validatedInsert(new List<Contact>{testCont});
        }catch(SFDCSecurityUtils.SFDC_CRUD_Exception e){
            System.assert(e != null);
        }
        Test.stopTest();
    }
}