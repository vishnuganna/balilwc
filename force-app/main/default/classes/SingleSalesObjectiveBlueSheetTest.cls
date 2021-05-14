@isTest
public with sharing class SingleSalesObjectiveBlueSheetTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Competition__c comp = TestDataUtil.createCompetition(bs, acc, true);
        }
    }

    static testMethod void testsaveSingleSalesObjective() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Blue_Sheet__c> bS = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            map<String, String> sSOData = new Map<String, String>();
            sSOData.put('blueSheetId', bS[0].Id);
            sSOData.put('singleSalesObjectiveBS', 'test comp Details');

            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('singleSalesObjectiveBlueSheet', rfs);

            String jsonstring = JSON.Serialize(sSOData);
            SingleSalesObjectiveBSWrapper data = SingleSalesObjectiveBlueSheet.saveSingleSalesObjective(
                jsonstring,
                rfsData
            );
            System.assertEquals(true, data != null);
        }
    }

    static testMethod void testSaveSingleSalesObjectiveException() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            try {
                List<Blue_Sheet__c> bS = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
                map<String, String> sSOData = new Map<String, String>();
                sSOData.put('blueSheetId', null);
                sSOData.put('singleSalesObjectiveBS', 'test comp Details');

                Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
                Map<String, Boolean> rfs = new Map<String, Boolean>();
                rfs.put('redFlagSelected', false);
                rfs.put('strengthSelected', false);
                rfs.put('noneSelected', false);
                rfs.put('fieldApiName', false);
                rfsData.put('singleSalesObjectiveBlueSheet', rfs);

                String jsonstring = JSON.Serialize(sSOData);
                SingleSalesObjectiveBSWrapper data = SingleSalesObjectiveBlueSheet.saveSingleSalesObjective(
                    jsonstring,
                    rfsData
                );
            } catch (Exception ex) {
                System.assertEquals(ex.getMessage().contains('error in updating record'), true);
            }
        }
    }

    static testMethod void testSaveSingleSalesObjectivePermission() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Boolean> objectPermissionValue = SingleSalesObjectiveBlueSheet.getSingleSalesObjectiveAccess();
            system.assertEquals(true, objectPermissionValue.size() > 0, 'Check access map size');
            Test.stopTest();
        }
    }
}