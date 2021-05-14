@istest
public with sharing class InvestmentProgramControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Investment_Program__c> fc = TestDataUtil.createInvProgram(gs, true);
        }
    }

    static testMethod void testgetInvProgram() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;

            List<InvestmentProgramControllerWrapper> wrapper = InvestmentProgramController.getInvProgramRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            List<InvestmentProgramControllerWrapper> wrapper2 = InvestmentProgramController.getInvProgramRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Complete'
            );
            List<InvestmentProgramControllerWrapper> wrapper3 = InvestmentProgramController.getInvProgramRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Incomplete'
            );
            InvestmentProgramController.InvestmentProgramInfo wrapperInfo = InvestmentProgramController.getInvProgramList(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapper[0].goldsheet, goldSheet.Id, 'No result found');
            Test.stopTest();
        }
    }

    static testMethod void testSaveInvProgram() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('gsInvProgramTitle', 'Test data insert');
            newmap.put('gsInvProgramAssignedTo', UserInfo.getUserId());
            newmap.put('gsInvProgramStatus', 'Complete');
            newmap.put('gsInvProgramDescription', 'Test descrption');
            newmap.put('gsInvProgramDueDate', date.today());
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);
            Test.startTest();
            InvestmentProgramController.createInvProgramsRec(jsonstring);
            List<Investment_Program__c> lstActions = [
                SELECT Id, Investment_Program_Title__c
                FROM Investment_Program__c
                WHERE Investment_Program_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstActions.size(), 'No result found');
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
            newmap.put('gsInvProgramTitle', 'Test data insert');
            newmap.put('gsInvProgramAssignedTo', UserInfo.getUserId());
            newmap.put('gsInvProgramStatus', 'Complete');
            newmap.put('gsInvProgramDescription', 'Test descrption');
            newmap.put('gsInvProgramDueDate', date.today());
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);

            InvestmentProgramController.createInvProgramsRec(jsonstring);
            List<Investment_Program__c> lstActions = [
                SELECT Id, Investment_Program_Title__c
                FROM Investment_Program__c
                WHERE Investment_Program_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstActions.size(), 'No result found');

            map<String, Object> newmap2 = new Map<String, Object>();
            newmap2.put('gsInvProgramTitle', 'Test data insert');
            newmap2.put('gsInvProgramAssignedTo', UserInfo.getUserId());
            newmap2.put('gsInvProgramStatus', 'Complete');
            newmap2.put('gsInvProgramDescription', 'Test descrption');
            newmap2.put('gsInvProgramDueDate', date.today());
            newmap2.put('goldSheet', goldSheet.Id);
            newmap2.put('id', lstActions[0].Id);

            String jsonstring2 = JSON.Serialize(newmap2);
            InvestmentProgramController.createInvProgramsRec(jsonstring2);
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
            List<InvestmentProgramControllerWrapper> wrapper = InvestmentProgramController.getInvProgramRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            InvestmentProgramController.deleteInvProgramRecord(wrapper[0].Id);
            List<InvestmentProgramControllerWrapper> wrapperAfterDelete = InvestmentProgramController.getInvProgramRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapperAfterDelete.size(), 1, 'No result found');
            Test.stopTest();
        }
    }

    static testMethod void testGetPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String status = InvestmentProgramController.getStatusPicklistValues();
            System.assert(!String.isEmpty(status), 'No result found');
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = InvestmentProgramController.getInvProgramAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
    static testMethod void testGetLookupObjects() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            InvestmentProgramController.WrapperLookupObject wrapper = InvestmentProgramController.getLookupObjects();
            System.assertNotEquals(wrapper, null, 'No result found');
            Test.stopTest();
        }
    }
}