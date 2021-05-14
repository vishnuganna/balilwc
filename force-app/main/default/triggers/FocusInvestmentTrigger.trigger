trigger FocusInvestmentTrigger on Focus_Investment__c(after insert, after update, after delete, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            LandingPageGoldSheetCompletedActivities.focusInvestmentGSCompletedActivities(
                Trigger.new,
                Trigger.oldMap,
                'Focus Investment'
            );
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                LandingPageGoldSheetCompletedActivities.focusInvestmentGSCompletedActivities(
                    Trigger.new,
                    Trigger.oldMap,
                    'Focus Investment'
                );
            }
        }

        if (Trigger.isDelete) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
            LandingPageGoldSheetCompletedActivities.deleteFocusInvestmentAfter();
        }
    }

    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            LandingPageGoldSheetCompletedActivities.deleteFocusInvestmentBefore(Trigger.old);
        }
    }
}