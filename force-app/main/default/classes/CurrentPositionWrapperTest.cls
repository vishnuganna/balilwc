@isTest
public with sharing class CurrentPositionWrapperTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Current_Position__c cp = TestDataUtil.createCurrentPosition(bs, true);
        }
    }

    @isTest
    static void validateConstrPara() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Current_Position__c cp = [
                SELECT Id, Name, Current_Position__c, Blue_Sheet__c
                FROM Current_Position__c
                LIMIT 1
            ];
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];

            Test.startTest();
            CurrentPositionWrapper cpWrapper = new CurrentPositionWrapper(cp);
            CurrentPositionWrapper.convertWrapperToObject(cpWrapper);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }
}