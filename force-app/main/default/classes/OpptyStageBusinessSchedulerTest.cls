@isTest
public with sharing class OpptyStageBusinessSchedulerTest {
    static testMethod void testOpptyStageBusinessScheduler() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<String> opptyStagePickListValues = OpportunityStagesToBusinessRules.getOpptyStageValues();
            OpportunityStage__c opptyStage = new OpportunityStage__c();
            opptyStage.Name = opptyStagePickListValues[0];
            insert opptyStage;

            Test.startTest();
            OpptySatgeBusinessRulesScheduler sch = new OpptySatgeBusinessRulesScheduler();
            String chron = '0 0 23 * * ?';
            String jobid = System.schedule('OpptyStageScheduler', chron, sch);
            OpportunityStage__c opptyStages = [SELECT id, name FROM OpportunityStage__c LIMIT 1];
            System.assertEquals(opptyStagePickListValues[0], opptyStages.Name);
            System.assertNotEquals(opptyStagePickListValues[1], opptyStages.Name);
            Test.stopTest();
        }
    }
}