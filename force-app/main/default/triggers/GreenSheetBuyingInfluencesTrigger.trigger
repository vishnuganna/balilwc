trigger GreenSheetBuyingInfluencesTrigger on Green_Sheet_Buying_Influence__c(
    after insert,
    after update,
    after delete,
    before delete
) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.new);
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.GREENSHEET);
        }

        if (Trigger.isUpdate) {
            if (GreenSheet.LastUpdatedDate == true) {
                GreenSheet.LastUpdatedDate = false;
                GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.new);
            }
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.GREENSHEET);
        }

        if (Trigger.isDelete) {
            GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForGreenSheetBI(Trigger.old);
        }
    }
}