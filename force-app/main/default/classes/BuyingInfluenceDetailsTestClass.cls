@isTest
public with sharing class BuyingInfluenceDetailsTestClass {
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
    static void validateConstructor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            BuyingInfluenceDetails bidObj = new BuyingInfluenceDetails();
            Test.stopTest();
            system.assertEquals(true, bidObj != null);
        }
    }

    @isTest
    static void validateGetWrapperObject() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            BuyingInfluenceWrapperClass wrap = new BuyingInfluenceWrapperClass();
            wrap = BuyingInfluenceDetails.getWrapperObject();
            Test.stopTest();
            system.assertEquals(true, wrap != null);
        }
    }

    @isTest
    static void validateGetBuyingInfluence() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];

            Test.startTest();
            BuyingInfluenceDetails.getBuyingInfluence(opp.Id);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validateGetBlueSheetId() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            //String oppId  = bi[0].Blue_Sheet__r.Opportunity__c;

            Test.startTest();
            BuyingInfluenceDetails.getBlueSheetId(opp.Id);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validateSaveRecord() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            String oppId = opp.id;
            Contact con = [SELECT id FROM Contact LIMIT 1];
            Account ac = [SELECT id FROM Account LIMIT 1];
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            String blueSheetId = bi[0].id;
            String jsonString = '{ "Blue_Sheet__c":"opp.id" , "Contact__c":"con.id"}';
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);

            Test.startTest();
            //BuyingInfluenceDetails.saveRecord(jsonString);
            BuyingInfluenceDetails.saveRecord(jsonString, blueSheetId, rfsData, oppId);
            bi[0].High__c = false;
            BuyingInfluenceDetails.saveRecord(jsonString, blueSheetId, rfsData, oppId);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validateSaveRecordCreate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            String oppId = opp.id;
            Contact con = [SELECT id FROM Contact LIMIT 1];
            Account ac = [SELECT id FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT id, name FROM Blue_Sheet__c LIMIT 1];
            /*Buying_Influence__c binf = new Buying_Influence__c(
                Blue_Sheet__c = bs.Id, Business_Results__c='check', Personal_Wins__c='wins',             
                Contact__c =cont.Id, Rating__c='+2', Buying_From_us__c=true, Rating_Evidence__c='testRate',
                Medium__c=true, Economic__c=false, Coach__c=false, Technical__c=false, User__c=false, Over_Confident__c=true);*/
            String blueSheetId = bs.id;
            String jsonString = '{ "Blue_Sheet__c":"bs.id" , "Contact__c":"con.id" , "Business_Results__c":"check2" , "Personal_Wins__c":"wins2" , "Rating__c":"+2" , "Buying_From_us__c":"true" , "Rating_Evidence__c":"testRate2" , "Medium__c":"true" , "Economic__c":"true" , "Coach__c":"false" , "Technical__c":"false" , "User__c":"false" , "Over_Confident__c":"true"}';
            Map<String, Map<String, Boolean>> rfsData = new Map<String, Map<String, Boolean>>();
            Map<String, Boolean> rfs = new Map<String, Boolean>();
            rfs.put('redFlagSelected', false);
            rfs.put('strengthSelected', false);
            rfs.put('noneSelected', false);
            rfs.put('fieldApiName', false);
            rfsData.put('BuyingInfluenceRole', rfs);

            Test.startTest();
            //BuyingInfluenceDetails.saveRecord(jsonString);
            BuyingInfluenceDetails.saveRecord(jsonString, blueSheetId, rfsData, oppId);
            System.assertEquals(opp.name, 'Test Opportunity');
            Test.stopTest();
        }
    }

    @isTest
    static void validateDeleteRecord() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
            ];

            Test.startTest();
            Map<String, String> mapResult = BuyingInfluenceDetails.deleteRecord(bi[0].id);
            Test.stopTest();
            system.assertEquals('Success', mapResult.get('status'));
        }
    }

    @isTest
    static void validateDeleteRecordException() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Buying_Influence__c> bi = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c, High__c
                FROM Buying_Influence__c
            ];

            Test.startTest();
            Map<String, String> mapResult = BuyingInfluenceDetails.deleteRecord(bi[0].Name);
            Test.stopTest();
            system.assertEquals('Error', mapResult.get('status'));
        }
    }

    @isTest
    static void validateGetObjectName() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            BuyingInfluenceDetails.wrapperLookupObject wrap = BuyingInfluenceDetails.getObjectName();
            System.assertEquals(true, wrap != null);
            Test.stopTest();
        }
    }
}