@isTest
private with sharing class ActionPlanWrapperClassTest {
    static void testData() {
        //create opportunity
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            opportunity objOppt = new opportunity();
            objOppt.Name = 'Test Opportunity';
            objOppt.StageName = 'Needs Analysis';
            objOppt.CloseDate = date.today();
            insert objOppt;

            Blue_Sheet__c blueSheet = new Blue_Sheet__c();
            blueSheet.Opportunity__c = objOppt.Id;
            insert blueSheet;

            Action_Plan__c ap = new Action_Plan__c();
            ap.Blue_Sheet__c = blueSheet.Id;
            ap.Summary__c = 'Test Summary';
            ap.Description__c = 'Test Description';
            ap.IsProvidingPerspective__c = false;
            insert ap;
        }
    }

    static testMethod void getactionPlan_Test() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Action_Plan__c ap = [
                SELECT
                    Blue_Sheet__c,
                    Summary__c,
                    Description__c,
                    Name,
                    Contact__c,
                    Contact__r.Name,
                    Due_Date__c,
                    Is_a_Best_Action__c,
                    Priority__c,
                    Start_Date__c,
                    Status__c,
                    User__c,
                    Action_Type__c,
                    AssignedTo__c,
                    IsProvidingPerspective__c,
                    ProvidingPerspectiveDescription__c,
                    AssignedTo__r.Name
                FROM Action_Plan__c
                LIMIT 1
            ];
            Test.startTest();
            ActionPlanWrapperClass wrap = new ActionPlanWrapperClass(ap, true);
            System.assertEquals(wrap.summary, 'Test Summary');
            Test.stopTest();
        }
    }
}