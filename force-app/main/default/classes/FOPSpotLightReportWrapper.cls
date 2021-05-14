@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public with sharing class FOPSpotLightReportWrapper {
    @AuraEnabled
    public String goldsheetId { get; set; }
    @AuraEnabled
    public String fieldOdPlayName { get; set; }
    @AuraEnabled
    public String fopThisYear { get; set; }
    @AuraEnabled
    public String owner { get; set; }
    @AuraEnabled
    public Datetime createdDate { get; set; }
    @AuraEnabled
    public Decimal goalCompleted { get; set; }
    @AuraEnabled
    public Decimal goalNotCompleted { get; set; }
    @AuraEnabled
    public Decimal countFOPOpportunity { get; set; }
    @AuraEnabled
    public Decimal sponsor { get; set; }
    @AuraEnabled
    public Decimal antisponsor { get; set; }
    @AuraEnabled
    public Decimal strategicCoach { get; set; }
    @AuraEnabled
    public Decimal keyPlayer { get; set; }
    @AuraEnabled
    public Decimal lowTarget { get; set; }
    @AuraEnabled
    public Decimal hightTarget { get; set; }
    @AuraEnabled
    public Decimal realisticTarget { get; set; }
    @AuraEnabled
    public String fopLinkName { get; set; }
    @AuraEnabled
    public String milestoneNumber { get; set; }
    @AuraEnabled
    public String milestoneName { get; set; }
    @AuraEnabled
    public Date scheduledDate { get; set; }

    public FOPSpotLightReportWrapper(Gold_Sheet__c gsRecord) {
        this.goldsheetId = gsRecord.Id;
        this.fieldOdPlayName = gsRecord.FOP_Name__c;
        this.fopThisYear = gsRecord.FOP_This_Year__c;
        this.owner = gsRecord.Owner.Name;
        this.createdDate = gsRecord.CreatedDate;
        this.goalCompleted = gsRecord.Goals_Completed__c;
        this.goalNotCompleted = gsRecord.Goals_Incomplete__c;
        this.countFOPOpportunity = gsRecord.Count_FOP_Opportunity__c;
        this.sponsor = gsRecord.Strategic_Player_Sponsor__c;
        this.antisponsor = gsRecord.Strategic_Player_Antisponsor__c;
        this.strategicCoach = gsRecord.Strategic_Player_Coach__c;
        this.keyPlayer = gsRecord.Strategic_Player_Key_Player__c;
        this.lowTarget = gsRecord.Low_Target_Current_Year__c;
        this.hightTarget = gsRecord.High_Target_Current_Year__c;
        this.realisticTarget = gsRecord.Realistic_Target_Current_Year__c;
        this.fopLinkName = '/' + gsRecord.Id;
    }
    public FOPSpotLightReportWrapper(Milestone__c mlRecord) {
        this.goldsheetId = mlRecord.Gold_Sheet__c;
        this.fieldOdPlayName = mlRecord.Gold_Sheet__r.FOP_Name__c;
        this.owner = mlRecord.Gold_Sheet__r.Owner.Name;
        this.milestoneName = mlRecord.Milestone_Name__c;
        this.milestoneNumber = mlRecord.Milestone_Number__c;
        this.scheduledDate = mlRecord.Meeting_Date__c;
        this.fopLinkName = '/' + mlRecord.Gold_Sheet__c;
    }
}