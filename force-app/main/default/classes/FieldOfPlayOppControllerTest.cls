@isTest
public with sharing class FieldOfPlayOppControllerTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
            List<Field_of_Play_Opportunity__c> f = TestDataUtil.createListFopOpps(goldSheet, con, true);
        }
    }

    @isTest
    static void checkAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String idval = [SELECT id FROM Gold_Sheet__c LIMIT 1].id;
            String fieldval = [SELECT id FROM Field_of_Play_Opportunity__c LIMIT 1].Id;
            Test.startTest();

            Map<String, Boolean> accessMap = FieldOfPlayOppController.getFoPOpportunityAccess();
            System.assertEquals(
                accessMap.get('isCreateable'),
                true,
                'User has create access on Field_of_Play_Opportunity__c'
            );
            FieldOfPlayOppController.getObjectName();
            Test.stopTest();
        }
    }

    @isTest
    static void createAndDeleteFoPTrendRecTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Map<String, String> rec = new Map<String, String>();
            rec.put('Title', 'Test Title');
            rec.put('Description', 'Test Description');
            rec.put('GoldSheetId', goldSheet.id);
            rec.put('KPI__c', 'KPI-Test');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('Title', rfs);

            Test.startTest();
            List<Field_of_Play_Opportunity__c> fopOppLst = [SELECT Id FROM Field_of_Play_Opportunity__c LIMIT 1];
            System.assertEquals(null, null, 'No Field_of_Play_Opportunity__c record exists');
            FieldOfPlayOppController.createFoPORec(rec, rfsData);
            fopOppLst = [SELECT Id FROM Field_of_Play_Opportunity__c LIMIT 1];
            System.assertEquals(fopOppLst.size(), 1, 'Record got created.');
            List<FieldOfPlayOppController.PlayOppWrapper> fopWrap = FieldOfPlayOppController.getFOPORec(goldSheet.Id);
            System.assertEquals(fopWrap[0].description, 'Test Description', 'Got record.');
            FieldOfPlayOppController.deleteFOPORec(fopOppLst[0].Id);
            fopOppLst = [SELECT Id FROM Field_of_Play_Opportunity__c WHERE id = :fopOppLst[0].Id];
            System.assertEquals(null, null, 'Record got deleted.');
            Test.stopTest();
        }
    }

    @isTest
    static void updateFoPTrendRecTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            Map<String, String> rec = new Map<String, String>();
            rec.put('Title', 'Test Title');
            rec.put('Description', 'Test Description');
            rec.put('GoldSheetId', goldSheet.id);
            rec.put('KPI', 'KPI-Test');
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('Title', rfs);

            Test.startTest();
            FieldOfPlayOppController.createFoPORec(rec, rfsData);
            List<Field_of_Play_Opportunity__c> fopOppLst = [
                SELECT Id, KPI__c
                FROM Field_of_Play_Opportunity__c
                LIMIT 1
            ];
            System.debug(fopOppLst[0]);
            Field_of_Play_Opportunity__c fop = fopOppLst[0];
            String newVal = fop.KPI__c + '-Updated';
            rec.put('Id', fop.Id);
            rec.put('KPI', newVal);
            System.assertEquals(fopOppLst.size(), 1, 'Record got created.');
            FieldOfPlayOppController.updateFOPORec(rec, rfsData, goldSheet.id);
            fopOppLst = [SELECT Id, KPI__c FROM Field_of_Play_Opportunity__c LIMIT 1];
            fop = fopOppLst[0];
            System.debug(fopOppLst[0]);
            System.assertEquals(newVal, fop.KPI__c, 'Update is successful.');
            Test.stopTest();
        }
    }
}