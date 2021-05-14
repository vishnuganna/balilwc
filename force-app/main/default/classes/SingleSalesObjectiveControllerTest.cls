@isTest
private with sharing class SingleSalesObjectiveControllerTest {
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            //create opportunity
            opportunity objOppt = new opportunity();
            objOppt.Name = 'Test Opportunity';
            objOppt.StageName = 'Needs Analysis';
            objOppt.CloseDate = date.today();
            insert objOppt;

            Blue_Sheet__c blueSheet = new Blue_Sheet__c();
            blueSheet.Opportunity__c = objOppt.Id;
            insert blueSheet;
        }
    }

    static testMethod void createSSORecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Test.startTest();
            //Single_Sales_Objective__c sso = new Single_Sales_Objective__c();
            opportunity objOppt = [
                SELECT Name, StageName, CloseDate
                FROM Opportunity
                WHERE Name = 'Test Opportunity'
                LIMIT 1
            ];
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('EvaluationOfObjective', rfs);
            String sso = '{"blueSheet":"","custTimingPriorities":"Active","customerStatedObjective":"type","evaluationOfObjectives":"test","ssoId":""}';
            SingleSalesObjectiveController.createSSORecord(sso, objOppt.Id, rfsData);
            SingleSalesObjectiveController.getSSOAccess();
            system.assertEquals(true, SingleSalesObjectiveController.getSSORecords(objOppt.Id).size() > 0);
            /* String sso1= '{"blueSheet":"","custTimingPriorities":"","customerStatedObjective":"","evaluationOfObjectives":""}';
             SingleSalesObjectiveController.emptySSORecord(sso1,objOppt.Id,rfsData,false);*/
            Test.stopTest();
        }
    }
}