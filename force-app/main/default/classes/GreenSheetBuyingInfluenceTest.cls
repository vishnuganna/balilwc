@istest
public with sharing class GreenSheetBuyingInfluenceTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
        }
    }

    @istest
    static void getGreenBuyingInfluenceRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheetId,
                true,
                con
            );
            List<GreenSheetBuyingInfluenceWrapper> greenbiList = GreenSheetBuyingInfluence.getGreenBuyingInfluenceRecords(
                greenSheetId
            );
            system.assertequals(greenbiList[0].buyingInfluenceRole, 'economic', 'Checking Economic in Greensheet BI');
            system.assertequals(greenbiList[0].concept, 'Test Concept1', 'Checking Concept in Greensheet BI');
        }
    }

    @istest
    static void removeGreenBuyingInfluenceTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheetId,
                true,
                con
            );
            GreenSheetBuyingInfluence.removeGreenBuyingInfluence(greenBI[0].Id);
            system.assertequals(greenBI.size(), 3, 'Checking size for GreenSheet BI');
            List<GreenSheetBuyingInfluenceWrapper> greenbiList = GreenSheetBuyingInfluence.getGreenBuyingInfluenceRecords(
                greenSheetId
            );
            system.assertequals(greenbiList.size(), 2, 'Checking size for GreenSheet BI');
            GreenSheetBuyingInfluence.getGreenBuyingInfluenceAccess();
        }
    }

    @istest
    static void removeGreenBuyingInfluenceTest2() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheetId,
                true,
                con
            );
            system.assertequals(greenBI.size(), 3, 'Checking size for GreenSheet BI');
            system.assertNotequals(greenBI.size(), 2, 'Checking size for GreenSheet BI');
            try {
                GreenSheetBuyingInfluence.removeGreenBuyingInfluence(greenSheetId);
            } catch (Exception e) {
                system.System.debug('exception ----' + e);
            }
        }
    }

    @istest
    static void createGSBIRecTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('concept', 'test concept 4');
            newmap.put('buyingInfluenceRole', 'user,coach');
            newmap.put('contactId', con.Id);
            newmap.put('greenSheet', greenSheetId);
            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);
            GreenSheetBuyingInfluence.createGSBIRec(jsonstring, rfsData);
            List<GreenSheetBuyingInfluenceWrapper> greenbiList = GreenSheetBuyingInfluence.getGreenBuyingInfluenceRecords(
                greenSheetId
            );
            system.assertequals(greenbiList.size(), 1, 'Checking size for GreenSheet BI');
            system.assertNotequals(greenbiList.size(), 0, 'Checking size for GreenSheet BI');
        }
    }

    @istest
    static void createGSBIRecTest2() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Task> taskList = [SELECT Id, Subject, Priority, Status, OwnerId FROM Task];
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id, Name, title FROM Contact WHERE AccountId = :acc.Id];
            String greenSheetId = GreenSheetNavigate.createGreenSheet(taskList[0].Id);
            List<Green_Sheet_Buying_Influence__c> greenBI = TestDataUtil.createGreenSheetBuyingInfluence(
                greenSheetId,
                true,
                con
            );
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('concept', 'test concept 4');
            newmap.put('buyingInfluenceRole', 'user,coach');
            newmap.put('contactId', con.Id);
            newmap.put('greenSheet', greenSheetId);
            newmap.put('id', greenBI[0].id);
            String jsonstring = JSON.Serialize(newmap);
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);
            GreenSheetBuyingInfluence.createGSBIRec(jsonstring, rfsData);
            List<GreenSheetBuyingInfluenceWrapper> greenbiList = GreenSheetBuyingInfluence.getGreenBuyingInfluenceRecords(
                greenSheetId
            );
            system.assertequals(greenbiList.size(), 3, 'Checking size for GreenSheet BI');
            system.assertNotequals(greenbiList.size(), 4, 'Checking size for GreenSheet BI');
        }
    }
}