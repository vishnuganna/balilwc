trigger StopInvestmentTrigger on Stop_Investment__c(after insert, after update, after delete, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            LandingPageGoldSheetCompletedActivities.stopInvestmentGSCompletedActivities(
                Trigger.new,
                Trigger.oldMap,
                'Stop Investment'
            );
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                LandingPageGoldSheetCompletedActivities.stopInvestmentGSCompletedActivities(
                    Trigger.new,
                    Trigger.oldMap,
                    'Stop Investment'
                );
            }
        }

        if (Trigger.isDelete) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
            LandingPageGoldSheetCompletedActivities.deleteStopInvestmentAfter();
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            LandingPageGoldSheetCompletedActivities.deleteStopInvestmentBefore(Trigger.old);
        }
    }
}