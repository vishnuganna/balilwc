@isTest
public with sharing class GreenSheetCommitmentandIssuesPDFTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
        }
    }

    @istest
    static void getBasicIssueQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Basic_Issues__c> greenGI = TestDataUtil.createGSBasicIssuesQuestion(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<BasicIssuesWrapper> basicIssueQuestList = GreenSheetCommitmentandIssuesPDF.getBasicIssueRecords(
                greenSheetId
            );
            system.assertequals(basicIssueQuestList[0].question, 'Is the a test Issue?', 'Checking Issue Question');
            system.assertequals(basicIssueQuestList.size(), 2, 'Size of Records reurned');
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
            List<GettingCommitmentWrapper> gcWrapperList = GreenSheetCommitmentandIssuesPDF.getGettingCommitmentData(
                greenSheetId
            );
            system.assertequals(gcWrapperList[0].bestActionCommitment, 'best action1', 'Checking best action');
            Test.stopTest();
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            GreenSheetCommitmentandIssuesPDF pdfObj = new GreenSheetCommitmentandIssuesPDF();
            Green_Sheet__c green = [SELECT Id FROM Green_Sheet__c WHERE Task_Id__c = :taskList[0].Id LIMIT 1];
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }
}