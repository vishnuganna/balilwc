@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public with sharing class GreenSheetNavigate {
    @AuraEnabled
    public static String createGreenSheet(String taskId) {
        String greenSheetId;
        List<Green_Sheet__c> listGreenSheet = new List<Green_Sheet__c>();
        if (Schema.sObjectType.Green_Sheet__c.isCreateable() || Schema.sObjectType.Green_Sheet__c.isUpdateable()) {
            String greensheetQuery = 'Select Id,Name,Task_Id__c FROM Green_Sheet__c WHERE Task_Id__c =:taskId LIMIT 1';
            String taskQuery = 'Select Id, Subject, ActivityDate, WhatId, OwnerId, What.Name, Owner.Name, LastModifiedDate FROM Task WHERE Id =:taskId LIMIT 1';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('taskId', taskId);
            Map<String, Object> paramtersGreenSheet = new Map<String, Object>();
            paramtersGreenSheet.put('taskId', taskId);
            List<Task> listTask = DataFactory.read(taskQuery, paramters);
            listGreenSheet = DataFactory.read(greensheetQuery, paramtersGreenSheet);
            if (!listTask.isEmpty() && listGreenSheet.isEmpty()) {
                Task task = listTask[0];
                Green_Sheet__c green = new Green_Sheet__c();
                green.Task_Id__c = taskId;
                green.Task_Name__c = task.Subject;
                green.Related_To_Id__c = task.WhatId;
                green.Related_To_Name__c = task.What.Name;
                green.Task_Owner_Id__c = task.OwnerId;
                green.Task_Owner_Name__c = task.Owner.Name;
                green.Meeting_Date__c = task.ActivityDate;
                green.Last_Updated__c = task.LastModifiedDate;
                if (task.WhatId != null) {
                    String sObjName = task.WhatId.getSObjectType().getDescribe().getName();
                    if (sObjName == 'Opportunity') {
                        green.Opportunity__c = task.WhatId;
                    }
                }

                DataFactory.create(green);
                doGreenSheetCountCalculation(listTask, null);
                greenSheetId = green.Id;
            } else {
                greenSheetId = listGreenSheet[0].Id;
            }
        } else {
            if (Schema.sObjectType.Green_Sheet__c.isAccessible()) {
                if (!listGreenSheet.isEmpty()) {
                    greenSheetId = listGreenSheet[0].Id;
                }
            } else {
                greenSheetId = 'NoGSAccess';
            }
        }

        return greenSheetId;
    }

    public static void doGreenSheetCountCalculation(List<Task> taskLstNew, List<Task> taskLstOld) {
        Set<String> oppIdSet = new Set<String>();
        oppIdSet = getApplicableOpportunity(taskLstNew, taskLstOld);

        if (!oppIdSet.isEmpty()) {
            String gsQuery = 'Select Id, Related_To_Id__c,Task_Id__c from Green_Sheet__c where Related_To_Id__c in : oppIdSet';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppIdSet', oppIdSet);
            List<Green_Sheet__c> listGreenSheet = DataFactory.read(gsQuery, paramters);
            Map<String, Set<String>> mapOppIdTaskList = new Map<String, Set<String>>();

            for (Green_Sheet__c gs : listGreenSheet) {
                Set<String> taskIdSet = new Set<String>();
                if (mapOppIdTaskList.containsKey(gs.Related_To_Id__c)) {
                    taskIdSet = mapOppIdTaskList.get(gs.Related_To_Id__c);
                    taskIdSet.add(gs.Task_Id__c);
                } else {
                    taskIdSet.add(gs.Task_Id__c);
                }
                mapOppIdTaskList.put(gs.Related_To_Id__c, taskIdSet);
            }

            updateGreenSheetCountOnOpp(oppIdSet, mapOppIdTaskList);
        }
    }

    private static Set<String> getApplicableOpportunity(List<Task> taskLstNew, List<Task> taskLstOld) {
        Set<String> oppIdSet = new Set<String>();
        if (taskLstNew == null) {
            // means delete
            oppIdSet.addAll(getOppId(taskLstOld));
        } else if (taskLstOld == null) {
            // Insert
            oppIdSet.addAll(getOppId(taskLstNew));
        } else {
            // Update
            List<Task> taskLstNewChanged = new List<Task>();
            List<Task> taskLstOldChanged = new List<Task>();
            Map<String, Task> taskOldMap = getTaskMap(taskLstOld);
            for (Task newTask : taskLstNew) {
                Task oldTask = taskOldMap.get(newTask.Id);
                if (newTask.WhatId != oldTask.WhatId) {
                    taskLstNewChanged.add(newTask);
                    taskLstOldChanged.add(oldTask);
                }
            }
            oppIdSet.addAll(getOppId(taskLstNewChanged));
            oppIdSet.addAll(getOppId(taskLstOldChanged));
        }
        return oppIdSet;
    }
    private static Map<String, Task> getTaskMap(List<Task> taskList) {
        Map<String, Task> mapTask = new Map<String, Task>();
        for (Task t : taskList) {
            mapTask.put(t.Id, t);
        }
        return mapTask;
    }

    private static Set<String> getOppId(List<Task> taskList) {
        Set<String> idSetOpp = new Set<String>();
        if (taskList != null && !taskList.isEmpty()) {
            for (Task t : taskList) {
                if (t.WhatId != null) {
                    String sObjName = t.WhatId.getSObjectType().getDescribe().getName();
                    if (sObjName == 'Opportunity') {
                        idSetOpp.add(t.WhatId);
                    }
                }
            }
        }
        return idSetOpp;
    }

    private static void updateGreenSheetCountOnOpp(Set<String> oppIdSet, Map<String, Set<String>> mapOppIdTaskList) {
        Map<Id, Opportunity> oppRecordsMap = ApexCommonUtil.getOpportunityRecordForUpdate(oppIdSet);
        List<Opportunity> oppToUpdateLst = new List<Opportunity>();
        for (String oppId : oppRecordsMap.keySet()) {
            Opportunity opp = oppRecordsMap.get(oppId);
            Set<String> taskIdSet = mapOppIdTaskList.get(oppId);
            Integer gsCount = (taskIdSet == null ? 0 : taskIdSet.size());
            if (opp.Green_Sheet_Count__c != gsCount) {
                opp.Green_Sheet_Count__c = gsCount;
                oppToUpdateLst.add(opp);
            }
        }

        if (!oppToUpdateLst.isEmpty()) {
            DataFactory.modify(oppToUpdateLst);
        }
    }
}