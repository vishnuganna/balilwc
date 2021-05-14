@isTest
public with sharing class FieldOfPlayTrendsTestClass {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    @isTest
    static void createFoPTrendRecTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Map<String, String> trendData = new Map<String, String>();
            trendData.put('trendTitle', 'Test Title');
            trendData.put('trendDescription', 'Test Description');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('TrendTitle', rfs);

            Test.startTest();
            FieldOfPlayTrend.createFoPTrendRec(trendData, goldSheet.Id, rfsData);
            System.assertEquals(acc.name, 'Test Account');
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
            Field_of_Play_Trend__c foptrend = new Field_of_Play_Trend__c();
            foptrend.Trend__c = 'Test Title';
            foptrend.Trend_Description__c = 'Test Description';

            Map<String, String> trendData = new Map<String, String>();
            trendData.put('trendTitle', 'Test Title');
            trendData.put('trendDescription', 'Test Description');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('TrendTitle', rfs);

            Test.startTest();
            FieldOfPlayTrend.createFoPTrendRec(trendData, goldSheet.Id, rfsData);
            FieldOfPlayTrendWrapperClass wrap = new FieldOfPlayTrendWrapperClass(foptrend, true);
            List<FieldOfPlayTrendWrapperClass> recordListWrap = FieldOfPlayTrend.getTrendsRecords(
                goldSheet.Id,
                queryLimit,
                queryOffset
            );
            system.assertEquals(true, recordListWrap.size() > 0);
            Test.stopTest();
        }
    }

    @isTest
    static void deleteFoPTrendRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Field_of_Play_Trend__c foptrend = new Field_of_Play_Trend__c();
            foptrend.Trend__c = 'Test Title';
            foptrend.Trend_Description__c = 'Test Description';

            Map<String, String> trendData = new Map<String, String>();
            trendData.put('trendTitle', 'Test Title');
            trendData.put('trendDescription', 'Test Description');

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('TrendTitle', rfs);

            Test.startTest();
            FieldOfPlayTrend.createFoPTrendRec(trendData, goldSheet.Id, rfsData);
            foptrend.Trend__c = 'UpdateTest Title';
            System.assertEquals(acc.name, 'Test Account');
            FieldOfPlayTrend.deleteFoPTrendRecord(foptrend.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void updateFoPTrendRecordTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Field_of_Play_Trend__c foptrend = new Field_of_Play_Trend__c();
            foptrend.Trend__c = 'Test Title';
            foptrend.Trend_Description__c = 'Test Description';
            foptrend.Gold_Sheet__c = goldSheet.Id;
            insert foptrend;
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', true);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('TrendTitle', rfs);

            Test.startTest();
            Map<string, string> trendData = new Map<string, string>();
            trendData.put('trendTitle', 'Test UpdateTest Title');
            trendData.put('recId', foptrend.Id);
            System.assertEquals(acc.name, 'Test Account');
            FieldOfPlayTrend.updateFoPTrendRecord(trendData, rfsData, goldSheet.Id);
            Test.stopTest();
        }
    }

    @isTest
    static void getTrendsListTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Field_of_Play_Trend__c foptrend = new Field_of_Play_Trend__c();
            foptrend.Trend__c = 'Test Title';
            foptrend.Trend_Description__c = 'Test Description';
            foptrend.Gold_Sheet__c = goldSheet.Id;
            insert foptrend;
            Map<String, String> trendData = new Map<String, String>();
            trendData.put('trendTitle', 'Test Title');
            trendData.put('trendDescription', 'Test Description');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('TrendTitle', rfs);
            List<Field_of_Play_Trend__c> trendList = [SELECT Id, Name FROM Field_of_Play_Trend__c];
            Integer countRec = trendList.size();
            Test.startTest();
            FieldOfPlayTrend.getTrendsList(goldSheet.Id, queryLimit, queryOffset);
            system.assertEquals(1, countRec);
            Test.stopTest();
        }
    }
    @isTest
    static void checkAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Map<String, Boolean> accessMap = new Map<String, Boolean>();
            String objName = Util.getNamespaceWithUnderScores() + 'Field_of_Play_Trend__c';
            Test.startTest();
            Map<String, Boolean> accessData = FieldOfPlayTrend.getFoPTrendAccess();
            ApexCommonUtil.getObjectAccess(objName);
            system.assertEquals(true, accessData.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
}