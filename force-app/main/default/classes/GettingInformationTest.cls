@istest
public with sharing class GettingInformationTest {
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
            Map<String, Boolean> objectPermissionValue = GettingInformation.getInfoQuestionsAccess();
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
            List<Getting_Information__c> greenGI = TestDataUtil.createGreenSheetGettingInfoQuestion(greenSheet, true);
            String greenSheetId = greenSheet.Id;
            List<GettingInformationWrapper> greengiquestList = GettingInformation.getGIQuestions(greenSheetId);
            system.assertequals(greengiquestList[0].question, 'Is the a test Question?', 'Checking Question');
            system.assertequals(
                greengiquestList[0].goldenSilence,
                false,
                'Checking GoldenSilence in Greensheet Getting Information'
            );
        }
    }

    @istest
    static void removeGreenGIQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Getting_Information__c> greenGI = TestDataUtil.createGreenSheetGettingInfoQuestion(greenSheet, true);
            Test.startTest();
            GettingInformation.removeGreenGIQuestions(greenGI[0].Id);
            String greenSheetId = greenSheet.Id;
            List<GettingInformationWrapper> greengiquestList = GettingInformation.getGIQuestions(greenSheetId);
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
            newGiQMap.put('questionType', 'Attitude');
            newGiQMap.put('question', 'Attitude Question?');
            newGiQMap.put('goldenSilence', true);
            newGiQMap.put('greenSheet', greenSheetId);
            String jsonstring = JSON.Serialize(newGiQMap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', true);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('QuestionTpye', rfs);
            GettingInformation.upsertGIQuestions(jsonstring, rfsData);
            List<Getting_Information__c> lstInformationQuestions = [
                SELECT Id, Question_Type__c
                FROM Getting_Information__c
                WHERE Question_Type__c = 'Attitude'
            ];
            system.assertEquals(1, lstInformationQuestions.size());
            map<String, Object> newGiQMap2 = new Map<String, Object>();
            newGiQMap2.put('question', 'Test Attitude Question?');
            newGiQMap2.put('questionType', 'Attitude');
            newGiQMap2.put('goldenSilence', false);
            newGiQMap2.put('greenSheet', greenSheetId);
            newGiQMap2.put('id', lstInformationQuestions[0].Id);
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', false);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('QuestionTpye', rfs2);
            String jsonstring2 = JSON.Serialize(newGiQMap2);
            GettingInformation.upsertGIQuestions(jsonstring2, rfsData2);
            List<GettingInformationWrapper> greengiquestList = GettingInformation.getGIQuestions(greenSheetId);
            system.assertequals(greengiquestList.size(), 1, 'Checking size for GreenSheet Getting Information');
            system.assertNotequals(greengiquestList.size(), 4, 'Checking size for GreenSheet Getting Information');
        }
    }
}