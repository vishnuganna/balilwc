@isTest
public with sharing class BlueSheetStatusTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Strategy_Engine__c se = TestDataUtil.createStrategySSO(bs, true);
        }
    }
    static testMethod void testSingleSalesObjectiveCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            System.assertNotEquals(bs.Progress__c, sso.Blue_Sheet__r.Progress__c);
        }
    }
    static testMethod void testActionPlanCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Action_Plan__c action = TestDataUtil.createActionPlan(bs, true);
            System.assertNotEquals(bs.Progress__c, action.Blue_Sheet__r.Progress__c);
        }

    }
    static testMethod void testCurrentPositionCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Current_Position__c cp = TestDataUtil.createCurrentPosition(bs, true);
            System.assertNotEquals(bs.Progress__c, cp.Blue_Sheet__r.Progress__c);
        }
    }
    static testMethod void testScoreCardCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Score_Card__c cp = TestDataUtil.createScoreCard(bs, true);
            System.assertNotEquals(bs.Progress__c, cp.Blue_Sheet__r.Progress__c);
        }
    }
    static testMethod void testCompetitionCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Account acc = [SELECT Id FROM Account];
            Competition__c competition = TestDataUtil.createCompetition(bs, acc, true);
            System.assertNotEquals(bs.Progress__c, competition.Blue_Sheet__r.Progress__c);
        }
    }
    static testMethod void testBuyingInfluenceCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Contact con = [SELECT Id FROM Contact];
            List<Buying_Influence__c> buying = TestDataUtil.createBuyingInfluence(bs, con, true);
            System.assertEquals(bs.Progress__c, 'Not Started');
        }
    }
    static testMethod void testBuyingInfluenceActionCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Contact con = [SELECT Id FROM Contact];
            List<Buying_Influence__c> buying = TestDataUtil.createBuyingInfluence(bs, con, true);
            Action_Plan__c action = TestDataUtil.createActionPlan(bs, true);
            System.assertNotEquals(bs.Progress__c, action.Blue_Sheet__r.Progress__c);
        }
    }
    static testMethod void testActionPlanBuyingCreation() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Contact con = [SELECT Id FROM Contact];
            Action_Plan__c action = TestDataUtil.createActionPlan(bs, true);
            List<Buying_Influence__c> buying = TestDataUtil.createBuyingInfluence(bs, con, true);
            System.assertNotEquals(bs.Progress__c, action.Blue_Sheet__r.Progress__c);
        }
    }

    static testMethod void testGetBlueSheetActionInprogress() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            List<BlueSheetProgressWrapper> bSPW = BlueSheetStatus.getBlueSheetActionInprogress(opp.Id);
            system.assertEquals(true, bSPW.size() > 0, 'Check List in wrapper');
            Test.stopTest();
        }
    }
    static testMethod void testGetBlueSheetAndSelfGuidedJourneyAcess() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Boolean haveAccess = BlueSheetStatus.getBlueSheetAndSelfGuidedJourneyAcess();
            system.assertEquals(haveAccess, true, 'Check access of Two Object');
            Test.stopTest();
        }
    }
}