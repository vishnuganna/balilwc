@isTest
public with sharing class GreenSheetPDFControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Task task = TestDataUtil.createTask(user, true);
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheetVBR(task, true);
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            GreenSheetPDFController pdfObj = new GreenSheetPDFController();
            Green_Sheet__c green = [SELECT Id FROM Green_Sheet__c WHERE Task_Id__c = :taskList[0].Id LIMIT 1];
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }

    @isTest
    static void getGreenSheetByIdTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Green_Sheet__c bs = [
                SELECT
                    id,
                    Name,
                    Task_Name__c,
                    Task_Owner__c,
                    Task_Owner_Id__c,
                    Last_Updated__c,
                    Meeting_Date__c,
                    Related_To_Name__c
                FROM Green_Sheet__c
                LIMIT 1
            ];
            GreenSheetAndTaskDataWrapperClass greenSheetAndOpportunityData = GreenSheetPDFController.getGreenSheetById(
                bs.id
            );
            System.assertEquals(greenSheetAndOpportunityData.greenSheetName, bs.name, 'Test Record must be 1');
            Test.stopTest();
        }
    }
}