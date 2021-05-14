public with sharing class LandingPageActionPlanWrapper {
    @AuraEnabled
    public String opportunityName;
    @AuraEnabled
    public String oppId;
    @AuraEnabled
    public String summary;
    @AuraEnabled
    public String dueDate;
    @AuraEnabled
    public String opportunityOwnerFirstName;
    @AuraEnabled
    public String opportunityOwnerLastName;

    public LandingPageActionPlanWrapper(Action_Plan__c actionPlanObj) {
        this.opportunityName = actionPlanObj.Blue_Sheet__r.Opportunity__r.Name;
        this.oppId = actionPlanObj.Blue_Sheet__r.Opportunity__r.Id;
        this.summary = actionPlanObj.Summary__c;
        this.dueDate = String.valueOf(actionPlanObj.Due_Date__c);
        this.opportunityOwnerFirstName = actionPlanObj.Blue_Sheet__r.Opportunity__r.Owner.FirstName;
        this.opportunityOwnerLastName = actionPlanObj.Blue_Sheet__r.Opportunity__r.Owner.LastName;
    }
}