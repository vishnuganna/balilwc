public with sharing class GreenSheet {
    public static boolean taskUpdate = true;
    public static boolean LastUpdatedDate = true;

    @AuraEnabled
    public static Map<String, Boolean> getGreensheetAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Green_Sheet__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    public static void greensheetUpdate(List<Task> taskRecords) {
        if (Schema.sObjectType.Green_Sheet__c.isUpdateable()) {
            List<String> taskIds = new List<String>();
            Map<String, Task> taskMap = new Map<String, Task>();
            for (Task task : taskRecords) {
                taskIds.add(task.id);
            }
            String greenSheetQuery = 'Select Id,Task_Id__c,Task_Name__c,Related_To_Id__c,Related_To_Name__c,Task_Owner_Id__c,Task_Owner_Name__c,Meeting_Date__c FROM Green_Sheet__c WHERE Task_Id__c IN:taskIds';
            String taskQuery = 'Select Id, Subject, ActivityDate, WhatId, OwnerId, What.Name, Owner.Name FROM Task WHERE Id IN:taskIds';

            Map<String, Object> params = new Map<String, Object>();
            params.put('taskIds', taskIds);

            //Reading task data to pull out Owner.name and what.name
            taskRecords = DataFactory.read(taskQuery, params);
            for (Task task : taskRecords) {
                taskMap.put(task.id, task);
            }
            List<Green_Sheet__c> greenSheetList = DataFactory.read(greenSheetQuery, params);
            List<Green_Sheet__c> updatedGreenSheet = new List<Green_Sheet__c>();
            for (Green_Sheet__c greenSheet : greenSheetList) {
                Task task = taskMap.get(greenSheet.Task_Id__c);
                greenSheet.Task_Name__c = task.Subject;
                greenSheet.Related_To_Id__c = task.WhatId;
                greenSheet.Related_To_Name__c = task.What.Name;
                greenSheet.Task_Owner_Id__c = task.OwnerId;
                greenSheet.Task_Owner_Name__c = task.Owner.Name;
                greenSheet.Meeting_Date__c = task.ActivityDate;
                if (task.WhatId != null) {
                    String sObjName = task.WhatId.getSObjectType().getDescribe().getName();
                    if (sObjName == 'Opportunity') {
                        greenSheet.Opportunity__c = task.WhatId;
                    } else {
                        greenSheet.Opportunity__c = null;
                    }
                }
                updatedGreenSheet.add(greenSheet);
            }
            if (updatedGreenSheet.size() > 0) {
                DataFactory.modify(updatedGreenSheet);
            }
        }
    }

    @AuraEnabled
    public static String greensheetDelete(String greensheetId) {
        String taskId = null;
        String greenSheetQuery = 'Select Task_Id__c FROM Green_Sheet__c WHERE Id =:greensheetId';
        Map<String, Object> params = new Map<String, Object>();
        params.put('greensheetId', greensheetId);
        List<Green_Sheet__c> greenSheetList = DataFactory.read(greenSheetQuery, params);

        if (!greenSheetList.isEmpty()) {
            taskId = greenSheetList[0].Task_Id__c;
            try {
                String objName = 'Green_Sheet__c';
                ApexCommonUtil.deleteRecord(greensheetId, objName);
            } catch (Exception ex) {
                throw new GreenSheetException('Error occured while deleting data from Green Sheet');
            }
        }
        return taskId;
    }

    //KFS-2107 Start// Updating Green Sheet Last Updated Date
    public static void greenSheetLastUpdatedDateAndTime(List<sObject> ls) {
        List<sObject> objList = new List<sObject>();
        Set<sObject> setObj = new Set<sObject>();
        Set<string> greensSheetIds = new Set<string>();
        for (sObject s : ls) {
            Green_Sheet__c greenSheet = new Green_Sheet__c();
            greensSheetIds.add((Id) s.get('Green_Sheet__c'));
        }
        for (string s : greensSheetIds) {
            Green_Sheet__c greenSheet = new Green_Sheet__c();
            greenSheet.Id = s;
            greenSheet.Last_Updated__c = (DateTime) system.now();
            setObj.add(greenSheet);
        }
        objList.addAll(setObj);
        if (objList.size() > 0) {
            DataFactory.modify(objList);
        }
    }

    private class GreenSheetException extends Exception {
    }
}