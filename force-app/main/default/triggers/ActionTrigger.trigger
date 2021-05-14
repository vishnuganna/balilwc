trigger ActionTrigger on Action__c(after insert, after update, after delete, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
            gsObj.processGoldSheetActivityDueDate();
            LandingPageGoldSheetCompletedActivities.actionGSCompletedActivities(Trigger.new, Trigger.oldMap, 'Action');
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                GoldSheetLandingPageAction.updateBestActivityAction(Trigger.newMap);
                GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
                gsObj.processGoldSheetActivityDueDate();
                LandingPageGoldSheetCompletedActivities.actionGSCompletedActivities(
                    Trigger.new,
                    Trigger.oldMap,
                    'Action'
                );
            }
        }
        if (Trigger.isDelete) {
            GoldSheetLandingPageAction.deleteBestActionRecord();
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            GoldSheetLandingPageAction.deleteBestActivityAction(Trigger.oldMap);
        }
    }
}