public with sharing class FocusInvestment {
    //Method to create Focus Investment record
    @AuraEnabled
    public static void createFocusInvestmentRec(String inputString, Map<String, Map<String, Boolean>> rfsMap) {
        List<Focus_Investment__c> listFocusInvestment = new List<Focus_Investment__c>();
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        FocusInvestmentWrapper wrapper = (FocusInvestmentWrapper) System.JSON.deserialize(
            inputString,
            FocusInvestmentWrapper.class
        );
        String goldSheetId = wrapper.goldSheet;
        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Focus_Investment__c');
        if (goldSheetId != null) {
            Focus_Investment__c foInv = new Focus_Investment__c();
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
    //Method to read FoP Focus Investment records
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static List<FocusInvestmentWrapper> getFocusInvestmentRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        Boolean isDeletable = false;
        List<Focus_Investment__c> fopFocInvestList = new List<Focus_Investment__c>();
        List<FocusInvestmentWrapper> fieldOfFocInvestWrapperList = new List<FocusInvestmentWrapper>();
        if (Schema.sObjectType.Focus_Investment__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String focInvestQuery;
            if (sortFilter != null && sortFilter != 'DateCreated') {
                if (sortFilter == 'Complete') {
                    focInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Focus_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
                if (sortFilter == 'Incomplete') {
                    focInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Focus_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
            } else {
                focInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Focus_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from Field Of Play Focus Investments section
            fopFocInvestList = DataFactory.read(focInvestQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Focus_Investment__c fInvest : fopFocInvestList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = fInvest.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                FocusInvestmentWrapper wrapper = new FocusInvestmentWrapper(fInvest, isDeletable);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                fieldOfFocInvestWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FieldOfFocInvestException('Error occured while getting data from Focus Investment');
        }
        //return list of wrapper containing all Focus Investment data
        return fieldOfFocInvestWrapperList;
    }

    public class FocusInvestmentInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<FocusInvestmentWrapper> focInvRecords { get; set; }

        public FocusInvestmentInfo(Integer totalRecordCount, List<FocusInvestmentWrapper> focInvRecords) {
            this.totalRecordCount = totalRecordCount;
            this.focInvRecords = focInvRecords;
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static FocusInvestmentInfo getFocInvList(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        return new FocusInvestmentInfo(
            countFocInvRecords(goldSheetId),
            getFocusInvestmentRecords(goldSheetId, queryLimit, queryOffset, sortFilter)
        );
    }

    //Method to count Focus Investment records
    @AuraEnabled
    public static Integer countFocInvRecords(String goldSheetId) {
        return ApexCommonUtil.countOfObjectRecords(goldSheetId, 'Focus_Investment__c', 'Fields_of_Play_Gold_Sheet__c');
    }

    @AuraEnabled(cacheable=true)
    public static String getStatusPicklistValues() {
        return ApexCommonUtil.getPicklistValues('Focus_Investment__c', 'Status__c');
    }

    //Method to get access of Focus Investment oject
    @AuraEnabled
    public static Map<String, Boolean> getFocusInvestmentAccess() {
        return ApexCommonUtil.getObjectAccess('Focus_Investment__c');
    }

    @AuraEnabled
    public static void deleteInvestment(String recordId) {
        ApexCommonUtil.deleteRecord(recordId, 'Focus_Investment__c');
    }

    private class FieldOfFocInvestException extends Exception {
    }
}