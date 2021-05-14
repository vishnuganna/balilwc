@isTest
public with sharing class CommitmentQuestionTriggerHelperTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
        }
    }
    @istest
    static void testGetGettingCommitmentData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<Commitment_Question__c> cqList = TestDataUtil.createGreenSheetCommitmentQuestion(greenGC[0], true);
            Test.startTest();
            Green_Sheet__c greemSheetRec = [
                SELECT Id, Name, Count_Commitment_Question__c
                FROM Green_Sheet__c
                WHERE Id = :greenSheet.Id
                LIMIT 1
            ];
            system.assertequals(greemSheetRec.Count_Commitment_Question__c, 2, 'Checking questions count');
            Test.stopTest();
        }
    }
    @istest
    static void testremoveGettingCommitmentData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<Commitment_Question__c> cqList = TestDataUtil.createGreenSheetCommitmentQuestion(greenGC[0], true);
            delete cqList;
            List<Commitment_Question__c> commitmentQuestions = [
                SELECT Id, Name
                FROM Commitment_Question__c
                WHERE Getting_Commitment__c = :greenGC[0].Id
            ];
            Test.startTest();
            Green_Sheet__c greemSheetRec = [
                SELECT Id, Name, Count_Commitment_Question__c
                FROM Green_Sheet__c
                WHERE Id = :greenSheet.Id
                LIMIT 1
            ];
            system.assertequals(0, commitmentQuestions.size(), 'Checking questions count');
            Test.stopTest();
        }
    }
}