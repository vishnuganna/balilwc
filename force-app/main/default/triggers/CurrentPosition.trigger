trigger CurrentPosition on Current_Position__c(after insert, after update, before delete) {
    public static Boolean cpAvoidRecursion = true;
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (cpAvoidRecursion == true) {
                cpAvoidRecursion = false;
                //StrategyEngine.updateCurrentPosition(Trigger.new);
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
                ProgressNavigation.updateProgressCurrentPosition(Trigger.new);
                BlueSheetStatus.updateBlueFromCurrentPosition(Trigger.new);
            }
            if (BlueSheetChildren.cpInsert == true) {
                BlueSheetChildren.cpInsert = false;
                BlueSheetChildren.updateCurrentPosition(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateInsert == true) {
                ProgressNavigation.LastUpdatedDateInsert = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }

        if (Trigger.isUpdate) {
            if (cpAvoidRecursion == true) {
                cpAvoidRecursion = false;
                //StrategyEngine.updateCurrentPosition(Trigger.new);
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
                ProgressNavigation.updateProgressCurrentPosition(Trigger.new);
            }
            if (BlueSheetChildren.cpUpdate == true) {
                BlueSheetChildren.cpUpdate = false;
                BlueSheetChildren.updateCurrentPosition(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }
    }

    // if (Trigger.isBefore) {
    //     if (Trigger.isDelete) {
    //         DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForCurrentPosition(Trigger.old);
    //     }
    // }

}