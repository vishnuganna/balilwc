public with sharing class GreenSheetCommitmentRulesEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute
        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soql =
            'SELECT Id,Name,Green_Sheet__c,Green_Sheet__r.Meeting_Date__c,Green_Sheet__r.Opportunity__c,LastModifiedDate,' +
            'Minimum_Acceptable_Action_Commit__c,Best_Action_Commitment__c' +
            ' FROM Getting_Commitment__c where LastModifiedDate >=: backDaterange AND Green_Sheet__r.Meeting_Date__c >= :todayDate';
        return Database.getQueryLocator(soql);
    }

    public void execute(Database.BatchableContext batchContext, List<Getting_Commitment__c> greenSheetCommitmentList) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(greenSheetCommitmentList, RulesEngineConfig.Scope.GREENSHEET);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}