trigger CommitmentQuestionTrigger on Commitment_Question__c(after insert, before delete, after update, after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        CommitmentQuestionTriggerHelper.updateQuestionCountonGreenSheet(Trigger.New);
        GettingCommitment.gettingCommitmentLastUpdatedDateAndTime(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        CommitmentQuestionTriggerHelper.updateQuestionCountonGreenSheet(Trigger.Old);
    }

    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            if (GettingCommitment.lastUpdatedDate == true) {
                GettingCommitment.lastUpdatedDate = false;
                GettingCommitment.gettingCommitmentLastUpdatedDateAndTime(Trigger.new);
            }
        }
        if (Trigger.isDelete) {
            GettingCommitment.gettingCommitmentLastUpdatedDateAndTime(Trigger.old);
        }
    }
}