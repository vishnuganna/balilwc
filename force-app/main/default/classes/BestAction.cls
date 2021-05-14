/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-357,main US=KFS-66 : Create/update KFSellBestAction record as per Recommendations record,RecommendationsTrigger
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-June-05
 */
public with sharing class BestAction {
    public static boolean kfSellBestActionInsert = true;
    public static boolean kfSellBestActionUpdate = true;
    public static List<KF_Sell_Best__c> bestActionLstToDelete;

    public static void createUpdateBestAction(List<Recommendations__c> recommLst) {
        Set<String> recommIdSet = new Set<String>();
        for (Recommendations__c recomm : recommLst) {
            recommIdSet.add(recomm.Id);
        }
        Map<String, String> mapRecommIdBAId = getExistingBestActionId(recommIdSet);
        List<KF_Sell_Best__c> bestActionLst = new List<KF_Sell_Best__c>();
        for (Recommendations__c recomm : recommLst) {
            KF_Sell_Best__c bestActionRec = new KF_Sell_Best__c();
            String bestActionRecId = mapRecommIdBAId.get(recomm.Id);
            if (bestActionRecId != null) {
                bestActionRec.Id = bestActionRecId;
            }

            bestActionRec.Manager_Recommended_Action__c = recomm.Manager_Recommended_Action_Message__c;
            bestActionRec.Seller_Recommended_Action__c = recomm.Seller_Recommended_Action_Message__c;
            bestActionRec.Recommendations__c = recomm.Id;
            bestActionRec.Blue_Sheet__c = recomm.Blue_Sheet__c;
            bestActionRec.Opportunity__c = recomm.Opportunity__c;
            bestActionRec.Manager_URL_Text__c = recomm.Manager_URL_Text__c;
            bestActionRec.Manager_URL_Link__c = recomm.Manager_URL_Link__c;
            bestActionRec.Seller_URL_Link__c = recomm.Seller_URL_Link__c;
            bestActionRec.Seller_URL_Text__c = recomm.Seller_URL_Text__c;
            bestActionRec.Action_Title__c = recomm.Action_Title__c;
            bestActionRec.Seller_Email_Text__c = recomm.Seller_Email_Text__c;
            bestActionRec.Associated_Object__c = recomm.Associated_Object__c;

            //lookup
            if (recomm.Action_Plan__c != null) {
                bestActionRec.Action_Plan__c = recomm.Action_Plan__c;
            }
            if (recomm.Buying_Influence__c != null) {
                bestActionRec.Buying_Influence__c = recomm.Buying_Influence__c;
            }
            if (recomm.Competition__c != null) {
                bestActionRec.Competition__c = recomm.Competition__c;
            }
            if (recomm.Current_Position__c != null) {
                bestActionRec.Current_Position__c = recomm.Current_Position__c;
            }
            if (recomm.Score_Card__c != null) {
                bestActionRec.Score_Card__c = recomm.Score_Card__c;
            }

            bestActionLst.add(bestActionRec);
        }

        if (bestActionLst != null && !bestActionLst.isEmpty()) {
            DataFactory.upsurt(bestActionLst);
        }
    }

    // map of RecommedationRecordId,BestActionRecordId
    public static Map<String, String> getExistingBestActionId(Set<String> recommIdSet) {
        Map<String, String> mapRecommIdBAId = new Map<String, String>();
        String soqlBestAction = 'Select Id,Recommendations__c from KF_Sell_Best__c where Recommendations__c=:recommIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('recommIdSet', recommIdSet);
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(soqlBestAction, parameters);
        if (bestActionLst != null && !bestActionLst.isEmpty()) {
            for (KF_Sell_Best__c bestActionObj : bestActionLst) {
                mapRecommIdBAId.put(bestActionObj.Recommendations__c, bestActionObj.Id);
            }
        }
        return mapRecommIdBAId;
    }

    // Get Best action data for widget
    @AuraEnabled
    public static List<BestActionsWrapper> getBestActionList(String oppId) {
        if (
            Schema.sObjectType.Blue_Sheet__c.isCreateable() ||
            Schema.sObjectType.Blue_Sheet__c.isUpdateable() ||
            Schema.sObjectType.Blue_Sheet__c.isAccessible()
        ) {
            String query = 'select id, Action_Title__c, Business_Rules__c, Seller_URL_Link__c, Seller_Recommended_Action__c,Opportunity__c,Associated_Object__c,Alert_Type__c,green_Sheet__c,BestActionRuleId__c from KF_Sell_Best__c where Opportunity__c=:oppId ORDER BY createddate ASC';
            List<KF_Sell_Best__c> relKFSell = new List<KF_Sell_Best__c>();
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            relKFSell = DataFactory.read(query, paramters);
            List<BestActionsWrapper> allWrapData = new List<BestActionsWrapper>();
            for (KF_Sell_Best__c kf : relKFSell) {
                if (kf.Seller_Recommended_Action__c != null && kf.Seller_Recommended_Action__c != '') {
                    BestActionsWrapper wrapdemo = new BestActionsWrapper(
                        ConverStringFromCustomLabels.getStringByLabels(kf, false)
                    );
                    allWrapData.add(wrapdemo);
                }
            }
            return allWrapData;
        } else {
            return null;
        }
    }

    public static void deleteBestActionRecBefore(Map<Id, Recommendations__c> recommMaps) {
        Set<Id> recommIdsSet = new Set<Id>();
        recommIdsSet = recommMaps.keySet();
        String baSoql = 'Select Id from KF_Sell_Best__c Where Recommendations__c =:recommIdsSet';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recommIdsSet', recommIdsSet);
        bestActionLstToDelete = DataFactory.read(baSoql, soqlParamMap);
    }

    // When Recommendation record is deleted, delete related Best Action record
    public static void deleteBestActionRecord() {
        if (bestActionLstToDelete != null && !bestActionLstToDelete.isEmpty()) {
            DataFactory.remove(bestActionLstToDelete);
        }
    }

    @AuraEnabled
    public static String getBlueSheetId(string oppId) {
        String bsID = '';
        Map<Id, Blue_Sheet__c> bsInfoMap = new Map<Id, Blue_Sheet__c>();
        Set<String> opptIdSet = new Set<String>();
        try {
            opptIdSet.add(oppId);
            bsInfoMap = ApexCommonUtil.getBluesheetRecord(opptIdSet);
            if (bsInfoMap != null && !bsInfoMap.isEmpty()) {
                Blue_Sheet__c bs = bsInfoMap.get(oppId);
                bsID = bs.Id;
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return bsID;
    }

    @AuraEnabled
    public static Map<String, Boolean> getBlueSheetAccess() {
        return ApexCommonUtil.getObjectAccess('Blue_Sheet__c');
    }
    @AuraEnabled
    public static Map<String, Boolean> getGreenSheetAccess() {
        return ApexCommonUtil.getObjectAccess('Green_Sheet__c');
    }

    public class BestActionsWrapper {
        @AuraEnabled
        public String actionTitle;
        @AuraEnabled
        public String managerRec;
        @AuraEnabled
        public String recId;
        @AuraEnabled
        public String refresherUrl;
        @AuraEnabled
        public String scrollTo;
        @AuraEnabled
        public Boolean isGreensheetAlert;
        @AuraEnabled
        public String greenSheetId;
        @AuraEnabled
        public boolean isOverviewTabAction = false;

        public BestActionsWrapper(KF_Sell_Best__c kfRec) {
            this.actionTitle = kfRec.Action_Title__c;
            this.managerRec = kfRec.Seller_Recommended_Action__c;
            this.recId = kfRec.Id;
            this.refresherUrl = kfRec.Seller_URL_Link__c;
            if (kfRec.BestActionRuleId__c == 'BAL_4' || kfRec.BestActionRuleId__c == 'BAL_5') {
                this.isOverviewTabAction = true;
            }
            if (kfRec.Associated_Object__c == 'Action Plan') {
                this.scrollTo = 'anchor_actionPlanCallDetails';
            } else if (kfRec.Associated_Object__c == 'Buying Influence') {
                this.scrollTo = 'anchor_buyingInfluenceCallDetails';
            } else if (kfRec.Associated_Object__c == 'Competition') {
                this.scrollTo = 'anchor_competitionCallDetails';
            } else if (kfRec.Associated_Object__c == 'Current Position') {
                this.scrollTo = 'anchor_cpCallDetails';
            } else if (kfRec.Associated_Object__c == 'Scorecard') {
                this.scrollTo = 'anchor_scoreCardCallDetails';
            } else {
                this.scrollTo = '';
            }
            this.greenSheetId = kfRec.Green_Sheet__c;
            if (kfRec.Alert_Type__c == 'Greensheet') {
                this.isGreensheetAlert = true;
            } else {
                this.isGreensheetAlert = false;
            }
        }

        public BestActionsWrapper(KFSellBestHelperWrapper kfRec) {
            this.actionTitle = kfRec.actionTitle;
            this.managerRec = kfRec.sellerRecommendedAction;
            this.recId = kfRec.id;
            this.refresherUrl = kfRec.sellerURLLink;
            if (
                kfRec.sellerRecommendedAction == System.Label.BAL_4_SellerRecommendedAction ||
                kfRec.sellerRecommendedAction == System.Label.BAL_5_SellerRecommendedAction
            ) {
                this.isOverviewTabAction = true;
            }
            if (kfRec.associatedObject == 'Action Plan') {
                this.scrollTo = 'anchor_actionPlanCallDetails';
            } else if (kfRec.associatedObject == 'Buying Influence') {
                this.scrollTo = 'anchor_buyingInfluenceCallDetails';
            } else if (kfRec.associatedObject == 'Competition') {
                this.scrollTo = 'anchor_competitionCallDetails';
            } else if (kfRec.associatedObject == 'Current Position') {
                this.scrollTo = 'anchor_cpCallDetails';
            } else if (kfRec.associatedObject == 'Scorecard') {
                this.scrollTo = 'anchor_scoreCardCallDetails';
            } else {
                this.scrollTo = '';
            }
            this.greenSheetId = kfRec.greenSheet;
            if (kfRec.alertType == 'Greensheet') {
                this.isGreensheetAlert = true;
            } else {
                this.isGreensheetAlert = false;
            }
        }
    }
}