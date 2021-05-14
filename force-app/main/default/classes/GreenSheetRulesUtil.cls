public with sharing class GreenSheetRulesUtil {
    public static void upsertBestActions(GreenSheetRulesUtil.RuleParams ruleParameter) {
        if (ruleParameter == null) {
            return;
        }
        if (!ruleParameter.listBestActionsToInsert.isEmpty()) {
            DataFactory.upsurt(ruleParameter.listBestActionsToInsert);
        }

        if (!ruleParameter.listBestActionsToUpdate.isEmpty()) {
            DataFactory.modify(ruleParameter.listBestActionsToUpdate);
        }
    }

    @TestVisible
    public class RuleParams {
        public List<KF_Sell_Best__c> allBestActions;
        public List<KF_Sell_Best__c> listBestActionsToInsert;
        public List<KF_Sell_Best__c> listBestActionsToUpdate;
        public Map<String, List<String>> BALandBRIdMap;
        public Map<String, List<AlertRecommendationsWrapper>> mapRuleMSg;
        public List<Business_Rules__c> businessRuleList;
        public map<Id, List<KF_sell_best__c>> allBestActionsMap;
        public Business_Rules__c brObj;

        public RuleParams setBestActionLstToInsert(List<KF_Sell_Best__c> listBestActionsToInsert) {
            this.listBestActionsToInsert = listBestActionsToInsert;
            return this;
        }
        public RuleParams setBestActionLstToUpdate(List<KF_Sell_Best__c> listBestActionsToUpdate) {
            this.listBestActionsToUpdate = listBestActionsToUpdate;
            return this;
        }
        public RuleParams setBestActionList(List<KF_Sell_Best__c> allBestActions) {
            this.allBestActions = allBestActions;
            return this;
        }
        public RuleParams setBusinessRules(List<Business_Rules__c> businessRuleList) {
            this.businessRuleList = businessRuleList;
            return this;
        }
        public RuleParams setBrObj(Business_Rules__c brObj) {
            this.brObj = brObj;
            return this;
        }
        public RuleParams setMapRuleMSg(Map<String, List<AlertRecommendationsWrapper>> mapRuleMSg) {
            this.mapRuleMSg = mapRuleMSg;
            return this;
        }
        public RuleParams setAllBestActionsMap(map<Id, List<KF_sell_best__c>> allBestActionsMap) {
            this.allBestActionsMap = allBestActionsMap;
            return this;
        }
        public RuleParams setBalIdBrIdMap(Map<String, List<String>> BALandBRIdMap) {
            this.BALandBRIdMap = BALandBRIdMap;
            return this;
        }
    }
}