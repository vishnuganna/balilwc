/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* KFS-480,main US=KFS-230 : after insert and after update trigger
  on the Action Plan object to calculate logic only for Not Started,In Progress and Completeto update the Action Plan-Progress Navigation field on blue sheet object
  and after delete trigger to check if that is the last record in case of many to many relationships to change the progress field to “Not Started”.
  In this case “Action Plan Progress” field to “Not Started”
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Janakiram Bali  
* @created        2020-June-23
*/

trigger ActionPlanTrigger on Action_Plan__c(after insert, after update, after delete, before delete) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (ProgressNavigation.actionPlanInsert == true) {
                ProgressNavigation.actionPlanInsert = false;
                BlueSheetStatus.updateBlueFromActionPlan(Trigger.new);
                // StrategyEngine.actionPlanUpdate(Trigger.new);
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
                ProgressNavigation.updateActionPlanProgressNavigation(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateInsert == true) {
                ProgressNavigation.LastUpdatedDateInsert = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }

        if (Trigger.isUpdate) {
            if (ProgressNavigation.actionPlanUpdate == true) {
                ProgressNavigation.actionPlanUpdate = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.BLUESHEET);
                ProgressNavigation.updateActionPlanProgressNavigation(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }

        if (Trigger.isDelete) {
            // StrategyEngine.deleteActionPlan(Trigger.old);
            // StrategyEngine.deleteRecommendationRecAfterForActionPlan();
            ProgressNavigation.updateActionPlanProgressNavigation(Trigger.old);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            // StrategyEngine.deleteRecommendationRecBeforeForActionPlan(Trigger.oldMap);
            DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForActionPlans(Trigger.old);
        }
    }
}