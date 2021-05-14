@istest
public with sharing class StrategicPlayerControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Strategic_Player__c> sp = TestDataUtil.createListStrategicPlayer(gs, con, true);
        }
    }
    static testMethod void testGetStrategicPlayers() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Test.startTest();
            List<StrategicPlayerWrapper> wrapper = StrategicPlayerController.getStrategicPlayerData(
                goldSheet.Id,
                queryLimit,
                queryOffset
            );
            StrategicPlayerController.StrategicPlayersInfo wrapperInfo = StrategicPlayerController.getPlayersList(
                goldSheet.Id,
                queryLimit,
                queryOffset
            );
            List<String> accountOwnerTitle = StrategicPlayerController.getAccountOwnerTitle(goldSheet.Id);
            system.assertEquals(wrapper[0].goldsheetId, goldSheet.Id);
            Test.stopTest();
        }
    }
    static testMethod void testSaveStrategicPlayers() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('buySellPosition', 'Level 1: Commodities');
            newmap.put('ourTeamMember', user.Id);
            newmap.put('role', 'Sponsor');
            newmap.put('goldsheetId', goldSheet.Id);
            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('role', rfs);
            Test.startTest();
            List<StrategicPlayerWrapper> wrapper = StrategicPlayerController.saveStrategicPlayerData(
                jsonstring,
                rfsData
            );
            system.assertEquals(wrapper[0].buySellPosition, 'Level 1: Commodities');
            Test.stopTest();
        }
    }
    static testMethod void testUpdateStrategicPlayers() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = new Contact(firstname = 'Test1', lastname = 'Contact1', Accountid = acc.id);
            DataFactory.create(con);
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Strategic_Player__c> strategicPlayerList = [
                SELECT Id, Name, Gold_Sheet__c, Team_Member__c, Strategic_Player_Role__c, Strategic_Player__c
                FROM Strategic_Player__c
                WHERE Gold_Sheet__c = :goldsheet.Id
            ];

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('buySellPosition', 'Level 1: Commodities');
            newmap.put('ourTeamMember', user.Id);
            newmap.put('role', 'Additional Key Player');
            newmap.put('goldsheetId', goldSheet.Id);
            newmap.put('id', strategicPlayerList[0].Id);
            newmap.put('strategicPlayer', con.Id);
            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('role', rfs);
            Test.startTest();
            List<StrategicPlayerWrapper> wrapper = StrategicPlayerController.saveStrategicPlayerData(
                jsonstring,
                rfsData
            );
            system.assertEquals(wrapper[0].role, 'Anti Sponsor');
            Test.stopTest();
        }
    }
    static testMethod void testDeleteStrategicPlayers() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Integer queryLimit = 5;
            Integer queryOffset = 0;
            Test.startTest();
            List<StrategicPlayerWrapper> wrapper = StrategicPlayerController.getStrategicPlayerData(
                goldSheet.Id,
                queryLimit,
                queryOffset
            );
            StrategicPlayerController.removeStrategicPlayer(wrapper[0].Id);
            List<StrategicPlayerWrapper> wrapperAfterDelete = StrategicPlayerController.getStrategicPlayerData(
                goldSheet.Id,
                queryLimit,
                queryOffset
            );
            system.assertEquals(wrapperAfterDelete.size(), 2);
            Test.stopTest();
        }
    }

    static testMethod void testGetLookupObjects() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            StrategicPlayerController.WrapperLookupObject wrapper = StrategicPlayerController.getLookupObjects();
            System.assertNotEquals(wrapper, null);
            Test.stopTest();
        }
    }
    static testMethod void testBuySellPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String buySellValues = StrategicPlayerController.getbuySellPicklistValues();
            System.assert(!String.isEmpty(buySellValues));
            Test.stopTest();
        }
    }
    static testMethod void testRolePicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String roleValues = StrategicPlayerController.getRolePicklistValues();
            System.assert(!String.isEmpty(roleValues));
            Test.stopTest();
        }
    }
    static testMethod void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = StrategicPlayerController.getObjectPermission();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
}