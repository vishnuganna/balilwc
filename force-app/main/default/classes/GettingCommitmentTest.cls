@isTest
public with sharing class GettingCommitmentTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
        }
    }

    @istest
    static void testGetGettingCommitmentAccess() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = GettingCommitment.getGettingCommitmentAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }

    @istest
    static void testGetCommitmentQuestionAccess() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = GettingCommitment.getCommitmentQuestionAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
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
            List<GettingCommitmentWrapper> gcWrapperList = GettingCommitment.getGettingCommitmentData(greenSheetId);
            system.assertequals(gcWrapperList[0].bestActionCommitment, 'best action1', 'Checking best action');
            Test.stopTest();
        }
    }

    @istest
    static void testUpsertCommitmentQuestion() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            Green_Sheet__c greenSheet2 = TestDataUtil.createGreenSheet(taskList[1], true);
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            String greenSheet2Id = greenSheet2.Id;
            String gcId = greenGC[0].id;
            String jsonStringNoGC = '{ "greenSheet":"' + greenSheet2Id + '","commitmentQuestion":"question1 no gc"}';
            String jsonString =
                '{ "greenSheet":"' +
                greenSheetId +
                '" , "gettingCommitment":"' +
                gcId +
                '" ,"commitmentQuestion":"question1"}';
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('commitmentQuestions', rfs2);
            Test.startTest();
            GettingCommitment.upsertCommitmentQuestion(jsonStringNoGC, greenSheet2Id, rfsData2);
            GettingCommitment.upsertCommitmentQuestion(jsonString, greenSheetId, rfsData2);
            List<Commitment_Question__c> question = [
                SELECT Id, Getting_Commitment__c, Question__c
                FROM Commitment_Question__c
                WHERE Getting_Commitment__c = :gcId
            ];
            String jsonStringUpdated =
                '{ "greenSheet":"' +
                greenSheetId +
                '" , "id":"' +
                question[0].id +
                '" ,"gettingCommitment":"' +
                gcId +
                '" ,"commitmentQuestion":"question2"}';
            GettingCommitment.upsertCommitmentQuestion(jsonStringUpdated, greenSheetId, rfsData2);
            System.assertEquals(question[0].Id != null, true, 'CommitmentQuestion Record created!');
            Test.stopTest();
        }
    }

    @istest
    static void testUpsertBestActionCommitment() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            String greenSheetId = greenSheet.Id;
            String jsonString = '{ "greenSheet":"' + greenSheetId + '" , "bestActionCommitment":"best ac1"}';
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('BestActionCommitment', rfs2);
            Test.startTest();
            GettingCommitment.upsertBestActionCommitment(jsonString, rfsData2);
            List<Getting_Commitment__c> gc = [SELECT Id, Best_Action_Commitment__c FROM Getting_Commitment__c];
            String jsonStringUpdated =
                '{ "greenSheet":"' +
                greenSheetId +
                '" , "id":"' +
                gc[0].Id +
                '","bestActionCommitment":"best ac1 updated"}';
            GettingCommitment.upsertBestActionCommitment(jsonStringUpdated, rfsData2);
            System.assertEquals(gc[0].Id != null, true, 'BestActionCommitment Record created!');
            Test.stopTest();
        }
    }

    @istest
    static void testUpsertMinimumActionCommitment() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            String greenSheetId = greenSheet.Id;
            String jsonString = '{ "greenSheet":"' + greenSheetId + '" , "minimumActionCommitment":"min ac1"}';
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('MinimumActionCommitment', rfs2);
            Test.startTest();
            GettingCommitment.upsertMinimumActionCommitment(jsonString, rfsData2);
            List<Getting_Commitment__c> gc = [
                SELECT Id, Minimum_Acceptable_Action_Commit__c
                FROM Getting_Commitment__c
            ];
            String jsonStringUpdated =
                '{ "greenSheet":"' +
                greenSheetId +
                '" , "id":"' +
                gc[0].Id +
                '","minimumActionCommitment":"min ac1 updated"}';
            GettingCommitment.upsertMinimumActionCommitment(jsonStringUpdated, rfsData2);
            System.assertEquals(gc[0].Id != null, true, 'MinimumActionCommitment Record created!');
            Test.stopTest();
        }
    }

    @istest
    static void testDeleteMinimumActionCommitment() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, true);
            Test.startTest();
            String greenSheetId = greenSheet.Id;
            System.assertEquals(true, greenSheetId != null, 'MinimumActionCommitment Record Id is not null');
            GettingCommitment.deleteMinimumActionCommitment(greenSheetId);
            Test.stopTest();
        }
    }

    @istest
    static void testDeleteBestActionCommitment() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, true);
            Test.startTest();
            String greenSheetId = greenSheet.Id;
            System.assertEquals(true, greenSheetId != null, 'BestActionCommitment Record Id is not null');
            GettingCommitment.deleteBestActionCommitment(greenSheetId);
            Test.stopTest();
        }
    }

    @istest
    static void testDeleteCommitmentQuestion() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Commitment__c> greenGC = TestDataUtil.createGreenSheetGettingCommitment(greenSheet, true);
            Test.startTest();
            String gcId = greenGC[0].Id;
            List<Commitment_Question__c> cqList = TestDataUtil.createGreenSheetCommitmentQuestion(greenGC[0], true);
            System.assertEquals(true, gcId != null, 'CommitmentQuestion Record Id is not null');
            GettingCommitment.deleteCommitmentQuestion(cqList[0].Id);
            Test.stopTest();
        }
    }
}