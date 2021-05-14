@isTest
public with sharing class GreenSheetVBRTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Task task = TestDataUtil.createTask(user, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheetVBR(task, true);
        }
    }

    @isTest
    static void checkAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Map<String, Boolean> accessMap = new Map<String, Boolean>();
            String objName = 'Green_Sheet__c';
            Test.startTest();
            Map<String, Boolean> accessData = GreenSheetVBR.getGreenSheetAccess();
            ApexCommonUtil.getObjectAccess(objName);
            System.assertEquals(4, accessData.size(), 'Check access map size');
            Test.stopTest();
        }
    }

    @isTest
    static void getGreenSheetVBRTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Test.startTest();
            Green_Sheet__c greenSheet = [SELECT Id FROM Green_Sheet__c LIMIT 1];
            List<GreenSheetWrapper> greenSheetVBRWrapperList = new List<GreenSheetWrapper>();
            greenSheetVBRWrapperList = GreenSheetVBR.getGreenSheetVBR(greenSheet.Id);
            System.assertEquals(true, greenSheetVBRWrapperList.size() > 0, 'Checking size of the list is not null');
            Test.stopTest();
        }
    }

    @isTest
    static void upsertVBRTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Map<String, Map<String, Object>> rfsMap = new Map<String, Map<String, Object>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', true);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsMap.put('ReasonVBR', rfs);

            Test.startTest();
            Green_Sheet__c greenSheet = [SELECT Id, Credibility__c FROM Green_Sheet__c LIMIT 1];
            String jsonString =
                '{ "id":"' +
                greenSheet.Id +
                '" , "credibility":"Established" ,"reason":"Test Notes" ,"toIncreaseCredibility":"test increase"}';
            GreenSheetVBR.upsertVBR(jsonString, rfsMap);
            Map<String, Map<String, Object>> rfsData = new Map<String, Map<String, Object>>();
            Map<String, Boolean> rfss = new Map<String, Boolean>();
            rfss.put('redFlagSelected', true);
            rfss.put('strengthSelected', false);
            rfss.put('noneSelected', false);
            rfss.put('fieldApiName', false);
            rfsData.put('CredibilityVBR', rfss);
            GreenSheetVBR.upsertVBR(jsonString, rfsData);
            System.assertEquals(
                true,
                greenSheet.Credibility__c == 'Established',
                'Checking if greensheet credibility is equal to Established'
            );
            Test.stopTest();
        }
    }

    @isTest
    static void deleteVBRTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Test.startTest();
            Green_Sheet__c greenSheet = [SELECT Id FROM Green_Sheet__c LIMIT 1];
            System.assertEquals(true, greenSheet != null, 'Checking if greensheet is not null');
            GreenSheetVBR.deleteVBR(greenSheet.Id);
            Test.stopTest();
        }
    }
}