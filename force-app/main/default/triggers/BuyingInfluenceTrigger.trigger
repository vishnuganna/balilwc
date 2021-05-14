trigger BuyingInfluenceTrigger on Buying_Influence__c(after insert, after update, after delete, before delete) {
    public static Boolean bIAvoidRecursion = true;
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // StrategyEngine.updateBuyingInfluence(Trigger.new);
            BlueSheetStatus.updateBlueFromBuyingInfluence(Trigger.new);
            ProgressNavigation.updateProgressBI(Trigger.new);
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BI);

            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
        }
        if (Trigger.isUpdate) {
            if (ProgressNavigation.bIAvoidRecursion == true) {
                ProgressNavigation.bIAvoidRecursion = false;
                // StrategyEngine.updateBuyingInfluence(Trigger.new);
                ProgressNavigation.updateProgressBI(Trigger.new);
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BI);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            // StrategyEngine.DeleteBuyingInfluence(Trigger.old);
            // StrategyEngine.deleteRecommendationRecAfterForBI(Trigger.oldMap);
            ProgressNavigation.updateProgressBI(Trigger.old);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        //evaluator.deleteBestActions(Trigger.old);
        DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForBuyingInfluence(Trigger.old);
    }

}