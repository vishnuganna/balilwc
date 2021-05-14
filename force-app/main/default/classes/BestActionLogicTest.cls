/*
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* KFS-277 (part of main US KFS-277) : Test Class for BestActionLogic, RecommendationsActionMessages, 
RecommendationsActionWrapper, Trigger-StrategyEngineTrigger
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Rakesh Singh   
* @created        2020-05-30 
* Note: if there is single quote in any msg, escape it in this class
*/
@SuppressWarnings('PMD.EmptyStatementBlock')
@isTest
public class BestActionLogicTest {
    /* @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
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
                Is_a_Blue_Sheet_required__c = 'Yes',
                Stage_BS_Req__c = oppStageId,
                BS_Req_for_certain_Rev_Range__c = 'Yes',
                Opty_Amount_2__c = 100,
                Stage_BS_Req_Rev_Range__c = oppStageId,
                Max_Days_Allowed_Since_Last_BS_Update__c = 5,
                Stage_BS_Last_Updated__c = oppStageId,
                Max_Days_Allowed_in_a_Opty_Stage__c = 5,
                Long_SSO_Sales_Stage__c = oppStageId,
                Min_Number_of_Actions_for_a_Opty_Stage__c = 8,
                Stage_Min_Poss_Action__c = oppStageId,
                Business_Rules_Group__c = brg.Id,
                Stage_Scorecard_req__c = oppStageId,
                Scorecard_Required__c = 'Yes',
                Stage_BI_Role__c = oppStageId,
                Buying_Influence_Role__c = 'Coach',
                is_curr_pos_negative__c = true,
                is_competitor_identified__c = true,
                is_pos_competition_zero__c = true
            );
            brLst.add(br1);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
            op1.Amount = 10000;
            op1.StageName = 'Qualification';
            Opportunity op2 = op1.clone(false, false, false, false);
            op2.Name = 'Opp Rule';
            List<Opportunity> opplst = new List<Opportunity>();
            opplst.add(op1);
            opplst.add(op2);
            insert opplst;
            StrategyEngine.createBlueSheet(op1.id);
        }
    }

    @IsTest
    static void testBestActionlogic_BAL_8() {
        User user = [SELECT Id FROM user LIMIT 1];
        System.runAs(user) {
            Opportunity op1 = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];
            StrategyEngine.createBlueSheet(op1.id);
            String ruleNum = 'BAL_8';
            Set<String> oppIdSet = new Set<String>();
            oppIdSet.add(op1.Id);
            Blue_Sheet__c bsObj = [SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c = :op1.Id];
            Current_Position__c cPosition = new Current_Position__c();
            cPosition.Current_Position__c = 'Concern';
            cPosition.Blue_Sheet__c = bsObj.Id;
            DataFactory.create(cPosition);
            List<Recommendations__c> recommLst = getRecommendationsRec(ruleNum, oppIdSet);
            RecommendationsActionWrapper recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
            Recommendations__c recommObj = [
                SELECT Id, BestActionLogic__c
                FROM Recommendations__c
                WHERE BestActionLogic__c = 'BAL_8' AND Opportunity__c = :op1.Id
            ];
            System.assertEquals('BAL_8', recommObj.BestActionLogic__c, 'Recommendation record got updated!');
            KF_Sell_Best__c bestActionObj = [
                SELECT Id, Seller_Recommended_Action__c
                FROM KF_Sell_Best__c
                WHERE Recommendations__c = :recommObj.Id AND Opportunity__c = :op1.Id
            ];
            System.assertEquals(
                recommWrapperMsg.sellerRecommendedActionMessage,
                bestActionObj.Seller_Recommended_Action__c,
                'Best Action record got created!'
            );
            Current_Position__c cPositionObj = [
                SELECT id, Current_Position__c
                FROM Current_Position__c
                WHERE id = :cPosition.Id
            ];
            cPositionObj.Current_Position__c = 'Worry';
            update cPositionObj;
            bestActionObj = [
                SELECT Id, Seller_Recommended_Action__c
                FROM KF_Sell_Best__c
                WHERE Recommendations__c = :recommObj.Id AND Opportunity__c = :op1.Id
            ];
            System.assertEquals(
                recommWrapperMsg.sellerRecommendedActionMessage,
                bestActionObj.Seller_Recommended_Action__c,
                'Best Action record got updated!'
            );
        }
    }

    @isTest
    static void testBestActionlogic_BAL_9_10() {
        User user = [SELECT Id FROM user LIMIT 1];
        System.runAs(user) {
            Opportunity op1 = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity'];

            String ruleNum = 'BAL_9';
            Set<String> oppIdSet = new Set<String>();
            oppIdSet.add(op1.Id);
            Blue_Sheet__c bsObj = [SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c = :op1.Id];
            Competition__c competition = new Competition__c();
            competition.Competitive_Detail__c = 'details';
            competition.Competitor_Type__c = 'Doing Nothing';
            competition.My_Position_Vs_Competitor__c = 'Zero';
            competition.Blue_Sheet__c = bsObj.Id;
            DataFactory.create(competition);
            List<Strategy_Engine__c> seRec = [
                SELECT Id, Competition__c, Competitor__c, Position_vs_Competition__c
                FROM Strategy_Engine__c
                WHERE Competition__c = :competition.Id
            ];
            //List<Recommendations__c> recommLst = getRecommendationsRec(ruleNum,oppIdSet);

            List<Recommendations__c> recommLst = [
                SELECT Id, BestActionLogic__c
                FROM Recommendations__c
                WHERE (BestActionLogic__c = 'BAL_9' OR BestActionLogic__c = 'BAL_10') AND Opportunity__c = :op1.Id
            ];
            Recommendations__c recomm_9 = null;
            Recommendations__c recomm_10 = null;
            for (Recommendations__c recomm : recommLst) {
                if (recomm.BestActionLogic__c == 'BAL_9') {
                    recomm_9 = recomm;
                } else if (recomm.BestActionLogic__c == 'BAL_10') {
                    recomm_10 = recomm;
                }
            }

            List<KF_Sell_Best__c> bestActionObjLst = [
                SELECT Id, Seller_Recommended_Action__c, Recommendations__c
                FROM KF_Sell_Best__c
                WHERE
                    (Recommendations__c = :recomm_9.Id
                    OR Recommendations__c = :recomm_10.Id)
                    AND Opportunity__c = :op1.Id
            ];
            KF_Sell_Best__c baRec_9 = null;
            KF_Sell_Best__c baRec_10 = null;
            for (KF_Sell_Best__c baRec : bestActionObjLst) {
                if (baRec.Recommendations__c == recomm_9.Id) {
                    baRec_9 = baRec;
                } else if (baRec.Recommendations__c == recomm_10.Id) {
                    baRec_10 = baRec;
                }
            }
            RecommendationsActionWrapper recommWrapperMsg_9 = getRecommendationsActionWrapper(ruleNum);
            System.assertEquals(
                recommWrapperMsg_9.sellerRecommendedActionMessage,
                baRec_9.Seller_Recommended_Action__c,
                'Best Action record got created!'
            );
            String ruleNum_10 = 'BAL_10';
            RecommendationsActionWrapper recommWrapperMsg_10 = getRecommendationsActionWrapper(ruleNum_10);
            System.assertEquals(
                recommWrapperMsg_10.sellerRecommendedActionMessage,
                baRec_10.Seller_Recommended_Action__c,
                'Best Action record got created!'
            );

            Competition__c competition1 = [
                SELECT id, Competitor_Type__c
                FROM Competition__c
                WHERE id = :Competition.id
            ];
            competition1.Competitor_Type__c = 'test';
            update competition1;
            bestActionObjLst = [
                SELECT Id, Seller_Recommended_Action__c, Recommendations__c
                FROM KF_Sell_Best__c
                WHERE
                    (Recommendations__c = :recomm_9.Id
                    OR Recommendations__c = :recomm_10.Id)
                    AND Opportunity__c = :op1.Id
            ];
            for (KF_Sell_Best__c baRec : bestActionObjLst) {
                if (baRec.Recommendations__c == recomm_9.Id) {
                    baRec_9 = baRec;
                } else if (baRec.Recommendations__c == recomm_10.Id) {
                    baRec_10 = baRec;
                }
            }

            System.assertEquals(
                recommWrapperMsg_9.sellerRecommendedActionMessage,
                baRec_9.Seller_Recommended_Action__c,
                'Best Action record got update!'
            );

            System.assertEquals(
                recommWrapperMsg_10.sellerRecommendedActionMessage,
                baRec_10.Seller_Recommended_Action__c,
                'Best Action record got updated!'
            );
        }
    }*/

