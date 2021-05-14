public with sharing class RevenueTargetWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public RevenueTargetDetailWrapper currentYearWrapper { get; set; }
    @AuraEnabled
    public RevenueTargetDetailWrapper newYearWrapper { get; set; }
    @AuraEnabled
    public RevenueTargetDetailWrapper customDateWrapper { get; set; }
    @AuraEnabled
    public String goldSheetId { get; set; }
    @AuraEnabled
    public Date customDate { get; set; }

    public RevenueTargetWrapper(Revenue_Target__c revenueTarget) {
        this.Id = revenueTarget.Id;
        this.name = revenueTarget.Name;
        this.customDate = revenueTarget.Custom_Date__c;
        this.goldSheetId = revenueTarget.Gold_Sheet__c;
    }
}