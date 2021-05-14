public with sharing class LandingKFSActions {
    public class LandingKFSActionsRecordsInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<LandingKFSellActionsWrapper> recommendationRecords { get; set; }

        public LandingKFSActionsRecordsInfo(
            Integer totalRecordCount,
            List<LandingKFSellActionsWrapper> recommendationRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.recommendationRecords = recommendationRecords;
        }
    }

    @AuraEnabled
    public static LandingKFSActionsRecordsInfo getRecommendationRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingKFSActionsRecordsInfo(
            countRecommendationRecordsData(userIdSet),
            getRecommendationRecordsData(userIdSet, queryLimit, queryOffset)
        );
    }
    @AuraEnabled
    public static Integer countRecommendationRecordsData(List<String> userIdSet) {
        Integer recommCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM KF_Sell_Best__c  USING SCOPE team WHERE Completed__c = false AND Opportunity__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        recommCount = DataFactory.countQuery(query, paramters);
        system.System.debug('data count ----' + recommCount);
        return recommCount;
    }
    @AuraEnabled
    public static List<LandingKFSellActionsWrapper> getRecommendationRecordsData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<LandingKFSellActionsWrapper> recommWrapperListToReturn = new List<LandingKFSellActionsWrapper>();
        try {
            String query = 'SELECT Id, Name, Action_Title__c, Completed__c, Opportunity__r.Name, Opportunity__r.IsClosed, Opportunity__r.Id, Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName FROM KF_Sell_Best__c USING SCOPE team WHERE Completed__c = false AND Opportunity__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> params = new Map<String, Object>();
            params.put('userIdSet', userIdSet);
            params.put('queryLimit', queryLimit);
            params.put('queryOffset', queryOffset);
            List<KF_Sell_Best__c> recommendationsList = DataFactory.read(query, params);
            for (KF_Sell_Best__c recomm : recommendationsList) {
                LandingKFSellActionsWrapper wrapperObj = new LandingKFSellActionsWrapper(recomm);
                recommWrapperListToReturn.add(wrapperObj);
            }
        } catch (Exception ex) {
            throw new LandingKFSActionsException('Error occured while getting Recommendations record');
        }
        return recommWrapperListToReturn;
    }
    private class LandingKFSActionsException extends Exception {
    }
}