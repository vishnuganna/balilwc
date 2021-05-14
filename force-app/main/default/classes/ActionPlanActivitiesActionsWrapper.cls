@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public with sharing class ActionPlanActivitiesActionsWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String gsActionName { get; set; }
    @AuraEnabled
    public String gsActionAssignedToName { get; set; }
    @AuraEnabled
    public String gsActionTitle { get; set; }
    @AuraEnabled
    public String gsActionDescription { get; set; }
    @AuraEnabled
    public String gsActionStatus { get; set; }
    @AuraEnabled
    public Date gsActionDueDate { get; set; }
    @AuraEnabled
    public String gsActionDueDateString { get; set; }
    @AuraEnabled
    public String goldSheet { get; set; }
    @AuraEnabled
    public String gsActionAssignedTo { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }

    public ActionPlanActivitiesActionsWrapper(Action__c action, boolean hasEditAccess) {
        this.id = action.Id;
        this.gsActionName = action.Name;
        this.gsActionTitle = action.Action_Title__c;
        this.gsActionDescription = action.Description__c;
        this.gsActionStatus = action.Status__c;
        this.gsActionDueDate = action.Due_Date__c;
        Date dt = (Date) action.Due_Date__c;
        if (dt != null) {
            this.gsActionDueDateString = DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('MM/dd/YYYY');
        }
        this.gsActionAssignedTo = action.Assigned_To__c;
        this.gsActionAssignedToName = action.Assigned_To__r.Name;
        this.goldSheet = action.Fields_of_Play_Gold_Sheet__c;
        this.hasEditAccess = hasEditAccess;
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }
}