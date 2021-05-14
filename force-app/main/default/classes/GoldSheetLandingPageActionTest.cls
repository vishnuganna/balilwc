@isTest
public with sharing class GoldSheetLandingPageActionTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
            List<Information_Needed__c> info = TestDataUtil.createInformationNeeded(goldSheet, true);
            List<Action__c> action = TestDataUtil.createActions(goldSheet, true);
            List<Investment_Program__c> invest = TestDataUtil.createInvProgram(goldSheet, true);
        }
    }

    @isTest
    static void testprocessGoldSheetLastUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            goldSheet.Last_Updated__c = date.today().addDays(-12);
            update goldSheet;
            Test.startTest();
            GoldSheetLandingPageAction goldLand = new GoldSheetLandingPageAction();
            goldLand.processGoldSheetLastUpdate();
            Map<Id, Gold_Sheet__c> goldMap = new Map<Id, Gold_Sheet__c>();
            KF_Sell_Best__c bestAct = [
                SELECT Id, Fields_of_Play_Gold_Sheet__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];

            goldMap.put(goldSheet.Id, goldSheet);
            goldSheet.Last_Updated__c = date.today();
            update goldSheet;
            bestAct.Action_Title__c = 'Update Past Due';
            update bestAct;
            GoldSheetLandingPageAction goldLand1 = new GoldSheetLandingPageAction();
            goldLand1.processGoldSheetLastUpdate();
            delete goldSheet;
            GoldSheetLandingPageAction.deleteBestAction(goldMap);
            System.assertEquals(bestAct.Id != null, true, 'Record created!');
            Test.stopTest();
        }
    }

    @isTest
    static void testprocessGoldSheetActivityDueDate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Information_Needed__c info1 = [
                SELECT Id, Name, Due_Date__c
                FROM Information_Needed__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            Action__c act1 = [
                SELECT Id, Name, Due_Date__c
                FROM Action__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            Investment_Program__c invt1 = [
                SELECT Id, Name, Due_Date__c
                FROM Investment_Program__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            invt1.Due_Date__c = date.today().addDays(-2);
            act1.Due_Date__c = date.today().addDays(-1);
            info1.Due_Date__c = date.today().addDays(-3);
            update invt1;
            update act1;
            update info1;

            Test.startTest();
            GoldSheetLandingPageAction goldLand = new GoldSheetLandingPageAction();
            goldLand.processGoldSheetActivityDueDate();
            List<KF_Sell_Best__c> bestAct = [
                SELECT Id, Activity_Due_Date__c
                FROM KF_Sell_Best__c
                WHERE Activity_Due_Date__c != null
            ];
            System.assertEquals(bestAct.size() > 0, true, 'Record created!');
            Test.stopTest();
        }
    }

    @isTest
    static void testupdateActivity() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Information_Needed__c info1 = [
                SELECT Id, Name, Due_Date__c
                FROM Information_Needed__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            Action__c act1 = [
                SELECT Id, Name, Due_Date__c
                FROM Action__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            Investment_Program__c invt1 = [
                SELECT Id, Name, Due_Date__c
                FROM Investment_Program__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            invt1.Due_Date__c = date.today().addDays(-2);
            act1.Due_Date__c = date.today().addDays(-1);
            info1.Due_Date__c = date.today().addDays(-3);
            update invt1;
            update act1;
            update info1;

            Test.startTest();
            GoldSheetLandingPageAction goldLand = new GoldSheetLandingPageAction();
            goldLand.processGoldSheetActivityDueDate();
            invt1.Due_Date__c = date.today().addDays(3);
            act1.Due_Date__c = date.today().addDays(2);
            info1.Due_Date__c = date.today().addDays(5);
            update invt1;
            update act1;
            update info1;
            Map<Id, Information_Needed__c> infoMap = new Map<Id, Information_Needed__c>();
            Map<Id, Action__c> actionMap = new Map<Id, Action__c>();
            Map<Id, Investment_Program__c> invstMap = new Map<Id, Investment_Program__c>();
            infoMap.put(info1.Id, info1);
            actionMap.put(act1.Id, act1);
            invstMap.put(invt1.Id, invt1);
            GoldSheetLandingPageAction.updateBestActivityAction(actionMap);
            GoldSheetLandingPageAction.updateBestActivityInfoNeeded(infoMap);
            GoldSheetLandingPageAction.updateBestActivityInvProg(invstMap);
            List<KF_Sell_Best__c> bestAct = [
                SELECT Id, Activity_Due_Date__c
                FROM KF_Sell_Best__c
                WHERE Activity_Due_Date__c != null
            ];
            System.assertEquals(bestAct.size() > 0, false, 'Record updated!');
            Test.stopTest();
        }
    }

    @isTest
    static void testdeleteActivity() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Information_Needed__c info1 = [
                SELECT Id, Name, Due_Date__c
                FROM Information_Needed__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            Action__c act1 = [
                SELECT Id, Name, Due_Date__c
                FROM Action__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            Investment_Program__c invt1 = [
                SELECT Id, Name, Due_Date__c
                FROM Investment_Program__c
                WHERE Fields_of_Play_Gold_Sheet__c = :goldSheet.Id
                LIMIT 1
            ];
            invt1.Due_Date__c = date.today().addDays(-2);
            act1.Due_Date__c = date.today().addDays(-1);
            info1.Due_Date__c = date.today().addDays(-3);
            update invt1;
            update act1;
            update info1;
            Test.startTest();
            GoldSheetLandingPageAction goldLand = new GoldSheetLandingPageAction();
            goldLand.processGoldSheetActivityDueDate();
            invt1.Due_Date__c = date.today().addDays(-3);
            act1.Due_Date__c = date.today().addDays(-2);
            info1.Due_Date__c = date.today().addDays(-1);
            update invt1;
            update act1;
            update info1;
            Map<Id, Information_Needed__c> infoMap = new Map<Id, Information_Needed__c>();
            Map<Id, Action__c> actionMap = new Map<Id, Action__c>();
            Map<Id, Investment_Program__c> invstMap = new Map<Id, Investment_Program__c>();
            infoMap.put(info1.Id, info1);
            actionMap.put(act1.Id, act1);
            invstMap.put(invt1.Id, invt1);
            GoldSheetLandingPageAction.updateBestActivityAction(actionMap);
            GoldSheetLandingPageAction.updateBestActivityInfoNeeded(infoMap);
            GoldSheetLandingPageAction.updateBestActivityInvProg(invstMap);
            delete invt1;
            delete act1;
            delete info1;
            List<KF_Sell_Best__c> bestActionLstDelete = new List<KF_Sell_Best__c>();
            GoldSheetLandingPageAction.deleteBestActivityAction(actionMap);
            GoldSheetLandingPageAction.deleteBestActivityInfoNeeded(infoMap);
            GoldSheetLandingPageAction.deleteBestActivityInvProg(invstMap);
            GoldSheetLandingPageAction.deleteBestActionRecord();
            List<KF_Sell_Best__c> bestAct = [
                SELECT Id, Activity_Due_Date__c
                FROM KF_Sell_Best__c
                WHERE
                    Gold_Sheet_Investment_Program__c = :invt1.Id
                    OR Gold_Sheet_Action__c = :act1.Id
                    OR Gold_Sheet_InfoNeeded__c = :info1.Id
            ];
            System.assertEquals(bestAct.size() > 0, false, 'Record deleted!');
            Test.stopTest();
        }
    }
}