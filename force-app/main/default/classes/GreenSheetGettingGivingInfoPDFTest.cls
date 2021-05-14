@istest
public with sharing class GreenSheetGettingGivingInfoPDFTest {
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
    static void getGIQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Information__c> greenGI = TestDataUtil.createGreenSheetGettingInfoQuestion(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<GettingInformationWrapper> greengiquestList = GreenSheetGettingGivingInformationPDF.getGIQuestions(
                greenSheetId
            );
            system.assertequals(greengiquestList[0].question, 'Is the a test Question?', 'Checking Question');
            system.assertequals(
                greengiquestList[0].goldenSilence,
                false,
                'Checking GoldenSilence in Greensheet Getting Information'
            );
        }
    }
    @istest
    static void getGivingInformationRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Giving_Information__c> greenGI = TestDataUtil.createGreenSheetGivingInfo(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<GivingInformationWrapper> greengiquestList = GreenSheetGettingGivingInformationPDF.getGivingInformationRecords(
                greenSheetId
            );
            system.assertequals(
                greengiquestList[0].description,
                'Is the a test giving information?',
                'Checking Question'
            );
            system.assertequals(
                greengiquestList[0].isPerspective,
                false,
                'Checking isPerspective in Greensheet Giving Information'
            );
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            GreenSheetGettingGivingInformationPDF pdfObj = new GreenSheetGettingGivingInformationPDF();
            Green_Sheet__c green = [SELECT Id FROM Green_Sheet__c WHERE Task_Id__c = :taskList[0].Id LIMIT 1];
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }
}