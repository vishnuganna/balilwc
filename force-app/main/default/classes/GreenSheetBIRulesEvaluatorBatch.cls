public with sharing class GreenSheetBIRulesEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute
        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soql =
            'SELECT Id,Name,Green_Sheet__c,Green_Sheet__r.Meeting_Date__c,Green_Sheet__r.Opportunity__c,Concept__c,LastModifiedDate' +
            ' FROM Green_Sheet_Buying_Influence__c where LastModifiedDate >=: backDaterange AND Green_Sheet__r.Meeting_Date__c >= :todayDate';
        return Database.getQueryLocator(soql);
    }

    public void execute(
        Database.BatchableContext batchContext,
        List<Green_Sheet_Buying_Influence__c> greenSheetBIList
    ) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(greenSheetBIList, RulesEngineConfig.Scope.GREENSHEET);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}