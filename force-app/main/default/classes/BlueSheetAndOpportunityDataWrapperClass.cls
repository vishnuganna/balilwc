public with sharing class BlueSheetAndOpportunityDataWrapperClass {
    @AuraEnabled
    public String blueSheetName { get; set; }
    @AuraEnabled
    public String ownerName { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public Date closeDate { get; set; }
    @AuraEnabled
    public Decimal amount { get; set; }
    @AuraEnabled
    public String opportunityName { get; set; }
    @AuraEnabled
    //public String bluesheetScorecardLastUpdated { get; set; }
    public Datetime bluesheetScorecardLastUpdated { get; set; }
    @AuraEnabled
    public Decimal expectedRevenue { get; set; }
    @AuraEnabled
    public String stageName { get; set; }
}