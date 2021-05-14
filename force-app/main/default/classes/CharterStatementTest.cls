@isTest
public with sharing class CharterStatementTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldsheet = TestDataUtil.createGoldSheet(acc, true);
        }
    }
    static testMethod void testSaveData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Gold_Sheet__c goldsheet = [SELECT Id, Name, Charter_Statement__c FROM Gold_Sheet__c LIMIT 1];
            String id = goldsheet.Id;

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('EvaluationOfObjective', rfs);

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('charterStatement', 'test descrpiton');
            newmap.put('goldSheetId', id);
            newmap.put('hasEditAccess', true);

            String jsonstring = JSON.Serialize(newmap);

            charterStatementWrapper wrapper = charterStatement.saveCharterStatementData(jsonstring, rfsData);

            Gold_Sheet__c goldsheetData = [SELECT Id, Name, Charter_Statement__c FROM Gold_Sheet__c LIMIT 1];
            system.assertEquals(goldsheetData.Charter_Statement__c, 'test descrpiton');

            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('EvaluationOfObjective', rfs2);
            charterStatementWrapper wrapper2 = charterStatement.saveCharterStatementData(jsonstring, rfsData2);
            system.assertEquals(goldsheetData.Charter_Statement__c, 'test descrpiton');
        }
    }
    static testMethod void testGetData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Gold_Sheet__c goldsheet = [SELECT Id, Name, Charter_Statement__c FROM Gold_Sheet__c LIMIT 1];
            String id = goldsheet.Id;

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('charterStatement', 'test descrpiton');
            newmap.put('goldSheetId', id);
            newmap.put('hasEditAccess', true);

            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            charterStatementWrapper wrapper = charterStatement.saveCharterStatementData(jsonstring, rfsData);
            charterStatementWrapper wrapper2 = charterStatement.getCharterStatementData(id);
            Gold_Sheet__c goldsheetData = [SELECT Id, Name, Charter_Statement__c FROM Gold_Sheet__c LIMIT 1];
            system.assertEquals(wrapper2.charterStatement, 'test descrpiton');
        }
    }
    static testMethod void testdeleteData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Gold_Sheet__c goldsheet = [SELECT Id, Name, Charter_Statement__c FROM Gold_Sheet__c LIMIT 1];
            String id = goldsheet.Id;
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('charterStatement', 'test descrpiton');
            newmap.put('goldSheetId', id);
            newmap.put('hasEditAccess', true);

            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            charterStatementWrapper wrapper = charterStatement.saveCharterStatementData(jsonstring, rfsData);

            charterStatement.deleteCharterStatement(id);
            Gold_Sheet__c goldsheetdata = [SELECT Id, Name, Charter_Statement__c FROM Gold_Sheet__c LIMIT 1];
            system.assertEquals(goldsheetdata.Charter_Statement__c, null);
        }
    }
}