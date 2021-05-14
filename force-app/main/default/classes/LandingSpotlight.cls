public with sharing class LandingSpotlight {
    public class LandingSpotlightInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<LandingPageBlueSheetWrapper> blueSheetRecords { get; set; }

        public LandingSpotlightInfo(Integer totalRecordCount, List<LandingPageBlueSheetWrapper> blueSheetRecords) {
            this.totalRecordCount = totalRecordCount;
            this.blueSheetRecords = blueSheetRecords;
        }
    }
    @AuraEnabled
    public static LandingSpotlightInfo getBlueSheetRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingSpotlightInfo(
            countBluesheetRecords(userIdSet),
            getBlueSheetRecordData(userIdSet, queryLimit, queryOffset)
        );
    }
    @AuraEnabled
    public static Integer countBluesheetRecords(List<String> userIdSet) {
        Integer bluesheetCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM Blue_Sheet__c WHERE Opportunity__r.IsClosed = false AND Opportunity__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        bluesheetCount = DataFactory.countQuery(query, paramters);
        return bluesheetCount;
    }

    @AuraEnabled
    public static List<LandingPageBlueSheetWrapper> getBlueSheetRecordData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<LandingPageBlueSheetWrapper> bsWrapperListToReturn = new List<LandingPageBlueSheetWrapper>();
        try {
            String query =
                'SELECT Id, Name, Current_Position__c, Customer_Timing_for_Priorities__c, LastModifiedDate, Scorecard_Total__c,' +
                ' Best_Action_Count__c, UBI_Count__c, EBI_Count__c, TBI_Count__c, Coach_Count__c, BI_Total__c, Opportunity__r.CloseDate,' +
                ' Opportunity__r.Amount, Opportunity__r.StageName, Opportunity__r.Name, Opportunity__r.IsClosed, Opportunity__r.Id,' +
                ' Opportunity__r.Owner.FirstName, Opportunity__r.Owner.LastName FROM Blue_Sheet__c WHERE Opportunity__r.IsClosed = false AND Opportunity__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> params = new Map<String, Object>();
            params.put('userIdSet', userIdSet);
            params.put('queryLimit', queryLimit);
            params.put('queryOffset', queryOffset);
            List<Blue_Sheet__c> blueSheetList = DataFactory.read(query, params);
            for (Blue_Sheet__c bsObj : blueSheetList) {
                LandingPageBlueSheetWrapper wrapperObj = new LandingPageBlueSheetWrapper(bsObj);
                bsWrapperListToReturn.add(wrapperObj);
            }
        } catch (Exception ex) {
            throw new LandingSpotlightException('Error occured while getting Blue Sheet record');
        }
        //
        return bsWrapperListToReturn;
    }
    private class LandingSpotlightException extends Exception {
    }
}