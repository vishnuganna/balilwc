@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class ScoreCardOpptyWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String templateId { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public Boolean isActive { get; set; }
    @AuraEnabled
    public Boolean isDefault { get; set; }
    @AuraEnabled
    public decimal totalPoints { get; set; }
    @AuraEnabled
    public decimal businessScore { get; set; }
    @AuraEnabled
    public decimal opportunityScore { get; set; }
    @AuraEnabled
    public decimal potentialScore { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public TemplateCriteria[] templateCriteria { get; set; }

    public scoreCardOpptyWrapper() {
        this.potentialScore = 0;
        this.businessScore = 0;
    }
    public ScoreCardOpptyWrapper(Admin_Score_Card__c adminScore, boolean hasEditAccess) {
        this.templateId = adminScore.id;
        this.name = adminScore.Admin_Scorecard_Name__c;
        this.isActive = adminScore.Is_Active__c;
        this.isDefault = adminScore.Is_Default__c;
        this.totalPoints = adminScore.Total_Points__c;
        this.hasEditAccess = hasEditAccess;
    }
    public ScoreCardOpptyWrapper(Score_Card__c scoreCard, boolean hasEditAccess) {
        this.id = scoreCard.id;
        this.businessScore = scoreCard.BusinessCriteria_Score__c;
        this.opportunityScore = scoreCard.OpportunityCriteria_Score__c;
        this.potentialScore = scoreCard.Potential_Score__c;
        this.name = scoreCard.Name;
        this.totalPoints = scoreCard.Total_Score__c;
        this.hasEditAccess = hasEditAccess;
    }
    public class TemplateCriteria {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String templateCriteriaId { get; set; }
        @AuraEnabled
        public String section { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String criteriaDef { get; set; }
        @AuraEnabled
        public Double pointValue { get; set; }
        @AuraEnabled
        public Double currentScore { get; set; }
        @AuraEnabled
        public String scoreValue { get; set; }
        @AuraEnabled
        public Boolean isOpptySection { get; set; }
    }
}