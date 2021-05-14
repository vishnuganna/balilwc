@isTest
public with sharing class CustomLookupControllerTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
        }
    }

    @isTest
    static void validateFindRecordsConstr() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            CustomLookupController c = new CustomLookupController();
            system.assertEquals(true, c != null);
        }
    }

    @isTest
    static void validateFindRecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String searchKey = 'test';
            String accountId = '';
            Account account = [SELECT Id FROM Account LIMIT 1];
            String accountIds = account.Id;
            Test.startTest();
            CustomLookupController.findRecords(searchKey, accountId);
            CustomLookupController.findStrategicPlayerRecords(searchKey, accountIds);
            System.assertEquals(searchKey, 'test');
            Test.stopTest();
        }
    }
}