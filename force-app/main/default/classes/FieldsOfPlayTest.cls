@isTest
public with sharing class FieldsOfPlayTest {
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
        }
    }
    static testMethod void getTest() {
        testData();
        List<Gold_Sheet__c> g = [SELECT Id FROM Gold_Sheet__c];
        system.assertEquals(true, g.size() > 0);
    }
}