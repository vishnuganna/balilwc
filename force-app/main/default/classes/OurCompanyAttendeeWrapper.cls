public with sharing class OurCompanyAttendeeWrapper {
    @AuraEnabled
    public String nameId { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String greenSheetId { get; set; }
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String userLinkName { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }

    public OurCompanyAttendeeWrapper(Company_Attendee__c oca, boolean hasEditAccess) {
        this.nameId = oca.Name__c;
        this.title = oca.Name__r.Title;
        this.greenSheetId = oca.Green_Sheet__c;
        this.id = oca.id;
        this.name = oca.Name__r.Name;
        this.userLinkName = '/' + oca.Name__c;
        this.hasEditAccess = hasEditAccess;
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }
}