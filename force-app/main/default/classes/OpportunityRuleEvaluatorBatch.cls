public with sharing class OpportunityRuleEvaluatorBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute

        Date backDaterange = Date.Today() - 365;
        Date todayDate = Date.Today();
        String soqlSE = 'Select Id, Name, Amount, CloseDate, StageName, LastModifiedDate from Opportunity where LastModifiedDate >=: backDaterange OR CloseDate < :todayDate';
        return Database.getQueryLocator(soqlSE);
    }

    public void execute(Database.BatchableContext batchContext, List<Opportunity> opportunityList) {
        RulesAdapter adapter = new RulesAdapter();
        adapter.executeRules(opportunityList, RulesEngineConfig.Scope.OPP);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}