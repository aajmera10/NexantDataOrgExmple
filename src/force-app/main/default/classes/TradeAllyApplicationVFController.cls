public class TradeAllyApplicationVFController {
    public Application__c currentRecord{get;set;}
    public StartApplicationAllInfoWrapper allInfoWrapper {get; set;}
    public String applicationId{get;set;}
    public String tradeAllyId{get;set;}
    
    public TradeAllyApplicationVFController(){
        applicationId = apexpages.currentpage().getparameters().get('applicationId');
        tradeAllyId = apexpages.currentpage().getparameters().get('accountId');
        system.debug('applicationId:'+applicationId);
        system.debug('tradeAllyId:'+tradeAllyId);
    }
    
    public void loadApplicationData()
    {
        allInfoWrapper = StartApplicationController.getAllInfoWrapper(applicationId, tradeAllyId);
    }
}