public with sharing class SearchRequestWrapper {
@AuraEnabled public List<SingleFilterInfoWrapper__c> listOfFilters {get;set;}
    
    public SearchRequestWrapper() {
        
    }
}