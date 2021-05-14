@istest
public with sharing class LandingTestClass {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Opportunity opp = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            Business_Rules_Group__c brg = new Business_Rules_Group__c();
            brg.name = 'EasterGrp';
            insert brg;
            Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
            brgm.Member_Name__c = user.Id;
            brgm.Business_Rules_Group__c = brg.Id;
            insert brgm;
            List<Business_Rules__c> brLst = new List<Business_Rules__c>();
            Business_Rules__c br1 = new Business_Rules__c(
                IsActive__c = true,
                Opportunity_Stage_Global__c = 'Qualification',
                Business_Rule_Catagory__c = 'Opportunity',
                is_curr_pos_negative__c = true,
                is_competitor_identified__c = true,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
        }
    }

    @isTest
    static void getFOpSpotLightRecordsTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            system.test.startTest();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Strategic_Player__c> sp = TestDataUtil.createListStrategicPlayer(goldSheet, con, true);
            LandingFOpSpotLight.FOPSpotLightRecordsInfo wrapper = LandingFOpSpotLight.getFOpSpotLightRecords(
                userset,
                5,
                0
            );
            system.assertEquals(1, wrapper.totalRecordCount, 'Error on getFOpSpotLightRecordsTest');
            system.assertEquals(1, wrapper.fopSpotLightRecords.size(), 'Error on getFOpSpotLightRecordsTest');
            system.test.stopTest();
        }
    }
    @isTest
    static void getLandingSpotLightTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            system.test.startTest();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Opportunity opp = [SELECT Id, Name, stageName FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
            opp.stageName = 'Closed';
            update opp;
            LandingSpotlight.LandingSpotlightInfo wrapper = LandingSpotlight.getBlueSheetRecords(userset, 5, 0);
            system.assertEquals(opp.Id, wrapper.blueSheetRecords[0].oppId, 'Error on getBlueSheetRecordsTest');
            system.assertEquals(
                'false',
                wrapper.blueSheetRecords[0].opportunityIsClosed,
                'Error on getBlueSheetRecordsTest'
            );
            system.test.stopTest();
        }
    }
    @isTest
    static void getLandingkfsActionsTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Opportunity opp = [SELECT Id, Name, stageName FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
            //opp.stageName = 'Closed';
            //update opp;
            Blue_Sheet__c bs = [SELECT Id, Progress__c FROM Blue_Sheet__c LIMIT 1];
            Current_Position__c cp = TestDataUtil.createCurrentPosition(bs, false);
            cp.Current_Position__c = 'Panic';
            insert cp;
            system.test.startTest();
            TestDataUtil.createCompetition(bs, acc, true);

            LandingKFSActions.LandingKFSActionsRecordsInfo wrapper = LandingKFSActions.getRecommendationRecords(
                userset,
                5,
                0
            );
            system.assertEquals(true, true, 'record not found');
            system.assertEquals(true, true, 'record not found');
            system.assertEquals(
                opp.Id,
                wrapper.recommendationRecords[0].oppId,
                'Error on getRecommendationRecordsTest'
            );
            system.assertEquals(
                opp.Name,
                wrapper.recommendationRecords[0].opportunityName,
                'Error on getRecommendationRecordsTest'
            );
            system.test.stopTest();
        }
    }
    @isTest
    static void getLandingDueSoonTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            system.test.startTest();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Opportunity opp = [SELECT Id, Name, stageName FROM Opportunity WHERE AccountId = :acc.Id LIMIT 1];
            opp.stageName = 'Closed';
            update opp;
            Blue_Sheet__c bluesheet = [
                SELECT Id, Name, Action_Plan_Progress__c
                FROM Blue_Sheet__c
                WHERE Opportunity__c = :opp.Id
                LIMIT 1
            ];
            Action_Plan__c ap = TestDataUtil.createActionPlan(bluesheet, true);
            ap.Due_Date__c = date.today() + 3;
            update ap;
            LandingDueSoon.LandingDueSoonRecordsInfo wrapper = LandingDueSoon.getActionPlanRecord(userset, 5, 0);
            system.assertEquals(opp.Id, wrapper.kfsellLandingRecords[0].oppId, 'Error on getActionPlanRecordTest');
            system.assertEquals(
                'test Com Detail',
                wrapper.kfsellLandingRecords[0].summary,
                'Error on getActionPlanRecordTest'
            );
            system.test.stopTest();
        }
    }
    @isTest
    static void getLandingGoldSheetActivitiesDueTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            system.test.startTest();
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Action__c> fc = TestDataUtil.createActions(gs, true);
            fc[0].Due_Date__c = date.today() - 3;
            update fc[0];
            GoldSheetLandingPageAction obj = new GoldSheetLandingPageAction();
            obj.processGoldSheetActivityDueDate();
            LandingGoldSheetActivitiesPastDue.LandingGoldSheetActivitiesPastDueInfo wrapper = LandingGoldSheetActivitiesPastDue.getFoPActivityRecords(
                userset,
                5,
                0
            );
            system.assertEquals(gs.Name, wrapper.activityRecords[0].fopName, 'Error on getActionPlanRecordTest');
            system.assertEquals(gs.Id, wrapper.activityRecords[0].fopId, 'Error on getActionPlanRecordTest');
            system.test.stopTest();
        }
    }
    @isTest
    static void getLandingMilestonesTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            system.test.startTest();
            Account acc = [SELECT Name FROM Account WHERE Name = 'Test Account' LIMIT 1];
            Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
            Gold_Sheet__c goldSheet = [SELECT Id, Name FROM Gold_Sheet__c WHERE Account__c = :acc.Id LIMIT 1];
            List<Strategic_Player__c> sp = TestDataUtil.createListStrategicPlayer(goldSheet, con, true);
            List<Milestone__c> miles = TestDataUtil.createListMilestones(goldSheet, sp[0], true);
            LandingMilestones.LandingMilestoneRecordsInfo wrapper = LandingMilestones.getFOpMilestoneRecords(
                userset,
                5,
                0
            );
            system.assertEquals(4, wrapper.milestoneRecords.size(), 'cheking size of milestone records');
            system.assertNotEquals(5, wrapper.milestoneRecords.size(), 'cheking size of milestone records');
            Landing.getSetOfReportees();
            Landing.checkIfLoggedUserIsManager();
            Landing.getreportLinkMap('KFS_Landing_Owner');
            system.test.stopTest();
        }
    }
    @isTest
    static void getKFSFOPActionsTest() {
        User user = UserTest.createUserWithPerms();
        List<String> userset = new List<String>();
        userset.add(user.Id);
        System.runAs(user) {
            system.test.startTest();
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
            List<Action__c> fc = TestDataUtil.createActions(gs, true);
            gs.Last_Updated__c = date.today() - 12;
            update gs;
            GoldSheetLandingPageAction obj = new GoldSheetLandingPageAction();
            obj.processGoldSheetLastUpdate();
            LandingFOPKFSActions.LandingFOPKFSActionsInfo wrapper = LandingFOPKFSActions.getFoPRecords(userset, 5, 0);
            system.assertEquals(gs.Name, wrapper.fOPKFSRecords[0].fopName, 'Error on getActionPlanRecordTest');
            system.assertNotEquals(
                String.ValueOf(date.today()),
                wrapper.fOPKFSRecords[0].fopLastUpdated,
                'Error on getActionPlanRecordTest'
            );
            system.test.stopTest();
        }
    }
}