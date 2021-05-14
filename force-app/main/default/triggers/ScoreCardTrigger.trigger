trigger ScoreCardTrigger on Score_Card__c(after insert, after update, after delete) {
    public static Boolean isRecursivecall = true;
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            // StrategyEngine.updateScoreCardInSEInsertDelete(Trigger.newMap.values(), 'Insert');
            if (BlueSheetChildren.scInsert == true) {
                BlueSheetChildren.scInsert = false;
                BlueSheetChildren.updateScores(Trigger.new);
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            }
            if (ProgressNavigation.LastUpdatedDateInsert == true) {
                ProgressNavigation.LastUpdatedDateInsert = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
            if (BlueSheetRulesEvaluator.BlueSheetRulesEvaluatorInsertFlag == true) {
                BlueSheetRulesEvaluator.BlueSheetRulesEvaluatorInsertFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
            }
            if (ScoreCardRulesEvaluator.ScorecardRulesEvaluatorInsertFlag == true) {
                ScoreCardRulesEvaluator.ScorecardRulesEvaluatorInsertFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.SCORECARD);
            }
        }
    }
    if (Trigger.isInsert) {
        blueSheetStatus.updateBlueFromScoreCard(Trigger.new);
    }
    //KFS-225 code to update navigation progress on bluesheet
    if (Trigger.isAfter && Trigger.isUpdate) {
        if (isRecursivecall) {
            isRecursivecall = false;
            ProgressNavigation.updateNavigationProgress(Trigger.new);
        }
        if (BlueSheetChildren.scUpdate == true) {
            BlueSheetChildren.scUpdate = false;
            BlueSheetChildren.updateScores(Trigger.new);
        }
        if (ProgressNavigation.LastUpdatedDateUpdate == true) {
            ProgressNavigation.LastUpdatedDateUpdate = false;
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
        }
        if (ScoreCardRulesEvaluator.ScorecardRulesEvaluatorUpdateFlag == true) {
            ScoreCardRulesEvaluator.ScorecardRulesEvaluatorUpdateFlag = false;
            adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.SCORECARD);
        }
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        if (isRecursivecall) {
            isRecursivecall = false;
            ProgressNavigation.updateNavigationAfterDelete(Trigger.OldMap);
        }
        // StrategyEngine.updateScoreCardInSEInsertDelete(Trigger.OldMap.values(), 'Delete');
        ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.old);
    }
    //KFS-225 -end of logic
}