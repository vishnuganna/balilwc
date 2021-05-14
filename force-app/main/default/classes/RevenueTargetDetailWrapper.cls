@SuppressWarnings('PMD.ExcessivePublicCount')
public class RevenueTargetDetailWrapper {
    @AuraEnabled
    public decimal cyLTRecurringRevenue { get; set; }
    @AuraEnabled
    public decimal cyLTLostRevenue { get; set; }
    @AuraEnabled
    public decimal cyLTNewRevenue { get; set; }
    @AuraEnabled
    public decimal cyLowTarget { get; set; }
    @AuraEnabled
    public decimal cyRTRecurringRevenue { get; set; }
    @AuraEnabled
    public decimal cyRTLostRevenue { get; set; }
    @AuraEnabled
    public decimal cyRTNewRevenue { get; set; }
    @AuraEnabled
    public decimal cyRealisticTarget { get; set; }
    @AuraEnabled
    public decimal cyHTRecurringRevenue { get; set; }
    @AuraEnabled
    public decimal cyHTLostRevenue { get; set; }
    @AuraEnabled
    public decimal cyHTNewRevenue { get; set; }
    @AuraEnabled
    public decimal cyHighTarget { get; set; }
    @AuraEnabled
    public String cyAssumptions { get; set; }
    @AuraEnabled
    public String recordId { get; set; }
    @AuraEnabled
    public String tabType { get; set; }

    public RevenueTargetDetailWrapper(Revenue_Target_Detail__c gsRecord) {
        this.cyLTRecurringRevenue = gsRecord.Low_Recurring_Revenue__c;
        this.cyLTLostRevenue = gsRecord.Low_Lost_Revenue__c;
        this.cyLTNewRevenue = gsRecord.Low_New_Revenue__c;
        this.cyLowTarget = gsRecord.Low_Target__c;
        this.cyRTRecurringRevenue = gsRecord.Realistic_Recurring_Revenue__c;
        this.cyRTLostRevenue = gsRecord.Realistic_Lost_Revenue__c;
        this.cyRTNewRevenue = gsRecord.Realistic_New_Revenue__c;
        this.cyRealisticTarget = gsRecord.Realistic_Target__c;
        this.cyHTRecurringRevenue = gsRecord.High_Recurring_Revenue__c;
        this.cyHTLostRevenue = gsRecord.High_Lost_Revenue__c;
        this.cyHTNewRevenue = gsRecord.High_New_Revenue__c;
        this.cyHighTarget = gsRecord.High_Target__c;
        this.cyAssumptions = gsRecord.Assumptions__c;
        this.recordId = gsRecord.Id;
        this.tabType = gsRecord.Tab_Type__c;
    }
}