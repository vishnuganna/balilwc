trigger GreenSheetTrigger on Green_Sheet__c(after insert, after update, after delete, before delete) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.GREENSHEET);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForGreenSheet(Trigger.old);
        }
    }
}