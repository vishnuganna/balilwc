trigger GettingCommitmentTrigger on Getting_Commitment__c(after insert, after update, after delete) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.GREENSHEET);
            GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.new);
        }
        if (Trigger.isDelete) {
            GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }
}