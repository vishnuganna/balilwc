public with sharing class BestActionRuleBatch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute

        Date seBackDaterange = Date.Today() - 365;
        String soqlSE = 'Select Id,Opportunity_Amount__c,Place_in_Sales_Funnel__c,Blue_Sheet__c,Opportunity__c,Opty_Close_Date__c,Opty_Stage_Last_Modified_Date__c,Bluesheet_Count_Actions__c,lastmodifieddate,Best_Action_Due_Date__c,Current_Position__c,Competition__c,Position_vs_Competition__c,Score_Card__c,Is_Master__c,Buying_Influence_Role__c,CurrentPosition__c,Action_Plan__c,Buying_Influence__c,Competitor__c,Bluesheet_Last_Modified_Date__c,AP_IsBestAction__c,Customer_Timing_for_Priorities__c from Strategy_Engine__c where lastmodifieddate >=: seBackDaterange';
        return Database.getQueryLocator(soqlSE);
    }

    public void execute(Database.BatchableContext batchContext, List<Strategy_Engine__c> strategyEngineLst) {
        BestActionLogic.upsertRecommendationsRec(strategyEngineLst);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}