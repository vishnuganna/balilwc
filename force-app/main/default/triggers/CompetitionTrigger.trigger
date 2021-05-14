trigger CompetitionTrigger on Competition__c(after insert, after update, after delete, before delete) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //StrategyEngine.updateCompetition(Trigger.new);
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            BlueSheetStatus.updateBlueFromCompetition(Trigger.new);
            ProgressNavigation.updateProgressCompetition(Trigger.new);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);

            if (CompetitorRulesEvaluator.CompetitorRulesEvaluatorInsertFlag == true) {
                CompetitorRulesEvaluator.CompetitorRulesEvaluatorInsertFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.COMPETITOR);
            }
        }
        if (Trigger.isUpdate) {
            if (ProgressNavigation.competetitionAvoidRecursion == true) {
                ProgressNavigation.competetitionAvoidRecursion = false;
                //StrategyEngine.updateCompetition(Trigger.new);
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
                ProgressNavigation.updateProgressCompetition(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
            if (CompetitorRulesEvaluator.CompetitorRulesEvaluatorUpdateFlag == true) {
                CompetitorRulesEvaluator.CompetitorRulesEvaluatorUpdateFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.COMPETITOR);
            }
        }
        if (Trigger.isDelete) {
            // StrategyEngine.DeleteCompetition(Trigger.old);
            // StrategyEngine.deleteRecommendationRecAfterForCompetition();
            ProgressNavigation.updateProgressCompetition(Trigger.old);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            // StrategyEngine.deleteRecommendationRecBeforeForCompetition(Trigger.oldMap);
            DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForCompetition(Trigger.old);
            InsightsAlertRecommendations.deleteInsightsForCompetition(Trigger.old);
        }
    }
}