    // static testMethod void testBestActionlogic_BAL_11() {
    //     User user = [SELECT Id FROM user LIMIT 1];
    //     System.runAs(user) {
    //         String ruleNum = 'BAL_11';
    //         Business_Rules__c br = [
    //             SELECT Id, Is_a_Blue_Sheet_required__c, BS_Req_for_certain_Rev_Range__c
    //             FROM Business_Rules__c
    //             LIMIT 1
    //         ];
    //         br.Is_a_Blue_Sheet_required__c = 'No';
    //         br.BS_Req_for_certain_Rev_Range__c = 'No';
    //         update br;
    //         Business_Rules_Group_Member__c brgm = [
    //             SELECT id, Member_Name__c
    //             FROM Business_Rules_Group_Member__c
    //             LIMIT 1
    //         ];
    //         brgm.Member_Name__c = user.Id;
    //         update brgm;
    //         Account acc = [SELECT Id FROM Account];
    //         Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
    //         op1.OwnerId = user.Id;
    //         insert op1;
    //         StrategyEngine.createBlueSheet(op1.id);
    //         RecommendationsActionWrapper recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
    //         List<Recommendations__c> recommObj = [
    //             SELECT Id, BestActionLogic__c, Opportunity__c
    //             FROM Recommendations__c
    //             WHERE BestActionLogic__c = 'BAL_11' AND Opportunity__c = :op1.Id
    //         ];
    //         List<KF_Sell_Best__c> bestActionObj = [
    //             SELECT Id, Seller_Recommended_Action__c, opportunity__c, Recommendations__c
    //             FROM KF_Sell_Best__c
    //             WHERE Recommendations__c = :recommObj[0].Id AND Opportunity__c = :op1.Id
    //         ];
    //         // System.assertEquals(
    //         //     recommWrapperMsg.sellerRecommendedActionMessage,
    //         //     bestActionObj[0].Seller_Recommended_Action__c,
    //         //     'Best Action record got created!'
    //         // );
    //     }
    // }
    /*
    static testMethod void test_rule13_fail() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            System.debug(user.id);
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
                Is_a_Blue_Sheet_required__c = 'Yes',
                Stage_BS_Req__c = oppStageId,
                BS_Req_for_certain_Rev_Range__c = 'Yes',
                Opty_Amount_2__c = 100,
                Stage_BS_Req_Rev_Range__c = oppStageId,
                Max_Days_Allowed_Since_Last_BS_Update__c = 5,
                Stage_BS_Last_Updated__c = oppStageId,
                Max_Days_Allowed_in_a_Opty_Stage__c = 5,
                Long_SSO_Sales_Stage__c = oppStageId,
                Min_Number_of_Actions_for_a_Opty_Stage__c = 8,
                Stage_Min_Poss_Action__c = oppStageId,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
            insert op1;
            StrategyEngine.createBlueSheet(op1.id);
            Strategy_Engine__c seRec = [
                SELECT
                    Id,
                    Bluesheet_Last_Modified_Date__c,
                    Opty_Close_Date__c,
                    Customer_Timing_for_Priorities__c,
                    Opty_Stage_Last_Modified_Date__c,
                    Bluesheet_Count_Actions__c,
                    AP_IsBestAction__c,
                    Competition__c,
                    Opportunity__c,
                    Place_in_Sales_Funnel__c,
                    Best_Action_Due_Date__c,
                    Current_Position__c,
                    Position_vs_Competition__c
                FROM Strategy_Engine__c
                WHERE Opportunity__c = :op1.Id
            ];
            seRec.Customer_Timing_for_Priorities__c = 'Negative';
            seRec.Opportunity__c = op1.Id;
            update seRec;
            BestAction.getBestActionList(op1.Id);
            List<Recommendations__c> recommRectoDelete = [
                SELECT Id
                FROM Recommendations__c
                ORDER BY lastmodifieddate DESC
                LIMIT 5
            ];
            List<Strategy_Engine__c> sel = new List<Strategy_Engine__c>();
            sel.add(SeREc);
            BestActionLogic.upsertRecommendationsRec(sel);
            List<Recommendations__c> recommendationResults = [
                SELECT Id, Name, BestActionLogic__c
                FROM Recommendations__c
                WHERE BestActionLogic__c = 'BAL_13'
            ];
            System.assert(!recommendationResults.isEmpty(), 'Recommendation list: ');
            System.assertEquals('BAL_13', recommendationResults.get(0).BestActionLogic__c, 'Negative Current Position');
            delete recommendationResults;
        }
    }

    static testMethod void test_rule13_pass() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            System.debug(user.id);
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
                Is_a_Blue_Sheet_required__c = 'Yes',
                Stage_BS_Req__c = oppStageId,
                BS_Req_for_certain_Rev_Range__c = 'Yes',
                Opty_Amount_2__c = 100,
                Stage_BS_Req_Rev_Range__c = oppStageId,
                Max_Days_Allowed_Since_Last_BS_Update__c = 5,
                Stage_BS_Last_Updated__c = oppStageId,
                Max_Days_Allowed_in_a_Opty_Stage__c = 5,
                Long_SSO_Sales_Stage__c = oppStageId,
                Min_Number_of_Actions_for_a_Opty_Stage__c = 8,
                Stage_Min_Poss_Action__c = oppStageId,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
            insert op1;
            StrategyEngine.createBlueSheet(op1.id);
            Strategy_Engine__c seRec = [
                SELECT
                    Id,
                    Bluesheet_Last_Modified_Date__c,
                    Opty_Close_Date__c,
                    Customer_Timing_for_Priorities__c,
                    Opty_Stage_Last_Modified_Date__c,
                    Bluesheet_Count_Actions__c,
                    AP_IsBestAction__c,
                    Competition__c,
                    Opportunity__c,
                    Place_in_Sales_Funnel__c,
                    Best_Action_Due_Date__c,
                    Current_Position__c,
                    Position_vs_Competition__c
                FROM Strategy_Engine__c
                WHERE Opportunity__c = :op1.Id
            ];
            seRec.Customer_Timing_for_Priorities__c = 'Positive';
            seRec.Opportunity__c = op1.Id;
            update seRec;
            BestAction.getBestActionList(op1.Id);
            List<Recommendations__c> recommRectoDelete = [
                SELECT Id
                FROM Recommendations__c
                ORDER BY lastmodifieddate DESC
                LIMIT 5
            ];
            List<Strategy_Engine__c> sel = new List<Strategy_Engine__c>();
            sel.add(SeREc);
            BestActionLogic.upsertRecommendationsRec(sel);
            List<Recommendations__c> recommendationResults = [
                SELECT Id, Name, BestActionLogic__c
                FROM Recommendations__c
                WHERE BestActionLogic__c = 'BAL_13'
            ];

            System.assert(recommendationResults.isEmpty(), 'Recommendation list: ');
        }
    }
*/
    /*   static testMethod void test_isInCurrencyRange_is_true_for_amount_in_range() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = TestDataUtil.getOpportunity();
            opp.Amount = 1000;
            Business_Rules__c rule = new Business_Rules__c(
                Minimum_Range__c = 0,
                Maximum_Range__c = 5000,
                Opportunity_Currency_Fields__c = 'Amount'
            );
            Boolean result = BestActionLogic.isInCurrencyRange(rule, opp);
            System.assertEquals(result, true, 'Currency working?' + result);
        }
    }

    static testMethod void test_isInCurrencyRange_is_false_for_amount_not_in_range() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = TestDataUtil.getOpportunity();
            opp.Amount = 10000;
            Business_Rules__c rule = new Business_Rules__c(
                Minimum_Range__c = 0,
                Maximum_Range__c = 5000,
                Opportunity_Currency_Fields__c = 'Amount'
            );
            Boolean result = BestActionLogic.isInCurrencyRange(rule, opp);
            System.assertEquals(result, false, 'Currency working?');
        }
    }

    static testMethod void test_isInCurrencyRange_is_true_if_amountField_is_null() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = TestDataUtil.getOpportunity();
            opp.Amount = 10000;
            Business_Rules__c rule = new Business_Rules__c(Minimum_Range__c = 0, Maximum_Range__c = 5000);
            Boolean result = BestActionLogic.isInCurrencyRange(rule, opp);
            System.assertEquals(result, true, 'Currency working?');
        }
    }

    static testMethod void test_isInCurrencyRange_is_true_for_amount_inRange_if_MaxRange_is_not_set() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = TestDataUtil.getOpportunity();
            opp.Amount = 1000;
            Business_Rules__c rule = new Business_Rules__c(
                Minimum_Range__c = 0,
                Opportunity_Currency_Fields__c = 'Amount'
            );
            Boolean result = BestActionLogic.isInCurrencyRange(rule, opp);
            System.assertEquals(result, true, 'Currency working?' + result);
        }
    }
    private static List<Recommendations__c> getRecommendationsRec(String ruleName, Set<String> oppIdSet) {
        List<Recommendations__c> recommObj = [
            SELECT Id, BestActionLogic__c, Opportunity__c
            FROM Recommendations__c
            WHERE BestActionLogic__c = :ruleName AND Opportunity__c = :oppIdSet
        ];
        return recommObj;
    }
    private static RecommendationsActionWrapper getRecommendationsActionWrapper(String ruleName) {
        Map<String, RecommendationsActionWrapper> mapRuleMSg = new Map<String, RecommendationsActionWrapper>();
        RecommendationsActionMessages recomActionMsgObj = new RecommendationsActionMessages();
        mapRuleMSg = recomActionMsgObj.getRecommendationsActionMessages();
        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(ruleName);
        return recommenActionWrapper;
    }
}*/
    //     /*@testSetup
    //     static void setup() {
    //         Account acc = TestDataUtil.createAccount(true);
    //         //Opportunity op = TestDataUtil.createOpportunity(acc,true);
    //         //Blue_Sheet__c bs = TestDataUtil.createBluesheet(op,false);
    //         //Contact con = TestDataUtil.createContact(acc,true);
    //         //List<Buying_Influence__c> buying= TestDataUtil.createBuyingInfluence(bs,con,true);
    //         //Single_Sales_Objective__c sso= TestDataUtil.createSSO(bs,true);
    //         //TestDataUtil.createBusinessRules(true);
    //     }*/

