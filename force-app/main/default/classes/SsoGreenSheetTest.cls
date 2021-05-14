@isTest
public with sharing class SsoGreenSheetTest {
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acnt = TestDataUtil.createAccount(true);
            Opportunity opty = TestDataUtil.createOpportunity(acnt, true);
            Blue_Sheet__c bluesheet = TestDataUtil.createBluesheet(opty, true);
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bluesheet, true);
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
        }
    }

    @isTest
    static void getSSOGreenSheetTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Test.startTest();

            Opportunity opty = [SELECT Id, Name FROM Opportunity LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Green_Sheet__c greenSheet = [SELECT Id, Task_Id__c FROM Green_Sheet__c LIMIT 1];
            Task task = [SELECT Id, Subject FROM Task LIMIT 1];
            task.WhatId = opty.id;
            List<Task> taskListToUpdate = new List<Task>();
            taskListToUpdate.add(task);
            DataFactory.modify(taskListToUpdate);

            List<OpportunitySSOWrapper> greenSheetOppSSOWrapperList = new List<OpportunitySSOWrapper>();
            greenSheetOppSSOWrapperList = SsoGreenSheet.getSSOGreenSheet(greenSheet.Id);
            system.assertEquals(true, greenSheetOppSSOWrapperList.size() > 0, 'Checking size of the list is not null');
            Test.stopTest();
        }
    }

    @isTest
    static void checkAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Map<String, Boolean> accessMap = new Map<String, Boolean>();
            String objName = 'Green_Sheet__c';
            Test.startTest();
            Map<String, Boolean> accessData = SsoGreenSheet.getGreenSheetAccess();
            ApexCommonUtil.getObjectAccess(objName);
            system.assertEquals(4, accessData.size(), 'Check access map size');
            Test.stopTest();
        }
    }
}