@istest
public with sharing class InformationNeededTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Information_Needed__c> fc = TestDataUtil.createInformationNeeded(gs, true);
        }
    }

    static testMethod void testgetInformationNeededRecords() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;

            List<InformationNeededWrapper> wrapper = InformationNeeded.getInformationNeededRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            List<InformationNeededWrapper> wrapper2 = InformationNeeded.getInformationNeededRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Complete'
            );
            List<InformationNeededWrapper> wrapper3 = InformationNeeded.getInformationNeededRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Incomplete'
            );
            InformationNeeded.InformationNeededInfo wrapperInfo = InformationNeeded.getInformationNeededList(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapper[0].goldsheet, goldSheet.Id);
            Test.stopTest();
        }
    }

    static testMethod void testSaveInformationNeededRecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('gsInformationNeededTitle', 'Test data insert');
            newmap.put('gsInformationNeededAssignedTo', UserInfo.getUserId());
            newmap.put('gsInformationNeededStatus', 'Complete');
            newmap.put('gsInformationNeededDescription', 'Test descrption');
            newmap.put('gsInformationNeededSource', 'Test source');
            newmap.put('gsInformationNeededDueDate', date.today());
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);
            Test.startTest();
            InformationNeeded.createInformationNeededRec(jsonstring);
            List<Information_Needed__c> lstInformationNeeded = [
                SELECT Id, Information_Needed_Title__c
                FROM Information_Needed__c
                WHERE Information_Needed_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstInformationNeeded.size());
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
            newmap.put('gsInformationNeededTitle', 'Test data insert');
            newmap.put('gsInformationNeededAssignedTo', UserInfo.getUserId());
            newmap.put('gsInformationNeededStatus', 'Complete');
            newmap.put('gsInformationNeededDescription', 'Test descrption');
            newmap.put('gsInformationNeededSource', 'Test source');
            newmap.put('gsInformationNeededDueDate', date.today());
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);

            InformationNeeded.createInformationNeededRec(jsonstring);
            List<Information_Needed__c> lstInformationNeeded = [
                SELECT Id, Information_Needed_Title__c
                FROM Information_Needed__c
                WHERE Information_Needed_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstInformationNeeded.size());

            map<String, Object> newmap2 = new Map<String, Object>();
            newmap2.put('gsInformationNeededTitle', 'Test data insert');
            newmap2.put('gsInformationNeededAssignedTo', UserInfo.getUserId());
            newmap2.put('gsInformationNeededStatus', 'Complete');
            newmap2.put('gsInformationNeededDescription', 'Test descrption');
            newmap2.put('gsInformationNeededSource', 'Test source');
            newmap2.put('gsInformationNeededDueDate', date.today());
            newmap2.put('goldSheet', goldSheet.Id);
            newmap2.put('id', lstInformationNeeded[0].Id);

            String jsonstring2 = JSON.Serialize(newmap2);
            InformationNeeded.createInformationNeededRec(jsonstring2);
        }
        Test.stopTest();
    }

    static testMethod void testDeleteInformationNeededRec() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Test.startTest();
            List<InformationNeededWrapper> wrapper = InformationNeeded.getInformationNeededRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            InformationNeeded.deleteInformationNeededRecord(wrapper[0].Id);
            List<InformationNeededWrapper> wrapperAfterDelete = InformationNeeded.getInformationNeededRecords(
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
            String Status = InformationNeeded.getStatusPicklistValues();
            System.assert(!String.isEmpty(Status));
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = InformationNeeded.getInformationNeededAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
    static testMethod void testGetLookupObjects() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            InformationNeeded.WrapperLookupObject wrapper = InformationNeeded.getLookupObjects();
            System.assertNotEquals(wrapper, null);
            Test.stopTest();
        }
    }
}