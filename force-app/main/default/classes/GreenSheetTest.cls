@istest
public with sharing class GreenSheetTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Task task = TestDataUtil.createTask(user, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(task, true);
        }
    }

    @isTest
    static void updateGreenSheetTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Task task = [SELECT Id, Subject, OwnerId FROM Task LIMIT 1];
            String updatedSubject = 'test subject';
            task.Subject = updatedSubject;
            List<Task> listTask = new List<task>();
            listTask.add(task);
            DataFactory.upsurt(listTask);
            Test.startTest();
            Green_Sheet__c greenSheet = [SELECT Id, Task_Name__c FROM Green_Sheet__c LIMIT 1];
            system.assertequals(greenSheet.Task_Name__c, updatedSubject, 'Error on updateGreenSheetTest');
            Test.stopTest();
        }
    }

    @isTest
    static void deleteGreenSheetTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Green_Sheet__c> greenSheetRecord = [SELECT Id, Task_Name__c FROM Green_Sheet__c];
            String taskId = GreenSheet.greensheetDelete(greenSheetRecord[0].Id);
            greenSheetRecord = [SELECT Id, Task_Name__c FROM Green_Sheet__c];
            system.assertEquals(greenSheetRecord.size(), 0);
        }
    }
}