@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class OpportunityWithScorecardWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String optyName { get; set; }
    @AuraEnabled
    public String opportunityStage { get; set; }
    @AuraEnabled
    public Integer countOptyPerStage { get; set; }
    @AuraEnabled
    public Decimal optyRevenuePerStage { get; set; }
    @AuraEnabled
    public Decimal opportunityAmount { get; set; }
    @AuraEnabled
    public Decimal opportunityRevenue { get; set; }
    @AuraEnabled
    public Decimal opportunityRadius { get; set; }
    @AuraEnabled
    public Decimal scorecardTotalScore { get; set; }
    @AuraEnabled
    public ScorecardWrapper scorecard { get; set; }
    @AuraEnabled
    public List<String> optyStages { get; set; }
    @AuraEnabled
    public String daysInStage { get; set; }
    @AuraEnabled
    public boolean isConnectedToBluesheet { get; set; }

    public OpportunityWithScorecardWrapper(Opportunity opty) {
        this.id = opty.Id;
        this.optyName = opty.Name;
        this.opportunityAmount = opty.Amount;
        this.opportunityStage = opty.StageName;
        if (this.opportunityAmount == null || this.opportunityAmount == 0.0) {
            this.opportunityRevenue = 0.0;
            this.opportunityRadius = 3.0;
        } else {
            this.opportunityRevenue = (this.opportunityAmount * opty.Probability) / 100;
        }
    }

    public class ScorecardWrapper {
        @AuraEnabled
        public String cardId { get; set; }
        @AuraEnabled
        public String cardName { get; set; }
        @AuraEnabled
        public Decimal totalScore { get; set; }
        @AuraEnabled
        public Decimal businessScore { get; set; }
        @AuraEnabled
        public Decimal opportunityScore { get; set; }
        @AuraEnabled
        public Decimal potentialScore { get; set; }

        public ScorecardWrapper(Score_Card__c sc) {
            this.cardId = sc.Id;
            this.cardName = sc.Name;
            this.businessScore = sc.BusinessCriteria_Score__c;
            this.opportunityScore = sc.OpportunityCriteria_Score__c;
            this.potentialScore = sc.Potential_Score__c;
            this.totalScore = sc.Total_Score__c;
        }
    }
}