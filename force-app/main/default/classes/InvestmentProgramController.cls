@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class InvestmentProgramController {
    //Method to Create and Update ActionPlanActivities Actions Records
    @AuraEnabled
    public static void createInvProgramsRec(String inputString) {
        List<Investment_Program__c> listActions = new List<Investment_Program__c>();
        InvestmentProgramControllerWrapper wrapper = (InvestmentProgramControllerWrapper) System.JSON.deserialize(
            inputString,
            InvestmentProgramControllerWrapper.class
        );
        String goldSheetId = wrapper.goldSheet;
        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Investment_Program__c');
        if (goldSheetId != null) {
            Investment_Program__c actions = new Investment_Program__c();
            if (wrapper.id != null) {
                actions.Id = wrapper.id;
            }
            actions.Fields_of_Play_Gold_Sheet__c = goldsheetId;
            actions.Investment_Program_Title__c = wrapper.gsInvProgramTitle;
            actions.Assigned_To__c = wrapper.gsInvProgramAssignedTo;
            actions.Status__c = wrapper.gsInvProgramStatus;
            actions.Description__c = wrapper.gsInvProgramDescription;
            actions.Due_Date__c = wrapper.gsInvProgramDueDate;

            listActions.add(actions);
        }
        DataFactory.upsurt(listActions);
    }

    //Method to GET Records from Investment Program Activities-Actions Tab in Gold Sheet
    @AuraEnabled
    public static List<InvestmentProgramControllerWrapper> getInvProgramRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        Boolean isDeletable = false;
        List<Investment_Program__c> actionsList = new List<Investment_Program__c>();
        List<InvestmentProgramControllerWrapper> actionsWrapperList = new List<InvestmentProgramControllerWrapper>();
        if (Schema.sObjectType.Investment_Program__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String invProgQuery;
            if (sortFilter != null && sortFilter != 'DateCreated') {
                if (sortFilter == 'Complete') {
                    invProgQuery = 'Select Id, Name, Investment_Program_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
                if (sortFilter == 'Incomplete') {
                    invProgQuery = 'Select Id, Name, Investment_Program_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
            } else {
                invProgQuery = 'Select Id, Name, Investment_Program_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from ActionPlan Activities - Actions section
            actionsList = DataFactory.read(invProgQuery, paramters);
            //Iterate through list to get list of wrapper to return to UI
            for (Investment_Program__c gsActions : actionsList) {
                String sourceId = gsActions.Id;
                InvestmentProgramControllerWrapper wrapper = new InvestmentProgramControllerWrapper(
                    gsActions,
                    isDeletable
                );
                actionsWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new InvestmentProgramControllerException(
                'Error occured while getting data from ActionPlan Activities - Actions'
            );
        }
        //Return list of wrapper containing all ActionPlan Activities - Actions data
        return actionsWrapperList;
    }

    // Method to Delete ActionPlanActivities Actions Record
    @AuraEnabled
    public static void deleteInvProgramRecord(String recordId) {
        ApexCommonUtil.deleteRecord(recordId, 'Investment_Program__c');
    }

    @AuraEnabled(cacheable=true)
    public static String getStatusPicklistValues() {
        return ApexCommonUtil.getPicklistValues('Investment_Program__c', 'Status__c');
    }

    /* get required objects fro lookup component */
    @AuraEnabled
    public static WrapperLookupObject getLookupObjects() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        String apiName = 'Investment_Program__c';
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace(apiName);
        apiName = 'Assigned_To__c';
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace(apiName);
        return wrapper;
    }

    public class InvestmentProgramInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<InvestmentProgramControllerWrapper> apActionsRecords { get; set; }

        public InvestmentProgramInfo(
            Integer totalRecordCount,
            List<InvestmentProgramControllerWrapper> apActionsRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.apActionsRecords = apActionsRecords;
        }
    }

    @AuraEnabled
    public static InvestmentProgramInfo getInvProgramList(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        return new InvestmentProgramInfo(
            countInvProgramRecords(goldSheetId),
            getInvProgramRecords(goldSheetId, queryLimit, queryOffset, sortFilter)
        );
    }

    @AuraEnabled
    public static Integer countInvProgramRecords(String goldSheetId) {
        return ApexCommonUtil.countOfObjectRecords(
            goldSheetId,
            'Investment_Program__c',
            'Fields_of_Play_Gold_Sheet__c'
        );
    }

    //Method to get access of ActionPlanActivities Actions oject
    @AuraEnabled
    public static Map<String, Boolean> getInvProgramAccess() {
        return ApexCommonUtil.getObjectAccess('Investment_Program__c');
    }

    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    private class InvestmentProgramControllerException extends Exception {
    }
}