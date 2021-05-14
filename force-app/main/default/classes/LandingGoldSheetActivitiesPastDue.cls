public with sharing class LandingGoldSheetActivitiesPastDue {
    public class LandingGoldSheetActivitiesPastDueInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<LandingFOPActivitiesWrapper> activityRecords { get; set; }

        public LandingGoldSheetActivitiesPastDueInfo(
            Integer totalRecordCount,
            List<LandingFOPActivitiesWrapper> activityRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.activityRecords = activityRecords;
        }
    }
    @AuraEnabled
    public static LandingGoldSheetActivitiesPastDueInfo getFoPActivityRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingGoldSheetActivitiesPastDueInfo(
            countGoldSheetActivitiesPastDueData(userIdSet),
            getFoPActivityRecordData(userIdSet, queryLimit, queryOffset)
        );
    }
    @AuraEnabled
    public static Integer countGoldSheetActivitiesPastDueData(List<String> userIdSet) {
        Integer milestoneCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM KF_Sell_Best__c WHERE Alert_Type__c = \'Gold_Sheet_Activities_Past_Due\' AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        milestoneCount = DataFactory.countQuery(query, paramters);
        return milestoneCount;
    }
    @AuraEnabled
    public static List<LandingFOPActivitiesWrapper> getFoPActivityRecordData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<LandingFOPActivitiesWrapper> activityListToReturn = new List<LandingFOPActivitiesWrapper>();
        try {
            String query = 'SELECT Id, Name, Activity_Title__c, Associated_Object__c, Activity_Due_Date__c, Fields_of_Play_Gold_Sheet__c, Fields_of_Play_Gold_Sheet__r.FOP_Name__c,Fields_of_Play_Gold_Sheet__r.Owner.Name, Fields_of_Play_Gold_Sheet__r.Id, Fields_of_Play_Gold_Sheet__r.Account__r.Name, Gold_Sheet_AccountOwner__c, Fields_of_Play_Gold_Sheet__r.OwnerId, Gold_Sheet_Action__r.Action_Title__c, Gold_Sheet_InfoNeeded__r.Information_Needed_Title__c, Gold_Sheet_Investment_Program__r.Investment_Program_Title__c, Fields_of_Play_Gold_Sheet__r.Account__r.Id  FROM KF_Sell_Best__c WHERE Alert_Type__c = \'Gold_Sheet_Activities_Past_Due\' AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset ';
            Map<String, Object> params = new Map<String, Object>();
            params.put('userIdSet', userIdSet);
            params.put('queryLimit', queryLimit);
            params.put('queryOffset', queryOffset);
            List<KF_Sell_Best__c> fopList = DataFactory.read(query, params);
            for (KF_Sell_Best__c sheet : fopList) {
                LandingFOPActivitiesWrapper wrapperObj = new LandingFOPActivitiesWrapper(sheet);
                activityListToReturn.add(wrapperObj);
                //activityListToReturn = GoldSheetLandingPageAction.getActivityTitle(fopList);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new LandingGoldSheetActivitiesPastDueException('Error occured while getting Field of Play record');
        }
        return activityListToReturn;
    }
    private class LandingGoldSheetActivitiesPastDueException extends Exception {
    }
}