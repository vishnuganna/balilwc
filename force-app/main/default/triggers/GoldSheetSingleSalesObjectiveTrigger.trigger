trigger GoldSheetSingleSalesObjectiveTrigger on Gold_Sheet_Single_Sales_Objective__c(
    after insert,
    after update,
    after delete
) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            FOPSpotLightReportFields.getOpportunityGoldSheetSSoCount(Trigger.new);
            OpportunityCountOnGoldSheet.countSSOonGoldSheet(Trigger.new);
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                FOPSpotLightReportFields.getOpportunityGoldSheetSSoCount(Trigger.new);
                OpportunityCountOnGoldSheet.countSSOonGoldSheet(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            FOPSpotLightReportFields.getOpportunityGoldSheetSSoCount(Trigger.old);
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
            OpportunityCountOnGoldSheet.countSSOonGoldSheet(Trigger.old);
        }
    }
}