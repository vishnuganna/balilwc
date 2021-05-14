@isTest
public with sharing class BlueSheetWrapperTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
        }
    }

    @isTest
    static void validateConstrPara() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Blue_Sheet__c> bi = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];

            Test.startTest();
            BlueSheetWrapperClass bsWrapper = new BlueSheetWrapperClass(bi[0]);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }
}