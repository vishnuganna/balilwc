/*
    Its main class to schedule all Schedulable classes
*/
public with sharing class MainSchedulerClass implements Schedulable {
    public void execute(SchedulableContext context) {
        System.enqueueJob(new CustomProfileQueueable());
        System.enqueueJob(new GoldSheetQueueable());
        BestActionRuleBatch b = new BestActionRuleBatch();
        Database.executeBatch(b, 150);
        OpportunityRuleEvaluatorBatch optyBatch = new OpportunityRuleEvaluatorBatch();
        Database.executeBatch(optyBatch, 150);
        BluesheetRuleEvaluatorBatch bsBatch = new BluesheetRuleEvaluatorBatch();
        Database.executeBatch(bsBatch, 150);
        ActionPlanRulesEvaluatorBatch apBatch = new ActionPlanRulesEvaluatorBatch();
        Database.executeBatch(apBatch, 150);
        ScoreCardRulesEvaluatorBatch cardBatch = new ScoreCardRulesEvaluatorBatch();
        Database.executeBatch(cardBatch, 150);
    }
}