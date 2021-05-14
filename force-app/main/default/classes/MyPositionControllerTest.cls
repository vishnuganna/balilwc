@isTest
private with sharing class MyPositionControllerTest {
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            opportunity objOppt = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c blueSheet = TestDataUtil.createBluesheet(objOppt, true);
        }
    }

    static testMethod void createSummaryRecTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Map<String, String> sumData = new Map<String, String>();
            sumData.put('summary', 'Test Summary');
            sumData.put('description', 'Test Description');
            sumData.put('redFlag', 'false');
            sumData.put('strength', 'true');

            Test.startTest();
            MyPositionController.createSummaryRec(sumData, objOppt.Id);
            List<Summary_of_My_Position_Today__c> sum = [
                SELECT Id, Blue_Sheet__c, Summary__c, Description__c
                FROM Summary_of_My_Position_Today__c
            ];
            system.assertEquals(sum.size(), 1);
            Test.stopTest();
        }
    }

    static testMethod void getSOMPRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Summary_of_My_Position_Today__c sop = new Summary_of_My_Position_Today__c();
            sop.Summary__c = 'Test Summary';
            sop.Description__c = 'Test Description';
            sop.Is_a_Strength__c = true;
            sop.Is_a_Red_Flag__c = false;

            Map<String, String> sumData = new Map<String, String>();
            sumData.put('summary', 'Test Summary');
            sumData.put('description', 'Test Description');
            sumData.put('redFlag', 'false');
            sumData.put('strength', 'true');

            Test.startTest();
            MyPositionController.createSummaryRec(sumData, objOppt.Id);
            MyPositionController.PositionSummaryWrapper wrap = new MyPositionController.PositionSummaryWrapper(
                sop,
                true
            );
            List<MyPositionController.PositionSummaryWrapper> recordListWrap = MyPositionController.getSOMPRecords(
                objOppt.Id
            );
            system.assertEquals(true, recordListWrap.size() > 0);
            Test.stopTest();
        }
    }

    static testMethod void deleteSOMPRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Summary_of_My_Position_Today__c sop = new Summary_of_My_Position_Today__c();
            sop.Summary__c = 'Test Summary';
            sop.Description__c = 'Test Description';
            sop.Is_a_Strength__c = true;
            sop.Is_a_Red_Flag__c = false;

            Map<String, String> sumData = new Map<String, String>();
            sumData.put('summary', 'Test Summary');
            sumData.put('description', 'Test Description');
            sumData.put('redFlag', 'false');
            sumData.put('strength', 'true');

            Test.startTest();
            MyPositionController.createSummaryRec(sumData, objOppt.Id);
            sop.Summary__c = 'UpdateTest';
            MyPositionController.deleteSOMPRecord(sop.Id);
            List<Summary_of_My_Position_Today__c> sum = [
                SELECT Id, Blue_Sheet__c, Summary__c, Description__c
                FROM Summary_of_My_Position_Today__c
                WHERE Id = :sop.Id
            ];
            system.assertEquals(sum.size(), 0);
            Test.stopTest();
        }
    }

    static testMethod void updateSOMPRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Blue_Sheet__c blueSheet = [SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c = :objOppt.Id];
            Summary_of_My_Position_Today__c sop = new Summary_of_My_Position_Today__c();
            sop.Summary__c = 'Test Summary';
            sop.Description__c = 'Test Description';
            sop.Is_a_Strength__c = true;
            sop.Is_a_Red_Flag__c = false;
            sop.Blue_Sheet__c = blueSheet.Id;
            insert sop;

            Test.startTest();
            Map<string, string> sumData = new Map<string, string>();
            sumData.put('summary', 'Test UpdateTest');
            sumData.put('recId', sop.Id);
            MyPositionController.updateSOMPRecord(sumData);
            List<Summary_of_My_Position_Today__c> sum = [
                SELECT Id, Blue_Sheet__c, Summary__c, Description__c
                FROM Summary_of_My_Position_Today__c
            ];
            system.assertEquals(sum[0].Summary__c, 'Test UpdateTest');
            Test.stopTest();
        }
    }
}