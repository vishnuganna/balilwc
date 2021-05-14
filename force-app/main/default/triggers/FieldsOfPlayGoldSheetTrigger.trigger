trigger FieldsOfPlayGoldSheetTrigger on Gold_Sheet__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            ClosedWonOpportunityOnGoldSheet.checkIfClosedWon(Trigger.new);
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                GoldSheetLandingPageAction.deleteBestAction(Trigger.oldMap);
                ClosedWonOpportunityOnGoldSheet.checkIfClosedWon(Trigger.new);
            }
        }

        if (Trigger.isDelete) {
            GoldSheetLandingPageAction.deleteBestAction(Trigger.oldMap);
            ClosedWonOpportunityOnGoldSheet.checkIfClosedWon(Trigger.old);
        }
    }
}