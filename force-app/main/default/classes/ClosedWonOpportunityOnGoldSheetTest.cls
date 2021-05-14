@istest
public with sharing class ClosedWonOpportunityOnGoldSheetTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Opportunity opp = TestDataUtil.createOpportunity(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    @istest
    static void checkIfClosedWonTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Opportunity opp1 = TestDataUtil.createOpportunity(acc, false);
            opp1.AccountId = acc.Id;
            insert opp1;
            Test.startTest();
            opp1.StageName = 'Closed Won';
            update opp1;
            Test.stopTest();
            Opportunity opty = [
                SELECT Id, Name, Has_an_Associated_GoldSheet__c
                FROM Opportunity
                WHERE StageName = 'Closed Won'
                LIMIT 1
            ];
            system.assertEquals(opty.Has_an_Associated_GoldSheet__c, true, 'data is incorrect');
        }
    }
}