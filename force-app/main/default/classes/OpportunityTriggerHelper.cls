public with sharing class OpportunityTriggerHelper {
    public static void updateStageModifiedTimeStamp(
        List<Opportunity> opportunities,
        map<Id, Opportunity> oldOpportunityalues
    ) {
        for (Opportunity opp : opportunities) {
            if (
                (opp.StageName != null && oldOpportunityalues == null) ||
                (oldOpportunityalues != null &&
                oldOpportunityalues.get(opp.Id).StageName != opp.StageName)
            ) {
                opp.Stage_Last_ModifiedOn__c = DateTime.now();
            }
        }
    }
}