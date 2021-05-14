@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public with sharing class InformationNeededWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String gsInformationNeededName { get; set; }
    @AuraEnabled
    public String gsInformationNeededAssignedToName { get; set; }
    @AuraEnabled
    public String gsInformationNeededTitle { get; set; }
    @AuraEnabled
    public String gsInformationNeededSource { get; set; }
    @AuraEnabled
    public String gsInformationNeededDescription { get; set; }
    @AuraEnabled
    public String gsInformationNeededStatus { get; set; }
    @AuraEnabled
    public Date gsInformationNeededDueDate { get; set; }
    @AuraEnabled
    public String gsInformationNeededDueDateString { get; set; }
    @AuraEnabled
    public String goldSheet { get; set; }
    @AuraEnabled
    public String gsInformationNeededAssignedTo { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }

    public InformationNeededWrapper(Information_Needed__c informationNeeded, boolean hasEditAccess) {
        this.id = informationNeeded.Id;
        this.gsInformationNeededName = informationNeeded.Name;
        this.gsInformationNeededTitle = informationNeeded.Information_Needed_Title__c;
        this.gsInformationNeededSource = informationNeeded.Source__c;
        this.gsInformationNeededDescription = informationNeeded.Description__c;
        this.gsInformationNeededStatus = informationNeeded.Status__c;
        this.gsInformationNeededDueDate = informationNeeded.Due_Date__c;
        Date dt = (Date) informationNeeded.Due_Date__c;
        if (dt != null) {
            this.gsInformationNeededDueDateString = DateTime.newInstance(dt.year(), dt.month(), dt.day())
                .format('MM/dd/YYYY');
        }
        this.gsInformationNeededAssignedTo = informationNeeded.Assigned_To__c;
        this.gsInformationNeededAssignedToName = informationNeeded.Assigned_To__r.Name;
        this.goldSheet = informationNeeded.Fields_of_Play_Gold_Sheet__c;
        this.hasEditAccess = hasEditAccess;
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }
}
//Done