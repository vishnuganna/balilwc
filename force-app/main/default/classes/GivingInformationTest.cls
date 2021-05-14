@istest
public with sharing class GivingInformationTest {
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
    static void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = GivingInformation.getGivingInfoAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }

    @istest
    static void getGIQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Giving_Information__c> greenGI = TestDataUtil.createGreenSheetGivingInfo(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<GivingInformationWrapper> greengiquestList = GivingInformation.getGivingInformationRecords(
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

    @istest
    static void removeGreenGivingInfoTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Giving_Information__c> greenGI = TestDataUtil.createGreenSheetGivingInfo(greenSheet, true);
            Test.startTest();
            GivingInformation.removeGreenGivingInfo(greenGI[0].Id);
            String greenSheetId = greenSheet.Id;
            List<GivingInformationWrapper> greengiquestList = GivingInformation.getGivingInformationRecords(
                greenSheetId
            );
            system.assertequals(greengiquestList.size(), 2, 'Checking size for GreenSheet Getting Information');
        }
    }

    @istest
    static void upsertGIQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            String greenSheetId = greenSheet.Id;
            map<String, Object> newGiQMap = new Map<String, Object>();
            newGiQMap.put('title', 'Attitude');
            newGiQMap.put('description', 'Attitude Question?');
            newGiQMap.put('isPerspective', true);
            newGiQMap.put('greenSheet', greenSheetId);
            String jsonstring = JSON.Serialize(newGiQMap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', true);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('title', rfs);
            GivingInformation.upsertGivingInfo(jsonstring, rfsData);
            List<Giving_Information__c> lstInformationQuestions = [
                SELECT Id, Title__c
                FROM Giving_Information__c
                WHERE Title__c = 'Attitude'
            ];
            system.assertEquals(1, lstInformationQuestions.size());
            map<String, Object> newGiQMap2 = new Map<String, Object>();
            newGiQMap2.put('description', 'Test Attitude Question?');
            newGiQMap2.put('title', 'Attitude');
            newGiQMap2.put('isPerspective', false);
            newGiQMap2.put('greenSheet', greenSheetId);
            newGiQMap2.put('id', lstInformationQuestions[0].Id);
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', false);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('title', rfs2);
            String jsonstring2 = JSON.Serialize(newGiQMap2);
            GivingInformation.upsertGivingInfo(jsonstring2, rfsData2);
            List<GivingInformationWrapper> greengiquestList = GivingInformation.getGivingInformationRecords(
                greenSheetId
            );
            system.assertequals(greengiquestList.size(), 1, 'Checking size for GreenSheet Getting Information');
            system.assertNotequals(greengiquestList.size(), 4, 'Checking size for GreenSheet Getting Information');
        }
    }
}