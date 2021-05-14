@isTest
public with sharing class BuyingInfluenceEvaluatorTest {
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
                Business_Rule_Catagory__c = 'Buying Influences',
                Buying_Influence_Role__c = 'Coach',
                is_negative_rating__c = true,
                is_high_rated_BI_no_coach__c = true,
                is_person_win_identified__c = true,
                is_business_result_identified__c = true,
                is_coach_with_low_BI__c = true,
                is_discon_mode_cust_timing__c = true,
                Min_Number_Buying_Influence_Contacts__c = 2,
                Business_Rules_Group__c = brg.Id
            );
            brLst.add(br1);
            insert brLst;
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Contact con = TestDataUtil.createContact(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            //List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, true);
        }
    }

    @isTest
    static void validateBusinessRule1Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '-4';
            biList[0].Rating_Evidence__c = null;
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_18'
            ];
            system.assertEquals(bestAction.size(), 1);
            system.assertEquals(bestAction[0].BestActionRuleId__c, 'BAL_18');
        }
    }
    @isTest
    static void validateBusinessRule1TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '-4';
            biList[0].Rating_Evidence__c = null;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_18'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_18', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Rating__c = '-2';
            biList[0].Rating_Evidence__c = null;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_18'
            ];
            system.assertEquals('BAL_18', bestActionupdate[0].BestActionRuleId__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule1TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '-4';
            biList[0].Rating_Evidence__c = null;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_18'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_18', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Rating__c = '+2';
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_18'
            ];
            system.assertEquals(null, bestActionupdate[0].Action_Title__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule2Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '+4';
            biList[0].Coach__c = false;
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_19'
            ];
            system.assertEquals(1, bestAction.size(), 'Record mismatch');
            system.assertEquals('BAL_19', bestAction[0].BestActionRuleId__c, 'Record mismatch');
        }
    }
    @isTest
    static void validateBusinessRule2TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '+5';
            biList[0].Coach__c = false;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_19'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_19', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Rating__c = '+4';
            biList[0].Coach__c = false;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_19'
            ];
            system.assertEquals('BAL_19', bestActionupdate[0].BestActionRuleId__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule2TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '+5';
            biList[0].Coach__c = false;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_19'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_19', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Rating__c = '+2';
            biList[0].Coach__c = true;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_19'
            ];
            system.assertEquals(null, bestActionupdate[0].Action_Title__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule3Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Personal_Wins__c = '';
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_20'
            ];
            system.assertEquals(1, bestAction.size(), 'Record mismatch');
            system.assertEquals('BAL_20', bestAction[0].BestActionRuleId__c, 'Record mismatch');
        }
    }
    @isTest
    static void validateBusinessRule3TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Personal_Wins__c = '';
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_20'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_20', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Personal_Wins__c = '';
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_20'
            ];
            system.assertEquals('BAL_20', bestActionupdate[0].BestActionRuleId__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule3TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Personal_Wins__c = '';
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_20'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_20', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Personal_Wins__c = 'my new data';
            biList[0].Coach__c = true;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_20'
            ];
            system.assertEquals(null, bestActionupdate[0].Action_Title__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule4Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Business_Results__c = '';
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_21'
            ];
            system.assertEquals(1, bestAction.size(), 'Record mismatch');
            system.assertEquals('BAL_21', bestAction[0].BestActionRuleId__c, 'Record mismatch');
        }
    }
    @isTest
    static void validateBusinessRule4TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Business_Results__c = '';
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_21'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_21', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Business_Results__c = '';
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_21'
            ];
            system.assertEquals('BAL_21', bestActionupdate[0].BestActionRuleId__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule4TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Business_Results__c = '';
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_21'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_21', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Business_Results__c = 'my new data';
            biList[0].Coach__c = true;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_21'
            ];
            system.assertEquals(null, bestActionupdate[0].Action_Title__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule5Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '+2';
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_22'
            ];
            system.assertEquals(0, bestAction.size(), 'Record mismatch');
        }
    }
    @isTest
    static void validateBusinessRule5TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Rating__c = '+2';
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_22'
            ];
            system.assertEquals(0, bestAction.size(), 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule5TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].rating__c = '+2';
            insert biList;
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            List<Buying_Influence__c> biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_22'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule6Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Coach__c = true;
            biList[0].Low__c = true;
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_23'
            ];
            system.assertEquals(1, bestAction.size(), 'Record mismatch');
            system.assertEquals('BAL_23', bestAction[0].BestActionRuleId__c, 'Record mismatch');
        }
    }
    @isTest
    static void validateBusinessRule6TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Coach__c = true;
            biList[0].Low__c = true;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_23'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_23', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Rating__c = '+2';
            biRec.Low__c = true;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_23'
            ];
            system.assertEquals('BAL_23', bestActionupdate[0].BestActionRuleId__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule6TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Coach__c = true;
            biList[0].Low__c = true;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_23'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            biRec.Coach__c = false;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_23'
            ];
            system.assertEquals(null, bestActionupdate[0].Action_Title__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule7Trigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Over_Confident__c = true;
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals(1, bestAction.size(), 'Record mismatch');
            system.assertEquals('BAL_24', bestAction[0].BestActionRuleId__c, 'Record mismatch');
        }
    }
    @isTest
    static void validateBusinessRule7TriggerUpdate() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Over_Confident__c = true;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals(1, bestAction.size(), 'record does not match');
            system.assertEquals('BAL_24', bestAction[0].BestActionRuleId__c, 'record does not match');
            biRec.Even_Keel__c = true;
            update biRec;
            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals('BAL_24', bestActionupdate[0].BestActionRuleId__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRule7TriggerRemoveAlert() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Over_Confident__c = true;
            insert biList[0];
            system.test.startTest();
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [
                SELECT Id, Name, Rating__c
                FROM Buying_Influence__c
                WHERE Blue_Sheet__c = :bs.Id
            ];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c, BestActionRuleId__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals('BAL_24', bestAction[0].BestActionRuleId__c, 'record does not match');
            system.assertEquals(1, bestAction.size(), 'record does not match');
            delete sso;
            biRec.Over_Confident__c = false;
            biRec.Even_Keel__c = false;
            update biRec;

            List<KF_Sell_Best__c> bestActionupdate = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals(null, bestActionupdate[0].Action_Title__c, 'record does not match');
            system.test.stopTest();
        }
    }
    @isTest
    static void validateBusinessRuleDeleteTrigger() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Contact con = [SELECT Id, name FROM contact LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            system.test.startTest();
            List<Buying_Influence__c> biList = TestDataUtil.createBuyingInfluence(bs, con, false);
            biList[0].Over_Confident__c = true;
            insert biList[0];
            Business_Rules__c br1 = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
            Buying_Influence__c biRec = [SELECT Id, Name FROM Buying_Influence__c WHERE Blue_Sheet__c = :bs.Id];
            List<KF_Sell_Best__c> bestAction = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Buying_Influence__c = :biRec.Id AND Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals(1, bestAction.size(), 'Record mismatch');
            delete biRec;
            List<KF_Sell_Best__c> bestAction2 = [
                SELECT Id, Name, Seller_Recommended_Action__c, Action_Title__c
                FROM KF_Sell_Best__c
                WHERE Business_Rules__c = :br1.Id AND BestActionRuleId__c = 'BAL_24'
            ];
            system.assertEquals(0, bestAction2.size(), 'Record mismatch');
            system.test.stopTest();
        }
    }
}