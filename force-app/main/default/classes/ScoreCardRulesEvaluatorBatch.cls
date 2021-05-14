public with sharing class ScoreCardRulesEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute

        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soqlSE = 'Select Id, Name, LastModifiedDate, Blue_Sheet__c from Score_Card__c where LastModifiedDate < :todayDate AND LastModifiedDate >=: backDaterange';
        return Database.getQueryLocator(soqlSE);
    }

    public void execute(Database.BatchableContext batchContext, List<Score_Card__c> scoreCardList) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(scoreCardList, RulesEngineConfig.Scope.SCORECARD);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}