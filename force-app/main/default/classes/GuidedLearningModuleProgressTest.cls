@isTest
public with sharing class GuidedLearningModuleProgressTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity opp = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(opp, true);
            List<Summary_of_My_Position_Today__c> sompList = TestDataUtil.createSummaryOfMyPosition(bs, true);
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            Contact cont = TestDataUtil.createContact(acc, true);
            List<Buying_Influence__c> biLst = TestDataUtil.createBuyingInfluence(bs, cont, true);
            Score_Card__c crd = TestDataUtil.createScoreCard(bs, true);
            Score_Card_Detail__c scrCrd = TestDataUtil.createScoreCardDetails(crd, true);
            Competition__c comp = TestDataUtil.createCompetition(bs, acc, true);
            Action_Plan__c plan = TestDataUtil.createActionPlan(bs, true);
        }
    }

    @isTest
    static void testGetSummaryOfMPData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<MyPositionController.PositionSummaryWrapper> sompLst = GuidedLearningModuleProgress.getSummaryOfMPData();
            System.assertEquals(sompLst != null, true, 'SOMP list is not null');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetSingleSalesObjectData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            SingleSalesObjectiveController.SingleSalesObjectiveWrapper ssoObj = GuidedLearningModuleProgress.getSingleSalesObjectData();
            System.assertEquals(ssoObj != null, true, 'SSO list is not null');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetBuyingInfluenceData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<BuyingInfluenceWrapperClass> biList = GuidedLearningModuleProgress.getBuyingInfluenceData();
            System.assertEquals(biList != null, true, 'Buying Influence list is not null');
            Boolean coachPresent = GuidedLearningModuleProgress.checkBIforCoach();
            Boolean degreePresent = GuidedLearningModuleProgress.checkBIforDegrees();
            Boolean modePresent = GuidedLearningModuleProgress.checkBIforModes();
            Boolean ratingsPresent = GuidedLearningModuleProgress.checkBIforRatings();
            Boolean winOrResultsPresnt = GuidedLearningModuleProgress.checkBIforWinOrResults();
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckBIforModes() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Buying_Influence__c biObj = [
                SELECT Id, Name, Contact__c, Growth__c, Even_Keel__c, Over_Confident__c, Trouble__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            biObj.Growth__c = false;
            biObj.Even_Keel__c = true;
            update biObj;
            Boolean modePresent = GuidedLearningModuleProgress.checkBIforModes();
            biObj.Even_Keel__c = false;
            biObj.Trouble__c = true;
            update biObj;
            modePresent = GuidedLearningModuleProgress.checkBIforModes();
            biObj.Trouble__c = false;
            biObj.Over_Confident__c = true;
            update biObj;
            modePresent = GuidedLearningModuleProgress.checkBIforModes();
            System.assertEquals(modePresent, true, 'Buying Influence mode present');
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckBIforWinOrResults() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Buying_Influence__c biObj = [
                SELECT Id, Name, Contact__c, Business_Results__c, Personal_Wins__c
                FROM Buying_Influence__c
                LIMIT 1
            ];
            biObj.Personal_Wins__c = '';
            update biObj;
            Boolean winOrResultsPresnt = GuidedLearningModuleProgress.checkBIforWinOrResults();
            System.assertEquals(winOrResultsPresnt, true, 'Buying Influence results present');
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckScoreCardForDecision() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Boolean decisionPresent = GuidedLearningModuleProgress.checkScoreCardForDecision();
            System.assertEquals(decisionPresent, true, 'Scorecard has decision');
            Score_Card_Detail__c scd = [
                SELECT
                    Id,
                    Point_Value__c,
                    Is_Opportunity_Section__c,
                    Name,
                    Current_Score__c,
                    Score_Value__c,
                    Section__c,
                    Title__c,
                    Criteria_Definition__c
                FROM Score_Card_Detail__c
                LIMIT 1
            ];
            scd.Score_Value__c = 'No';
            update scd;
            decisionPresent = GuidedLearningModuleProgress.checkScoreCardForDecision();
            scd.Score_Value__c = 'Unknown';
            update scd;
            decisionPresent = GuidedLearningModuleProgress.checkScoreCardForDecision();
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckCompetitivePreference() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Boolean competitivePreferencePresent = GuidedLearningModuleProgress.checkCompetitivePreference();
            System.assertEquals(competitivePreferencePresent, true, 'Competition has competitive preference');
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckMyPositionVsCompetitor() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Boolean myPositionPresent = GuidedLearningModuleProgress.checkMyPositionVsCompetitor();
            System.assertEquals(myPositionPresent, true, 'Competition has my position');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetActionPlan() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<ActionPlanWrapperClass> actionPlanWrapperList = GuidedLearningModuleProgress.getActionPlan();
            System.assertEquals(actionPlanWrapperList != null, true, 'Action Plan list is not null');
            Test.stopTest();
        }
    }
}