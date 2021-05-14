/*
    Apex class to schedule all Business rules related batch classes only
*/
public with sharing class BusinessRulesScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        OpportunityRuleEvaluatorBatch optyBatch = new OpportunityRuleEvaluatorBatch();
        Database.executeBatch(optyBatch, 150);
        BluesheetRuleEvaluatorBatch bsBatch = new BluesheetRuleEvaluatorBatch();
        Database.executeBatch(bsBatch, 150);
        ActionPlanRulesEvaluatorBatch apBatch = new ActionPlanRulesEvaluatorBatch();
        Database.executeBatch(apBatch, 150);
        ScoreCardRulesEvaluatorBatch cardBatch = new ScoreCardRulesEvaluatorBatch();
        Database.executeBatch(cardBatch, 150);
        GreenSheetRulesEvaluatorBatch greensheetBatch = new GreenSheetRulesEvaluatorBatch();
        Database.executeBatch(greensheetBatch, 150);
        GreenSheetBIRulesEvaluatorBatch greenBIBatch = new GreenSheetBIRulesEvaluatorBatch();
        Database.executeBatch(greenBIBatch, 150);
        GreenSheetCommitmentRulesEvaluatorBatch commitmentBatch = new GreenSheetCommitmentRulesEvaluatorBatch();
        Database.executeBatch(commitmentBatch, 150);
    }
}