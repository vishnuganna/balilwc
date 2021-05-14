trigger BlueSheetTrigger on Blue_Sheet__c(before insert, after insert, before update, after update, before delete) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (BlueSheetRulesEvaluator.BlueSheetRulesEvaluatorInsertFlag == true) {
                BlueSheetRulesEvaluator.BlueSheetRulesEvaluatorInsertFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            }
            if (ActionPlanRulesEvaluator.ActionPlanRulesEvaluatorInsertFlag == true) {
                ActionPlanRulesEvaluator.ActionPlanRulesEvaluatorInsertFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.ACTIONPLAN);
            }
        }
        if (Trigger.isUpdate) {
            if (BlueSheetRulesEvaluator.BlueSheetRulesEvaluatorUpdateFlag == true) {
                BlueSheetRulesEvaluator.BlueSheetRulesEvaluatorUpdateFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            }

            if (ActionPlanRulesEvaluator.ActionPlanRulesEvaluatorUpdateFlag == true) {
                ActionPlanRulesEvaluator.ActionPlanRulesEvaluatorUpdateFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.ACTIONPLAN);
            }
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForBluesheet(Trigger.old);
        InsightsAlertRecommendations.deleteInsightsForActionPlan(Trigger.old);
    }
}