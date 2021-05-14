public with sharing class LandingKFSellFOPActionsWrapper {
    @AuraEnabled
    public String fopName;
    @AuraEnabled
    public String fopId;
    @AuraEnabled
    public String accName;
    @AuraEnabled
    public String actionTitle;
    @AuraEnabled
    public String accOwnerName;
    @AuraEnabled
    public String fopLastUpdated;

    public LandingKFSellFOPActionsWrapper(KF_Sell_Best__c bestActions) {
        this.fopName = bestActions.Fields_of_Play_Gold_Sheet__r.FOP_Name__c;
        this.fopId = bestActions.Fields_of_Play_Gold_Sheet__r.Id;
        this.accName = bestActions.Fields_of_Play_Gold_Sheet__r.Account__r.Name;
        this.accOwnerName = bestActions.Fields_of_Play_Gold_Sheet__r.Owner.Name;
        this.fopLastUpdated = String.valueOf(bestActions.Fields_of_Play_Gold_Sheet__r.Last_Updated__c.date());
    }
}