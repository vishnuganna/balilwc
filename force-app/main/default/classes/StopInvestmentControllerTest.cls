@isTest
public class StopInvestmentControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Stop_Investment__c> fc = TestDataUtil.createStopInvestment(gs, true);
        }
    }
    static testMethod void testGetStopInvestmentController() {
        Test.startTest();
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            List<StopInvestmentWrapper> wrapper = StopInvestmentController.getStopInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            List<StopInvestmentWrapper> wrapper2 = StopInvestmentController.getStopInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Complete'
            );
            List<StopInvestmentWrapper> wrapper3 = StopInvestmentController.getStopInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                'Incomplete'
            );
            StopInvestmentController.StopInvestmentInfo wrapperInfo = StopInvestmentController.getStopInvList(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            system.assertEquals(wrapper[0].goldsheet, goldSheet.Id, 'No result found');
            Test.stopTest();
        }
    }
    static testMethod void testSaveStopInvestmentController() {
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
            StopInvestmentController.createStopInvestmentRec(jsonstring, rfsData);
            List<Stop_Investment__c> lstStopInvestmentController = [
                SELECT Id, Investment_Title__c
                FROM Stop_Investment__c
                WHERE Investment_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstStopInvestmentController.size(), 'No result found');
            Test.stopTest();
        }
    }
    static testMethod void testUpdateStopInvestmentController() {
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
            StopInvestmentController.createStopInvestmentRec(jsonstring, rfsData);
            List<Stop_Investment__c> lstStopInvestmentController = [
                SELECT Id, Investment_Title__c
                FROM Stop_Investment__c
                WHERE Investment_Title__c = 'Test data insert'
            ];
            system.assertEquals(1, lstStopInvestmentController.size(), 'No result found');
            map<String, Object> newmap2 = new Map<String, Object>();
            newmap2.put('foiInvestmentTitle', 'Test data insert');
            newmap2.put('foiAmount', 3456);
            newmap2.put('foiStatus', 'Complete');
            newmap2.put('foiDescription', 'Test descrption');
            newmap2.put('goldSheet', goldSheet.Id);
            newmap2.put('id', lstStopInvestmentController[0].Id);
            String jsonstring2 = JSON.Serialize(newmap2);
            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('role', rfs2);
            StopInvestmentController.createStopInvestmentRec(jsonstring2, rfsData2);
        }
        Test.stopTest();
    }
    static testMethod void testDeleteStopInvestmentController() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Test.startTest();
            List<StopInvestmentWrapper> wrapper = StopInvestmentController.getStopInvestmentRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset,
                null
            );
            StopInvestmentController.deleteInvestment(wrapper[0].Id);
            List<StopInvestmentWrapper> wrapperAfterDelete = StopInvestmentController.getStopInvestmentRecords(
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
            String status = StopInvestmentController.getStatusPicklistValues();
            System.assert(!String.isEmpty(status), 'No result found');
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = StopInvestmentController.getStopInvestmentAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Chcek access map size');
            Test.stopTest();
        }
    }
}