    //     static testMethod void testBestActionlogic_BAL_1() {
    //         User user = UserTest.createUserWithPerms();
    //         System.runAs(user) {
    //             System.debug(user.id);
    //             String oppStageId = TestDataUtil.getOppStageId();
    //             Business_Rules_Group__c brg = new Business_Rules_Group__c();
    //             brg.name = 'EasterGrp';
    //             insert brg;
    //             Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
    //             brgm.Member_Name__c = user.Id;
    //             brgm.Business_Rules_Group__c = brg.Id;
    //             insert brgm;
    //             List<Business_Rules__c> brLst = new List<Business_Rules__c>();
    //             Business_Rules__c br1 = new Business_Rules__c(
    //                 IsActive__c = true,
    //                 Is_a_Blue_Sheet_required__c = 'Yes',
    //                 Stage_BS_Req__c = oppStageId,
    //                 BS_Req_for_certain_Rev_Range__c = 'Yes',
    //                 Opty_Amount_2__c = 100,
    //                 Stage_BS_Req_Rev_Range__c = oppStageId,
    //                 Max_Days_Allowed_Since_Last_BS_Update__c = 5,
    //                 Stage_BS_Last_Updated__c = oppStageId,
    //                 Max_Days_Allowed_in_a_Opty_Stage__c = 5,
    //                 Long_SSO_Sales_Stage__c = oppStageId,
    //                 Min_Number_of_Actions_for_a_Opty_Stage__c = 8,
    //                 Stage_Min_Poss_Action__c = oppStageId,
    //                 Business_Rules_Group__c = brg.Id
    //             );
    //             brLst.add(br1);
    //             insert brLst;
    //             Account acc = TestDataUtil.createAccount(true);
    //             Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
    //             Opportunity op2 = TestDataUtil.createOpportunity(acc, false);
    //             op2.StageName = 'test';
    //             List<Opportunity> opplst = new List<Opportunity>();
    //             opplst.add(op1);
    //             opplst.add(op2);
    //             insert opplst;
    //             update opplst;
    //             System.assertEquals('EasterGrp', brg.name, 'Business rule group name');
    //         }
    //     }

