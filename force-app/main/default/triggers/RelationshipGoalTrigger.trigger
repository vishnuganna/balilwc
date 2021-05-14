trigger RelationshipGoalTrigger on Relationship_Goal__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
            FOPSpotLightReportFields.updateRelationshopGoals(Trigger.new);
            LandingGoalsByFOP.getGoalCountForFOP(Trigger.new);
        }

        if (Trigger.isUpdate) {
            if (FieldsOfPlay.LastUpdatedDate == true) {
                FieldsOfPlay.LastUpdatedDate = false;
                FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.new);
                FOPSpotLightReportFields.updateRelationshopGoals(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            FieldsOfPlay.goldSheetLastUpdatedDateAndTime(Trigger.old);
            FOPSpotLightReportFields.updateRelationshopGoals(Trigger.old);
            LandingGoalsByFOP.getGoalCountForFOP(Trigger.old);
        }
    }
}