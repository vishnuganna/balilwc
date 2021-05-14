@isTest
public with sharing class GreenSheetBIandVBRCredPDFTest {
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
    static void getGreenSheetVBRTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Test.startTest();
            Green_Sheet__c greenSheet = [SELECT Id FROM Green_Sheet__c LIMIT 1];
            List<GreenSheetWrapper> greenSheetVBRWrapperList = new List<GreenSheetWrapper>();
            greenSheetVBRWrapperList = GreenSheetBIandVBRCredPDF.getGreenSheetVBR(greenSheet.Id);
            System.assertEquals(true, greenSheetVBRWrapperList.size() > 0, 'Checking size of the list is not null');
            Test.stopTest();
        }
    }

    @istest
    static void getGreenBuyingInfluenceRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheetId,
                true,
                con
            );
            List<GreenSheetBuyingInfluenceWrapper> greenbiList = GreenSheetBIandVBRCredPDF.getGreenBuyingInfluenceRecords(
                greenSheetId
            );
            system.assertequals(greenbiList[0].buyingInfluenceRole, 'economic', 'Checking Economic in Greensheet BI');
            system.assertequals(greenbiList[0].concept, 'Test Concept1', 'Checking Concept in Greensheet BI');
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            GreenSheetBIandVBRCredPDF pdfObj = new GreenSheetBIandVBRCredPDF();
            Green_Sheet__c green = [SELECT Id FROM Green_Sheet__c WHERE Task_Id__c = :taskList[0].Id LIMIT 1];
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }
}