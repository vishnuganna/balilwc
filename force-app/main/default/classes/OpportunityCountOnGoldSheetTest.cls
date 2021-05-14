@istest
public with sharing class OpportunityCountOnGoldSheetTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Opportunity opp = TestDataUtil.createOpportunity(acc, true);
            Opportunity opp1 = TestDataUtil.createOpportunity(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            Gold_Sheet_Single_Sales_Objective__c gSSO = TestDataUtil.createGoldSheetSSO(gs, opp, true);
            Gold_Sheet_Single_Sales_Objective__c gSSO1 = TestDataUtil.createGoldSheetSSO(gs, opp1, true);
        }
    }

    @istest
    static void countSSOonGoldSheetTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Gold_Sheet_Single_Sales_Objective__c> gSSOList = [
                SELECT Id, Name, Gold_Sheet__c
                FROM Gold_Sheet_Single_Sales_Objective__c
            ];
            Test.startTest();
            OpportunityCountOnGoldSheet.countSSOonGoldSheet(gSSOList);
            system.assertEquals(gSSOList.size(), 2, 'Check List Szie');
            system.assertEquals(goldSheet.Id, gSSOList[0].Gold_Sheet__c, 'Check GoldSheetId');
            Test.stopTest();
        }
    }
}