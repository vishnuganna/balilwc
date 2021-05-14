@isTest
public with sharing class GoldSheetRevenueTabPDFControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity opp = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Revenue_Target_Detail__c> rtdList = TestDataUtil.createRevenueDetail(true);
            Revenue_Target__c rt = TestDataUtil.createRevenueTarget(gs, rtdList[0], true);
            Revenue_Target__c rtNxt = TestDataUtil.createRevenueTarget(gs, rtdList[1], true);
            Gold_Sheet_Single_Sales_Objective__c ssoGs = TestDataUtil.createGoldSheetSSO(gs, opp, true);
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            GoldSheetRevenueTabPDFController pdfObj = new GoldSheetRevenueTabPDFController();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            PageReference pageRef = Page.goldsheetA4; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(gs.Id));
            Test.setCurrentPage(pageRef);
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }

    @isTest
    static void getRevenueTargetDataTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            RevenueTargetWrapper revenueTargetWrapper = GoldSheetRevenueTabPDFController.getRevenueTargetData(gs.id);
            System.assertEquals(
                revenueTargetWrapper.goldSheetId,
                gs.id,
                'Inserted Test Record goldsheet must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getGoldSheetSSODataTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Opportunity op = [SELECT id, name FROM Opportunity LIMIT 1];
            List<GoldSheetSSOWrapper> goldSheetSSOWrapperList = GoldSheetRevenueTabPDFController.getGoldSheetSSOData(
                gs.id
            );
            System.assertEquals(
                goldSheetSSOWrapperList[0].oppId,
                op.id,
                'Inserted Test Record opportunity must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getSSOTotalRevenueTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Opportunity op = [SELECT id, name FROM Opportunity LIMIT 1];
            op.Amount = 1000;
            upsert op;
            Decimal revenue = GoldSheetRevenueTabPDFController.getSSOTotalRevenue(gs.id);
            System.assertEquals(revenue, 100, 'Inserted Test Record revenue must be a match');
            Test.stopTest();
        }
    }
}