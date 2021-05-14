trigger UniqueStrengthsTrigger on Unique_Strength__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.new);
        }

        if (Trigger.isUpdate) {
            if (GreenSheet.LastUpdatedDate == true) {
                GreenSheet.LastUpdatedDate = false;
                GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.new);
            }
        }

        if (Trigger.isDelete) {
            GreenSheet.greenSheetLastUpdatedDateAndTime(Trigger.old);
        }
    }
}