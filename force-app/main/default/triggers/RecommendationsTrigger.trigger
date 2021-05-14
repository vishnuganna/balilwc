/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-357,main US=KFS-66 : Whenever Recommendation record is created/updated/deleted, do the same in KF Sell Best Action obj
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-June-05
 */
trigger RecommendationsTrigger on Recommendations__c(after insert, after update, before delete, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            BestAction.deleteBestActionRecBefore(Trigger.oldMap);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (BestAction.kfSellBestActionInsert == true) {
                BestAction.kfSellBestActionInsert = false;
                BestAction.createUpdateBestAction(Trigger.new);
            }
        }

        if (Trigger.isUpdate) {
            if (BestAction.kfSellBestActionUpdate == true) {
                BestAction.kfSellBestActionUpdate = false;
                BestAction.createUpdateBestAction(Trigger.new);
            }
        }

        if (Trigger.isDelete) {
            BestAction.deleteBestActionRecord();
        }
    }
}