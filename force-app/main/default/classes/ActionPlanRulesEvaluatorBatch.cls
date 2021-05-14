public with sharing class ActionPlanRulesEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute

        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soqlSE = 'Select Id, Name, Due_Date__c,Blue_Sheet__c, LastModifiedDate from Action_Plan__c where Due_Date__c < :todayDate AND LastModifiedDate >=: backDaterange';
        return Database.getQueryLocator(soqlSE);
    }

    public void execute(Database.BatchableContext batchContext, List<Action_Plan__c> actionPlanList) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(actionPlanList, RulesEngineConfig.Scope.BLUESHEET);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}