    //     static testMethod void testBestActionlogic_BAL_2() {
    //         User user = UserTest.createUserWithPerms();
    //         System.runAs(user) {
    //             System.debug(user.id);
    //             String oppStageId = TestDataUtil.getOppStageId();
    //             Business_Rules_Group__c brg = new Business_Rules_Group__c();
    //             brg.name = 'EasterGrp';
    //             insert brg;
    //             Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
    //             brgm.Member_Name__c = user.Id;
    //             brgm.Business_Rules_Group__c = brg.Id;
    //             insert brgm;
    //             List<Business_Rules__c> brLst = new List<Business_Rules__c>();
    //             Business_Rules__c br1 = new Business_Rules__c(
    //                 IsActive__c = true,
    //                 Is_a_Blue_Sheet_required__c = 'Yes',
    //                 Stage_BS_Req__c = oppStageId,
    //                 BS_Req_for_certain_Rev_Range__c = 'Yes',
    //                 Opty_Amount_2__c = 100,
    //                 Stage_BS_Req_Rev_Range__c = oppStageId,
    //                 Max_Days_Allowed_Since_Last_BS_Update__c = 5,
    //                 Stage_BS_Last_Updated__c = oppStageId,
    //                 Max_Days_Allowed_in_a_Opty_Stage__c = 5,
    //                 Long_SSO_Sales_Stage__c = oppStageId,
    //                 Min_Number_of_Actions_for_a_Opty_Stage__c = 8,
    //                 Stage_Min_Poss_Action__c = oppStageId,
    //                 Business_Rules_Group__c = brg.Id
    //             );
    //             brLst.add(br1);
    //             insert brLst;
    //             Account acc = TestDataUtil.createAccount(true);
    //             Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
    //             Opportunity op2 = TestDataUtil.createOpportunity(acc, false);
    //             op1.amount = 10;
    //             op2.amount = 1000;
    //             List<Opportunity> opplst = new List<Opportunity>();
    //             opplst.add(op1);
    //             opplst.add(op2);
    //             insert opplst;
    //             update opplst;
    //             System.assertEquals(br1.IsActive__c, true, 'Business rule is Active');
    //         }
    //     }

