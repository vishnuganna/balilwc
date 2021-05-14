trigger InvestmentProgramTrigger on Investment_Program__c(after insert, after update, after delete, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
            gsObj.processGoldSheetActivityDueDate();
            LandingPageGoldSheetCompletedActivities.investmentProgGSCompletedActivities(
                Trigger.new,
                Trigger.oldMap,
                'Investment Program'
            );
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                GoldSheetLandingPageAction.updateBestActivityInvProg(Trigger.oldMap);
                GoldSheetLandingPageAction gsObj = new GoldSheetLandingPageAction();
                gsObj.processGoldSheetActivityDueDate();
                LandingPageGoldSheetCompletedActivities.investmentProgGSCompletedActivities(
                    Trigger.new,
                    Trigger.oldMap,
                    'Investment Program'
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
            GoldSheetLandingPageAction.deleteBestActivityInvProg(Trigger.oldMap);
        }
    }
}