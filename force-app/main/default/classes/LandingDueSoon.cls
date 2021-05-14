public with sharing class LandingDueSoon {
    public class LandingDueSoonRecordsInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<LandingPageActionPlanWrapper> kfsellLandingRecords { get; set; }

        public LandingDueSoonRecordsInfo(
            Integer totalRecordCount,
            List<LandingPageActionPlanWrapper> kfsellLandingRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.kfsellLandingRecords = kfsellLandingRecords;
        }
    }
    @AuraEnabled
    public static LandingDueSoonRecordsInfo getActionPlanRecord(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingDueSoonRecordsInfo(
            countKfsellRecordsData(userIdSet),
            getActionPlanRecordData(userIdSet, queryLimit, queryOffset)
        );
    }
    @AuraEnabled
    public static Integer countKfsellRecordsData(List<String> userIdSet) {
        Integer kfsellCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM Action_Plan__c USING SCOPE team WHERE Is_a_Best_Action__c = true AND Due_Date__c = NEXT_N_DAYS:10 AND Blue_Sheet__r.Opportunity__r.IsClosed = false AND Blue_Sheet__r.Opportunity__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        kfsellCount = DataFactory.countQuery(query, paramters);
        return kfsellCount;
    }
    @AuraEnabled
    public static List<LandingPageActionPlanWrapper> getActionPlanRecordData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<LandingPageActionPlanWrapper> apWrapperListToReturn = new List<LandingPageActionPlanWrapper>();
        try {
            String query = 'SELECT Id, Name, Is_a_Best_Action__c, Due_Date__c, Summary__c, Blue_Sheet__r.Opportunity__r.Name, Blue_Sheet__r.Opportunity__r.IsClosed, Blue_Sheet__r.Opportunity__r.Id, Blue_Sheet__r.Opportunity__r.Owner.FirstName, Blue_Sheet__r.Opportunity__r.Owner.LastName FROM Action_Plan__c USING SCOPE team WHERE Is_a_Best_Action__c = true AND Due_Date__c = NEXT_N_DAYS:10 AND Blue_Sheet__r.Opportunity__r.IsClosed = false AND Blue_Sheet__r.Opportunity__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> params = new Map<String, Object>();
            params.put('userIdSet', userIdSet);
            params.put('queryLimit', queryLimit);
            params.put('queryOffset', queryOffset);
            List<Action_Plan__c> actionPlanList = DataFactory.read(query, params);
            for (Action_Plan__c actionPlanObj : actionPlanList) {
                LandingPageActionPlanWrapper wrapperObj = new LandingPageActionPlanWrapper(actionPlanObj);
                apWrapperListToReturn.add(wrapperObj);
            }
        } catch (Exception ex) {
            throw new LandingDueSoonException('Error occured while getting Action Plan record');
        }
        return apWrapperListToReturn;
    }
    private class LandingDueSoonException extends Exception {
    }
}