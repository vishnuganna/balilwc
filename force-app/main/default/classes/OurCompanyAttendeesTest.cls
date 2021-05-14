@isTest
public with sharing class OurCompanyAttendeesTest {
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
    static void getCompanyAttendeeInfoTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Company_Attendee__c> company = TestDataUtil.createCompanyAttendees(greenSheetId, true, user);
            List<OurCompanyAttendeeWrapper> companyList = OurCompanyAttendees.getCompanyAttendeeInfo(greenSheetId);
            OurCompanyAttendees.getLookupObjects();
            system.assertequals(companyList[0].nameId, user.Id, 'checking name in company Attendees');
            system.assertequals(companyList[0].title, user.title, 'checking title in company Attendees');
        }
    }

    @istest
    static void removeCompanyAttendeeTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Company_Attendee__c> company = TestDataUtil.createCompanyAttendees(greenSheetId, true, user);
            List<OurCompanyAttendeeWrapper> companyList = OurCompanyAttendees.getCompanyAttendeeInfo(greenSheetId);
            OurCompanyAttendees.removeCompanyAttendee(companyList[0].Id);
            system.assertequals(companyList.size(), 3, 'Checking size for Company Attendee befor removing attendee');
            List<OurCompanyAttendeeWrapper> companyListAfterRemoving = OurCompanyAttendees.getCompanyAttendeeInfo(
                greenSheetId
            );
            system.assertequals(
                companyListAfterRemoving.size(),
                2,
                'Checking size for Company Attendee after removing attendee'
            );
            OurCompanyAttendees.getCompanyAccess();
        }
    }
    @istest
    static void removeCompanyAttendeeTestNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Company_Attendee__c> company = TestDataUtil.createCompanyAttendees(greenSheetId, true, user);
            List<OurCompanyAttendeeWrapper> companyList = OurCompanyAttendees.getCompanyAttendeeInfo(greenSheetId);

            system.assertequals(companyList.size(), 3, 'Checking size for Company Attendee');
            system.assertNotequals(companyList.size(), 2, 'Checking size for Company Attendee');
            try {
                OurCompanyAttendees.removeCompanyAttendee(greenSheetId);
            } catch (Exception e) {
                system.System.debug('exception ----' + e);
            }
        }
    }
    @istest
    static void saveCompanyAttendeeTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            OurCompanyAttendees.saveCompanyAttendee(user.Id, greenSheetId);
            List<OurCompanyAttendeeWrapper> companyListAfterSaving = OurCompanyAttendees.getCompanyAttendeeInfo(
                greenSheetId
            );
            system.assertequals(companyListAfterSaving.size(), 1, 'Checking size for Company Attendee after saving');
            system.assertNotequals(companyListAfterSaving.size(), 4, 'Checking size for Company Attendee after saving');
        }
    }
}