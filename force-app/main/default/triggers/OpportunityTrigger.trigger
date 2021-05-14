trigger OpportunityTrigger on Opportunity(
    after insert,
    after update,
    after delete,
    before insert,
    before update,
    before delete
) {
    RulesAdapter adapter = new RulesAdapter();
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (OpportunityRulesEvaluator.OpportunityRulesEvaluatorInsertFlag == true) {
                OpportunityRulesEvaluator.OpportunityRulesEvaluatorInsertFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.OPP);
            }
        }

        if (Trigger.isUpdate) {
            if (OpportunityRulesEvaluator.OpportunityRulesEvaluatorUpdateFlag == true) {
                OpportunityRulesEvaluator.OpportunityRulesEvaluatorUpdateFlag = false;
                adapter.executeRules(Trigger.new, RulesEngineConfig.Scope.OPP);
            }
        }
        // if (Trigger.isDelete) {
        // }
    }
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            OpportunityTriggerHelper.updateStageModifiedTimeStamp(Trigger.new, null);
            if (
                ClosedWonOpportunityOnGoldSheet.ClosedWonOpportunityOnGoldSheetInsertFlag == true &&
                Schema.sObjectType.Gold_Sheet__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Opportunity.fields.Has_an_Associated_GoldSheet__c.isUpdateable()
            ) {
                ClosedWonOpportunityOnGoldSheet.ClosedWonOpportunityOnGoldSheetInsertFlag = false;
                ClosedWonOpportunityOnGoldSheet.checkIfClosedWon(Trigger.new);
            }
        }
        if (Trigger.isUpdate) {
            OpportunityTriggerHelper.updateStageModifiedTimeStamp(Trigger.new, Trigger.oldMap);
            if (
                ClosedWonOpportunityOnGoldSheet.ClosedWonOpportunityOnGoldSheetUpdateFlag == true &&
                Schema.sObjectType.Gold_Sheet__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Opportunity.fields.Has_an_Associated_GoldSheet__c.isUpdateable()
            ) {
                ClosedWonOpportunityOnGoldSheet.ClosedWonOpportunityOnGoldSheetUpdateFlag = false;
                ClosedWonOpportunityOnGoldSheet.checkIfClosedWon(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            DeleteBusinessRuleAlerts.deleteBusinessRuleAlertForOpportunities(Trigger.old);
            /*if (
                ClosedWonOpportunityOnGoldSheet.ClosedWonOpportunityOnGoldSheetDeleteFlag == true &&
                Schema.sObjectType.Gold_Sheet__c.fields.Account__c.isAccessible() &&
                Schema.sObjectType.Opportunity.fields.Has_an_Associated_GoldSheet__c.isUpdateable()
            ) {
                ClosedWonOpportunityOnGoldSheet.ClosedWonOpportunityOnGoldSheetDeleteFlag = false;
                ClosedWonOpportunityOnGoldSheet.checkIfClosedWon(Trigger.new);
            }*/
        }
    }
}