    //     static testMethod void testBestActionlogic_BAL_3_All() {
    //         User user = UserTest.createUserWithPerms();
    //         System.runAs(user) {
    //             System.debug(user.id);
    //             String oppStageId = TestDataUtil.getOppStageId();
    //             Business_Rules_Group__c brg = new Business_Rules_Group__c();
    //             brg.name = 'EasterGrp';
    //             insert brg;
    //             Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
    //             brgm.Member_Name__c = user.Id;
    //             brgm.Business_Rules_Group__c = brg.Id;
    //             insert brgm;
    //             List<Business_Rules__c> brLst = new List<Business_Rules__c>();
    //             Business_Rules__c br1 = new Business_Rules__c(
    //                 IsActive__c = true,
    //                 Is_a_Blue_Sheet_required__c = 'Yes',
    //                 Stage_BS_Req__c = oppStageId,
    //                 BS_Req_for_certain_Rev_Range__c = 'Yes',
    //                 Opty_Amount_2__c = 100,
    //                 Stage_BS_Req_Rev_Range__c = oppStageId,
    //                 Max_Days_Allowed_Since_Last_BS_Update__c = 5,
    //                 Stage_BS_Last_Updated__c = oppStageId,
    //                 Max_Days_Allowed_in_a_Opty_Stage__c = 5,
    //                 Long_SSO_Sales_Stage__c = oppStageId,
    //                 Min_Number_of_Actions_for_a_Opty_Stage__c = 8,
    //                 Stage_Min_Poss_Action__c = oppStageId,
    //                 Business_Rules_Group__c = brg.Id
    //             );
    //             brLst.add(br1);
    //             insert brLst;
    //             Account acc = TestDataUtil.createAccount(true);
    //             Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
    //             insert op1;
    //             StrategyEngine.createBlueSheet(op1.id);
    //             Strategy_Engine__c seRec = [
    //                 SELECT
    //                     Id,
    //                     Bluesheet_Last_Modified_Date__c,
    //                     Opty_Close_Date__c,
    //                     Opty_Stage_Last_Modified_Date__c,
    //                     Bluesheet_Count_Actions__c,
    //                     AP_IsBestAction__c,
    //                     Best_Action_Due_Date__c,
    //                     Current_Position__c,
    //                     Position_vs_Competition__c
    //                 FROM Strategy_Engine__c
    //                 WHERE Opportunity__c = :op1.Id
    //             ];
    //             seRec.Bluesheet_Last_Modified_Date__c = Date.today() - 20;
    //             seRec.Opty_Close_Date__c = Date.today() - 20;
    //             seRec.Opty_Stage_Last_Modified_Date__c = Date.today() - 20;
    //             seREC.Bluesheet_Count_Actions__c = 2;
    //             seRec.AP_IsBestAction__c = true;
    //             seRec.Best_Action_Due_Date__c = Date.today() - 20;
    //             seREc.Current_Position__c = 'Discomfort';
    //             seRec.Position_vs_Competition__c = 'Shared';
    //             update seRec;

