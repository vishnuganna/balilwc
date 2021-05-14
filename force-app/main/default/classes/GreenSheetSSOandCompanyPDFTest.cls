@isTest
public with sharing class GreenSheetSSOandCompanyPDFTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity opty = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bluesheet = TestDataUtil.createBluesheet(opty, true);
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bluesheet, true);
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            Contact con = TestDataUtil.createContact(acc, true);
        }
    }

    @istest
    static void getCompanyAttendeeInfoTest() {
        User user = UserTest.createUserWithPerms();
        testData();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Company_Attendee__c> company = TestDataUtil.createCompanyAttendees(greenSheetId, true, user);
            List<OurCompanyAttendeeWrapper> companyList = GreenSheetSSOandCompanyPDF.getCompanyAttendeeInfo(
                greenSheetId
            );
            system.assertequals(companyList[0].nameId, user.Id, 'checking name in company Attendees');
            system.assertequals(companyList[0].title, user.title, 'checking title in company Attendees');
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
            greenSheetOppSSOWrapperList = GreenSheetSSOandCompanyPDF.getSSOGreenSheet(greenSheet.Id);
            system.assertEquals(true, greenSheetOppSSOWrapperList.size() > 0, 'Checking size of the list is not null');
            Test.stopTest();
        }
    }

    @isTest
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            GreenSheetSSOandCompanyPDF pdfObj = new GreenSheetSSOandCompanyPDF();
            Green_Sheet__c green = [SELECT Id FROM Green_Sheet__c WHERE Task_Id__c = :taskList[0].Id LIMIT 1];
            //PageReference pageRef = Page.goldsheetA4; // Add your VF page Name here
            //getParameters().put('id', String.valueOf(green.Id));
            //Test.setCurrentPage(pageRef);
            Test.stopTest();
            system.assertEquals(true, pdfObj != null, 'Validating constructor');
        }
    }
}