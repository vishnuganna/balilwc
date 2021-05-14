public with sharing class BestActionRuleScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        getStrategyengineRecords();
    }

    public void getStrategyengineRecords() {
        BestActionRuleBatch b = new BestActionRuleBatch();
        Database.executeBatch(b, 150);
    }
}