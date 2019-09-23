@IsTest
public with sharing class TradeAllySettingsControllerTest {
	@IsTest
	static void getInitDataTest() {
		List<Object> initData = TradeAllySettingsController.getInitData();
		System.assert(initData != null);
	}

	@IsTest
	static void createChatterGroupsTest() {
		List<Network> communityNameList = [
				SELECT  Id,
						Network.Name
				FROM    Network
		];
		Integer result = TradeAllySettingsController.createChatterGroups(communityNameList[0].Name);
		System.assert(result != null);
	}

	@IsTest
	static void createChatterGroupsTestSecond() {
		String firstGroupName = Constants.FIRST_GROUP_TEST_NAME;
		List<Network> communityNameList = [
				SELECT  Id,
						Network.Name
				FROM    Network
		];
		if(communityNameList.size() == 0) return;
		Id communityId = communityNameList[0].Id;
		CollaborationGroup firstGroup = new CollaborationGroup();
		firstGroup.NetworkId = communityId;
		firstGroup.Name = firstGroupName;
		firstGroup.CollaborationType = Constants.COLLABORATION_GROUP_PRIVATE_TYPE;
		insert firstGroup;
		Integer result = TradeAllySettingsController.createChatterGroups(communityNameList[0].Name);
		System.assert(result != null);
	}
}