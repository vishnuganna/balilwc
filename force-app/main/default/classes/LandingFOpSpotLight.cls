public with sharing class LandingFOpSpotLight {
    public class FOPSpotLightRecordsInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<FOPSpotLightReportWrapper> fopSpotLightRecords { get; set; }

        public FOPSpotLightRecordsInfo(Integer totalRecordCount, List<FOPSpotLightReportWrapper> fopSpotLightRecords) {
            this.totalRecordCount = totalRecordCount;
            this.fopSpotLightRecords = fopSpotLightRecords;
        }
    }

    @AuraEnabled
    public static FOPSpotLightRecordsInfo getFOpSpotLightRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new FOPSpotLightRecordsInfo(
            countFOpSpotLightRecordsData(userIdSet),
            getFOpSpotLightRecordsData(userIdSet, queryLimit, queryOffset)
        );
    }

    @AuraEnabled
    public static Integer countFOpSpotLightRecordsData(List<String> userIdSet) {
        Integer fopCount = 0;
        String query = 'SELECT COUNT()' + ' FROM Gold_Sheet__c WHERE OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        fopCount = DataFactory.countQuery(query, paramters);
        return fopCount;
    }

    @AuraEnabled
    public static List<FOPSpotLightReportWrapper> getFOpSpotLightRecordsData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<FOPSpotLightReportWrapper> landingSOPSpotLightReportToReturn = new List<FOPSpotLightReportWrapper>();
        Map<String, List<Object>> mapgoldSheetFopSpotlight = new Map<String, List<Object>>();
        try {
            //Query Gold Sheet object to get the corresponding fields
            String query =
                'SELECT Id,FOP_Name__c,FOP_This_Year__c,Owner__c,CreatedDate,Goals_Completed__c,Goals_Incomplete__c,Count_FOP_Opportunity__c,' +
                'High_Target_Current_Year__c,Low_Target_Current_Year__c, Realistic_Target_Current_Year__c,Owner.Name,' +
                'Strategic_Player_Antisponsor__c,Strategic_Player_Coach__c,Strategic_Player_Key_Player__c,Strategic_Player_Sponsor__c' +
                ' FROM Gold_Sheet__c WHERE OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userIdSet', userIdSet);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            List<Gold_Sheet__c> listGoldSheet = DataFactory.read(query, paramters);
            if (!listGoldSheet.isEmpty()) {
                for (Gold_Sheet__c gs : listGoldSheet) {
                    FOPSpotLightReportWrapper gsWrapper = new FOPSpotLightReportWrapper(gs);
                    landingSOPSpotLightReportToReturn.add(gsWrapper);
                }
            }
        } catch (Exception ex) {
            throw new LandingFOpSpotLightException('Error occured while getting FOP SpotLight record');
        }

        return landingSOPSpotLightReportToReturn;
    }
    private class LandingFOpSpotLightException extends Exception {
    }
}