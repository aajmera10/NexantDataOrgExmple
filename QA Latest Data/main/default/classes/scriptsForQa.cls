public with sharing class scriptsForQa {
//	public static void removeAutomaticalyCreatedGroups(){
//		List<Organization> organizationsList = [
//				SELECT Name
//				FROM Organization
//		];
//		String organizationName = '';
//		if(organizationsList.size() > 0){
//			organizationName = organizationsList[0].Name;
//		}
//		List<String> groupNamesList = new List<String>();
//		String firstGroupName = 'Tier 1 Trade Allies';
//		groupNamesList.add(firstGroupName);
//		String secondGroupName = organizationName + ' Announcements';
//		groupNamesList.add(secondGroupName);
//		String thirdGroupName = organizationName + ' Q&A';
//		groupNamesList.add(thirdGroupName);
//		List<CollaborationGroup> collaborationGroups = [
//				SELECT Name
//				FROM CollaborationGroup
//		WHERE Name IN: groupNamesList
//		];
//		delete collaborationGroups;
//			}
//
//	public static void removeAllCommunityGroups(){
//		List<CollaborationGroup> collaborationGroups = [
//				SELECT Name
//				FROM CollaborationGroup
//				WHERE NetworkId != NULL
//		];
//		delete collaborationGroups;
//	}

}