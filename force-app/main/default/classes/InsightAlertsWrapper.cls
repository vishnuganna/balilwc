public with sharing class InsightAlertsWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String insights { get; set; }
    @AuraEnabled
    public String insightsLink { get; set; }
    @AuraEnabled
    public String displayLinkAs { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public String optyType { get; set; }
    @AuraEnabled
    public String industry { get; set; }
    @AuraEnabled
    public String brCategory { get; set; }

    public InsightAlertsWrapper(Insight_Alert__c insightObj) {
        this.Id = insightObj.Id;
        this.name = insightObj.Name;
        this.insightsLink = insightObj.Insights_Link__c;
        this.displayLinkAs = insightObj.Display_Link_As__c;
        this.insights = insightObj.Insights__c;
        this.accountName = insightObj.Competitor__r.Name;
        this.accountId = insightObj.Competitor__c;
        this.optyType = insightObj.Opportunity_Type__c;
        this.industry = insightObj.Industry__c;
        this.brCategory = insightObj.Business_Rule_Category__c;
    }
}