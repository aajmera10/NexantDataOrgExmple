trigger TradeAllyUserOnChange on Contact (before insert)  {
    if (Trigger.isBefore && Trigger.isInsert) {
        TAUserTriggerHandler.setCorrectLevels(Trigger.new);
        TAUserTriggerHandler.populateContactFields(Trigger.new);
    }
}