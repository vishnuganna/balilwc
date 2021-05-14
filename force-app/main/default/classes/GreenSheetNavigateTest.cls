@istest
public with sharing class GreenSheetNavigateTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
        }
    }
    static testMethod void createGreenSheetTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            Green_Sheet__c green = [SELECT Id FROM Green_Sheet__c WHERE Task_Id__c = :taskList[0].Id LIMIT 1];
            system.assertequals(greenSheetId, green.Id, 'Error on createGreenSheetTest');
            String greenNewSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
        }
    }
}