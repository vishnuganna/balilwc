trigger BusinessRuleTrigger on Business_Rules__c(before delete, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            BusinessRules.businessRuleDeleteBefore(Trigger.old);
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            BusinessRules.businessRuleDeleteAfter();
        }
    }
}