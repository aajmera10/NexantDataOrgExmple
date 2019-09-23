public with sharing class TradeAllySettingsController {
	@AuraEnabled
	public static List<Object> getInitData() {
		List<Object> initData = new List<Object>();
		List<Network> communityList = getExistingNetworks();
		initData.add(communityList);
		Organization currentOrganization = getOrganization();
		String organizationName = currentOrganization.Name;
		List<String> groupNamesList = getGroupsNames(organizationName);
		initData.add(groupNamesList);
		return initData;
	}

	@AuraEnabled
	public static List<CollaborationGroup> getExistingGroups(List<String> groupNamesList, String networkName) {
		List<CollaborationGroup> groupList = new List<CollaborationGroup>();
		if (ESAPI.securityUtils().isAuthorizedToView('CollaborationGroup', new List<String>{'Name'})) {
			groupList = [
					SELECT  Name
					FROM    CollaborationGroup
					WHERE   Name IN: groupNamesList
					AND     Network.Name =: networkName
			];
		}
		return groupList;
	}

	@AuraEnabled
	public static Integer createChatterGroups(String networkName) {
		Organization currentOrganization = getOrganization();
		String organizationName = currentOrganization.Name;
		List<String> groupNamesList = getGroupsNames(organizationName);
		List<CollaborationGroup> groupList = getExistingGroups(groupNamesList, networkName);
		List<Network> communityList = getExistingNetworks();
		Network currentNetwork;
		for (Network network : communityList) {
			if (network.Name == networkName) {
				currentNetwork = network;
			}
		}
		Set<String> existingGroupsSet = new Set<String>();
		for (CollaborationGroup existingGroup : groupList) {
			String groupName = existingGroup.Name;
			existingGroupsSet.add(groupName);
		}
		Integer countOfInsertedGroups = 0;
		if (existingGroupsSet.size() == Constants.COUNT_OF_GROUPS) return countOfInsertedGroups;
		List<CollaborationGroup> newGroupsList = new List<CollaborationGroup>();
		for (String groupName : groupNamesList) {
			if (!existingGroupsSet.contains(groupName)) {
				countOfInsertedGroups++;
				CollaborationGroup firstGroup = new CollaborationGroup();
				firstGroup.NetworkId = currentNetwork.Id;
				firstGroup.Name = groupName;
				firstGroup.CollaborationType = Constants.COLLABORATION_GROUP_PRIVATE_TYPE;
				newGroupsList.add(firstGroup);
			}
		}
		ESAPI.securityUtils().validatedInsert(newGroupsList);
		return countOfInsertedGroups;
	}

	private static Organization getOrganization() {
		List<Organization> organizationsList = new List<Organization>();
		if (ESAPI.securityUtils().isAuthorizedToView('Organization', new List<String>{'Name'})) {
			organizationsList = [
					SELECT  Name
					FROM    Organization
					LIMIT   50000
			];
		}
		Organization currentOrganization;
		if (organizationsList.size() > 0) {
			currentOrganization = organizationsList[0];
		}
		return currentOrganization;
	}

	private static List<String> getGroupsNames(String organizationName) {
		if (Test.isRunningTest()) organizationName = Constants.ORGANIZATION_TEST_NAME;
		List<String> groupNamesList = new List<String>();
		String firstGroupName = Constants.FIRST_GROUP_NAME;
		if (Test.isRunningTest()) firstGroupName = Constants.FIRST_GROUP_TEST_NAME;
		groupNamesList.add(firstGroupName);
		String secondGroupName = organizationName + ' ' + Constants.SECOND_GROUP_NAME;
		groupNamesList.add(secondGroupName);
		String thirdGroupName = organizationName + ' ' + Constants.THIRD_GROUP_NAME;
		groupNamesList.add(thirdGroupName);
		return groupNamesList;
	}

	private static List<Network> getExistingNetworks() {
		List<Network> communityList = new List<Network>();
		if (ESAPI.securityUtils().isAuthorizedToView('Network', new List<String>{'Id', 'Name'})) {
			communityList = [
					SELECT  Id,
							Name
					FROM    Network
			];
		}
		return communityList;
	}
}