@istest
public with sharing class BasicIssuesTest {
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
    static void getBasicIssueAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = BasicIssues.getBasicIssueAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
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
            List<BasicIssuesWrapper> basicIssueQuestList = BasicIssues.getBasicIssueRecords(greenSheetId);
            system.assertequals(basicIssueQuestList[0].question, 'Is the a test Issue?', 'Checking Issue Question');
            system.assertequals(basicIssueQuestList.size(), 2, 'Size of Records reurned');
        }
    }

    @istest
    static void removeBasicIssueQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            List<Basic_Issues__c> greenGI = TestDataUtil.createGSBasicIssuesQuestion(greenSheet, true);
            Test.startTest();
            BasicIssues.removeBasicIssueRecords(greenGI[0].Id);
            String greenSheetId = greenSheet.Id;
            List<BasicIssuesWrapper> basicIssueQuestList = BasicIssues.getBasicIssueRecords(greenSheetId);
            system.assertequals(
                basicIssueQuestList.size(),
                1,
                'Checking size for GreenSheet Basic Issues after delete'
            );
            system.assertequals(
                basicIssueQuestList[0].question,
                'Is the a test Issue?',
                'Checking Issue remaining after delete'
            );
        }
    }

    @istest
    static void upsertBasicIssueQuestionsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            String greenSheetId = greenSheet.Id;
            map<String, Object> newbasicIssueQMap = new Map<String, Object>();
            newbasicIssueQMap.put('questionType', 'Basic Issue');
            newbasicIssueQMap.put('question', 'Issue Question?');
            newbasicIssueQMap.put('greenSheet', greenSheetId);
            String jsonstring = JSON.Serialize(newbasicIssueQMap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', true);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('IssueQuestionTpye', rfs);
            BasicIssues.upsertBasicIssueRecords(jsonstring, rfsData);
            List<Basic_Issues__c> listIssueQuestions = [
                SELECT Id, Question_Type__c
                FROM Basic_Issues__c
                WHERE Question_Type__c = 'Basic Issue'
            ];
            system.assertEquals(1, listIssueQuestions.size(), 'Record Size');
            map<String, Object> newbasicIssueQMap2 = new Map<String, Object>();
            newbasicIssueQMap2.put('question', 'Test Issue Question?');
            newbasicIssueQMap2.put('questionType', 'Basic Issue Question');
            newbasicIssueQMap2.put('greenSheet', greenSheetId);
            newbasicIssueQMap2.put('id', listIssueQuestions[0].Id);
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', false);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('IssueQuestionTpye', rfs2);
            String jsonstring2 = JSON.Serialize(newbasicIssueQMap2);
            BasicIssues.upsertBasicIssueRecords(jsonstring2, rfsData2);
            List<BasicIssuesWrapper> basicIssueQuestList = BasicIssues.getBasicIssueRecords(greenSheetId);
            system.assertequals(basicIssueQuestList.size(), 1, 'Checking GreenSheet Basic Issues size after update');
            system.assertNotequals(
                basicIssueQuestList.size(),
                4,
                'Checking Basic Issues for records returned size after update'
            );
        }
    }
}