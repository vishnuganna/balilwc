@isTest
public class BuySellHierarchyControllerTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldsheet = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    @isTest
    static void testGetPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            String buySellValues = BuySellHierarchyController.getPicklistValues();
            System.assert(!String.isEmpty(buySellValues));
            Test.stopTest();
        }
    }

    @isTest
    static void testGetObjectPermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = BuySellHierarchyController.getObjectPermission();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }

    @isTest
    static void testSaveBuySellHierarchyData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();

            Gold_Sheet__c goldsheet = [SELECT Id, Name FROM Gold_Sheet__c LIMIT 1];
            String id = goldsheet.Id;

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('EvaluationOfObjective', rfs);

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('buySellhierarchyName', 'add buy sell data');
            newmap.put('goldSheetId', id);
            newmap.put('hasEditAccess', true);

            String jsonsObjecttring = JSON.Serialize(newmap);

            BuySellHierarchyWrapper buySellWrapper = BuySellHierarchyController.saveBuySellHierarchyData(
                jsonsObjecttring,
                rfsData
            );

            Gold_Sheet__c goldsheetData = [SELECT Id, Name FROM Gold_Sheet__c LIMIT 1];

            system.assertEquals(buySellWrapper.hasEditAccess, true);

            Map<String, Map<String, Boolean>> rfsData2 = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs2 = new Map<String, Boolean>();
            rfs2.put('redFlagSelected', false);
            rfs2.put('strengthSelected', true);
            rfs2.put('noneSelected', false);
            rfs2.put('fieldApiName', false);
            rfsData2.put('EvaluationOfObjective', rfs2);
            BuySellHierarchyWrapper buySellHierarchyWrapperWrapper2 = BuySellHierarchyController.saveBuySellHierarchyData(
                jsonsObjecttring,
                rfsData2
            );
            system.assertEquals(buySellWrapper.hasEditAccess, true);
            Test.stopTest();
        }
    }

    @isTest
    static void testGetBusinessHierarchyData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();

            Gold_Sheet__c goldsheet = [SELECT Id, Name FROM Gold_Sheet__c LIMIT 1];
            String id = goldsheet.Id;
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', true);
            rfs.put('fieldApiName', false);
            rfsData.put('EvaluationOfObjective', rfs);

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('buySellhierarchyName', 'add buy sell data 2');
            newmap.put('goldSheetId', id);
            newmap.put('hasEditAccess', true);

            String jsonstring = JSON.Serialize(newmap);

            BuySellHierarchyWrapper buySellWrapper = BuySellHierarchyController.saveBuySellHierarchyData(
                jsonstring,
                rfsData
            );

            Gold_Sheet__c goldsheetData = [SELECT Id, Name FROM Gold_Sheet__c LIMIT 1];

            system.assertEquals(buySellWrapper.hasEditAccess, true);
            Test.stopTest();
        }
    }
}