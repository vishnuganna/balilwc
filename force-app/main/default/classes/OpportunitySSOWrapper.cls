//Wrapper class used in Green sheet for Opportunity and related SSO
public with sharing class OpportunitySSOWrapper {
    @AuraEnabled
    public Decimal oppRevenue { get; set; }
    @AuraEnabled
    public String oppStage { get; set; }
    @AuraEnabled
    public Date oppCloseDate { get; set; }
    @AuraEnabled
    public GreenSheetSSOWrapper gsSSOWrapper { get; set; }

    public OpportunitySSOWrapper(Opportunity opp) {
        this.oppRevenue = opp.Amount;
        /*if (opp.Amount != null && opp.Probability != null) {
            this.oppRevenue = (opp.Amount * opp.Probability) / 100;
        }*/
        this.oppStage = opp.StageName;
        this.oppCloseDate = opp.CloseDate;
    }

    public with sharing class GreenSheetSSOWrapper {
        @AuraEnabled
        public String custTimingPriorities { get; set; }
        @AuraEnabled
        public String customerStatedObjective { get; set; }
        @AuraEnabled
        public String evaluationOfObjectives { get; set; }

        public GreenSheetSSOWrapper(Single_Sales_Objective__c sso) {
            this.custTimingPriorities = sso.Customer_Timing_for_Priorities__c;
            this.customerStatedObjective = sso.Customers_Stated_Objectives__c;
            this.evaluationOfObjectives = sso.Evaluation_of_Objectives__c;
        }
    }
}