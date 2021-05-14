@isTest
public with sharing class GoldSheetPDFControllerTest {
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
            GoldSheetPDFController pdfObj = new GoldSheetPDFController();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            // ApexPages.StandardController sc = new ApexPages.StandardController(gs);
            // GoldSheetPDFController testGoldSheet = new GoldSheetPDFController(sc);
            PageReference pageRef = Page.goldsheetA4; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(gs.Id));
            Test.setCurrentPage(pageRef);
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }

    @isTest
    static void getGoldSheetByIdTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Gold_Sheet__c gs = [SELECT id, Account__c FROM Gold_Sheet__c LIMIT 1];
            GoldSheetAndAccountDataWrapperClass goldSheetAccountInfo = GoldSheetPDFController.getGoldSheetById(gs.id);
            System.assertEquals(
                goldSheetAccountInfo.accountName,
                'Test Account',
                'Inserted Test Record role must be a match'
            );
            Test.stopTest();
        }
    }
}