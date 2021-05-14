public with sharing class LandingKFSellActionsWrapper {
    @AuraEnabled
    public String opportunityName;
    @AuraEnabled
    public String oppId;
    @AuraEnabled
    public String actionTitle;
    @AuraEnabled
    public String opportunityOwnerFirstName;
    @AuraEnabled
    public String opportunityOwnerLastName;

    public LandingKFSellActionsWrapper(KF_Sell_Best__c recommObj) {
        this.opportunityName = recommObj.Opportunity__r.Name;
        this.oppId = recommObj.Opportunity__r.Id;
        this.actionTitle = recommObj.Action_Title__c;
        this.opportunityOwnerFirstName = recommObj.Opportunity__r.Owner.FirstName;
        this.opportunityOwnerLastName = recommObj.Opportunity__r.Owner.LastName;
    }
}