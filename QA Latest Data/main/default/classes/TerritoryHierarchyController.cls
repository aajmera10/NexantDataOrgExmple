public with sharing class TerritoryHierarchyController {

	public class Item {
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String name { get; set; }
		@AuraEnabled
		public Boolean expanded { get; set; }
		@AuraEnabled
		public List<Item> items { get; set; }
	}

	@AuraEnabled
	public static Item getCurrentItemWithParents(String currentTerritoryId) {
		currentTerritoryId = String.isBlank(currentTerritoryId) ? null : String.escapeSingleQuotes(currentTerritoryId);
		Territory__c currentTerritory;
		List<String> fieldsToCheck = new List<String>{
			'Id',
			'Name',
			Constants.NAMESPACE + 'Parent_Territory__c'
		};
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Territory__c',fieldsToCheck)) {
			currentTerritory = [
				SELECT 
						Name,
						Parent_Territory__c,
						Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name,
						Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c
				FROM	Territory__c
				WHERE	Id = :currentTerritoryId
			];
		}
//		System.debug('currentTerritory ' + currentTerritory);
		Item currentItem = new Item();
		currentItem.name = currentTerritory.Id;
		currentItem.label = currentTerritory.Name;
		currentItem.expanded = false;
		currentItem.items = new List<TerritoryHierarchyController.Item>();
		getChildItem(currentItem);

		if (currentTerritory.Parent_Territory__c != null) {
			Item parentItemLevel1 = new Item();
			parentItemLevel1.name = currentTerritory.Parent_Territory__c;
			parentItemLevel1.label = currentTerritory.Parent_Territory__r.Name;
			parentItemLevel1.expanded = true;
			parentItemLevel1.items = new List<TerritoryHierarchyController.Item>();
			parentItemLevel1.items.add(currentItem);

			if (currentTerritory.Parent_Territory__r.Parent_Territory__c != null) {
				Item parentItemLevel2 = new Item();
				parentItemLevel2.name = currentTerritory.Parent_Territory__r.Parent_Territory__c;
				parentItemLevel2.label = currentTerritory.Parent_Territory__r.Parent_Territory__r.Name;
				parentItemLevel2.expanded = true;
				parentItemLevel2.items = new List<TerritoryHierarchyController.Item>();
				parentItemLevel2.items.add(parentItemLevel1);

				if (currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c != null) {
					Item parentItemLevel3 = new Item();
					parentItemLevel3.name = currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c;
					parentItemLevel3.label = currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name;
					parentItemLevel3.expanded = true;
					parentItemLevel3.items = new List<TerritoryHierarchyController.Item>();
					parentItemLevel3.items.add(parentItemLevel2);

					if (currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c != null) {
						Item parentItemLevel4 = new Item();
						parentItemLevel4.name = currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c;
						parentItemLevel4.label = currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Name;
						parentItemLevel4.expanded = true;
						parentItemLevel4.items = new List<TerritoryHierarchyController.Item>();
						parentItemLevel4.items.add(parentItemLevel3);

						if (currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__c != null) {
//							Item parentItemLevel5 = new Item();
//							parentItemLevel5.name = currentTerritory.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Parent_Territory__r.Id;
//							parentItemLevel5.label = '...';
//							parentItemLevel5.expanded = true;
//							parentItemLevel5.items = new List<TerritoryHierarchyController.Item>();
//							parentItemLevel5.items.add(parentItemLevel4);
//							return parentItemLevel5;
						}
						else {
							return parentItemLevel4;
						}
					}
					else {
						return parentItemLevel3;
					}
				}
				else {
					return parentItemLevel2;
				}
			}
			else {
				return parentItemLevel1;
			}
		}
			return currentItem;

	}

	@AuraEnabled
	public static void getChildItem(Item currentItem) {
		List<Item> childItems = new List<Item>();

		List<Territory__c> childTerritories = new List<Territory__c>();
		List<String> fieldsToCheck = new List<String>{
			'Id',
			'Name',
			Constants.NAMESPACE + 'Parent_Territory__c'
		};
		if (ESAPI.securityUtils().isAuthorizedToView(Constants.NAMESPACE + 'Territory__c',fieldsToCheck)) {
			childTerritories = [
				SELECT 
						Id,
						Name,
						Parent_Territory__c,
						Parent_Territory__r.Name
				FROM	Territory__c
				WHERE	Parent_Territory__c = :currentItem.name
			];
		}
//		System.debug('childTerritories ' + childTerritories);
		for (Integer i = 0; i < childTerritories.size(); i++) {
			Item childItem = new Item();
			childItem.name = childTerritories[i].Id;
			childItem.label = childTerritories[i].Name;
			childItem.expanded = false;
			childItem.items = new List<TerritoryHierarchyController.Item>();
			currentItem.items.add(childItem);
		}
	}

}