@IsTest
private class TerritoryHierarchyControllerTest {

	@TestSetup
	static void setupTest() {
		Territory__c currentTerritory = new Territory__c();
		currentTerritory.Name = 'currentTerritory';
		insert currentTerritory;
		for (Integer i = 0; i < 4; i++) {
			Territory__c newTerritory = new Territory__c();
			newTerritory.Name = 'newTerritory ' + i;
			newTerritory.Parent_Territory__c = currentTerritory.Id;
			currentTerritory = newTerritory;
			insert newTerritory;
			System.debug('newTerritory ' + newTerritory);
		}

	}

	@IsTest
	static void getCurrentItemWithParentsTest() {
		List<Territory__c> territories = [
				SELECT Name,
						Parent_Territory__c,
						Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c
				FROM Territory__c
				WHERE Name =:  'newTerritory 3'
		];
		System.debug('territories ' + territories[0]);
		TerritoryHierarchyController.Item newItem = TerritoryHierarchyController.getCurrentItemWithParents(territories[0].Id);
		System.assertEquals('currentTerritory', newItem.label);
	}

	@IsTest
	static void getCurrentItemWithParentsTest2() {
		List<Territory__c> territories = [
				SELECT Name,
						Parent_Territory__c,
						Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c
				FROM Territory__c
				WHERE Name =:  'newTerritory 2'
		];
		System.debug('territories ' + territories[0]);
		TerritoryHierarchyController.Item newItem = TerritoryHierarchyController.getCurrentItemWithParents(territories[0].Id);
		System.assertEquals('currentTerritory', newItem.label);
	}

		@IsTest
	static void getCurrentItemWithParentsTest3() {
		List<Territory__c> territories = [
				SELECT Name,
						Parent_Territory__c,
						Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__c
				FROM Territory__c
				WHERE Name =:  'newTerritory 1'
		];
		System.debug('territories ' + territories[0]);
		TerritoryHierarchyController.Item newItem = TerritoryHierarchyController.getCurrentItemWithParents(territories[0].Id);
		System.assertEquals('currentTerritory', newItem.label);
	}

	@IsTest
	static void getCurrentItemWithParentsTest4() {
		List<Territory__c> territories = [
				SELECT Name,
						Parent_Territory__c,
						Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__c
				FROM Territory__c
				WHERE Name =:  'newTerritory 0'
		];
		System.debug('territories ' + territories[0]);
		TerritoryHierarchyController.Item newItem = TerritoryHierarchyController.getCurrentItemWithParents(territories[0].Id);
		System.assertEquals('currentTerritory', newItem.label);
	}

@IsTest
	static void getCurrentItemWithParentsTest5() {
		List<Territory__c> territories = [
				SELECT Name,
						Parent_Territory__c,
						Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__c
				FROM Territory__c
				WHERE Name =:  'currentTerritory'
		];
		System.debug('territories ' + territories[0]);
		TerritoryHierarchyController.Item newItem = TerritoryHierarchyController.getCurrentItemWithParents(territories[0].Id);
		System.assertEquals('currentTerritory', newItem.label);
	}



}