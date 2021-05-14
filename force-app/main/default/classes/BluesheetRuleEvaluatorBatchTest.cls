@isTest
public class BluesheetRuleEvaluatorBatchTest {
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
    static void validateBatchExecution() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, name FROM Opportunity LIMIT 1];
            opp.Amount = 5000;
            upsert opp;
            Blue_Sheet__c bss = TestDataUtil.createBluesheet(opp, true);
            upsert bss;
            Test.startTest();
            BluesheetRuleEvaluatorBatch bsBatch = new BluesheetRuleEvaluatorBatch();
            Database.executeBatch(bsBatch, 150);
            Test.stopTest();
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
            system.assertNotEquals(bss.id, null);
            system.assertNotEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_3', 'Checking BAL ID');
        }
    }
}