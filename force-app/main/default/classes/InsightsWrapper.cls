public with sharing class InsightsWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String bluesheetId { get; set; }
    @AuraEnabled
    public String businessRuleId { get; set; }
    @AuraEnabled
    public String competitionId { get; set; }
    @AuraEnabled
    public String insightAlertId { get; set; }
    @AuraEnabled
    public String opportunityId { get; set; }
    @AuraEnabled
    public String insightAlertText { get; set; }
    @AuraEnabled
    public String insightAlertLink { get; set; }
    @AuraEnabled
    public String insightAlertLinkDisplayLinkAs { get; set; }
    @AuraEnabled
    public String insightCompetitor { get; set; }

    public InsightsWrapper(Insight__c insightObj) {
        this.Id = insightObj.Id;
        this.name = insightObj.Name;
        this.bluesheetId = insightObj.Blue_Sheet__c;
        this.businessRuleId = insightObj.Business_Rules__c;
        this.competitionId = insightObj.Competition__c;
        this.insightAlertId = insightObj.Insight_Alert__c;
        this.opportunityId = insightObj.Opportunity__c;
        this.insightAlertText = insightObj.Insight_Alert__r.Insights__c;
        this.insightAlertLink = insightObj.Insight_Alert__r.Insights_Link__c;
        this.insightCompetitor = insightObj.Insight_Alert__r.Competitor__c;
        this.insightAlertLinkDisplayLinkAs = insightObj.Insight_Alert__r.Display_Link_As__c;
    }
}