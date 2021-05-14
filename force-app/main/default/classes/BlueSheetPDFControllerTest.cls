@isTest
public with sharing class BlueSheetPDFControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Opportunity opt = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bss = TestDataUtil.createBluesheet(opt, true);
        }
    }

    @isTest
    static void getSSORecordsForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            TestDataUtil.createSSO(bs, true);
            SingleSalesObjectiveController.SingleSalesObjectiveWrapper singleSalesObjectiveWrapper = BlueSheetPDFController.getSSORecordsForPDF(
                bs.id
            );
            System.assertEquals(
                singleSalesObjectiveWrapper.evaluationOfObjectives,
                'Test Record',
                'Test Record must be match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getCurrentPostionPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            TestDataUtil.createCurrentPosition(bs, true);
            String currentPostion = BlueSheetPDFController.getCurrentPostionPDF(bs.id);
            System.assertEquals(currentPostion, 'Comfort', 'Test Record must be Comfort');
            Test.stopTest();
        }
    }
    @isTest
    static void getScoreCardForBlueSheetPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Score_Card__c scoreCard = TestDataUtil.createScoreCard(bs, true);
            TestDataUtil.createScoreCardDetails(scoreCard, true);
            scoreCardOpptyWrapper scoreCardOppty = BlueSheetPDFController.getScoreCardForBlueSheetPDF(bs.id);
            System.assertEquals(scoreCardOppty.potentialScore, 60, 'Test Record must be 60');
            Test.stopTest();
        }
    }

    @isTest
    static void getCompetitionForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            TestDataUtil.createCompetition(bs, acc, true);
            List<CompetitionWrapperClass> listOfComp = BlueSheetPDFController.getCompetitionForPDF(bs.id);
            System.assertEquals(listOfComp.size(), 1, 'Test Record must be 1');
            Test.stopTest();
        }
    }

    @isTest
    static void getBuyingInfluenceForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact' LIMIT 1];
            TestDataUtil.createBuyingInfluence(bs, con, true);
            List<BuyingInfluenceWrapperClass> listOfBuyingInfluence = BlueSheetPDFController.getBuyingInfluenceForPDF(
                bs.id
            );
            System.assertEquals(listOfBuyingInfluence.size(), 3, 'Test Record must be 3');
            Test.stopTest();
        }
    }

    @isTest
    static void getSOMPRecordsForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            TestDataUtil.createSummaryOfMyPosition(bs, true);
            BlueSheetPDFController.PositionSummaryPdfWrapper listOfPositionSummary = BlueSheetPDFController.getSOMPRecordsForPDF(
                bs.id
            );
            System.assertEquals(listOfPositionSummary != null, true, 'Test Record must be 2');
            Test.stopTest();
        }
    }

    @isTest
    static void getActionPlanForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            TestDataUtil.createActionPlan(bs, true);
            List<ActionPlanWrapperClass> listOfActionPlan = BlueSheetPDFController.getActionPlanForPDF(bs.id);
            System.assertEquals(listOfActionPlan.size(), 1, 'Test Record must be 1');
            Test.stopTest();
        }
    }

    @isTest
    static void getBlueSheetByIdTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Blue_Sheet__c bs = [SELECT id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            BlueSheetAndOpportunityDataWrapperClass blueSheetAndOpportunityData = BlueSheetPDFController.getBlueSheetById(
                bs.id
            );
            System.assertEquals(blueSheetAndOpportunityData.blueSheetName, bs.name, 'Test Record must be 1');
            Test.stopTest();
        }
    }
}