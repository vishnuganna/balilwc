@istest
public with sharing class ActionPlanActivitiesActionsTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Action__c> fc = TestDataUtil.createActions(gs, true);
        }
    }

    static testMethod void testgetActions() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;

            List<ActionPlanActivitiesActionsWrapper> wrapper = ActionPlanActivitiesActions.getActionRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            List<ActionPlanActivitiesActionsWrapper> wrapper2 = ActionPlanActivitiesActions.getActionRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Complete'
            );
            List<ActionPlanActivitiesActionsWrapper> wrapper3 = ActionPlanActivitiesActions.getActionRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Incomplete'
            );
            ActionPlanActivitiesActions.ActionPlanActivitiesActionsInfo wrapperInfo = ActionPlanActivitiesActions.getActionsList(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapper[0].goldsheet, goldSheet.Id);
            Test.stopTest();
        }
    }

    static testMethod void testSaveActions() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('gsActionTitle', 'Test data insert');
            newmap.put('gsActionAssignedTo', UserInfo.getUserId());
            newmap.put('gsActionStatus', 'Complete');
            newmap.put('gsActionDescription', 'Test descrption');
            newmap.put('gsActionDueDate', date.today());
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);
            Test.startTest();
            ActionPlanActivitiesActions.createActionsRec(jsonstring);
            List<Action__c> lstActions = [
                SELECT Id, Action_Title__c
                FROM Action__c
                WHERE Action_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstActions.size());
            Test.stopTest();
        }
    }

    static testMethod void testUpdateActions() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('gsActionTitle', 'Test data insert');
            newmap.put('gsActionAssignedTo', UserInfo.getUserId());
            newmap.put('gsActionStatus', 'Complete');
            newmap.put('gsActionDescription', 'Test descrption');
            newmap.put('gsActionDueDate', date.today());
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);

            ActionPlanActivitiesActions.createActionsRec(jsonstring);
            List<Action__c> lstActions = [
                SELECT Id, Action_Title__c
                FROM Action__c
                WHERE Action_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstActions.size());

            map<String, Object> newmap2 = new Map<String, Object>();
            newmap2.put('gsActionTitle', 'Test data insert');
            newmap2.put('gsActionAssignedTo', UserInfo.getUserId());
            newmap2.put('gsActionStatus', 'Complete');
            newmap2.put('gsActionDescription', 'Test descrption');
            newmap2.put('gsActionDueDate', date.today());
            newmap2.put('goldSheet', goldSheet.Id);
            newmap2.put('id', lstActions[0].Id);

            String jsonstring2 = JSON.Serialize(newmap2);
            ActionPlanActivitiesActions.createActionsRec(jsonstring2);
        }
        Test.stopTest();
    }

    static testMethod void testDeleteActions() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Test.startTest();
            List<ActionPlanActivitiesActionsWrapper> wrapper = ActionPlanActivitiesActions.getActionRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            ActionPlanActivitiesActions.deleteActionsRecord(wrapper[0].Id);
            List<ActionPlanActivitiesActionsWrapper> wrapperAfterDelete = ActionPlanActivitiesActions.getActionRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapperAfterDelete.size(), 1);
            Test.stopTest();
        }
    }

    static testMethod void testGetPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String Status = ActionPlanActivitiesActions.getStatusPicklistValues();
            System.assert(!String.isEmpty(Status));
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = ActionPlanActivitiesActions.getActionAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
    static testMethod void testGetLookupObjects() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            ActionPlanActivitiesActions.WrapperLookupObject wrapper = ActionPlanActivitiesActions.getLookupObjects();
            System.assertNotEquals(wrapper, null);
            Test.stopTest();
        }
    }
}