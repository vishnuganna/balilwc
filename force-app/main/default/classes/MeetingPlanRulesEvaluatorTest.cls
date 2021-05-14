@isTest
public with sharing class MeetingPlanRulesEvaluatorTest {
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
        }
    }
    @isTest
    static void validateGreenSheetBusinessRule1Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_27'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR1TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            greenSheet.Credibility__c = 'Established';
            update greenSheet;
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_27'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR1TriggerEmpty() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            greenSheet.Reason__c = 'This is new reason';
            update greenSheet;
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_27'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals(null, bestAction[0].Action_Title__c, 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR2Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheet.Id,
                false,
                con
            );
            greenBI[0].Concept__c = null;
            insert greenBI[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_28'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR2TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheet.Id,
                false,
                con
            );
            for (Green_Sheet_Buying_Influence__c bi : greenBI) {
                bi.Concept__c = null;
            }
            insert greenBI;
            for (Green_Sheet_Buying_Influence__c bi : greenBI) {
                bi.Concept__c = 'this is concept';
            }
            update greenBI;
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE
                    Green_Sheet_Buying_Influence__c = :greenBI[0].Id
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_28'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals(null, bestAction[0].Action_Title__c, 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR3Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, false);
            for (Getting_Commitment__c gc : greenGC) {
                gc.Best_Action_Commitment__c = null;
            }
            insert greenGC;
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, Green_Sheet__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_26'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR4Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, false);
            for (Getting_Commitment__c gc : greenGC) {
                gc.Best_Action_Commitment__c = null;
            }
            insert greenGC;
            for (Getting_Commitment__c gc : greenGC) {
                gc.Best_Action_Commitment__c = 'Best action inserted';
            }
            update greenGC;

            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_26'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals(null, bestAction[0].Action_Title__c, 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR5Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, false);
            for (Getting_Commitment__c gc : greenGC) {
                gc.Minimum_Acceptable_Action_Commit__c = null;
            }
            insert greenGC;
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_25'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
    @isTest
    static void validateGreenSheetBR5TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId, ActivityDate FROM Task];
            Opportunity op = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], false);
            greenSheet.Meeting_Date__c = taskList[0].ActivityDate;
            greenSheet.Opportunity__c = op.Id;
            insert greenSheet;
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, false);
            for (Getting_Commitment__c gc : greenGC) {
                gc.Minimum_Acceptable_Action_Commit__c = null;
            }
            insert greenGC;
            for (Getting_Commitment__c gc : greenGC) {
                gc.Minimum_Acceptable_Action_Commit__c = 'Best action inserted';
            }
            update greenGC;

            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Green_Sheet__c = :greenSheet.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_25'
            ];
            //Test coverage
            system.assertEquals(1, bestAction.size(), 'record does not match');
        }
    }
}