public with sharing class LandingMilestones {
    public class LandingMilestoneRecordsInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<FOPSpotLightReportWrapper> milestoneRecords { get; set; }

        public LandingMilestoneRecordsInfo(Integer totalRecordCount, List<FOPSpotLightReportWrapper> milestoneRecords) {
            this.totalRecordCount = totalRecordCount;
            this.milestoneRecords = milestoneRecords;
        }
    }
    @AuraEnabled
    public static LandingMilestoneRecordsInfo getFOpMilestoneRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingMilestoneRecordsInfo(
            countFOpSpotLightRecordsData(userIdSet),
            getFOpMilestoneRecordsData(userIdSet, queryLimit, queryOffset)
        );
    }

    @AuraEnabled
    public static Integer countFOpSpotLightRecordsData(List<String> userIdSet) {
        Integer milestoneCount = 0;
        Date futureDate = Date.today().addDays(30);
        Date todayDate = Date.today();
        String query =
            'SELECT COUNT()' +
            ' FROM Milestone__c WHERE (Meeting_Date__c >=:todayDate and Meeting_Date__c <=:futureDate) AND Gold_Sheet__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        paramters.put('todayDate', todayDate);
        paramters.put('futureDate', futureDate);
        milestoneCount = DataFactory.countQuery(query, paramters);
        return milestoneCount;
    }

    @AuraEnabled
    public static List<FOPSpotLightReportWrapper> getFOpMilestoneRecordsData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<FOPSpotLightReportWrapper> landingMilestoneReport = new List<FOPSpotLightReportWrapper>();
        Date futureDate = Date.today().addDays(30);
        Date todayDate = Date.today();
        try {
            String qry =
                'SELECT Gold_Sheet__r.FOP_Name__c,Milestone_Number__c,Name ,Meeting_Date__c,Gold_Sheet__r.Owner__c,Milestone_Name__c, Gold_Sheet__r.OwnerId,Gold_Sheet__r.Owner.Name  FROM Milestone__c' +
                ' where (Meeting_Date__c >=:todayDate and Meeting_Date__c <=:futureDate) AND Gold_Sheet__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('todayDate', todayDate);
            paramters.put('futureDate', futureDate);
            paramters.put('userIdSet', userIdSet);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            List<Milestone__c> listMilestone = DataFactory.read(qry, paramters);
            if (!listMilestone.isEmpty()) {
                for (Milestone__c ml : listMilestone) {
                    FOPSpotLightReportWrapper gsWrapper = new FOPSpotLightReportWrapper(ml);
                    landingMilestoneReport.add(gsWrapper);
                }
            }
        } catch (Exception ex) {
            throw new LandingMilestonesException('Error occured while getting FOP SpotLight record');
        }
        return landingMilestoneReport;
    }
    private class LandingMilestonesException extends Exception {
    }
}