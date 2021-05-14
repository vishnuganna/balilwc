@isTest
public with sharing class ProgressNavigationTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Score_Card__c cp = TestDataUtil.createScoreCard(bs, true);
            Score_Card_Detail__c detail = TestDataUtil.createScoreCardDetails(cp, true);
            // Competition__c competition = TestDataUtil.createCompetition(bs,acc,true);
        }
    }

    static testMethod void testInsertScorecardDetails() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Score_Card__c scorecard = [SELECT Id, Name, Blue_Sheet__c FROM Score_Card__c LIMIT 1];
            Score_Card_Detail__c detail2 = TestDataUtil.createScoreCardDetails(scorecard, true);

            Blue_Sheet__c bluesheet = [
                SELECT Id, Name, Scorecard_Progress__c
                FROM Blue_Sheet__c
                WHERE Id = :scorecard.Blue_Sheet__c
                LIMIT 1
            ];

            system.assertEquals('In Progress', bluesheet.Scorecard_Progress__c);
            system.Test.stopTest();
        }
    }
    static testMethod void testScorecardCompleteStatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Score_Card__c scorecard = [SELECT Id, Name, Blue_Sheet__c, Total_Score__c FROM Score_Card__c LIMIT 1];

            List<Score_Card_Detail__c> listToInsert = new List<Score_Card_Detail__c>();
            for (Integer i = 0; i < 5; i++) {
                Score_Card_Detail__c detail2 = TestDataUtil.createScoreCardDetails(scorecard, false);
                listToInsert.add(detail2);
            }

            insert listToInsert;

            Blue_Sheet__c bluesheet = [
                SELECT Id, Name, Scorecard_Progress__c
                FROM Blue_Sheet__c
                WHERE Id = :scorecard.Blue_Sheet__c
                LIMIT 1
            ];

            system.assertEquals('Complete', bluesheet.Scorecard_Progress__c);
            system.Test.stopTest();
        }
    }
    static testMethod void testDeleteScorecard() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Score_Card__c scorecard = [SELECT Id, Name, Blue_Sheet__c FROM Score_Card__c LIMIT 1];
            List<Score_Card__c> lstScorecard = new List<Score_Card__c>{ scorecard };
            DataFactory.remove(lstScorecard, true, true, true);

            Blue_Sheet__c bluesheet = [
                SELECT Id, Name, Scorecard_Progress__c
                FROM Blue_Sheet__c
                WHERE Id = :scorecard.Blue_Sheet__c
                LIMIT 1
            ];

            system.assertEquals('Not Started', bluesheet.Scorecard_Progress__c);
            system.Test.stopTest();
        }
    }
    static testMethod void testCompetitionCompletionStatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Blue_Sheet__c bs = [SELECT Id, Progress__c, Competition_Progress__c FROM Blue_Sheet__c LIMIT 1];
            Account acc = [SELECT Id FROM Account];
            //Inserting a list of competition which has incomplete and complete competition records
            List<Competition__c> competition = TestDataUtil.createListCompetition(bs, acc, true);
            Blue_Sheet__c bsafterInsert = [SELECT Id, Progress__c, Competition_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterInsert.Competition_Progress__c, 'Complete');
            system.Test.stopTest();
        }
    }
    static testMethod void testCompetitionNotStartedStatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Blue_Sheet__c bs = [SELECT Id, Progress__c, Competition_Progress__c FROM Blue_Sheet__c LIMIT 1];
            Account acc = [SELECT Id FROM Account];
            //Inserting Competition record
            Competition__c competition = TestDataUtil.createCompetition(bs, acc, true);
            Blue_Sheet__c bsafterInsert = [SELECT Id, Progress__c, Competition_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterInsert.Competition_Progress__c, 'Complete');
            //Deleting Competition to check status
            delete competition;
            Blue_Sheet__c bsafterDelete = [SELECT Id, Progress__c, Competition_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterDelete.Competition_Progress__c, 'Not Started');
            system.Test.stopTest();
        }
    }
    static testMethod void testCurrentPositionCompletedStatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Blue_Sheet__c bs = [SELECT Id, Progress__c, Current_Position_Progress__c FROM Blue_Sheet__c LIMIT 1];
            Account acc = [SELECT Id FROM Account];
            //Inserting current position record
            Current_Position__c cp = TestDataUtil.createCurrentPosition(bs, true);
            Blue_Sheet__c bsafterInsert = [
                SELECT Id, Progress__c, Current_Position_Progress__c
                FROM Blue_Sheet__c
                LIMIT 1
            ];
            System.assertEquals(bsafterInsert.Current_Position_Progress__c, 'Complete');
            //Updating current Position record to null check status
            cp.Current_Position__c = '';
            update cp;
            Blue_Sheet__c bsafterDelete = [
                SELECT Id, Progress__c, Current_Position_Progress__c
                FROM Blue_Sheet__c
                LIMIT 1
            ];
            System.assertEquals(bsafterDelete.Current_Position_Progress__c, 'Not Started');
            system.Test.stopTest();
        }
    }
    // static testMethod void testBIProgressionStatus() {
    //     User user = UserTest.createUserWithPerms();
    //     System.runAs(user) {
    //         system.test.startTest();
    //         Blue_Sheet__c bs = [SELECT Id, Progress__c, Buying_Influence_Progress__c FROM Blue_Sheet__c LIMIT 1];
    //         Contact con = [SELECT Id FROM Contact];
    //         //Inserting a list of competition which has incomplete and complete competition records
    //         List<Buying_Influence__c> bI = TestDataUtil.createBuyingInfluence(bs, con, true);
    //         Blue_Sheet__c bsafterInsert = [
    //             SELECT Id, Progress__c, Buying_Influence_Progress__c
    //             FROM Blue_Sheet__c
    //             LIMIT 1
    //         ];
    //         System.assertEquals(bsafterInsert.Buying_Influence_Progress__c, 'Complete');
    //         //Update BI reord to refelct In progress Status
    //         List<Buying_Influence__c> bIUpdate = new List<Buying_Influence__c>();
    //         bI[0].Rating_Evidence__c = '';
    //         bI[1].Rating_Evidence__c = '';
    //         bI[2].Rating_Evidence__c = '';
    //         bIUpdate.add(bI[0]);
    //         bIUpdate.add(bI[1]);
    //         bIUpdate.add(bI[2]);
    //         update bIUpdate;
    //         Blue_Sheet__c bsafterUpdate = [
    //             SELECT Id, Progress__c, Buying_Influence_Progress__c
    //             FROM Blue_Sheet__c
    //             LIMIT 1
    //         ];
    //         System.assertEquals(bsafterUpdate.Buying_Influence_Progress__c, 'In Progress');
    //         //Delete all BI Records to update to Not Started status
    //         delete bI[0];
    //         delete bI[1];
    //         delete bI[2];
    //         Blue_Sheet__c bsafterDelete = [
    //             SELECT Id, Progress__c, Buying_Influence_Progress__c
    //             FROM Blue_Sheet__c
    //             LIMIT 1
    //         ];
    //         System.assertEquals(bsafterDelete.Buying_Influence_Progress__c, 'Not Started');
    //         system.Test.stopTest();
    //     }
    // }

    static testMethod void testupdateActionPlan() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bluesheet = [SELECT Id, Name, Action_Plan_Progress__c FROM Blue_Sheet__c LIMIT 1];
            Action_Plan__c ap = TestDataUtil.createActionPlan(bluesheet, true);
            ap.Status__c = 'Completed';
            update ap;
            delete ap;
            Blue_Sheet__c bsafterDelete = [SELECT Id, Progress__c, Action_Plan_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterDelete.Action_Plan_Progress__c, 'Not Started');
        }
    }
    //

    static testMethod void testSSOstatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Blue_Sheet__c blues = [SELECT Id, Progress__c, SSO_Progress__c FROM Blue_Sheet__c LIMIT 1];
            //Inserting sso record
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(blues, true);
            Blue_Sheet__c bsafterInsert = [SELECT Id, Progress__c, SSO_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterInsert.SSO_Progress__c, 'Complete');
            //Updating sso record to in progress status
            sso.Evaluation_of_Objectives__c = 'Test Data Progress';
            sso.Customer_Timing_for_Priorities__c = '';
            sso.Customers_Stated_Objectives__c = '';
            update sso;
            Blue_Sheet__c bsafterUpdate = [SELECT Id, Progress__c, SSO_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterUpdate.SSO_Progress__c, 'In Progress');
            system.Test.stopTest();
        }
    }

    static testMethod void testSSOnotStaretdStatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Blue_Sheet__c bsdelete = [SELECT Id, Progress__c, SSO_Progress__c FROM Blue_Sheet__c LIMIT 1];
            //Inserting sso empty record
            Single_Sales_Objective__c ssodelete = TestDataUtil.createSSO(bsdelete, true);
            ssodelete.Evaluation_of_Objectives__c = null;
            ssodelete.Customer_Timing_for_Priorities__c = null;
            ssodelete.Customers_Stated_Objectives__c = null;
            upsert ssodelete;
            Blue_Sheet__c bsafterDelete = [SELECT Id, Progress__c, SSO_Progress__c FROM Blue_Sheet__c LIMIT 1];
            System.assertEquals(bsafterDelete.SSO_Progress__c, 'Not Started');
            system.Test.stopTest();
        }
    }

    //
    static testMethod void testSummaryOfMyPositionProgressStatus() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            system.test.startTest();
            Blue_Sheet__c bs = [SELECT Id, Progress__c, Summary_Position_Progress__c FROM Blue_Sheet__c LIMIT 1];
            //Inserting Summary of my position record
            List<Summary_of_My_Position_Today__c> somp = TestDataUtil.createSummaryOfMyPosition(bs, true);
            Blue_Sheet__c bsafterInsert = [
                SELECT Id, Progress__c, Summary_Position_Progress__c
                FROM Blue_Sheet__c
                LIMIT 1
            ];
            System.assertEquals(bsafterInsert.Summary_Position_Progress__c, 'Complete');

            List<Summary_of_My_Position_Today__c> sompUpdate = new List<Summary_of_My_Position_Today__c>();
            somp[0].Is_a_Red_Flag__c = false;
            somp[0].Is_a_Strength__c = true;
            somp[1].Is_a_Red_Flag__c = false;
            somp[1].Is_a_Strength__c = true;
            sompUpdate.add(somp[0]);
            sompUpdate.add(somp[1]);
            update sompUpdate;
            Blue_Sheet__c bsafterUpdate = [
                SELECT Id, Progress__c, Summary_Position_Progress__c
                FROM Blue_Sheet__c
                LIMIT 1
            ];
            System.assertEquals(bsafterUpdate.Summary_Position_Progress__c, 'In Progress');

            //Delete strength somp record
            delete somp[0];
            delete somp[1];
            Blue_Sheet__c bsafterDelete = [
                SELECT Id, Progress__c, Summary_Position_Progress__c
                FROM Blue_Sheet__c
                LIMIT 1
            ];
            System.assertEquals(bsafterDelete.Summary_Position_Progress__c, 'Not Started');
            system.Test.stopTest();
        }
    }
}