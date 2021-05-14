@SuppressWarnings(
    'PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ExcessiveClassLength,PMD.CognitiveComplexity,PMD.ExcessivePublicCount'
)
public with sharing class ActionPlan {
    //Method to fetch data from action plan table and show it on UI under action plan section of blue sheet
    @AuraEnabled
    public static List<ActionPlanWrapperClass> getActionPlan(string oppId) {
        List<Action_Plan__c> listactionPlan = new List<Action_Plan__c>();
        Boolean isUpdatable;
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }
        List<ActionPlanWrapperClass> actionPlanWrapperListToReturn = new List<ActionPlanWrapperClass>();
        try {
            //formation of query
            String actionPlanQuery =
                ' Select Id,Name,Action_Type__c,AssignedTo__c,AssignedTo__r.Name,Blue_Sheet__c,Contact__c,Contact__r.Name,Description__c,Due_Date__c,Is_a_Best_Action__c' +
                ' ,Priority__c, Start_Date__c,IsProvidingPerspective__c,ProvidingPerspectiveDescription__c,Status__c,Summary__c,User__c,User__r.Name' +
                ' FROM Action_Plan__c WHERE Blue_Sheet__r.Opportunity__c=:oppId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from cometition section
            listactionPlan = DataFactory.read(actionPlanQuery, paramters);
            if (listactionPlan != null & !listactionPlan.isEmpty()) {
                listactionPlan = doGroupByAndSorting(listactionPlan);
            }
            //iterate through list to get list of wrapper to return to UI
            for (Action_Plan__c actionPlan : listactionPlan) {
                ActionPlanWrapperClass wrapper = new ActionPlanWrapperClass(actionPlan, isUpdatable);
                actionPlanWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new actionPlanException('Error occured while getting data from actionPlan');
        }
        //return list of wrapper containing all actionPlan data
        return actionPlanWrapperListToReturn;
    }

    @AuraEnabled
    public static String getBlueSheetId(string opptId) {
        String bsID = '';
        List<Blue_Sheet__c> listBS = new List<Blue_Sheet__c>();
        try {
            String bsQuery = 'SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: opptId limit 1';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('opptId', opptId);
            //get data from BI section
            listBS = DataFactory.read(bsQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Blue_Sheet__c bs : listBS) {
                BlueSheetWrapperClass wrapper = new BlueSheetWrapperClass(bs);
                bsID = string.valueof(wrapper.Id);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            //throw new Exception('Error occured while getting data from Blue Sheet');
        }
        return bsID;
    }

    @AuraEnabled
    public static String insertActionPlan(String actnPlan) {
        Map<String, Object> actnPlanDataMap = (Map<String, Object>) JSON.deserializeUntyped(actnPlan);
        Action_Plan__c actnPlanrcrd = new Action_Plan__c();

        // fetch bluesheet id using opp Id
        String bluesheetQuery = 'SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c =:oppId';
        Map<String, Object> paramters = new Map<String, Object>();
        String oppId = (String) actnPlanDataMap.get('OppId');
        paramters.put('oppId', oppId);
        List<Blue_Sheet__c> bluesheet = DataFactory.read(bluesheetQuery, paramters);
        actnPlanrcrd.Blue_Sheet__c = bluesheet[0].Id;

        actnPlanrcrd.Is_a_Best_Action__c = (Boolean) actnPlanDataMap.get('bestActionvalue'); //146
        actnPlanrcrd.Summary__c = (String) actnPlanDataMap.get('Summary');
        actnPlanrcrd.Description__c = (String) actnPlanDataMap.get('Description');
        actnPlanrcrd.Action_Type__c = (String) actnPlanDataMap.get('ActionType');

        if ((Boolean) actnPlanDataMap.get('bestActionvalue')) {
            actnPlanrcrd.IsProvidingPerspective__c = (Boolean) actnPlanDataMap.get('providingPerspectiveValue');
        }
        if ((Boolean) actnPlanDataMap.get('providingPerspectiveValue')) {
            actnPlanrcrd.ProvidingPerspectiveDescription__c = (String) actnPlanDataMap.get(
                'howWillYouProvidePerspectiveValue'
            );
        }

        if (
            (String) actnPlanDataMap.get('Contact') != '' &&
            (String) actnPlanDataMap.get('Contact') != null &&
            (String) actnPlanDataMap.get('Contact') != 'null' &&
            (String) actnPlanDataMap.get('Contact') != 'undefined'
        ) {
            actnPlanrcrd.Contact__c = (String) actnPlanDataMap.get('Contact');
        }
        if (
            (String) actnPlanDataMap.get('AssignedTo') != '' &&
            (String) actnPlanDataMap.get('AssignedTo') != null &&
            (String) actnPlanDataMap.get('AssignedTo') != 'null' &&
            (String) actnPlanDataMap.get('AssignedTo') != 'undefined'
        ) {
            actnPlanrcrd.AssignedTo__c = (String) actnPlanDataMap.get('AssignedTo');
        }
        actnPlanrcrd.Status__c = (String) actnPlanDataMap.get('Status');
        if (
            (String) actnPlanDataMap.get('StartDate') != '' &&
            (String) actnPlanDataMap.get('StartDate') != null &&
            (String) actnPlanDataMap.get('StartDate') != 'null' &&
            (String) actnPlanDataMap.get('StartDate') != 'undefined'
        ) {
            actnPlanrcrd.Start_Date__c = date.valueOf((String) actnPlanDataMap.get('StartDate'));
        }
        if (
            (String) actnPlanDataMap.get('DueDate') != '' &&
            (String) actnPlanDataMap.get('DueDate') != null &&
            (String) actnPlanDataMap.get('DueDate') != 'null' &&
            (String) actnPlanDataMap.get('DueDate') != 'undefined'
        ) {
            actnPlanrcrd.Due_Date__c = date.valueOf((String) actnPlanDataMap.get('DueDate'));
        }

        actnPlanrcrd.Priority__c = (String) actnPlanDataMap.get('Priority');
        List<Database.SaveResult> srList = DataFactory.create(actnPlanrcrd);
        if (srList != null && !srList.isEmpty()) {
            Best_Action_Task_Creation__c settings = Best_Action_Task_Creation__c.getInstance();
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess() && settings.Enable_Task_Creation__c && actnPlanrcrd.Is_a_Best_Action__c == true) {
                    Task task = new Task();
                    task.Subject = actnPlanrcrd.Summary__c;
                    task.WhatId = oppId;
                    if (actnPlanrcrd.Priority__c != null && actnPlanrcrd.Priority__c != '') {
                        task.Priority = actnPlanrcrd.Priority__c;
                    } else {
                        task.Priority = System.Label.Normal;
                    }
                    if (actnPlanrcrd.Status__c != null && actnPlanrcrd.Status__c != '') {
                        task.Status = actnPlanrcrd.Status__c;
                    } else {
                        task.Status = System.Label.NotStarted;
                    }
                    task.ActivityDate = actnPlanrcrd.Due_Date__c;
                    task.ActionPlanId__c = sr.getId();
                    task.ownerId = actnPlanrcrd.AssignedTo__c;
                    DataFactory.create(task);
                    return task.Id;
                }
            }
        }
        return null;
    }
    @AuraEnabled
    public static String updateActionPlan(String actnPlan) {
        Map<String, Object> actnPlanDataMap = (Map<String, Object>) JSON.deserializeUntyped(actnPlan);

        String actionPlanId = (String) actnPlanDataMap.get('Id');

        String query =
            'SELECT Id,name,Summary__c,Is_a_Best_Action__c,ProvidingPerspectiveDescription__c,Description__c,Action_Type__c,Contact__c,Status__c,' +
            ' Start_Date__c,Due_Date__c,IsProvidingPerspective__c,Priority__c,Assigned_To__c,Blue_Sheet__c,User__c,Blue_Sheet__r.Opportunity__c,AssignedTo__c from Action_Plan__c WHERE Id=:actionPlanId';

        map<String, Object> params = new Map<String, Object>();
        params.put('actionPlanId', actionPlanId);
        List<Action_Plan__c> actionplanRec = DataFactory.read(query, params);
        actionplanRec[0].Summary__c = (String) actnPlanDataMap.get('Summary');
        actionplanRec[0].Is_a_Best_Action__c = (Boolean) actnPlanDataMap.get('bestActionvalue'); //146
        actionplanRec[0].Description__c = (String) actnPlanDataMap.get('Description');
        actionplanRec[0].IsProvidingPerspective__c = (Boolean) actnPlanDataMap.get('providingPerspectiveValue'); //255
        actionplanRec[0].ProvidingPerspectiveDescription__c = (String) actnPlanDataMap.get(
            'howWillYouProvidePerspectiveValue'
        ); //255
        actionplanRec[0].Action_Type__c = (String) actnPlanDataMap.get('ActionType');

        if (actnPlanDataMap.containsKey('Contact')) {
            if (
                (String) actnPlanDataMap.get('Contact') == '' ||
                (String) actnPlanDataMap.get('Contact') == null ||
                (String) actnPlanDataMap.get('Contact') == 'null' ||
                (String) actnPlanDataMap.get('Contact') == 'undefined'
            ) {
                actionplanRec[0].Contact__c = null;
            } else {
                actionplanRec[0].Contact__c = (String) actnPlanDataMap.get('Contact');
            }
        }
        if (actnPlanDataMap.containsKey('AssignedTo')) {
            if (
                (String) actnPlanDataMap.get('AssignedTo') == '' ||
                (String) actnPlanDataMap.get('AssignedTo') == null ||
                (String) actnPlanDataMap.get('AssignedTo') == 'null' ||
                (String) actnPlanDataMap.get('AssignedTo') == 'undefined'
            ) {
                actionplanRec[0].AssignedTo__c = null;
            } else {
                actionplanRec[0].AssignedTo__c = (String) actnPlanDataMap.get('AssignedTo');
            }
        }
        actionplanRec[0].Status__c = (String) actnPlanDataMap.get('Status');
        if (
            (String) actnPlanDataMap.get('StartDate') == '' ||
            (String) actnPlanDataMap.get('StartDate') == null ||
            (String) actnPlanDataMap.get('StartDate') == 'null' ||
            (String) actnPlanDataMap.get('StartDate') == 'undefined'
        ) {
            actionplanRec[0].Start_Date__c = null;
        } else {
            actionplanRec[0].Start_Date__c = date.valueOf((String) actnPlanDataMap.get('StartDate'));
        }

        if (
            (String) actnPlanDataMap.get('DueDate') == '' ||
            (String) actnPlanDataMap.get('DueDate') == null ||
            (String) actnPlanDataMap.get('DueDate') == 'null' ||
            (String) actnPlanDataMap.get('DueDate') == 'undefined'
        ) {
            actionplanRec[0].Due_Date__c = null;
        } else {
            actionplanRec[0].Due_Date__c = date.valueOf((String) actnPlanDataMap.get('DueDate'));
        }

        actionplanRec[0].Priority__c = (String) actnPlanDataMap.get('Priority');
        DataFactory.modify(actionplanRec);
        Best_Action_Task_Creation__c settings = Best_Action_Task_Creation__c.getInstance();
        if (settings.Enable_Task_Creation__c) {
            String summary = actionplanRec[0].Summary__c;
            String oppId = actionplanRec[0].Blue_Sheet__r.Opportunity__c;
            String actionId = actionplanRec[0].Id;
            String taskQuery = 'Select Id, Subject, ActivityDate, WhatId, OwnerId, What.Name, Owner.Name, LastModifiedDate FROM Task WHERE ActionPlanId__c=:actionId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('summary', summary);
            paramters.put('actionId', actionId);
            List<Task> listTask = DataFactory.read(taskQuery, paramters);
            if (actionplanRec[0].Is_a_Best_Action__c == true) {
                String deletedtaskQuery = 'Select Id, Subject, isDeleted FROM Task WHERE isDeleted = true AND ActionPlanId__c=:actionId ALL ROWS';
                Map<String, Object> paraters = new Map<String, Object>();
                paraters.put('actionId', actionId);
                List<Task> listDeletedTask = DataFactory.read(deletedtaskQuery, paraters);
                if (!listDeletedTask.isEmpty()) {
                    List<Database.EmptyRecycleBinResult> recycle = Database.emptyRecycleBin(listDeletedTask);
                }
                Task task = new Task();
                String taskReturnStatus = null;
                if (!listTask.isEmpty()) {
                    task.Id = listTask[0].Id;
                } else {
                    taskReturnStatus = 'Created';
                }
                task.Subject = summary;
                if (actionplanRec[0].Priority__c != null && actionplanRec[0].Priority__c != '') {
                    task.Priority = actionplanRec[0].Priority__c;
                } else {
                    task.Priority = System.Label.Normal;
                }
                if (actionplanRec[0].Status__c != null && actionplanRec[0].Status__c != '') {
                    task.Status = actionplanRec[0].Status__c;
                } else {
                    task.Status = System.Label.NotStarted;
                }
                task.WhatId = oppId;
                task.ActivityDate = actionplanRec[0].Due_Date__c;
                task.ActionPlanId__c = actionId;
                task.ownerId = actionplanRec[0].AssignedTo__c;
                List<Task> taskLstUpsert = new List<Task>();
                taskLstUpsert.add(task);
                DataFactory.upsurt(taskLstUpsert);
                //return task.Id;
                return taskReturnStatus;
            } else {
                if (!listTask.isEmpty()) {
                    DataFactory.remove(listTask);
                    return System.Label.TaskDeleted;
                }
            }
        }

        return null;
    }
    @AuraEnabled
    public static Opportunity oppOwnerDetail(String oppId) {
        String query = 'Select id, ownerId, Owner.Name from Opportunity where Id=: OppId';
        map<String, Object> params = new Map<String, Object>();
        params.put('oppId', oppId);
        List<Opportunity> relOpp = DataFactory.read(query, params);
        return relOpp[0];
    }
    @AuraEnabled
    public static void deleteActionPlan(String recordId, String summary, Boolean isBestAction) {
        String query = 'SELECT Id from Action_Plan__c WHERE Id=:recordId';

        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<Action_Plan__c> actionplanRec = DataFactory.read(query, params);
        DataFactory.remove(actionplanRec);
        if (isBestAction == true) {
            String taskQuery = 'Select Id, Subject, ActivityDate, WhatId, OwnerId, What.Name, Owner.Name, LastModifiedDate FROM Task WHERE ActionPlanId__c=:recordId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('summary', summary);
            paramters.put('recordId', recordId);
            List<Task> listTask = DataFactory.read(taskQuery, paramters);
            if (!listTask.isEmpty()) {
                DataFactory.remove(listTask);
            }
        }
    }
    @AuraEnabled
    public static void undeleteTask(String recordId) {
        String taskIdtoDelete;
        String taskQuery = 'Select Id, Subject, isDeleted FROM Task WHERE isDeleted = true AND ActionPlanId__c=:recordId ALL ROWS';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('recordId', recordId);
        List<Task> listTask = DataFactory.read(taskQuery, paramters);
        if (!listTask.isEmpty()) {
            List<Database.UndeleteResult> undoDelete = DataFactory.unremove(listTask);
        }
        String query =
            'SELECT Id,name,Summary__c,Is_a_Best_Action__c,ProvidingPerspectiveDescription__c,Description__c,Action_Type__c,Contact__c,Status__c,' +
            ' Start_Date__c,Due_Date__c,IsProvidingPerspective__c,Priority__c,Assigned_To__c,Blue_Sheet__c,User__c,Blue_Sheet__r.Opportunity__c from Action_Plan__c WHERE Id=:recordId';

        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<Action_Plan__c> actionplanRec = DataFactory.read(query, params);
        actionplanRec[0].Is_a_Best_Action__c = true;
        DataFactory.modify(actionplanRec);
    }
    @AuraEnabled
    public static Map<String, Boolean> getActionPlanAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Action_Plan__c'
            : util.getNamespaceWithUnderScores() + 'Action_Plan__c';
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        return accessMap;
    }

    @AuraEnabled
    public static Map<String, String> getOppOwner(String opptId) {
        Map<String, String> oppOwnerMap = new Map<String, String>();
        Map<Id, Opportunity> oppInfoMap = new Map<Id, Opportunity>();
        Set<String> opptIdSet = new Set<String>();
        try {
            opptIdSet.add(opptId);
            oppInfoMap = ApexCommonUtil.getOpportunityRecord(opptIdSet);
            if (oppInfoMap != null && !oppInfoMap.isEmpty()) {
                Opportunity opty = oppInfoMap.get(opptId);
                oppOwnerMap.put('ownerid', opty.Ownerid);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }

        return oppOwnerMap;
    }

    // KFS-146-Start
    @AuraEnabled
    public static void updateIsAction(String recordId, boolean isActionchecks) {
        String query = 'SELECT Id,Is_a_Best_Action__c from Action_Plan__c WHERE Id=:recordId';

        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);

        List<Action_Plan__c> actionplanRec = DataFactory.read(query, params);

        actionplanRec[0].Is_a_Best_Action__c = isActionchecks;
        actionplanRec[0].IsProvidingPerspective__c = false; //255
        actionplanRec[0].ProvidingPerspectiveDescription__c = '';

        DataFactory.modify(actionplanRec);
    }

    @AuraEnabled(cacheable=true)
    public static String getActionTypePicklistValues() {
        map<string, string> options = new Map<string, string>();
        //List<String>
        Schema.DescribeFieldResult fieldResult = Action_Plan__c.Action_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.put(f.getValue(), f.getLabel());
        }
        return JSON.serialize(options);
    }

    @AuraEnabled(cacheable=true)
    public static String getStatusPicklistValues() {
        map<string, string> options = new Map<string, string>();
        //List<String>
        Schema.DescribeFieldResult fieldResult = Action_Plan__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.put(f.getValue(), f.getLabel());
        }
        return JSON.serialize(options);
    }

    @AuraEnabled(cacheable=true)
    public static String getPriorityPicklistValues() {
        map<string, string> options = new Map<string, string>();
        //List<String>
        Schema.DescribeFieldResult fieldResult = Action_Plan__c.Priority__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry f : ple) {
            options.put(f.getValue(), f.getLabel());
        }
        return JSON.serialize(options);
    }

    // KFS-146-End
    private class actionPlanException extends Exception {
    }

    // do group by and sorting
    private static List<Action_Plan__c> doGroupByAndSorting(List<Action_Plan__c> apRecLst) {
        /* Sorting order
        Best Action - Non Complete
        Best Action - Complete
        Possible Action - Non Complete
        Possible Action - Complete
        */
        List<Action_Plan__c> finalAPLst = new List<Action_Plan__c>();
        List<Action_Plan__c> bestActionCompleteLst = new List<Action_Plan__c>();
        List<Action_Plan__c> bestActionNonCompleteLst = new List<Action_Plan__c>();
        List<Action_Plan__c> possibleActionCompleteLst = new List<Action_Plan__c>();
        List<Action_Plan__c> possibleActionNonCompleteLst = new List<Action_Plan__c>();

        for (Action_Plan__c apObj : apRecLst) {
            if (apObj.Is_a_Best_Action__c == true) {
                // best action
                if (apObj.status__c == System.Label.Completed) {
                    bestActionCompleteLst.add(apObj);
                } else {
                    bestActionNonCompleteLst.add(apObj);
                }
            } else {
                // possible action
                if (apObj.status__c == System.Label.Completed) {
                    possibleActionCompleteLst.add(apObj);
                } else {
                    possibleActionNonCompleteLst.add(apObj);
                }
            }
        }

        finalAPLst.addAll(bestActionNonCompleteLst);
        finalAPLst.addAll(bestActionCompleteLst);
        finalAPLst.addAll(possibleActionNonCompleteLst);
        finalAPLst.addAll(possibleActionCompleteLst);

        return finalAPLst;
    }
    @AuraEnabled
    public static wrapperLookupObject getContactFieldName() {
        wrapperLookupObject wrapper = new wrapperLookupObject();
        wrapper.lookupOnObject = util.getNamespaceWithUnderScores() == ''
            ? 'Action_Plan__c'
            : util.getNamespaceWithUnderScores() + 'Action_Plan__c';
        wrapper.targetField = util.getNamespaceWithUnderScores() == ''
            ? 'Contact__c'
            : util.getNamespaceWithUnderScores() + 'Contact__c';
        return wrapper;
    }
    @AuraEnabled
    public static wrapperLookupObject getAssignedToFieldName() {
        wrapperLookupObject wrapper = new wrapperLookupObject();
        wrapper.lookupOnObject = util.getNamespaceWithUnderScores() == ''
            ? 'Action_Plan__c'
            : util.getNamespaceWithUnderScores() + 'Action_Plan__c';
        wrapper.targetField = util.getNamespaceWithUnderScores() == ''
            ? 'AssignedTo__c'
            : util.getNamespaceWithUnderScores() + 'AssignedTo__c';
        return wrapper;
    }
    public class wrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    /**
     * Method to insert action plan in bulk
     *
     * @param actnPlans JSON array of action plans
     */
    @AuraEnabled
    public static void insertActionPlans(final String actnPlans) {
        // get top level array / list
        List<Object> data = (List<Object>) JSON.deserializeUntyped(actnPlans);
        // only continue if we have data
        if (data.isEmpty()) {
            return;
        }
        // build list of new action plans
        List<Action_Plan__c> newPlans = new List<Action_Plan__c>();
        for (Object item : data) {
            Action_Plan__c newAp = new Action_Plan__c();
            Map<String, Object> apData = (Map<String, Object>) item;
            newAp.Blue_Sheet__c = (String) apData.get('BluesheetId');
            newAp.Summary__c = (String) apData.get('Summary');
            newPlans.add(newAp);
        }
        // save
        DataFactory.create(newPlans);
    }

    /**
     * Method to get SSO list data for action plan
     *
     * @param blueSheetId Blue Sheet ID for lookup
     *
     * @return JSON array of SSO data
     */
    @AuraEnabled
    public static String getSSOListData(String blueSheetId) {
        String query =
            'SELECT\n' +
            '    Id, Customers_Stated_Objectives__c\n' +
            'FROM Single_Sales_Objective__c\n' +
            'WHERE Blue_Sheet__c = :blueSheetId AND IsDeleted = FALSE';
        Map<String, Object> params = new Map<String, Object>();
        params.put('blueSheetId', blueSheetId);
        List<Single_Sales_Objective__c> ssoList = DataFactory.read(query, params);
        /*List<Red_Flag_Strength_Marker__c> markers = getListRedFlagStrengthMarkers(
         blueSheetId, 'CustomersStatedObjectives', 'Single_Sales_Objective__c');*/
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Single_Sales_Objective__c'
            : util.getNamespaceWithUnderScores() + 'Single_Sales_Objective__c';
        List<Red_Flag_Strength_Marker__c> markers = getAllRedFlagStrengthMarkersForObject(blueSheetId, objName);
        List<ActionPlan.ActionList> actionList = new List<ActionPlan.ActionList>();
        Integer i = 0;
        for (Single_Sales_Objective__c sso : ssoList) {
            /*if (!String.isBlank(sso.Customers_Stated_Objectives__c)) {
                // setup list item
                ActionPlan.ActionList item = new ActionPlan.ActionList();
                item.id = sso.Id;
                item.label = sso.Customers_Stated_Objectives__c;
                item.name = 'sso' + i++;
                item.isStrength = false;
                item.isRedFlag = false;
                // update marker data if present
                Red_Flag_Strength_Marker__c marker = getMarkerBySource(sso.Id, markers);
                if (marker != null) {
                    item.isStrength = (marker.Is_Strength_Selected__c != null) ? marker.Is_Strength_Selected__c : false;
                    item.isRedFlag = (marker.Is_Red_Flag_Selected__c != null) ? marker.Is_Red_Flag_Selected__c : false;
                }
                actionList.add(item);
            }*/
            List<Red_Flag_Strength_Marker__c> sourceMarkers = getMarkersBySource(sso.Id, markers);
            for (Red_Flag_Strength_Marker__c marker : sourceMarkers) {
                String fieldName = getCTSOFieldName(marker.Field_API_Name__c);
                if (marker.Is_Strength_Selected__c || marker.Is_Red_Flag_Selected__c) {
                    // setup list item
                    ActionPlan.ActionList item = new ActionPlan.ActionList();
                    item.id = sso.Id + '' + i++;
                    item.label = fieldName;
                    item.name = 'sso' + i;
                    item.isStrength = (marker.Is_Strength_Selected__c != null) ? marker.Is_Strength_Selected__c : false;
                    item.isRedFlag = (marker.Is_Red_Flag_Selected__c != null) ? marker.Is_Red_Flag_Selected__c : false;
                    actionList.add(item);
                }
            }
        }
        return JSON.serialize(actionList);
    }

    /**
     * Method to get BI list data for action plan
     *
     * @param blueSheetId Blue Sheet ID for lookup
     *
     * @return JSON array of BI data
     */
    @AuraEnabled
    public static String getBIListData(String blueSheetId) {
        String query =
            'SELECT\n' +
            '  Id, Contact__r.Name\n' +
            'FROM Buying_Influence__c\n' +
            'WHERE Blue_Sheet__c = :blueSheetId AND IsDeleted = FALSE';
        Map<String, Object> params = new Map<String, Object>();
        params.put('blueSheetId', blueSheetId);
        List<Buying_Influence__c> biList = DataFactory.read(query, params);
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Buying_Influence__c'
            : util.getNamespaceWithUnderScores() + 'Buying_Influence__c';
        List<Red_Flag_Strength_Marker__c> markers = getAllRedFlagStrengthMarkersForObject(blueSheetId, objName);
        List<ActionPlan.ActionList> actionList = new List<ActionPlan.ActionList>();
        Integer i = 0;
        for (Buying_Influence__c bi : biList) {
            if (!String.isBlank(bi.Contact__r.Name)) {
                List<Red_Flag_Strength_Marker__c> sourceMarkers = getMarkersBySource(bi.Id, markers);
                for (Red_Flag_Strength_Marker__c marker : sourceMarkers) {
                    String fieldName = getBIFieldName(marker.Field_API_Name__c);
                    if (
                        (marker.Is_Strength_Selected__c || marker.Is_Red_Flag_Selected__c) && !String.isEmpty(fieldName)
                    ) {
                        // setup list item
                        ActionPlan.ActionList item = new ActionPlan.ActionList();
                        item.id = bi.Id + '' + i++;
                        item.label = bi.Contact__r.Name + ': ' + fieldName;
                        item.name = 'bi' + i;
                        item.isStrength = (marker.Is_Strength_Selected__c != null)
                            ? marker.Is_Strength_Selected__c
                            : false;
                        item.isRedFlag = (marker.Is_Red_Flag_Selected__c != null)
                            ? marker.Is_Red_Flag_Selected__c
                            : false;
                        actionList.add(item);
                    }
                }
            }
        }
        return JSON.serialize(actionList);
    }

    /**
     * Method to get competitor list data for action plan
     *
     * @param blueSheetId Blue Sheet ID for lookup
     *
     * @return JSON array of competitor data
     */
    @AuraEnabled
    public static String getCompetitorListData(String blueSheetId) {
        String query =
            'SELECT\n' +
            '    Id, Competitior_Name__c, Account__r.Name\n' +
            'FROM Competition__c\n' +
            'WHERE Blue_Sheet__c = :blueSheetId\n' +
            '    AND IsDeleted = FALSE';
        Map<String, Object> params = new Map<String, Object>();
        params.put('blueSheetId', blueSheetId);
        List<Competition__c> compList = DataFactory.read(query, params);
        /*List<Red_Flag_Strength_Marker__c> markers = getListRedFlagStrengthMarkers(
         blueSheetId, 'competitor', 'Competition__c');*/
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Competition__c'
            : util.getNamespaceWithUnderScores() + 'Competition__c';
        List<Red_Flag_Strength_Marker__c> markers = getAllRedFlagStrengthMarkersForObject(blueSheetId, objName);
        List<ActionPlan.ActionList> actionList = new List<ActionPlan.ActionList>();
        Integer i = 0;
        for (Competition__c comp : compList) {
            if (!String.isBlank(comp.Account__r.Name) || !String.isBlank(comp.Competitior_Name__c)) {
                // setup list item
                /*ActionPlan.ActionList item = new ActionPlan.ActionList();
                item.id = comp.Id;
                item.label = String.isBlank(comp.Account__r.Name) ? comp.Competitior_Name__c : comp.Account__r.Name;
                item.name = 'comp' + i++;
                item.isStrength = false;
                item.isRedFlag = false;
                // update marker data if present
                Red_Flag_Strength_Marker__c marker = getMarkerBySource(comp.Id, markers);
                if (marker != null) {
                    item.isStrength = (marker.Is_Strength_Selected__c != null) ? marker.Is_Strength_Selected__c : false;
                    item.isRedFlag = (marker.Is_Red_Flag_Selected__c != null) ? marker.Is_Red_Flag_Selected__c : false;
                }
                actionList.add(item);*/
                List<Red_Flag_Strength_Marker__c> sourceMarkers = getMarkersBySource(comp.Id, markers);
                for (Red_Flag_Strength_Marker__c marker : sourceMarkers) {
                    String fieldName = getCompetitorFieldName(marker.Field_API_Name__c);
                    if (marker.Is_Strength_Selected__c || marker.Is_Red_Flag_Selected__c) {
                        // setup list item
                        ActionPlan.ActionList item = new ActionPlan.ActionList();
                        item.id = comp.Id + '' + i++;
                        if (fieldName == 'Competitor Name') {
                            item.label = String.isBlank(comp.Account__r.Name)
                                ? comp.Competitior_Name__c
                                : comp.Account__r.Name;
                        } else {
                            item.label = fieldName;
                        }
                        item.name = 'comp' + i;
                        item.isStrength = (marker.Is_Strength_Selected__c != null)
                            ? marker.Is_Strength_Selected__c
                            : false;
                        item.isRedFlag = (marker.Is_Red_Flag_Selected__c != null)
                            ? marker.Is_Red_Flag_Selected__c
                            : false;
                        actionList.add(item);
                    }
                }
            }
        }
        return JSON.serialize(actionList);
    }

    /**
     * Method to get competitor list data for action plan
     *
     * @param blueSheetId Blue Sheet ID for lookup
     *
     * @return JSON array of competitor data
     */
    @AuraEnabled
    public static String getSOMPListData(String blueSheetId) {
        String query =
            'SELECT\n' +
            '  Id, Summary__c, Is_a_Red_Flag__c, Is_a_Strength__c\n' +
            'FROM Summary_of_My_Position_Today__c\n' +
            'WHERE Blue_Sheet__c = :blueSheetId\n' +
            '  AND IsDeleted = FALSE';
        Map<String, Object> params = new Map<String, Object>();
        params.put('blueSheetId', blueSheetId);
        List<Summary_of_My_Position_Today__c> sompList = DataFactory.read(query, params);
        List<ActionPlan.ActionList> actionList = new List<ActionPlan.ActionList>();
        Integer i = 0;
        for (Summary_of_My_Position_Today__c somp : sompList) {
            if (!String.isBlank(somp.Summary__c)) {
                // setup list item
                ActionPlan.ActionList item = new ActionPlan.ActionList();
                item.id = somp.Id;
                item.label = somp.Summary__c;
                item.name = 'somp' + i++;
                item.isStrength = somp.Is_a_Strength__c;
                item.isRedFlag = somp.Is_a_Red_Flag__c;
                // update marker data if present
                actionList.add(item);
            }
        }
        return JSON.serialize(actionList);
    }

    /**
     * Get suggested action list metadata
     *
     * @return JSON array of configured suggested actions
     */
    @AuraEnabled
    public static String getSuggestedActionMetaData() {
        String query =
            'SELECT\n' +
            '    Id, Long_Label__c, Is_Red_Flag__c, Is_Strength__c\n' +
            'FROM Suggested_Possible_Action__mdt';
        List<Suggested_Possible_Action__mdt> mdtList = DataFactory.read(query, null);
        Integer cnt = 0;
        List<ActionPlan.ActionList> items = new List<ActionPlan.ActionList>();
        for (Suggested_Possible_Action__mdt mdt : mdtList) {
            ActionPlan.ActionList item = new ActionPlan.ActionList();
            item.id = mdt.Id;
            item.label = mdt.Long_Label__c;
            item.name = 'suggested' + cnt++;
            item.isStrength = mdt.Is_Strength__c;
            item.isRedFlag = mdt.Is_Red_Flag__c;
            items.add(item);
        }
        return JSON.serialize(items);
    }

    /**
     * Get all markers for given blue sheet and object name
     *
     * @param blueSheetId blue sheet for markers
     * @param objectName  object name filter
     *
     * @return list of red flag / strength markers for blue sheet / object name
     */
    private static List<Red_Flag_Strength_Marker__c> getAllRedFlagStrengthMarkersForObject(
        final String blueSheetId,
        final String objectName
    ) {
        String query =
            'SELECT\n' +
            '    Field_API_Name__c,\n' +
            '    Is_Red_Flag_Selected__c,\n' +
            '    Is_Strength_Selected__c,\n' +
            '    Object_API_Name__c,\n' +
            '    Source_ID__c\n' +
            'FROM Red_Flag_Strength_Marker__c\n' +
            'WHERE Parent_Id__c = :blueSheetId\n' +
            '    AND Object_API_Name__c = :objectName\n' +
            '    AND IsDeleted = FALSE';
        Map<String, Object> params = new Map<String, Object>();
        params.put('blueSheetId', blueSheetId);
        params.put('objectName', objectName);
        return DataFactory.read(query, params);
    }

    /**
     * Helper method to lookup red flag / strength data
     *
     * @param blueSheetId blue sheet ID for lookup
     * @param fieldName field name for lookup
     * @param objectName object name for lookup
     *
     * @return list of Red_Flag_Strength_Marker__c
     */
    private static List<Red_Flag_Strength_Marker__c> getListRedFlagStrengthMarkers(
        final String blueSheetId,
        final String fieldName,
        final String objectName
    ) {
        String query =
            'SELECT\n' +
            '    Field_API_Name__c,\n' +
            '    Is_Red_Flag_Selected__c,\n' +
            '    Is_Strength_Selected__c,\n' +
            '    Object_API_Name__c,\n' +
            '    Source_ID__c\n' +
            'FROM Red_Flag_Strength_Marker__c\n' +
            'WHERE Parent_Id__c = :blueSheetId\n' +
            '    AND Field_API_Name__c = :fieldName\n' +
            '    AND Object_API_Name__c = :objectName\n' +
            '    AND IsDeleted = FALSE';
        Map<String, Object> params = new Map<String, Object>();
        params.put('blueSheetId', blueSheetId);
        params.put('fieldName', fieldName);
        params.put('objectName', objectName);
        return DataFactory.read(query, params);
    }

    /**
     * Helper to find correct marker by source ID
     *
     * @param id source ID
     * @param markers list of markers
     *
     * @return found Red_Flag_Strength_Marker__c or NULL
     */
    private static Red_Flag_Strength_Marker__c getMarkerBySource(String id, List<Red_Flag_Strength_Marker__c> markers) {
        for (Red_Flag_Strength_Marker__c marker : markers) {
            if (marker.Source_ID__c.equals(id)) {
                return marker;
            }
        }
        return null;
    }

    /**
     * Helper to find correct marker by source ID
     *
     * @param id source ID
     * @param markers list of markers
     *
     * @return found Red_Flag_Strength_Marker__c or NULL
     */
    private static List<Red_Flag_Strength_Marker__c> getMarkersBySource(
        String id,
        List<Red_Flag_Strength_Marker__c> markers
    ) {
        List<Red_Flag_Strength_Marker__c> result = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c marker : markers) {
            if (marker.Source_ID__c.equals(id)) {
                result.add(marker);
            }
        }
        return result;
    }

    /**
     * Helper to resolve UI friendly field name
     * @param fieldApiName DB field name
     *
     * @return UI friendly field name
     */
    private static String getBIFieldName(final String fieldApiName) {
        switch on fieldApiName {
            when 'BuyingInfluenceRole' {
                return System.Label.Role;
            }
            when 'DegreeOfInfluence' {
                return System.Label.degreeofInfluence;
            }
            when 'BuyingMode' {
                return System.Label.buyingMode;
            }
            when 'CompetitivePreference' {
                return System.Label.competitivePreference;
            }
            when 'PersonalWins' {
                return System.Label.PersonalWinsPDF;
            }
            when 'BusinessResults' {
                return System.Label.businessResultsPDF;
            }
            when 'Rating' {
                return System.Label.rating;
            }
            when 'RatingEvidence' {
                return System.Label.ratingEvidence;
            }
        }
        return null;
    }

    /**
     * Helper to resolve UI friendly field name for Customer Timing card
     * @param fieldApiName DB field name
     *
     * @return UI friendly field name
     */
    private static String getCTSOFieldName(final String fieldApiName) {
        switch on fieldApiName {
            when 'CustomerTimingforPriorities' {
                return System.Label.Customer_Timing_for_Priorities;
            }
            when 'CustomersStatedObjectives' {
                return System.Label.Customer_Stated_Objective;
            }
            when 'EvaluationofObjectives' {
                return System.Label.Evaluation_of_Objective;
            }
        }
        return null;
    }

    /**
     * Helper to resolve UI friendly field name for Competitor card
     * @param fieldApiName DB field name
     *
     * @return UI friendly field name
     */
    private static String getCompetitorFieldName(final String fieldApiName) {
        switch on fieldApiName {
            when 'competitor' {
                return System.Label.competitior;
            }
            when 'competitiveDetail' {
                return System.Label.competitiveDetail;
            }
        }
        return null;
    }

    /**
     * Class to hold action list data
     */
    public class ActionList {
        public String id;
        public String label;
        public String name;
        public Boolean isStrength;
        public Boolean isRedFlag;
    }
}