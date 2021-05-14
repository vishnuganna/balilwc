@isTest
public class OpportunityRuleEvaluatorBatchTest {
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
                Opportunity_Stage_Global__c = 'Qualification,Prospecting',
                Business_Rule_Catagory__c = 'Opportunity',
                Opportunity_Currency_Fields__c = 'Amount',
                Minimum_Range__c = 1000,
                Maximum_Range__c = 10000,
                Max_Days_Allowed_in_a_Opty_Stage__c = 2,
                Is_a_Blue_Sheet_required__c = 'Yes',
                is_closed_date_past__c = true,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.CloseDate = date.TODAY().addDays(-5);
            insert op;
        }
    }

    @isTest
    static void validateBatchExecution() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            OpportunityRuleEvaluatorBatch optyBatch = new OpportunityRuleEvaluatorBatch();
            database.executebatch(optyBatch, 120);
            Test.stopTest();
            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_4' AND Business_Rules__c = :br1.Id
                LIMIT 1
            ];
            system.assertNotEquals(bestAction, null);
            system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_4', 'Checking BAL ID');
        }
    }
}