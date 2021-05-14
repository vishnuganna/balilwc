trigger FOPStrategicStrengthTrigger on FOP_Strategic_Strength__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }

        if (Trigger.isDelete) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }
}