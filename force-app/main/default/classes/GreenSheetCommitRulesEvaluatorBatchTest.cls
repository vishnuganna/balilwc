@isTest
public class GreenSheetCommitRulesEvaluatorBatchTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String oppStageId = TestDataUtil.getOppStageId();
            Business_Rules_Group__c brg = new Business_Rules_Group__c();
            brg.name = 'EasterGrp';
            insert brg;
            Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
            brgm.Member_Name__c = user.Id;
            brgm.Business_Rules_Group__c = brg.Id;
            insert brgm;
            List<Business_Rules__c> brLst = new List<Business_Rules__c>();
            Business_Rules__c br1 = new Business_Rules__c(
                IsActive__c = true,
                Opportunity_Stage_Global__c = 'Qualification',
                Business_Rule_Catagory__c = 'Meeting Plan',
                Is_Minimum_Action_Commitment_Added__c = true,
                Is_Concept_for_BI_Added__c = true,
                Is_Valid_Business_Reason_Added__c = true,
                Is_Best_Action_Commitment_Added__c = true,
                Number_of_Days_Before_Meeting__c = 4,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            List<Task> taskList = TestDataUtil.createTaskList(user, false);
            for (Task t : taskList) {
                t.ActivityDate = system.Date.today() + 3;
                t.WhatId = op.Id;
            }
            insert taskList;
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, false);
            for (Getting_Commitment__c gc : greenGC) {
                gc.Best_Action_Commitment__c = null;
            }
            insert greenGC;
        }
    }
    @isTest
    static void validateBatchExecution() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            green_Sheet__c greenSheet = [SELECT Id, Name FROM Green_Sheet__c LIMIT 1];
            system.test.startTest();
            GreenSheetCommitmentRulesEvaluatorBatch commitmentBatch = new GreenSheetCommitmentRulesEvaluatorBatch();
            Database.executeBatch(commitmentBatch, 150);
            system.test.stopTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, Green_Sheet__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_26'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
}