trigger StrategicPlayerTrigger on Strategic_Player__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (FieldsOfPlay.LastUpdatedDateInsert == true) {
                FieldsOfPlay.LastUpdatedDateInsert = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                FOPSpotLightReportFields.updateRoleFieldStrategicPlayer(Trigger.new);
                FOPSpotLightReportFields.updateRoleFieldStrategicBuySell(Trigger.new);
            }
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                FOPSpotLightReportFields.updateRoleFieldStrategicPlayer(Trigger.new);
                FOPSpotLightReportFields.updateRoleFieldStrategicBuySell(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
            FOPSpotLightReportFields.updateRoleFieldStrategicPlayer(Trigger.old);
            FOPSpotLightReportFields.updateRoleFieldStrategicBuySell(Trigger.old);
        }
    }
}