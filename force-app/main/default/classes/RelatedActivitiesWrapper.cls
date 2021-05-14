@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class RelatedActivitiesWrapper {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String raStatus { get; set; }
    @AuraEnabled
    public String goldsheetId { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String objectName { get; set; }
    @AuraEnabled
    public String objectLabel { get; set; }
    @AuraEnabled
    public String activityId { get; set; }
    @AuraEnabled
    public Decimal Amount { get; set; }
    @AuraEnabled
    public Date DueDate { get; set; }
    @AuraEnabled
    public String Source { get; set; }
    @AuraEnabled
    public String Who { get; set; }
    @AuraEnabled
    public boolean isFocusStop { get; set; }
    @AuraEnabled
    public String variantRAColor { get; set; }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public RelatedActivitiesWrapper() {
    }

    //parameter constructor that excepts the data from object and assign it to wrapper
    public RelatedActivitiesWrapper(Action__c raAction, boolean hasEditAccess, String Id) {
        this.activityId = raAction.Id;
        this.Id = Id;
        this.title = raAction.Action_Title__c;
        this.raStatus = raAction.Status__c;
        if (this.raStatus == 'Complete') {
            this.variantRAColor = 'Success';
        } else {
            this.variantRAColor = 'Warning';
        }
        this.DueDate = raAction.Due_Date__c;
        this.description = raAction.Description__c;
        this.Who = raAction.Assigned_To__r.Name;
        this.objectLabel = System.Label.ActionHeaderPDF;
        this.objectName = 'Action__c';
        this.isFocusStop = false;
    }
    public RelatedActivitiesWrapper(Investment_Program__c raInvestProg, boolean hasEditAccess, String Id) {
        this.activityId = raInvestProg.Id;
        this.Id = Id;
        this.title = raInvestProg.Investment_Program_Title__c;
        this.raStatus = raInvestProg.Status__c;
        if (this.raStatus == 'Complete') {
            this.variantRAColor = 'Success';
        } else {
            this.variantRAColor = 'Warning';
        }
        this.DueDate = raInvestProg.Due_Date__c;
        this.description = raInvestProg.Description__c;
        this.Who = raInvestProg.Assigned_To__r.Name;
        this.objectLabel = System.Label.InvestmentProgram;
        this.objectName = 'Investment_Program__c';
        this.isFocusStop = false;
    }
    public RelatedActivitiesWrapper(Information_Needed__c raInfoNeeded, boolean hasEditAccess, String Id) {
        this.activityId = raInfoNeeded.Id;
        this.Id = Id;
        this.title = raInfoNeeded.Information_Needed_Title__c;
        this.raStatus = raInfoNeeded.Status__c;
        if (this.raStatus == 'Complete') {
            this.variantRAColor = 'Success';
        } else {
            this.variantRAColor = 'Warning';
        }
        this.DueDate = raInfoNeeded.Due_Date__c;
        this.description = raInfoNeeded.Description__c;
        this.Who = raInfoNeeded.Assigned_To__r.Name;
        this.Source = raInfoNeeded.Source__c;
        this.objectLabel = System.Label.InformationNeededDisplay;
        this.objectName = 'Information_Needed__c';
        this.isFocusStop = false;
    }
    public RelatedActivitiesWrapper(Focus_Investment__c raFocus, boolean hasEditAccess, String Id) {
        this.activityId = raFocus.Id;
        this.Id = Id;
        this.title = raFocus.Investment_Title__c;
        this.raStatus = raFocus.Status__c;
        if (this.raStatus == 'Complete') {
            this.variantRAColor = 'Success';
        } else {
            this.variantRAColor = 'Warning';
        }
        this.Amount = raFocus.Amount__c;
        this.description = raFocus.Description__c;
        this.objectLabel = System.Label.FocusInvestment;
        this.objectName = 'Focus_Investment__c';
        this.isFocusStop = true;
    }
    public RelatedActivitiesWrapper(Stop_Investment__c raStop, boolean hasEditAccess, String Id) {
        this.activityId = raStop.Id;
        this.Id = Id;
        this.title = raStop.Investment_Title__c;
        this.raStatus = raStop.Status__c;
        if (this.raStatus == 'Complete') {
            this.variantRAColor = 'Success';
        } else {
            this.variantRAColor = 'Warning';
        }
        this.Amount = raStop.Amount__c;
        this.description = raStop.Description__c;
        this.objectLabel = System.Label.StopInvestmentHeader;
        this.objectName = 'Stop_Investment__c';
        this.isFocusStop = true;
    }
}