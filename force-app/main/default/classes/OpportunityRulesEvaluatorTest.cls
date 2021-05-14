@isTest
public with sharing class OpportunityRulesEvaluatorTest {
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
        }
    }

    @isTest
    static void validateBRForBluesheetRequired() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];

            Test.startTest();
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.amount = 3000;
            insert op;

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_1' AND Business_Rules__c = :br1.Id
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_1', 'Checking BAL ID');
            Test.stopTest();
        }
    }

    @isTest
    static void validateBRForBluesheetRequiredNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];

            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.amount = 3000;
            insert op;
            Test.startTest();
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Test.stopTest();
            op.amount = 3000;
            update op;

            List<KF_Sell_Best__c> bestAction = [
                SELECT
                    Id,
                    Name,
                    Seller_Recommended_Action__c,
                    Business_Rules__c,
                    Action_Title__c,
                    BestActionRuleId__c,
                    Opportunity__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_1' AND Opportunity__c = :op.Id AND Business_Rules__c = :br1.Id
            ];
            system.assertNotEquals(bestAction.size(), 0, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].Action_Title__c, null, 'Checking action title');
        }
    }

    @isTest
    static void validateBRForCloseDate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];

            Test.startTest();
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.CloseDate = date.TODAY().addDays(-5);
            op.amount = 3000;
            insert op;
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
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
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_4', 'Checking BAL ID');

            Test.stopTest();
        }
    }

    @isTest
    static void validateBRForCloseDateNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];

            Test.startTest();
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.CloseDate = date.TODAY().addDays(-5);
            op.amount = 3000;
            insert op;
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);

            Opportunity opp = op;
            opp.CloseDate = date.TODAY().addDays(5);
            upsert opp;

            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_4' AND Business_Rules__c = :br1.Id
                LIMIT 1
            ];
            //system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            system.assertEquals(bestAction[0].Action_Title__c, null, 'Checking action title');

            Test.stopTest();
        }
    }

    @isTest
    static void validateBRForLastModified() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];

            Test.startTest();
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.Stage_Last_ModifiedOn__c = date.TODAY().addDays(-5);
            op.amount = 3000;
            insert op;
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            update op;
            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_5' AND Business_Rules__c = :br1.Id
                LIMIT 1
            ];
            system.assertEquals(bestAction.size(), 1, 'Checking size of best action list');
            //system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_5', 'Checking BAL ID');
            Test.stopTest();
        }
    }
    /*
    @isTest
    static void validateBRForLastModifiedNegative() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Business_Rules__c br1 = [
                SELECT Id, Name, Business_Rule_Catagory__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
                LIMIT 1
            ];
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
			op.Stage_Last_ModifiedOn__c = date.TODAY().addDays(-5);
            op.amount = 3000;
            insert op;
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            op.Stage_Last_ModifiedOn__c = date.TODAY().addDays(-6);
			update op;
            Test.startTest();
            op.Stage_Last_ModifiedOn__c = date.TODAY().addDays(6);
			update op;

            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c = 'BAL_5' AND opportunity__c = :op.Id AND Business_Rules__c = :br1.Id
                LIMIT 1
            ];
            //system.assertEquals(bestAction.size(), 0, 'Checking size of best action list');
            system.assertEquals(bestAction[0].Action_Title__c, null, 'Checking size of best action list');
            Test.stopTest();
        }
    }*/
}