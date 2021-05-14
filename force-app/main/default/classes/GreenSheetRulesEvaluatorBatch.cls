public with sharing class GreenSheetRulesEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute
        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soql = 'Select Id, Name,Meeting_Date__c,Opportunity__c,Reason__c FROM Green_Sheet__c where LastModifiedDate >=: backDaterange AND Meeting_Date__c >= :todayDate';
        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext batchContext, List<Green_Sheet__c> greenSheetList) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(greenSheetList, RulesEngineConfig.Scope.GREENSHEET);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}