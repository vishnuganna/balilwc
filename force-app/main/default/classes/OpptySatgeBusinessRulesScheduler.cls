public with sharing class OpptySatgeBusinessRulesScheduler implements Schedulable {
    public void execute(SchedulableContext context) {
        OpportunityStagesToBusinessRules opptyStage = new OpportunityStagesToBusinessRules();
        opptyStage.createOpportunityStage();
    }
}