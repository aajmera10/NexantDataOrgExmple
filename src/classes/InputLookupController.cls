public with sharing class InputLookupController {

	@AuraEnabled
	public static List<SearchWrapper> searchData(String strInputData, String strObject) {
        List<SearchWrapper> listSearchWrapper = new List<SearchWrapper>();
        String strInput = '';
        
        try {
            if (!String.isBlank(strInputData) && !strInputData.equalsIgnoreCase('null')) {
                strInput = String.escapeSingleQuotes(strInputData);
            }
            
            String strQuery = 'SELECT Id, Name FROM '+String.escapeSingleQuotes(strObject)+' WHERE Name LIKE \'%'+strInput+'%\'';

            List<sObject> listOfsObjects = new List<sObject>();
			List<String> fieldsToCheck = new List<String>{'Id','Name'};
			if (ESAPI.securityUtils().isAuthorizedToView(String.escapeSingleQuotes(strObject),fieldsToCheck)) {
				listOfsObjects = Database.query(strQuery);
			}
            
            for (sObject currObj : listOfsObjects) {
                listSearchWrapper.add(new SearchWrapper(currObj));
            }
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        
        //return JSON.serialize(listSearchWrapper);
		return listSearchWrapper;
    }

	public class SearchWrapper {

		@AuraEnabled public String Id {get; set;}
		@AuraEnabled public String Name {get; set;}
        
        public SearchWrapper(sObject sObj) {
            this.Id = (Id) sObj.get('Id');
            this.Name = (String) sObj.get('Name');
        }
    }
}