public with sharing class BluesheetRuleEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute

        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soqlSE = 'Select Id, Name, LastModifiedDate, Opportunity__c from Blue_Sheet__c where LastModifiedDate < :todayDate AND LastModifiedDate >=: backDaterange';
        return Database.getQueryLocator(soqlSE);
    }

    public void execute(Database.BatchableContext batchContext, List<Blue_Sheet__c> blueSheetList) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(blueSheetList, RulesEngineConfig.Scope.BLUESHEET);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}