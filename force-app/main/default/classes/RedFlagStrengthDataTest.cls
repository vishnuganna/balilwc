@isTest
public with sharing class RedFlagStrengthDataTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, true);
        }
    }

    @isTest
    static void validatecreateRFSrecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            Blue_Sheet__c bs = [SELECT id, name FROM Blue_Sheet__c LIMIT 1];
            String blueSheetId = bs.id;
            String objectApiName = 'Buying_Influence__c';
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);

            Test.startTest();
            RedFlagStrengthData.createRFSrecords(blueSheetId, objectApiName, rfsData);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validategetRFSWrapperList() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            String sourceId = bi[0].id;

            Test.startTest();
            RedFlagStrengthData.getRFSWrapperList(sourceId);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validateupdateRFSrecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            String oppId = opp.id;
            Blue_Sheet__c bs = [SELECT id, name FROM Blue_Sheet__c LIMIT 1];
            String blueSheetId = bs.id;
            String objectApiName = 'Buying_Influence__c';
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            String recordId = bi[0].id;
            String objectName = 'Buying_Influence__c';

            Test.startTest();
            RedFlagStrengthData.updateRFSRecords(objectName, recordId, oppId, rfsData);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validateupdateRFSrecords2() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            String oppId = opp.id;
            Blue_Sheet__c bs = [SELECT id, name FROM Blue_Sheet__c LIMIT 1];
            String blueSheetId = bs.id;
            Contact cont = [SELECT id, firstname, lastname FROM Contact LIMIT 1];
            String objectApiName = 'Buying_Influence__c';
            Buying_Influence__c bi = new Buying_Influence__c(
                Blue_Sheet__c = bs.Id,
                Business_Results__c = 'check',
                Personal_Wins__c = 'wins',
                Contact__c = cont.Id,
                Rating__c = '+1',
                Buying_From_us__c = true,
                Rating_Evidence__c = 'testRate',
                Medium__c = true,
                Economic__c = true,
                Coach__c = false,
                Technical__c = false,
                User__c = false,
                Trouble__c = true
            );
            insert bi;
            String recordId = bi.id;
            String objectName = 'Buying_Influence__c';
            Red_Flag_Strength_Marker__c rf = new Red_Flag_Strength_Marker__c(
                Source_Id__c = recordId,
                Is_Red_Flag_Selected__c = true,
                Is_Strength_Selected__c = false,
                Blue_Sheet_ID__c = blueSheetId,
                Field_API_Name__c = 'BuyingMode',
                Object_API_Name__c = objectName
            );
            insert rf;
            Map<String, Map<String, Object>> rfsData = new Map<String, Map<String, Object>>();
            Map<String, Object> rfs = new Map<String, Object>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', true);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', 'BuyingMode');
            rfs.put('sourceId', recordId);
            rfsData.put('BuyingMode', rfs);
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', true);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', 'BuyingInfluenceRole');
            rfs.put('sourceId', recordId);
            rfsData.put('BuyingInfluenceRole', rfs);

            RedFlagStrengthData.updateRFSRecords(objectName, recordId, oppId, rfsData);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validategetRFSrecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            String recordId = bi[0].id;

            Test.startTest();
            RedFlagStrengthData.getRFSrecords(recordId);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validatecreateMarker() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            String oppId = opp.id;
            Blue_Sheet__c bs = [SELECT id, name FROM Blue_Sheet__c LIMIT 1];
            String blueSheetId = bs.id;
            String objectName = 'Buying_Influence__c';
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            String recordId = bi[0].id;
            String fld = 'BuyingInfluenceRole';

            Test.startTest();
            RedFlagStrengthData.createMarker(bluesheetId, objectName, recordId, fld, rfsData);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }
}