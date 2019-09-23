public class ProjectTriggerHandler {
    public static void createTAProjectJunctions(Map<Id, List<String>> projectIdPartnersMap, List<String> partnerIdList) {
        List<Trade_Ally_Project__c> listTAProjects = new List<Trade_Ally_Project__c>();
        List<Account> tradeAllyAccounts = [SELECT Id, External_Id__c FROM Account WHERE
                                           External_Id__c IN: partnerIdList];
        for(Account a: tradeAllyAccounts) {
            for(Id projectId : projectIdPartnersMap.keySet()) {
                List<String> partnerListFromMap = projectIdPartnersMap.get(projectId);
                if(partnerListFromMap.contains(a.External_Id__c)) {
                    Trade_Ally_Project__c tap = new Trade_Ally_Project__c();
                    tap.Project__c = projectId;
                    tap.Trade_Ally__c = a.Id;
                    /*Account a = new Account(External_Id__c=s);
					tap.Trade_Ally__r = a;*/
                    listTAProjects.add(tap);
                }
            }
        }
        insert listTAProjects;
    }
    
    public static void updateTAProjectJunctions(Map<Id, List<String>> projectIdPartnersMap, List<String> partnerIdList, List<Id> projectIdDeleteList) {
    	List<Trade_Ally_Project__c> objectsToDelete = [SELECT Id FROM Trade_Ally_Project__c WHERE Project__c IN: projectIdDeleteList];
        if(!objectsToDelete.isEmpty()){
            Database.Delete(objectsToDelete, false);
        }
        ProjectTriggerHandler.createTAProjectJunctions(projectIdPartnersMap, partnerIdList);
    }
}