    //             BestAction.getBestActionList(op1.Id);
    //             List<Recommendations__c> recommRectoDelete = [
    //                 SELECT Id
    //                 FROM Recommendations__c
    //                 ORDER BY lastmodifieddate DESC
    //                 LIMIT 5
    //             ];
    //             delete recommRectoDelete;
    //             System.assertEquals(seREc.Current_Position__c, 'Discomfort', 'Negative Current Position');
    //         }
    //     }

    // }
    // /* please dont delete this commented code

    //     static testMethod void testBestActionlogic_BAL_1_2() {
    //         User user = UserTest.createUserWithPerms();
    //         System.runAs(user) {
    //             Opportunity op1Temp = [Select Id from Opportunity where Name = 'Opp Rule'];
    //             Set<String> oppIdSet = new Set<String>();
    //             oppIdSet.add(op1Temp.Id);
    //             String ruleNum = 'BAL_1';
    //             List<Recommendations__c> recommLst = getRecommendationsRec(ruleNum,oppIdSet);
    //             RecommendationsActionWrapper recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
    //             Recommendations__c recommObj = [Select Id,BestActionLogic__c from Recommendations__c
    //                                             where BestActionLogic__c = 'BAL_1' AND Opportunity__c =: op1Temp.Id];
    //             System.assertEquals('BAL_1', recommObj.BestActionLogic__c, 'Recommendation record got created!');
    //             KF_Sell_Best__c bestActionObj = [Select Id,Seller_Recommended_Action__c from KF_Sell_Best__c where
    //                                              Recommendations__c =: recommObj.Id AND Opportunity__c =: op1Temp.Id];
    //             System.assertEquals(recommWrapperMsg.sellerRecommendedActionMessage, bestActionObj.Seller_Recommended_Action__c,
    //                                 'Best Action record got created!');
    //             Account acc = [Select Id from Account limit 1];
    //             Opportunity op1 = TestDataUtil.createOpportunity(acc, false);
    //             op1.StageName = 'BR Diff Opp Name';
    //             op1.Amount = 10000;
    //             List<Opportunity> opplst = new List<Opportunity>();
    //             opplst.add(op1);
    //             insert opplst;
    //             oppIdSet.clear();
    //             oppIdSet.add(op1.Id);
    //             recommLst = getRecommendationsRec(ruleNum,oppIdSet);
    //             recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
    //             List<Recommendations__c> recommObjLst = [Select Id,BestActionLogic__c from Recommendations__c
    //                                             where BestActionLogic__c = 'BAL_1' AND Opportunity__c =: op1.Id];
    //             System.assertEquals(0, recommObjLst.size(), 'Recommendation record not created!');
    //         }
    //     }

