/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-357,main US=KFS-66 : Test Class for KFSellBestAction,RecommendationsTrigger
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-June-05
 */

@isTest
public with sharing class BestActionTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Contact con = TestDataUtil.createContact(acc, true);
            List<Buying_Influence__c> buying = TestDataUtil.createBuyingInfluence(bs, con, true);
            Single_Sales_Objective__c sso = TestDataUtil.createSSO(bs, true);
            TestDataUtil.createBusinessRules(true);
        }
    }

    static testMethod void testBestActionlogic_Create_RecommedationRec() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.Is_a_Blue_Sheet_required__c = 'Yes';
            se.BS_Req_for_certain_Rev_Range__c = 'No';
            DataFactory.create(se); // this creates BAL_1 recommendation record and corresponding KF sell Best Action record

            se.BS_Req_for_certain_Rev_Range__c = 'Yes';
            DataFactory.modify(se); // this creates BAL_2 recommendation record and corresponding KF sell Best Action record

            List<Recommendations__c> recommLst = [SELECT id FROM Recommendations__c];
            DataFactory.remove(recommLst);

            List<KF_Sell_Best__c> kfsellBestActionRecLst = [SELECT id FROM KF_Sell_Best__c];
            System.assertEquals(kfsellBestActionRecLst.isEmpty(), true);
        }
    }

    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            opportunity objOppt = new opportunity();
            objOppt.Name = 'Test Opportunity';
            objOppt.StageName = 'Needs Analysis';
            objOppt.CloseDate = date.today();
            insert objOppt;

            KF_Sell_Best__c kfs = new KF_Sell_Best__c();
            kfs.Opportunity__c = objOppt.Id;
            kfs.Action_Title__c = 'Test Title';
            insert kfs;
        }
    }

    static testMethod void getBesActionListTest() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            opportunity objOppt = new opportunity();
            objOppt.Name = 'Test Opportunity';
            objOppt.StageName = 'Needs Analysis';
            objOppt.CloseDate = date.today();
            insert objOppt;

            KF_Sell_Best__c kfs = new KF_Sell_Best__c();
            kfs.Opportunity__c = objOppt.Id;
            kfs.Action_Title__c = 'Test Title';
            kfs.Seller_Recommended_Action__c = 'Test seller recommendation';
            insert kfs;

            //testData();
            //opportunity objOppt = [SELECT id, StageName, CloseDate FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
            //KF_Sell_Best__c kfs = [SELECT id, Action_Title__c, Seller_Recommended_Action__c from KF_Sell_Best__c where id=:kfs.Id];
            Test.startTest();
            BestAction.BestActionsWrapper wrap1 = new BestAction.BestActionsWrapper(kfs);
            List<BestAction.BestActionsWrapper> wrap = BestAction.getBestActionList(objOppt.Id);
            system.assertEquals(true, wrap.size() > 0);
            Test.stopTest();
        }
    }
}