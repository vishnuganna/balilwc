@istest
public with sharing class GoldsheetSSOControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Opportunity opp = TestDataUtil.createOpportunity(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            Gold_Sheet_Single_Sales_Objective__c gSSO = TestDataUtil.createGoldSheetSSO(gs, opp, true);
        }
    }
    static testMethod void testGetGsSSOData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Test.startTest();
            List<GoldSheetSSOWrapper> gsSSO = GoldsheetSSOController.getGoldSheetSSOData(goldSheet.Id);
            GoldsheetSSOController.getObjectPermission();
            system.assertEquals(opp.Id, gsSSo[0].oppId);
            system.assertEquals(opp.StageName, gsSSo[0].stageName);
            Test.stopTest();
        }
    }
    static testMethod void testGetSearchResult() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Test.startTest();
            List<GoldSheetSSOWrapper> gsSSO = GoldsheetSSOController.getSearchResult(goldSheet.Id, 'tes', true);
            system.assertEquals(opp.Id, gsSSo[0].oppId);
            system.assertEquals(opp.StageName, gsSSo[0].stageName);
            Test.stopTest();
        }
    }
    static testMethod void testGetSearchResultOnLoad() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Test.startTest();
            List<GoldSheetSSOWrapper> gsSSO = GoldsheetSSOController.getSearchResultOnLoad(goldSheet.Id);
            system.assertEquals(opp.Id, gsSSo[0].oppId);
            system.assertEquals(opp.StageName, gsSSo[0].stageName);
            Test.stopTest();
        }
    }
    static testMethod void testGetSearchResultwithoutAllAccounts() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Test.startTest();
            List<GoldSheetSSOWrapper> gsSSO = GoldsheetSSOController.getSearchResult(goldSheet.Id, 'tes', false);
            system.assertEquals(opp.Id, gsSSo[0].oppId);
            system.assertEquals(opp.StageName, gsSSo[0].stageName);
            Test.stopTest();
        }
    }
    static testMethod void testRemoveGsSSO() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            // Opportunity opp = [SELECT Id,Name,StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            // Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            // Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Gold_Sheet_Single_Sales_Objective__c> gsSSo = [
                SELECT Id
                FROM Gold_Sheet_Single_Sales_Objective__c
                LIMIT 1
            ];
            Test.startTest();
            GoldsheetSSOController.removeGoldSheetSSO(gsSSo[0].Id);
            List<Gold_Sheet_Single_Sales_Objective__c> gsSSoAfterDelete = [
                SELECT ID
                FROM Gold_Sheet_Single_Sales_Objective__c
                LIMIT 1
            ];
            system.assertEquals(gsSSoAfterDelete.size(), 0);
            system.assertEquals(gsSSo.size(), 1);
            Test.stopTest();
        }
    }
    static testMethod void testSaveGsSSOData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name, StageName FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Opportunity opp2 = TestDataUtil.createOpportunity(acc, true);
            Test.startTest();
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('accountName', 'test acc1');
            newmap.put('closeDate', '08/31/2020');
            newmap.put('expectedRevenue', 12.3);
            newmap.put('oppId', opp2.Id);
            newmap.put('opportunityName', 'test oppty acc1');
            newmap.put('stageName', 'Qualification');

            String jsonstring = '[' + JSON.Serialize(newmap) + ']';

            //String jsonstring = '[{"accountName":"test acc1","closeDate":"08/31/2020","expectedRevenue":12.3,"oppId":opp.Id,"opportunityName":"test oppty acc1","stageName":"Prospecting"}]';
            GoldsheetSSOController.saveSelectedRecords(jsonstring, goldSheet.Id);
            List<GoldSheetSSOWrapper> gsSSO = GoldsheetSSOController.getGoldSheetSSOData(goldSheet.Id);
            system.assertEquals(gsSSO.size(), 2);
            system.assertEquals('Qualification', gsSSo[0].stageName);
            Test.stopTest();
        }
    }
}