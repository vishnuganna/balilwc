@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class StopInvestmentController {
    //Method to create Stop Investment record
    @AuraEnabled
    public static void createStopInvestmentRec(String inputString, Map<String, Map<String, Boolean>> rfsMap) {
        List<Stop_Investment__c> listFocusInvestment = new List<Stop_Investment__c>();
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        StopInvestmentWrapper wrapper = (StopInvestmentWrapper) System.JSON.deserialize(
            inputString,
            StopInvestmentWrapper.class
        );
        String goldSheetId = wrapper.goldSheet;
        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Stop_Investment__c');
        if (goldSheetId != null) {
            Stop_Investment__c foInv = new Stop_Investment__c();
            if (wrapper.id != null) {
                foInv.Id = wrapper.id;
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    foInv.Id,
                    goldSheetId,
                    rfsMap
                );
            } else {
                markerList = RedFlagStrengthData.createRFSrecords(goldsheetId, objectApiName, rfsMap);
            }
            foInv.Fields_of_Play_Gold_Sheet__c = goldsheetId;
            foInv.Investment_Title__c = wrapper.foiInvestmentTitle;
            foInv.Amount__c = wrapper.foiAmount;
            foInv.Status__c = wrapper.foiStatus;
            foInv.Description__c = wrapper.foiDescription;
            listFocusInvestment.add(foInv);
        }
        List<Database.UpsertResult> srList = DataFactory.upsurt(listFocusInvestment);
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess() && !markerList.isEmpty()) {
                DataFactory.create(markerList);
            }
        }
        List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c marker : markerList) {
            marker.Source_ID__c = srList[0].getId();
            markerListUpdated.add(marker);
        }
        DataFactory.modify(markerListUpdated);
    }
    //Method to read FoP Stop Investment records
    @AuraEnabled
    public static List<StopInvestmentWrapper> getStopInvestmentRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        Boolean isDeletable = false;
        List<Stop_Investment__c> fopFocInvestList = new List<Stop_Investment__c>();
        List<StopInvestmentWrapper> fieldOfFocInvestWrapperList = new List<StopInvestmentWrapper>();
        if (Schema.sObjectType.Stop_Investment__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String stopInvestQuery;
            if (sortFilter != null && sortFilter != 'DateCreated') {
                if (sortFilter == 'Complete') {
                    stopInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Stop_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
                if (sortFilter == 'Incomplete') {
                    stopInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Stop_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
            } else {
                stopInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Stop_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from Field Of Play Stop Investments section
            fopFocInvestList = DataFactory.read(stopInvestQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Stop_Investment__c fInvest : fopFocInvestList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = fInvest.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                StopInvestmentWrapper wrapper = new StopInvestmentWrapper(fInvest, isDeletable);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                fieldOfFocInvestWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FieldOfFocInvestException('Error occured while getting data from Stop Investment');
        }
        //return list of wrapper containing all Stop Investment data
        return fieldOfFocInvestWrapperList;
    }

    public class StopInvestmentInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<StopInvestmentWrapper> focInvRecords { get; set; }

        public StopInvestmentInfo(Integer totalRecordCount, List<StopInvestmentWrapper> focInvRecords) {
            this.totalRecordCount = totalRecordCount;
            this.focInvRecords = focInvRecords;
        }
    }

    @AuraEnabled
    public static StopInvestmentInfo getStopInvList(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        return new StopInvestmentInfo(
            countStopInvRecords(goldSheetId),
            getStopInvestmentRecords(goldSheetId, queryLimit, queryOffset, sortFilter)
        );
    }

    //Method to count Stop Investment records
    @AuraEnabled
    public static Integer countStopInvRecords(String goldSheetId) {
        return ApexCommonUtil.countOfObjectRecords(goldSheetId, 'Stop_Investment__c', 'Fields_of_Play_Gold_Sheet__c');
    }

    @AuraEnabled(cacheable=true)
    public static String getStatusPicklistValues() {
        return ApexCommonUtil.getPicklistValues('Stop_Investment__c', 'Status__c');
    }

    //Method to get access of Stop Investment oject
    @AuraEnabled
    public static Map<String, Boolean> getStopInvestmentAccess() {
        return ApexCommonUtil.getObjectAccess('Stop_Investment__c');
    }

    @AuraEnabled
    public static void deleteInvestment(String recordId) {
        ApexCommonUtil.deleteRecord(recordId, 'Stop_Investment__c');
    }

    private class FieldOfFocInvestException extends Exception {
    }
}