public with sharing class EmailAlertBatchService implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        // collect the batches of records or objects to be passed to execute

        String soqlSE = 'SELECT Id, Action_Title__c,Business_Rules__c, Alert_Type__c, Opportunity__c, Opportunity__r.OwnerId,BestActionRuleId__c,Seller_Email_Text__c, Seller_URL_Link__c, Seller_URL_Text__c, Action_Title_Manager__c, Action_Title_Seller__c,Manager_Recommended_Action__c, Manager_URL_Link__c, Manager_URL_Text__c, Opportunity__r.Name,Green_Sheet__c, Green_Sheet__r.OwnerId,  Green_Sheet__r.Task_Name__c FROM KF_Sell_Best__c WHERE Opportunity__c != null OR Green_Sheet__c != null  order by Opportunity__r.OwnerId';
        return Database.getQueryLocator(soqlSE);
    }

    public void execute(Database.BatchableContext batchContext, List<KF_Sell_Best__c> kfSellBestActionList) {
        EmailAlertService.processTOSendEmail(kfSellBestActionList);
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public void finish(Database.BatchableContext batchContext) {
    }
}