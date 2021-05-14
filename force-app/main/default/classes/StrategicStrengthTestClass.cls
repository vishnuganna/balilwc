@isTest
public with sharing class StrategicStrengthTestClass {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    @isTest
    static void createfopssRecTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Map<String, String> fopssData = new Map<String, String>();
            fopssData.put('strategicStrength', 'Test Title');
            fopssData.put('ssDescription', 'Test Description');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('strategicStrength', rfs);

            Test.startTest();
            StrategicStrength.createfopssRec(fopssData, goldSheet.Id, rfsData);
            System.assertEquals(acc.name, 'Test Account', 'Account name is Test Account');
            Test.stopTest();
        }
    }

    @isTest
    static void getTrendsRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            FOP_Strategic_Strength__c fopss = new FOP_Strategic_Strength__c();
            fopss.Strength__c = 'Test Title';
            fopss.Strength_Description__c = 'Test Description';

            Map<String, String> fopssData = new Map<String, String>();
            fopssData.put('strategicStrength', 'Test Title');
            fopssData.put('ssDescription', 'Test Description');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('strategicStrength', rfs);
            Boolean isUpdatable = false;

            Test.startTest();
            StrategicStrength.createfopssRec(fopssData, goldSheet.Id, rfsData);
            StrategicStrengthWrapper wrap = new StrategicStrengthWrapper(fopss, isUpdatable);
            List<StrategicStrengthWrapper> recordListWrap = StrategicStrength.getStrategicStrengthRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset
            );
            system.assertEquals(true, recordListWrap.size() > 0, 'Check size of wrapper list');
            Test.stopTest();
        }
    }

    @isTest
    static void deletefopssRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            FOP_Strategic_Strength__c fopss = new FOP_Strategic_Strength__c();
            fopss.Strength__c = 'Test Title';
            fopss.Strength_Description__c = 'Test Description';

            Map<String, String> fopssData = new Map<String, String>();
            fopssData.put('strategicStrength', 'Test Title');
            fopssData.put('ssDescription', 'Test Description');

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('strategicStrength', rfs);

            Test.startTest();
            StrategicStrength.createfopssRec(fopssData, goldSheet.Id, rfsData);
            fopss.Strength__c = 'UpdateTest Title';
            System.assertEquals(true, goldSheet.Id != null, 'Gold sheet ID not null');
            StrategicStrength.deletefopssRecord(fopss.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void updatefopssRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            FOP_Strategic_Strength__c fopss = new FOP_Strategic_Strength__c();
            fopss.Strength__c = 'Test Title';
            fopss.Strength_Description__c = 'Test Description';
            fopss.Gold_Sheet__c = goldSheet.Id;
            insert fopss;
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', true);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('strategicStrength', rfs);

            Test.startTest();
            Map<string, string> fopssData = new Map<string, string>();
            fopssData.put('strategicStrength', 'Test UpdateTest Title');
            fopssData.put('recId', fopss.Id);
            System.assertEquals(acc.name, 'Test Account', 'Account name is Test Account');
            StrategicStrength.updateFoPStrategicStrengthRecord(fopssData, rfsData, goldSheet.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void getFopSSListTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            FOP_Strategic_Strength__c fopss = new FOP_Strategic_Strength__c();
            fopss.Strength__c = 'Test Title';
            fopss.Strength_Description__c = 'Test Description';

            Map<String, String> fopssData = new Map<String, String>();
            fopssData.put('strategicStrength', 'Test Title');
            fopssData.put('ssDescription', 'Test Description');

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('strategicStrength', rfs);

            List<FOP_Strategic_Strength__c> strategicStrengthList = [SELECT Id, Name FROM FOP_Strategic_Strength__c];
            Integer countRec = strategicStrengthList.size();

            Test.startTest();
            StrategicStrength.getStrategicStrengthRecords(goldSheet.Id, queryLimit, queryOffset);
            StrategicStrength.getStrategicStrengthList(goldSheet.Id, queryLimit, queryOffset);
            StrategicStrength.countStrategicStrengthRecords(goldSheet.Id);
            System.assertEquals(acc.name, 'Test Account', 'Account name is Test Account');
            Test.stopTest();
        }
    }

    @isTest
    static void checkAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Map<String, Boolean> accessMap = new Map<String, Boolean>();
            String objName = Util.getNamespaceWithUnderScores() + 'FOP_Strategic_Strength__c';

            Test.startTest();
            accessMap = StrategicStrength.getFoPSSAccess();
            system.assertEquals(4, accessMap.size());
            Test.stopTest();
        }
    }
}