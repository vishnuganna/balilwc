trigger MyPositionTrigger on Summary_of_My_Position_Today__c(after insert, after delete, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            ProgressNavigation.updateProgressSummaryOfMyPosition(Trigger.new);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
        }
        if (Trigger.isUpdate) {
            if (ProgressNavigation.myPositionUpdate == true) {
                ProgressNavigation.myPositionUpdate = false;
                ProgressNavigation.updateProgressSummaryOfMyPosition(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            ProgressNavigation.updateProgressSummaryOfMyPosition(Trigger.old);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }
}