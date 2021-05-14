@isTest
public with sharing class GoldSheetActionPlanPDFTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            GoldSheetActionPlanTabPDFController pdfObj = new GoldSheetActionPlanTabPDFController();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            PageReference pageRef = Page.goldsheetA4; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(gs.Id));
            Test.setCurrentPage(pageRef);
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }

    @isTest
    static void getActionRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createActions(gs, true);
            List<ActionPlanActivitiesActionsWrapper> actionsList = GoldSheetActionPlanTabPDFController.getActionRecords(
                gs.id
            );
            System.assertEquals(actionsList[0].goldSheet, gs.id, 'Inserted Test Record gold sheet must be a match');
            Test.stopTest();
        }
    }

    @isTest
    static void getInformationNeededRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createInformationNeeded(gs, true);
            List<InformationNeededWrapper> informationNeededList = GoldSheetActionPlanTabPDFController.getInformationNeededRecords(
                gs.id
            );
            System.assertEquals(
                informationNeededList[0].goldSheet,
                gs.id,
                'Inserted Test Record gold sheet must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getInvProgramRecordssTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createInvProgram(gs, true);
            List<InvestmentProgramControllerWrapper> investmentProgramList = GoldSheetActionPlanTabPDFController.getInvProgramRecords(
                gs.id
            );
            System.assertEquals(
                investmentProgramList[0].goldSheet,
                gs.id,
                'Inserted Test Record gold sheet must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getMilestoneRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createMilestones(gs, true);
            Map<String, List<MilestoneWrapper>> milestoneWrapperList = GoldSheetActionPlanTabPDFController.getMilestoneRecords(
                gs.id
            );
            System.assertEquals(
                milestoneWrapperList.get('Milestone1')[0].goldSheet,
                gs.id,
                'Inserted Test Record gold sheet must be a match'
            );
            Test.stopTest();
        }
    }
}