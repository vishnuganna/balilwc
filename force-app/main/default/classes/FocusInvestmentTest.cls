@istest
public with sharing class FocusInvestmentTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Focus_Investment__c> fc = TestDataUtil.createFocusInvestment(gs, true);
        }
    }
    static testMethod void testGetFocusInvestments() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;

            List<FocusInvestmentWrapper> wrapper = FocusInvestment.getFocusInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            List<FocusInvestmentWrapper> wrapper2 = FocusInvestment.getFocusInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Complete'
            );
            List<FocusInvestmentWrapper> wrapper3 = FocusInvestment.getFocusInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Incomplete'
            );
            FocusInvestment.FocusInvestmentInfo wrapperInfo = FocusInvestment.getFocInvList(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapper[0].goldsheet, goldSheet.Id);
            Test.stopTest();
        }
    }
    static testMethod void testSaveFocusInvestment() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('foiInvestmentTitle', 'Test data insert');
            newmap.put('foiAmount', 3454);
            newmap.put('foiStatus', 'Complete');
            newmap.put('foiDescription', 'Test descrption');
            newmap.put('goldSheet', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('role', rfs);
            Test.startTest();
            FocusInvestment.createFocusInvestmentRec(jsonstring, rfsData);
            List<Focus_Investment__c> lstFocusInvestment = [
                SELECT Id, Investment_Title__c
                FROM Focus_Investment__c
                WHERE Investment_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstFocusInvestment.size());
            Test.stopTest();
        }
    }
    static testMethod void testUpdateFocusInvestment() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('foiInvestmentTitle', 'Test data insert');
            newmap.put('foiAmount', 3456);
            newmap.put('foiStatus', 'Complete');
            newmap.put('foiDescription', 'Test descrption');
            newmap.put('goldSheet', goldSheet.Id);

            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('role', rfs);

            FocusInvestment.createFocusInvestmentRec(jsonstring, rfsData);
            List<Focus_Investment__c> lstFocusInvestment = [
                SELECT Id, Investment_Title__c
                FROM Focus_Investment__c
                WHERE Investment_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstFocusInvestment.size());

            map<String, Object> newmap2 = new Map<String, Object>();
            newmap2.put('foiInvestmentTitle', 'Test data insert');
            newmap2.put('foiAmount', 3456);
            newmap2.put('foiStatus', 'Complete');
            newmap2.put('foiDescription', 'Test descrption');
            newmap2.put('goldSheet', goldSheet.Id);
            newmap2.put('id', lstFocusInvestment[0].Id);

            String jsonstring2 = JSON.Serialize(newmap2);
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('role', rfs2);
            FocusInvestment.createFocusInvestmentRec(jsonstring2, rfsData2);
        }
        Test.stopTest();
    }
    static testMethod void testDeleteSFocusInvestment() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Test.startTest();
            List<FocusInvestmentWrapper> wrapper = FocusInvestment.getFocusInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            FocusInvestment.deleteInvestment(wrapper[0].Id);
            List<FocusInvestmentWrapper> wrapperAfterDelete = FocusInvestment.getFocusInvestmentRecords(
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
            String Status = FocusInvestment.getStatusPicklistValues();
            System.assert(!String.isEmpty(Status));
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = FocusInvestment.getFocusInvestmentAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
}