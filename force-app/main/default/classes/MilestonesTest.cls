@isTest
public with sharing class MilestonesTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    static Map<String, String> milestoneDataSetup(String goldSheetId, String milestoneNumber) {
        Map<String, String> milestoneData = new Map<String, String>();
        milestoneData.put('goldSheetId', goldSheetId);
        milestoneData.put('meetingdate', '2020-09-09');
        milestoneData.put('milestonenumber', milestoneNumber);
        milestoneData.put('meetingnotes', 'Test notes');
        return milestoneData;
    }

    @isTest
    static void upsertMilestoneTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            String jsonString =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msNumber":"Milestone 1" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" , "msPlayer":[] , "playerWrapperList":[] }';
            Test.startTest();
            Milestones.upsertMilestone(jsonString);
            Milestone__c milestone = [
                SELECT Id, Strategic_Player__c
                FROM Milestone__c
                WHERE Gold_Sheet__c = :goldSheet.Id
            ];
            System.assertEquals(milestone.Id != null, true, 'Record created!');
            Test.stopTest();
        }
    }

    @isTest
    static void getMilestoneRecordsTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            String milestone1Data =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer":[] , "msNumber":"Milestone 1" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';
            String milestone2Data =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer":[] , "msNumber":"Milestone 2" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';
            String milestone3Data =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer":[] , "msNumber":"Milestone 3" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';
            String milestone4Data =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer":[] , "msNumber":"Milestone 4" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';
            String milestone5Data =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer":[] , "msNumber":"Milestone 5" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';

            Test.startTest();
            Milestones.upsertMilestone(milestone1Data);
            Milestones.upsertMilestone(milestone2Data);
            Milestones.upsertMilestone(milestone3Data);
            Milestones.upsertMilestone(milestone4Data);
            Milestones.upsertMilestone(milestone5Data);
            Map<String, List<MilestoneWrapper>> milestonesWrapperMap = Milestones.getMilestoneRecords(goldSheet.Id);
            System.assertEquals(true, milestonesWrapperMap.size() > 0, 'Size of wrapper Map');
            Test.stopTest();
        }
    }

    @isTest
    static void deleteMilestoneTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            String milestoneData =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer":[] , "msNumber":"Milestone 1" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';

            Test.startTest();
            Milestones.upsertMilestone(milestoneData);
            Map<String, List<MilestoneWrapper>> milestonesWrapperMap = Milestones.getMilestoneRecords(goldSheet.Id);
            List<MilestoneWrapper> wrapperList = milestonesWrapperMap.get('Milestone1');
            String recordId = wrapperList[0].Id;
            System.assertEquals(true, recordId != null, 'Record Id is not null');
            Milestones.deleteMilestone(recordId);
            Test.stopTest();
        }
    }

    @isTest
    static void getMilestonesAccessTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            testData();
            Test.startTest();
            String objName = 'Milestone__c';
            Map<String, Boolean> accessData = Milestones.getMilestonesAccess();
            ApexCommonUtil.getObjectAccess(objName);
            System.assertEquals(true, accessData.size() > 0, 'Map of object access is not null');
            Test.stopTest();
        }
    }

    @isTest
    static void getStrategicPlayerName_Test() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Milestones.WrapperLookupObject wrapObj = Milestones.getStrategicPlayerName();
            String targetFieldName = ApexCommonUtil.getObjectwithNameSpace('Strategic_Player__c');
            System.assertEquals(wrapObj.targetField, targetFieldName, 'Got correct Target Field Name!');
        }
    }

    @isTest
    static void removePlayer_Test() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c goldSheet = TestDataUtil.createGoldSheet(acc, true);
            List<Strategic_Player__c> sp = TestDataUtil.createListStrategicPlayer(goldSheet, con, true);
            Set<String> idSet = new Set<String>();
            idSet.add(sp[0].Id);
            String milestoneData =
                '{ "goldSheet":"' +
                goldSheet.Id +
                '" , "msPlayer": ["' +
                sp[0].Id +
                '"] , "msNumber":"Milestone 1" ,"msNotes":"Test Notes" ,"msDate":"2020-09-09" }';

            Test.startTest();

            Milestones.upsertMilestone(milestoneData);

            Milestone__c milestone = [
                SELECT Id, Strategic_Player__c
                FROM Milestone__c
                WHERE Gold_Sheet__c = :goldSheet.Id
            ];

            List<String> idLst = new List<String>();
            idLst.add(sp[0].Id);
            Milestone_Strategic_Player_Map__c spMap = [
                SELECT Id, Name, Milestone_ID__c, Strategic_Player_ID__c
                FROM Milestone_Strategic_Player_Map__c
                WHERE Milestone_ID__c = :milestone.Id AND Strategic_Player_ID__c = :sp[0].Id
            ];
            System.assertEquals(spMap != null, true, 'Record exists!');
            Milestones.removePlayer(idLst, milestone.Id);

            List<Milestone_Strategic_Player_Map__c> spMapLst = [
                SELECT Id, Name, Milestone_ID__c, Strategic_Player_ID__c
                FROM Milestone_Strategic_Player_Map__c
                WHERE Milestone_ID__c = :milestone.Id AND Strategic_Player_ID__c = :sp[0].Id
            ];
            System.assertEquals(spMapLst.size() == 0, true, 'Record got deleted!');
        }
    }
}