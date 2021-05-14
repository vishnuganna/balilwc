@SuppressWarnings('PMD.TooManyFields, PMD.ExcessivePublicCount')
public with sharing class RulesEngineConfig {
    public enum Scope {
        BI,
        OPP,
        SCORECARD,
        GREENSHEET,
        BLUESHEET,
        COMPETITOR,
        ACTIONPLAN
    }
    public static final Map<Scope, RulesEvaluator> Evaluator = new Map<Scope, RulesEvaluator>{
        Scope.BI => new BuyingInfluenceEvaluator(),
        Scope.SCORECARD => new ScoreCardRulesEvaluator(),
        Scope.OPP => new OpportunityRulesEvaluator(),
        Scope.BLUESHEET => new BluesheetRulesEvaluator(),
        Scope.GREENSHEET => new MeetingPlanRulesEvaluator(),
        Scope.COMPETITOR => new CompetitorRulesEvaluator(),
        Scope.ACTIONPLAN => new ActionPlanRulesEvaluator()
    };
    @TestVisible
    public class RuleParams {
        public List<KF_Sell_Best__c> allBestActions;
        public List<KF_Sell_Best__c> listBestActionsToInsert;
        public List<KF_Sell_Best__c> listBestActionsToUpdate;
        public Map<String, String> bsOppMap;
        public Set<String> applicableStages;
        public Map<String, List<AlertRecommendationsWrapper>> mapRuleMSg;
        public Map<String, List<Business_Rules__c>> businessRuleMap;
        public map<Id, List<KF_sell_best__c>> allBestActionsMap;
        public Map<Id, Opportunity> oppsMap;
        public Blue_Sheet__c blueSheet;
        public Opportunity opportunity;
        public List<Insight__c> listInsightsToInsert;
        public List<Insight__c> listInsightsToUpdate;
        public Map<String, String> brCompIdMap;
        public Map<String, Insight_Alert__c> brInsightAlertMap;
        public Map<Id, List<Insight__c>> allInsightsMap;
        public List<Insight__c> insightsList;
        public Map<String, List<String>> BALandBRIdMap;
        public Business_Rules__c brObj;

        public RuleParams setBrObj(Business_Rules__c brObj) {
            this.brObj = brObj;
            return this;
        }
        public RuleParams setOpportunityMap(Map<Id, Opportunity> oppsMap) {
            this.oppsMap = oppsMap;
            return this;
        }
        public RuleParams setBlueSheetRec(Blue_Sheet__c blueSheet) {
            this.blueSheet = blueSheet;
            return this;
        }

        public RuleParams setOpportunityRec(Opportunity opportunity) {
            this.opportunity = opportunity;
            return this;
        }
        public RuleParams setBSOppMap(Map<String, String> bsOppMap) {
            this.bsOppMap = bsOppMap;
            return this;
        }
        public RuleParams setBestActionLstToInsert(List<KF_Sell_Best__c> listBestActionsToInsert) {
            this.listBestActionsToInsert = listBestActionsToInsert;
            return this;
        }
        public RuleParams setBestActionLstToUpdate(List<KF_Sell_Best__c> listBestActionsToUpdate) {
            this.listBestActionsToUpdate = listBestActionsToUpdate;
            return this;
        }
        public RuleParams setApplicableStages(Set<String> applicableStages) {
            this.applicableStages = applicableStages;
            return this;
        }
        public RuleParams setMapRuleMSg(Map<String, List<AlertRecommendationsWrapper>> mapRuleMSg) {
            this.mapRuleMSg = mapRuleMSg;
            return this;
        }
        public RuleParams setBestActionList(List<KF_Sell_Best__c> allBestActions) {
            this.allBestActions = allBestActions;
            return this;
        }
        public RuleParams setBusinessRules(Map<String, List<Business_Rules__c>> businessRuleMap) {
            this.businessRuleMap = businessRuleMap;
            return this;
        }
        public RuleParams setAllBestActionsMap(map<Id, List<KF_sell_best__c>> allBestActionsMap) {
            this.allBestActionsMap = allBestActionsMap;
            return this;
        }
        public RuleParams setInsightsLstToInsert(List<Insight__c> listInsightsToInsert) {
            this.listInsightsToInsert = listInsightsToInsert;
            return this;
        }
        public RuleParams setInsightsLstToUpdate(List<Insight__c> listInsightsToUpdate) {
            this.listInsightsToUpdate = listInsightsToUpdate;
            return this;
        }
        public RuleParams setBRCompIdMap(Map<String, String> brCompIdMap) {
            this.brCompIdMap = brCompIdMap;
            return this;
        }
        public RuleParams setInsightAlertBRMap(Map<String, Insight_Alert__c> brInsightAlertMap) {
            this.brInsightAlertMap = brInsightAlertMap;
            return this;
        }
        public RuleParams setallInsightsMap(Map<Id, List<Insight__c>> allInsightsMap) {
            this.allInsightsMap = allInsightsMap;
            return this;
        }
        public RuleParams setInsightsList(List<Insight__c> insightsList) {
            this.insightsList = insightsList;
            return this;
        }
        public RuleParams setBalIdBrIdMap(Map<String, List<String>> BALandBRIdMap) {
            this.BALandBRIdMap = BALandBRIdMap;
            return this;
        }
    }
}