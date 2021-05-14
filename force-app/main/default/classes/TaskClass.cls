public with sharing class TaskClass {
    //public static List<Green_Sheet__c> listGreenSheetToDelete = new List<Green_Sheet__c>();
    public static Set<String> listGreenSheetIdToDelete = new Set<String>();

    public static void greenSheetDeleteBefore(List<Task> taskLst) {
        if (Schema.sObjectType.Green_Sheet__c.isDeletable()) {
            Set<String> taskIdSet = new Set<String>();
            for (Task taskObj : taskLst) {
                taskIdSet.add(taskObj.Id);
            }
            String greenSheetQuery = 'Select Id FROM Green_Sheet__c WHERE Task_Id__c=:taskIdSet';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('taskIdSet', taskIdSet);
            List<Green_Sheet__c> listGreenSheetToDelete = DataFactory.read(greenSheetQuery, paramters);
            for (Green_Sheet__c gsObj : listGreenSheetToDelete) {
                listGreenSheetIdToDelete.add(gsObj.Id);
            }
        }
    }

    public static void greenSheetDeleteAfter() {
        if (Schema.sObjectType.Green_Sheet__c.isDeletable() && !TaskClass.listGreenSheetIdToDelete.isEmpty()) {
            List<String> taskIdLst = new List<String>();
            taskIdLst.addAll(TaskClass.listGreenSheetIdToDelete);
            DataFactory.remove(taskIdLst);
        }
    }
}