    //     static testMethod void testBestActionlogic_BAL_1_AND_2_Update() {
    //         User user = UserTest.createUserWithPerms();
    //         System.runAs(user) {
    //             Opportunity op1Temp = [Select Id,Amount from Opportunity where Name = 'Opp Rule'];
    //             op1Temp.StageName = 'BR Diff Opp Name';
    //             update op1Temp;
    //             Set<String> oppIdSet = new Set<String>();
    //             oppIdSet.add(op1Temp.Id);
    //             String ruleNum = 'BAL_1';
    //             List<Recommendations__c> recommLst = getRecommendationsRec(ruleNum,oppIdSet);
    //             RecommendationsActionWrapper recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
    //             Recommendations__c recommObj = [Select Id,BestActionLogic__c from Recommendations__c
    //                                             where BestActionLogic__c = 'BAL_1' AND Opportunity__c =: op1Temp.Id];
    //             System.assertEquals('BAL_1', recommObj.BestActionLogic__c, 'Recommendation record got updated!');
    //             KF_Sell_Best__c bestActionObj = [Select Id,Seller_Recommended_Action__c from KF_Sell_Best__c where
    //                                              Recommendations__c =: recommObj.Id AND Opportunity__c =: op1Temp.Id];
    //             System.assertEquals(null, bestActionObj.Seller_Recommended_Action__c,
    //                                 'Best Action updated & rule not satisfied!');

