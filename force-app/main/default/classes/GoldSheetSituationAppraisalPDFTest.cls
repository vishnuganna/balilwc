@isTest
public with sharing class GoldSheetSituationAppraisalPDFTest {
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
            GoldSheetSituationAppraisalPDFController pdfObj = new GoldSheetSituationAppraisalPDFController();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            PageReference pageRef = Page.goldsheetA4; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(gs.Id));
            Test.setCurrentPage(pageRef);
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }

    @isTest
    static void getCriticalVulnerabilityRecordForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            CriticalVulnerabilityWrapper criticalVulnerability = GoldSheetSituationAppraisalPDFController.getCriticalVulnerabilityRecordForPDF(
                gs.id
            );
            System.assertEquals(
                criticalVulnerability.title,
                'Critical Title Sample',
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void getStrategicPlayerDataForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createListStrategicPlayer(gs, con, true);
            List<StrategicPlayerWrapper> strategicPlayers = GoldSheetSituationAppraisalPDFController.getStrategicPlayerDataForPDF(
                gs.id
            );
            System.assertEquals(strategicPlayers[0].role, 'Sponsor', 'Inserted Test Record role must be a match');
            Test.stopTest();
        }
    }

    @isTest
    static void getTrendsRecordsForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createListFopTrends(gs, true);
            List<FieldOfPlayTrendWrapperClass> fopTrends = GoldSheetSituationAppraisalPDFController.getTrendsRecordsForPDF(
                gs.id
            );
            System.assertEquals(fopTrends[0].trendTitle, 'Sponsor', 'Inserted Test Record role must be a match');
            Test.stopTest();
        }
    }

    @isTest
    static void getFopOpportunitiesForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createListFopOpps(gs, con, true);
            List<FieldOfPlayOppController.PlayOppWrapper> fopOpportunities = GoldSheetSituationAppraisalPDFController.getFopOpportunitiesForPDF(
                gs.id
            );
            System.assertEquals(fopOpportunities[0].title, 'Title 1', 'Inserted Test Record role must be a match');
            Test.stopTest();
        }
    }

    @isTest
    static void getStrategicStrengthRecordsForPDFTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // testData();
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            Contact con = [SELECT id, Accountid FROM Contact LIMIT 1];
            TestDataUtil.createListFopStrengths(gs, true);
            List<StrategicStrengthWrapper> strategicStrengths = GoldSheetSituationAppraisalPDFController.getStrategicStrengthRecordsForPDF(
                gs.id
            );
            System.assertEquals(
                strategicStrengths[0].strategicStrength,
                'Sponsor',
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }
}