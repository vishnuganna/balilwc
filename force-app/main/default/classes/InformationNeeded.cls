@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class InformationNeeded {
    //Method to Create and Update Information Needed Records
    @AuraEnabled
    public static void createInformationNeededRec(String informationNeededDataString) {
        List<Information_Needed__c> listInformationNeeded = new List<Information_Needed__c>();
        InformationNeededWrapper wrapper = (InformationNeededWrapper) System.JSON.deserialize(
            informationNeededDataString,
            InformationNeededWrapper.class
        );
        String goldSheetId = wrapper.goldSheet;
        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Information_Needed__c');
        if (goldSheetId != null) {
            Information_Needed__c informationNeeded = new Information_Needed__c();
            if (wrapper.id != null) {
                informationNeeded.Id = wrapper.id;
            }
            informationNeeded.Fields_of_Play_Gold_Sheet__c = goldsheetId;
            informationNeeded.Information_Needed_Title__c = wrapper.gsInformationNeededTitle;
            informationNeeded.Source__c = wrapper.gsInformationNeededSource;
            informationNeeded.Assigned_To__c = wrapper.gsInformationNeededAssignedTo;
            informationNeeded.Status__c = wrapper.gsInformationNeededStatus;
            informationNeeded.Description__c = wrapper.gsInformationNeededDescription;
            informationNeeded.Due_Date__c = wrapper.gsInformationNeededDueDate;

            listInformationNeeded.add(informationNeeded);
        }
        DataFactory.upsurt(listInformationNeeded);
    }

    //Method to GET Records from Information Needed Tab in Gold Sheet
    @AuraEnabled
    public static List<InformationNeededWrapper> getInformationNeededRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        Boolean isDeletable = false;
        List<Information_Needed__c> informationNeededList = new List<Information_Needed__c>();
        List<InformationNeededWrapper> informationNeededWrapperList = new List<InformationNeededWrapper>();
        if (Schema.sObjectType.Information_Needed__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String informationNeededQuery;
            if (sortFilter != null && sortFilter != 'DateCreated') {
                if (sortFilter == 'Complete') {
                    informationNeededQuery = 'Select Id, Name, Information_Needed_Title__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
                if (sortFilter == 'Incomplete') {
                    informationNeededQuery = 'Select Id, Name, Information_Needed_Title__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
            } else {
                informationNeededQuery = 'Select Id, Name, Information_Needed_Title__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from Information Needed section
            informationNeededList = DataFactory.read(informationNeededQuery, paramters);
            //Iterate through list to get list of wrapper to return to UI
            for (Information_Needed__c gsInformationNeeds : informationNeededList) {
                String sourceId = gsInformationNeeds.Id;
                InformationNeededWrapper wrapper = new InformationNeededWrapper(gsInformationNeeds, isDeletable);
                informationNeededWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new InformationNeededException('Error occured while getting data from InInformation Needed');
        }
        //Return list of wrapper containing all Information Needed data
        return informationNeededWrapperList;
    }

    // Method to Delete Information Needed Record
    @AuraEnabled
    public static void deleteInformationNeededRecord(String recordId) {
        ApexCommonUtil.deleteRecord(recordId, 'Information_Needed__c');
    }

    @AuraEnabled(cacheable=true)
    public static String getStatusPicklistValues() {
        return ApexCommonUtil.getPicklistValues('Information_Needed__c', 'Status__c');
    }

    /* get required objects fro lookup component */
    @AuraEnabled
    public static WrapperLookupObject getLookupObjects() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        String apiName = 'Information_Needed__c';
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace(apiName);
        apiName = 'Assigned_To__c';
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace(apiName);
        return wrapper;
    }

    public class InformationNeededInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<InformationNeededWrapper> inInformationNeededRecords { get; set; }

        public InformationNeededInfo(
            Integer totalRecordCount,
            List<InformationNeededWrapper> inInformationNeededRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.inInformationNeededRecords = inInformationNeededRecords;
        }
    }

    @AuraEnabled
    public static InformationNeededInfo getInformationNeededList(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        return new InformationNeededInfo(
            countInformationneededRecords(goldSheetId),
            getInformationNeededRecords(goldSheetId, queryLimit, queryOffset, sortFilter)
        );
    }

    @AuraEnabled
    public static Integer countInformationneededRecords(String goldSheetId) {
        return ApexCommonUtil.countOfObjectRecords(
            goldSheetId,
            'Information_Needed__c',
            'Fields_of_Play_Gold_Sheet__c'
        );
    }

    //Method to get access of Information Needed oject
    @AuraEnabled
    public static Map<String, Boolean> getInformationNeededAccess() {
        return ApexCommonUtil.getObjectAccess('Information_Needed__c');
    }

    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    private class InformationNeededException extends Exception {
    }
}