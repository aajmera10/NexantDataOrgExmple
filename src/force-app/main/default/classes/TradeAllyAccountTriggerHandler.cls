public class TradeAllyAccountTriggerHandler {
    public Static void doAfterInsert(List<Account> newAccounts){
        updateChildCount(newAccounts,Null);
    }
    public Static void doAfterUpdate(List<Account> newAccounts,Map<Id,Account> mapOldAccounts){
        updateChildCount(newAccounts,mapOldAccounts);
    }
    
    public Static void doAfterDelete(Map<Id,Account> mapOldAccounts){
        updateChildCount(Null,mapOldAccounts);
    }
    
    private static void updateChildCount(List<Account> newAccounts, Map<Id, Account> mapOldAccounts) {
        Set<Id> setParentAccountIds= new Set<Id>();
        List<Account> acclist = new List<Account>();
        Map<Id, Id> mapAccountIdToParentAccountId = new Map<Id, Id>();
        List<Account> listParentAccountsToUpdate = new List<Account>();
        List<AggregateResult> aggrResult = new List<AggregateResult>();
        
        if(newAccounts !=null && newAccounts.size() >0){
            for(Account accObj : newAccounts){
                if((mapOldAccounts == null && accObj.ParentId != null) || (mapOldAccounts != null && mapOldAccounts.get(accObj.Id).ParentId != accObj.ParentId && accObj.ParentId != null)){
                    setParentAccountIds.add(accObj.ParentId);
                    if((mapOldAccounts != null && mapOldAccounts.get(accObj.Id).ParentId != null)) {
                        setParentAccountIds.add(mapOldAccounts.get(accObj.Id).ParentId);
                    }
                }
                if(mapOldAccounts != null && mapOldAccounts.get(accObj.Id).ParentId != null){
                    setParentAccountIds.add(mapOldAccounts.get(accObj.Id).ParentId);
                }
            }
        }
        else{
            for(Account accObj : mapOldAccounts.values()){
                if((mapOldAccounts.get(accObj.Id).ParentId != null)){
                    setParentAccountIds.add(mapOldAccounts.get(accObj.Id).ParentId);
                }
            }
        }
        
        if(
            ESAPI.securityUtils().isAuthorizedToView(
                'Account',
                new List<String>{
                    'Id',
                        'ParentId',
                        Constants.NAMESPACE + 'Child_Account_Count__c'
                        }
            )
        ) {
            aggrResult = [Select Count(Id) cnt, ParentId parentId From Account
                          Where ParentId IN : setParentAccountIds
                          Group By ParentId];
        }
        Map<Id,Integer> mapParentIdWithCount = new Map<Id,Integer>();
        for(AggregateResult aggr : aggrResult) {
            mapParentIdWithCount.put((Id)aggr.get('parentId'),(Integer)aggr.get('cnt'));
            System.debug('map' + mapParentIdWithCount);
        }
        for (Id pId: setParentAccountIds)
        {
            if(!mapParentIdWithCount.containsKey(pId)){
                Account parentAccount = new Account(Id = pId);
                parentAccount.put(Constants.NAMESPACE +'Child_Account_Count__c',0);
                listParentAccountsToUpdate.add(parentAccount);
            }
            else{
                Account parentAccount = new Account(Id = pId);
                parentAccount.put(Constants.NAMESPACE +'Child_Account_Count__c',mapParentIdWithCount.get(pId));
                listParentAccountsToUpdate.add(parentAccount);
            }
        }
        
        
        
        if(listParentAccountsToUpdate != null && listParentAccountsToUpdate.size() > 0) {
            update listParentAccountsToUpdate;
        }
        
    }
}