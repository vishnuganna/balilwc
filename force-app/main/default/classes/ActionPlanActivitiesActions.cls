public with sharing class ActionPlanActivitiesActions {
    //Method to Create and Update ActionPlanActivities Actions Records
    @AuraEnabled
    public static void createActionsRec(String actionsDataString) {
        List<Action__c> listActions = new List<Action__c>();
        ActionPlanActivitiesActionsWrapper wrapper = (ActionPlanActivitiesActionsWrapper) System.JSON.deserialize(
            actionsDataString,
            ActionPlanActivitiesActionsWrapper.class
        );
        String goldSheetId = wrapper.goldSheet;
        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Action__c');
        if (goldSheetId != null) {
            Action__c actions = new Action__c();
            if (wrapper.id != null) {
                actions.Id = wrapper.id;
            }
            actions.Fields_of_Play_Gold_Sheet__c = goldsheetId;
            actions.Action_Title__c = wrapper.gsActionTitle;
            actions.Assigned_To__c = wrapper.gsActionAssignedTo;
            actions.Status__c = wrapper.gsActionStatus;
            actions.Description__c = wrapper.gsActionDescription;
            actions.Due_Date__c = wrapper.gsActionDueDate;

            listActions.add(actions);
        }
        DataFactory.upsurt(listActions);
    }

    //Method to GET Records from Action Plan Activities-Actions Tab in Gold Sheet
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static List<ActionPlanActivitiesActionsWrapper> getActionRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        Boolean isDeletable = false;
        List<Action__c> actionsList = new List<Action__c>();
        List<ActionPlanActivitiesActionsWrapper> actionsWrapperList = new List<ActionPlanActivitiesActionsWrapper>();
        if (Schema.sObjectType.Action__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String actionsQuery;

            if (sortFilter != null && sortFilter != 'DateCreated') {
                if (sortFilter == 'Complete') {
                    actionsQuery = 'Select Id, Name, Action_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
                if (sortFilter == 'Incomplete') {
                    actionsQuery = 'Select Id, Name, Action_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC,createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
                }
            } else {
                actionsQuery = 'Select Id, Name, Action_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from ActionPlan Activities - Actions section
            actionsList = DataFactory.read(actionsQuery, paramters);
            //Iterate through list to get list of wrapper to return to UI
            for (Action__c gsActions : actionsList) {
                String sourceId = gsActions.Id;
                ActionPlanActivitiesActionsWrapper wrapper = new ActionPlanActivitiesActionsWrapper(
                    gsActions,
                    isDeletable
                );
                actionsWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new ActionPlanActivitiesActionsException(
                'Error occured while getting data from ActionPlan Activities - Actions'
            );
        }
        //Return list of wrapper containing all ActionPlan Activities - Actions data
        return actionsWrapperList;
    }

    // Method to Delete ActionPlanActivities Actions Record
    @AuraEnabled
    public static void deleteActionsRecord(String recordId) {
        ApexCommonUtil.deleteRecord(recordId, 'Action__c');
    }

    @AuraEnabled(cacheable=true)
    public static String getStatusPicklistValues() {
        return ApexCommonUtil.getPicklistValues('Action__c', 'Status__c');
    }

    /* get required objects fro lookup component */
    @AuraEnabled
    public static WrapperLookupObject getLookupObjects() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        String apiName = 'Action__c';
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace(apiName);
        apiName = 'Assigned_To__c';
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace(apiName);
        return wrapper;
    }

    public class ActionPlanActivitiesActionsInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<ActionPlanActivitiesActionsWrapper> apActionsRecords { get; set; }

        public ActionPlanActivitiesActionsInfo(
            Integer totalRecordCount,
            List<ActionPlanActivitiesActionsWrapper> apActionsRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.apActionsRecords = apActionsRecords;
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static ActionPlanActivitiesActionsInfo getActionsList(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset,
        String sortFilter
    ) {
        return new ActionPlanActivitiesActionsInfo(
            countActionsRecords(goldSheetId),
            getActionRecords(goldSheetId, queryLimit, queryOffset, sortFilter)
        );
    }

    @AuraEnabled
    public static Integer countActionsRecords(String goldSheetId) {
        return ApexCommonUtil.countOfObjectRecords(goldSheetId, 'Action__c', 'Fields_of_Play_Gold_Sheet__c');
    }

    //Method to get access of ActionPlanActivities Actions oject
    @AuraEnabled
    public static Map<String, Boolean> getActionAccess() {
        return ApexCommonUtil.getObjectAccess('Action__c');
    }

    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    private class ActionPlanActivitiesActionsException extends Exception {
    }
}