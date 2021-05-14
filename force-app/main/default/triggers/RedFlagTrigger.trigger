trigger RedFlagTrigger on Red_Flag__c(after insert, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            }
            if (ProgressNavigation.LastUpdatedDateUpdate == true) {
                ProgressNavigation.LastUpdatedDateUpdate = false;
                ProgressNavigation.blueSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }
    }
}