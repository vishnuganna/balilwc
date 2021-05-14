trigger StrategyEngineTrigger on Strategy_Engine__c(after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            if (BestActionLogic.bestActionLogicInsertSEFlag == true) {
                BestActionLogic.bestActionLogicInsertSEFlag = false;
                BestActionLogic.upsertRecommendationsRec(Trigger.new);
            }
        }

        if (Trigger.isUpdate) {
            if (BestActionLogic.bestActionLogicUpdateSEFlag == true) {
                BestActionLogic.bestActionLogicUpdateSEFlag = false;
                BestActionLogic.upsertRecommendationsRec(Trigger.new);
            }
        }

        if (Trigger.isDelete) {
            // execute only when Buying influence record is deleted
            List<Strategy_Engine__c> seLstforBI = new List<Strategy_Engine__c>();
            for (Strategy_Engine__c seObj : Trigger.oldMap.values()) {
                if (seObj.Buying_Influence_Name__c != null) {
                    seLstforBI.add(seObj);
                }
            }
            if (!seLstforBI.isEmpty()) {
                BestActionLogic.upsertRecommendationsRec(Trigger.old);
            }
        }
    }
}