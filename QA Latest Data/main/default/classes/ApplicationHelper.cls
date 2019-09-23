public without sharing class ApplicationHelper {
    public static List<Application__c> getApplication(String query) {
        List<Application__c> listOfAvailableApplications = Database.query(query);
        return listOfAvailableApplications;
    }
    
    public static void changeOwnership(Id userId, Application__c application) {
         application.OwnerId = userId;
         update application;
    }
}