    //         }
    //     }
    //     static testMethod void testBestActionlogic_BAL_1_AND_2_Update_Match() {
    //         User user = UserTest.createUserWithPerms();
    //         System.runAs(user) {
    //             Opportunity op1Temp = [Select Id,Amount from Opportunity where Name = 'Opp Rule'];
    //             op1Temp.Amount = 20000;
    //             update op1Temp;
    //             Set<String> oppIdSet = new Set<String>();
    //             oppIdSet.add(op1Temp.Id);
    //             String ruleNum = 'BAL_1';
    //             List<Recommendations__c> recommLst = getRecommendationsRec(ruleNum,oppIdSet);
    //             RecommendationsActionWrapper recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
    //             Recommendations__c recommObj = [Select Id,BestActionLogic__c from Recommendations__c
    //                                             where BestActionLogic__c = 'BAL_1' AND Opportunity__c =: op1Temp.Id];
    //             System.assertEquals('BAL_1', recommObj.BestActionLogic__c, 'Recommendation record got updated!');
    //             KF_Sell_Best__c bestActionObj = [Select Id,Seller_Recommended_Action__c from KF_Sell_Best__c where
    //                                              Recommendations__c =: recommObj.Id AND Opportunity__c =: op1Temp.Id];
    //             System.assertEquals(recommWrapperMsg.sellerRecommendedActionMessage, bestActionObj.Seller_Recommended_Action__c,
    //                                 'Best Action record got updated!');

    //         }
    //     }

    //         static testMethod void testBestActionlogic_BAL_12() {
    //         User user = [Select Id from user limit 1];
    //         System.runAs(user) {
    //             String ruleNum = 'BAL_12';
    //             Business_Rules__c br = [Select Id,Is_a_Blue_Sheet_required__c,
    // 			BS_Req_for_certain_Rev_Range__c,Buying_Influence_Role__c from Business_Rules__c limit 1];
    //             br.Is_a_Blue_Sheet_required__c = 'No';
    //             br.BS_Req_for_certain_Rev_Range__c = 'No';
    //             br.Scorecard_Required__c = 'No';
    //             update br;
    //             Business_Rules_Group_Member__c brgm = [Select id, Member_Name__c from Business_Rules_Group_Member__c limit 1];
    //             brgm.Member_Name__c = user.Id;
    //             update brgm;
    //             Account acc = TestDataUtil.createAccount(true);
    //             Opportunity op1 = TestDataUtil.createOpportunity(acc,false);
    //             op1.OwnerId = user.Id;
    //             insert op1;
    //             TestDataUtil.createContact(acc,true);
    //             Contact c = [Select Id from Contact limit 1];
    //             StrategyEngine.createBlueSheet(op1.id);
    //             Blue_Sheet__c bsObj = [Select Id from Blue_Sheet__c where Opportunity__c =: op1.Id];
    //             Buying_Influence__c bi = new Buying_Influence__c();
    //             bi.Blue_Sheet__c = bsObj.Id;
    //             bi.Economic__c = true;
    //             bi.Contact__c = c.Id;
    //             insert bi;
    //             bi.Economic__c = false;
    //             bi.User__c = true;
    //             update bi;
    //             RecommendationsActionWrapper recommWrapperMsg = getRecommendationsActionWrapper(ruleNum);
    //             List<Recommendations__c> recommObj = [Select Id,BestActionLogic__c,Opportunity__c from Recommendations__c
    //                                                   where BestActionLogic__c =: ruleNum AND Opportunity__c =: op1.Id
    //                                             ];//
    //             List<KF_Sell_Best__c> bestActionObj = [Select Id,Seller_Recommended_Action__c,opportunity__c,Recommendations__c from KF_Sell_Best__c
    //                                                   where Recommendations__c =: recommObj[0].Id AND Opportunity__c =: op1.Id
    //                                              ]; //
    //             String wrapSellerRecommendedActionMsg = recommWrapperMsg.sellerRecommendedActionMessage;
    //             wrapSellerRecommendedActionMsg = wrapSellerRecommendedActionMsg.replace('{Business_Rules__c.Buying_Influence_Role__c}',
    //                                             String.valueOf(br.Buying_Influence_Role__c));
    //             System.assertEquals(wrapSellerRecommendedActionMsg,bestActionObj[0].Seller_Recommended_Action__c,
    //                                 'Best Action record got created!');
    //         }
    //     }

    //     */
}