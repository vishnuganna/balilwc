@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public with sharing class LandingGoalsByFOPWrapper {
    @AuraEnabled
    public String goldsheetId { get; set; }
    @AuraEnabled
    public String fieldOdPlayName { get; set; }
    @AuraEnabled
    public String owner { get; set; }
    @AuraEnabled
    public Decimal goalCompleted { get; set; }
    @AuraEnabled
    public Decimal goalsPresent { get; set; }
    @AuraEnabled
    public String fopLinkName { get; set; }
    @AuraEnabled
    public String accLinkName { get; set; }
    @AuraEnabled
    public String accName { get; set; }

    public LandingGoalsByFOPWrapper(Gold_Sheet__c gsRecord) {
        this.goldsheetId = gsRecord.Id;
        this.fieldOdPlayName = gsRecord.FOP_Name__c;
        this.accName = gsRecord.Account__r.Name;
        this.owner = gsRecord.Owner.Name;
        this.goalCompleted = gsRecord.Goals_Completed__c;
        this.goalsPresent = gsRecord.Goals_Present__c;
        this.fopLinkName = '/' + gsRecord.Id;
        this.accLinkName = '/' + gsRecord.Account__c;
    }
}