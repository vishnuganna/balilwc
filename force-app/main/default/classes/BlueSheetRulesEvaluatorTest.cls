@isTest
public with sharing class BlueSheetRulesEvaluatorTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
            String oppStageId = TestDataUtil.getOppStageId();
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
                Opportunity_Currency_Fields__c = 'Amount',
                Minimum_Range__c = 1000,
                Maximum_Range__c = 10000,
                is_pos_competition_zero__c = true,
                is_competitor_identified__c = true,
                is_curr_pos_negative__c = true,
                is_past_action_due__c = true,
                Min_Number_of_Actions_For_a_Opty_Stage__c = 2,
                Scorecard_Required__c = 'Yes',
                is_cust_time_later__c = true,
                Max_Days_Allowed_Since_Last_BS_Update__c = -2,
                Business_Rules_Group__c = brg.Id
            );
            Business_Rules__c br2 = new Business_Rules__c(
                IsActive__c = true,
                Opportunity_Stage_Global__c = 'Qualification',
                Business_Rule_Catagory__c = 'Scorecard',
                Opportunity_Currency_Fields__c = 'Amount',
                Minimum_Range__c = 1000,
                Maximum_Range__c = 10000,
                Scorecard_Required__c = 'Yes',
                Business_Rules_Group__c = brg.Id
            );
            Business_Rules__c br3 = new Business_Rules__c(
                IsActive__c = true,
                Opportunity_Stage_Global__c = 'Qualification',
                Business_Rule_Catagory__c = 'Buying Influences',
                Buying_Influence_Role__c = 'Coach',
                is_negative_rating__c = true,
                is_high_rated_BI_no_coach__c = true,
                is_person_win_identified__c = true,
                is_business_result_identified__c = true,
                is_coach_with_low_BI__c = true,
                is_discon_mode_cust_timing__c = true,
                Min_Number_Buying_Influence_Contacts__c = 1,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            brLst.add(br2);
            brLst.add(br3);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
        }
    }

    @isTest
    static void validateCompetitionBRforPosition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Positive scenario
            Competition__c comp = TestDataUtil.createCompetition(bs, acc, false);
            insert comp;
            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Competition__c compRec = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Competition__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Competition__c = :compRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_10'
                LIMIT 1
            ];
            system.assertEquals(compRec.Blue_Sheet__c, bs.Id, 'Checking Competition ID');
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_10', 'Checking BAL ID');

            Test.stopTest();
        }
    }

    @isTest
    static void validateCompetitionBRforCompetitior() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Positive scenario
            Competition__c comp = TestDataUtil.createCompetition(bs, acc, false);
            // comp.Competitor_Type__c = 'Buying From Someone Else';
            upsert comp;
            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Competition__c compRec = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Competition__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Competition__c = :compRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_9'
                LIMIT 1
            ];
            system.assertEquals(compRec.Blue_Sheet__c, bs.Id, 'Checking Competition ID');
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_9', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateCompetitionBRforCompetitiorNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Negative scenario
            Competition__c comp = TestDataUtil.createCompetition(bs, acc, false);
            comp.Competitor_Type__c = 'Buying From Someone Else';
            upsert comp;
            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Competition__c compRec = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Competition__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Competition__c = :compRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_9'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBRforPositiveCP() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Positive CP scenario
            Current_Position__c cpNeg = TestDataUtil.createCurrentPosition(bs, true);
            // cpNeg.Current_Position__c = 'Concern';
            // upsert cpNeg;
            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Current_Position__c cpRec = [
                SELECT Id, Name, Blue_Sheet__c, Current_Position__c
                FROM Current_Position__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Current_Position__c = :cpRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_8'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            // system.assertEquals(bestAction[0].Action_Title__c, 'Negative Current Position', 'Checking action title');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBRforNegativeCP() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];

            Test.startTest();
            //Negative CP scenario
            Current_Position__c cpNeg = TestDataUtil.createCurrentPosition(bs, false);
            cpNeg.Current_Position__c = 'Concern';
            insert cpNeg;

            Current_Position__c cpRec = [
                SELECT Id, Name, Blue_Sheet__c, Current_Position__c
                FROM Current_Position__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Current_Position__c = :cpRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_8'
                LIMIT 1
            ];
            system.assertEquals(cpRec.Blue_Sheet__c, bs.Id, 'Checking current position ID');
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            // system.assertEquals(bestAction[0].Action_Title__c, 'Negative Current Position', 'Checking action title');
            Test.stopTest();
        }
    }

    @isTest
    static void validateActionPlanBRforPastDueDate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Positive scenario
            Action_Plan__c plan = TestDataUtil.createActionPlan(bs, true);
            plan.Due_Date__c = Date.today() - 10;
            upsert plan;

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Action_Plan__c apRec = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Action_Plan__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Action_Plan__c = :apRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_7'
                LIMIT 1
            ];
            system.assertEquals(apRec.Blue_Sheet__c, bs.Id, 'Checking action plan ID');
            //system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_7', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateActionPlanBRforMinActions() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Positive scenario
            Action_Plan__c plan = TestDataUtil.createActionPlan(bs, true);

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bs.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_6'
                LIMIT 1
            ];
            system.assertEquals(plan.Blue_Sheet__c, bs.Id, 'Checking action plan ID');
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_6', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateActionPlanBRforMinActionsNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Negative scenario
            Action_Plan__c plan2 = TestDataUtil.createActionPlan(bs, true);
            Action_Plan__c plan3 = TestDataUtil.createActionPlan(bs, true);

            List<Action_Plan__c> apRecList = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Action_Plan__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            Set<Id> apIds = new Set<Id>();
            for (Action_Plan__c ap : apRecList) {
                apIds.add(ap.Id);
            }
            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction2 = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Action_Plan__c IN :apIds AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_6'
                LIMIT 1
            ];
            system.assertEquals(bestAction2.size(), 0, 'Checking size of best action list');
            Test.stopTest();
        }
    }

    @isTest
    static void validateScoreCardBR() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Opportunity opp = [SELECT Id, name FROM Opportunity LIMIT 1];
            opp.Amount = 5000;
            upsert opp;

            Test.startTest();
            Blue_Sheet__c bss = TestDataUtil.createBluesheet(opp, true);
            upsert bss;

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_11'
                LIMIT 1
            ];
            system.assertNotEquals(bss.id, null);
            system.assertNotEquals(bestAction.size(), 0, 'Checking size of best action list');

            Test.stopTest();
        }
    }

    @isTest
    static void validateScoreCardBRNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Opportunity opp = [SELECT Id, name FROM Opportunity LIMIT 1];
            opp.Amount = 5000;
            upsert opp;

            Test.startTest();
            Blue_Sheet__c bss = TestDataUtil.createBluesheet(opp, true);
            upsert bss;

            Score_Card__c card = TestDataUtil.createScoreCard(bss, true);

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bss.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_11'
                LIMIT 1
            ];
            system.assertEquals(card.Blue_Sheet__c, bss.id, 'Checking score card Id');
            system.assertNotEquals(bestAction.size(), 0, 'Checking size of best action list');
            // system.assertEquals(bestAction[0].Action_Title__c, null, 'Checking action title');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBRforSSO() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            //Negative scenario
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Single_Sales_Objective__c ssoRec = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Single_Sales_Objective__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE
                    Single_Sales_Objective__c = :ssoRec.Id
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_13'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBRforSSOPositive() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Test.startTest();
            //Positive scenario
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, false);
            sso.Customer_Timing_for_Priorities__c = 'Later';
            insert sso;

            Single_Sales_Objective__c ssoRec = [
                SELECT Id, Name, Blue_Sheet__c
                FROM Single_Sales_Objective__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE
                    Single_Sales_Objective__c = :ssoRec.Id
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_13'
                LIMIT 1
            ];
            system.assertEquals(ssoRec.Blue_Sheet__c, bs.Id, 'Checking SSO ID');
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_13', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBRForLastModified() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Opportunity opp = [SELECT Id, name FROM Opportunity LIMIT 1];
            opp.Amount = 5000;
            upsert opp;

            Test.startTest();
            Blue_Sheet__c bss = TestDataUtil.createBluesheet(opp, true);
            upsert bss;

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_3'
                LIMIT 1
            ];
            system.assertNotEquals(bss.Id, null);
            system.assertNotEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_3', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateMininimumBuyingInfluence() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Opportunity opp = [SELECT Id, name FROM Opportunity LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '-4';
            insert biList[0];

            Business_Rules__c br1 = [
                SELECT Id, Name
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Buying Influences'
                LIMIT 1
            ];

            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bs.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_22'
            ];
            system.assertEquals(bestAction.size(), 1, 'Check best action list size');
            system.assertEquals(bestAction[0].Action_Title__c, null, 'Match the action title');
        }
    }
}
//test