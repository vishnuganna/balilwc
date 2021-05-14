@isTest
public with sharing class ScoreCardRulesEvaluatorTest {
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
                Business_Rule_Catagory__c = 'Scorecard',
                Opportunity_Currency_Fields__c = 'Amount',
                Minimum_Score__c = 10,
                Maximum_Score__c = 80,
                OpportunityCriteria_Minimum_Score__c = 10,
                OpportunityCriteria_Maximum_Score__c = 30,
                BusinessCriteria_Minimum_Score__c = 10,
                BusinessCriteria_Maximum_Score__c = 30,
                Check_Business_Criteria_Score__c = true,
                Check_Opportunity_Score__c = true,
                Check_Total_Score__c = true,
                Check_Scorecard_Last_Modified__c = true,
                Scorecard_Number_of_Days_Updated__c = -2,
                Scorecard_Required__c = 'Yes',
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
        }
    }

    @isTest
    static void validateOptyScorePositive() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bss = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();

            Score_Card__c card = TestDataUtil.createScoreCard(bss, true);
            Score_Card_Detail__c scrd = TestDataUtil.createScoreCardDetails(card, true);

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bss.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_16'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_16', 'Checking BAL_ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBusinessScorePositive() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bss = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();

            Score_Card__c card = TestDataUtil.createScoreCard(bss, true);
            Score_Card_Detail__c scrd = TestDataUtil.createScoreCardDetails(card, false);
            scrd.Section__c = 'Business';
            insert scrd;

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bss.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_17'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_17', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateTotalScorePositive() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bss = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();

            Score_Card__c card = TestDataUtil.createScoreCard(bss, true);
            Score_Card_Detail__c scrd = TestDataUtil.createScoreCardDetails(card, false);
            scrd.Section__c = '';
            insert scrd;

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bss.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_15'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_15', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateScorecardLastModifiedPositive() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bss = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();

            Score_Card__c card = TestDataUtil.createScoreCard(bss, true);

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bss.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_14'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_14', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateScorecardLastModifiedNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bss = [SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Scorecard'
                LIMIT 1
            ];

            Test.startTest();

            Score_Card__c card = TestDataUtil.createScoreCard(bss, true);

            br1.Scorecard_Number_of_Days_Updated__c = 2;
            upsert br1;

            card.Potential_Score__c = 80;
            upsert card;

            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE
                    Opportunity__c = :bss.Opportunity__c
                    AND Business_Rules__c = :br1.Id
                    AND BestActionRuleId__c = 'BAL_14'
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            system.assertEquals(bestAction[0].Action_Title__c, null, 'Checking action title');
            Test.stopTest();
        }
    }
}