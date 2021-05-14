public with sharing class LandingPageBlueSheetWrapper {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String currentPosition;
    @AuraEnabled
    public String customerTimingforPriorities;
    @AuraEnabled
    public String lastModifiedDate;
    @AuraEnabled
    public String scorecardTotal;
    @AuraEnabled
    public String ebiCount;
    @AuraEnabled
    public String coachCount;
    @AuraEnabled
    public String biTotal;
    @AuraEnabled
    public String opportunityCloseDate;
    @AuraEnabled
    public String opportunityAmount;
    @AuraEnabled
    public String opportunityStageName;
    @AuraEnabled
    public String opportunityName;
    @AuraEnabled
    public String oppId;
    @AuraEnabled
    public String opportunityIsClosed;
    @AuraEnabled
    public String opportunityOwnerFirstName;
    @AuraEnabled
    public String opportunityOwnerLastName;

    public LandingPageBlueSheetWrapper(Blue_Sheet__c bsObj) {
        this.name = bsObj.name;
        this.currentPosition = bsObj.Current_Position__c;
        this.customerTimingforPriorities = bsObj.Customer_Timing_for_Priorities__c;
        this.lastModifiedDate = String.valueOf(bsObj.LastModifiedDate);
        this.scorecardTotal = String.valueOf(bsObj.Scorecard_Total__c);
        this.ebiCount = String.valueOf(bsObj.EBI_Count__c);
        this.coachCount = String.valueOf(bsObj.Coach_Count__c);
        this.biTotal = String.valueOf(bsObj.BI_Total__c);
        this.opportunityCloseDate = String.valueOf(bsObj.Opportunity__r.CloseDate);
        this.opportunityAmount = String.valueOf(bsObj.Opportunity__r.Amount);
        this.opportunityStageName = bsObj.Opportunity__r.StageName;
        this.opportunityName = bsObj.Opportunity__r.Name;
        this.oppId = bsObj.Opportunity__r.Id;
        this.opportunityIsClosed = String.valueOf(bsObj.Opportunity__r.IsClosed);
        this.opportunityOwnerFirstName = bsObj.Opportunity__r.Owner.FirstName;
        this.opportunityOwnerLastName = bsObj.Opportunity__r.Owner.LastName;
    }
}