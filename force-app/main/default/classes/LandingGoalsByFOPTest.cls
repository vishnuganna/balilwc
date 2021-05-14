@istest
public with sharing class LandingGoalsByFOPTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Relationship_Goal__c> goals = TestDataUtil.createListGoals(gs, true);
        }
    }
    /*
    @isTest
    static void getupdateRelationshopGoalsTest() {
        User user1 = UserTest.createUserAsManager();
        System.runAs(user1) {
            Account acc = [SELECT Name, OwnerId FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            TestDataUtil.createListGoals(goldSheet, true);
            Gold_Sheet__c goldSheetAfterUpdate = [
                SELECT Id, Name, Goals_Completed__c, Goals_Present__c
                FROM Gold_Sheet__c
                WHERE Account__c = :acc.Id
                LIMIT 1
            ];
        }
        User use = UserTest.createUserWithPerms();
        System.runAs(use) {
            Account acc = [SELECT Name, OwnerId FROM Account WHERE Name = 'Test Account' LIMIT 1];
            List<String> userIdSet = new List<String>();
            userIdSet.add(user1.Id);
            userIdSet.add(use.Id);
            userIdSet.add(acc.OwnerId);
            LandingGoalsByFOP.GoalsByFOPRecordsInfo info = LandingGoalsByFOP.getGoalsByFOPRecords(userIdSet, 10, 0);
            system.assertEquals(1, info.totalRecordCount, 'Checking returned value from getGoalsByFOPRecords');
            system.assertNotEquals(2, info.totalRecordCount, 'Checking returned value from getGoalsByFOPRecords');
        }
    }
*/
}