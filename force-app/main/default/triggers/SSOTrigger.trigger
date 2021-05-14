trigger SSOTrigger on Single_Sales_Objective__c(after insert, after update, before delete) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //StrategyEngine.updateSingleSalesObjective(Trigger.new);
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            BlueSheetStatus.updateBlueFromSSO(Trigger.new);
            if (BlueSheetChildren.ssoInsert == true) {
                BlueSheetChildren.ssoInsert = false;
                BlueSheetChildren.updateSingleSalesObjective(Trigger.new);
                ProgressNavigation.updateProgressSingleSalesObjective(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateInsert == true) {
                ProgressNavigation.LastUpdatedDateInsert = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }

        if (Trigger.isUpdate) {
            //StrategyEngine.updateSingleSalesObjective(Trigger.new);
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            if (BlueSheetChildren.ssoUpdate == true) {
                BlueSheetChildren.ssoUpdate = false;
                BlueSheetChildren.updateSingleSalesObjective(Trigger.new);
                ProgressNavigation.updateProgressSingleSalesObjective(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }
    }

    // if (Trigger.isBefore) {
    //     if (Trigger.isDelete) {
    //         DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForSSO(Trigger.old);
    //     }
    // }

}