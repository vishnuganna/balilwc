@isTest
public with sharing class GoldSheetStrategyTabPDFControllerTest {
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
            GoldSheetStrategyTabPDFController pdfObj = new GoldSheetStrategyTabPDFController();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            PageReference pageRef = Page.goldsheetA4; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(gs.Id));
            Test.setCurrentPage(pageRef);
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }

    @isTest
    static void getBusinessHierarchyDataTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createBuySellHierarchy(gs, true);
            BuySellHierarchyWrapper buySellWrapper = GoldSheetStrategyTabPDFController.getBusinessHierarchyData(gs.id);
            System.assertEquals(buySellWrapper.goldSheetId, gs.Id, 'Inserted Test Record role must be a match');
            Test.stopTest();
        }
    }

    @isTest
    static void getCharterStatementDataTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createCharterStatement(gs, true);
            CharterStatementWrapper charterStatementWrapper = GoldSheetStrategyTabPDFController.getCharterStatementData(
                gs.id
            );
            System.assertEquals(
                charterStatementWrapper.goldSheetId,
                gs.Id,
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getFocusInvestmentRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createFocusInvestment(gs, true);
            List<FocusInvestmentWrapper> focusInvestmentWrapperList = GoldSheetStrategyTabPDFController.getFocusInvestmentRecords(
                gs.id
            );
            System.assertEquals(
                focusInvestmentWrapperList[0].foiInvestmentTitle,
                'Test 1',
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getStopInvestmentRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createStopInvestment(gs, true);
            List<StopInvestmentWrapper> stopInvestmentWrapperList = GoldSheetStrategyTabPDFController.getStopInvestmentRecords(
                gs.id
            );
            System.assertEquals(
                stopInvestmentWrapperList[0].foiInvestmentTitle,
                'Test 1',
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getRelationshipGoalsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createListGoals(gs, true);
            List<RelationshipGoalsWrapper> relationshipGoalsWrapperList = GoldSheetStrategyTabPDFController.getRelationshipGoals(
                gs.id
            );
            System.assertEquals(
                relationshipGoalsWrapperList[0].goalStatus,
                'Complete',
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }
}