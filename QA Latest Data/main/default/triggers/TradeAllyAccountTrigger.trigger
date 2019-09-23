trigger TradeAllyAccountTrigger on Account (after insert,after update,after delete) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            TradeAllyAccountTriggerHandler.doAfterInsert(Trigger.new);
        }
        if(Trigger.isUpdate){
            TradeAllyAccountTriggerHandler.doAfterUpdate(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isDelete){
            TradeAllyAccountTriggerHandler.doAfterDelete(Trigger.oldMap);
        }
    }
}