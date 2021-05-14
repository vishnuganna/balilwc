trigger InformationNeededTrigger on Information_Needed__c(after insert, after update, after delete, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
            gsObj.processGoldSheetActivityDueDate();
            LandingPageGoldSheetCompletedActivities.infoNeededGSCompletedActivities(
                Trigger.new,
                Trigger.oldMap,
                'Information Needed'
            );
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                GoldSheetLandingPageAction.updateBestActivityInfoNeeded(Trigger.oldMap);
                GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
                gsObj.processGoldSheetActivityDueDate();
                LandingPageGoldSheetCompletedActivities.infoNeededGSCompletedActivities(
                    Trigger.new,
                    Trigger.oldMap,
                    'Information Needed'
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
            GoldSheetLandingPageAction.deleteBestActivityInfoNeeded(Trigger.oldMap);
        }
    }
}