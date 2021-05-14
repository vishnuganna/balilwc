/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-277 (part of main US KFS-277) : Test Class for BestActionRuleScheduler
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-05-30
 * Note: if there is single quote in any msg, escape it in this class
 */
@isTest
public with sharing class BestActionRuleSchedulerTest {
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

    static testMethod void testGetStrategyengineRecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Strategy_Engine__c> seLst = new List<Strategy_Engine__c>();
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Strategy_Engine__c se = TestDataUtil.createStrategyEngine(bs, false);
            se.Place_in_Sales_Funnel__c = 'Qualification';
            se.Opportunity_Amount__c = 200;
            se.BS_Req_for_certain_Rev_Range__c = 'No';
            //se.lastmodifieddate = Date.Today()-30;
            se.Blue_Sheet__c = bs.id;
            seLst.add(se);
            insert seLst;

            Test.startTest();
            BestActionRuleScheduler sch = new BestActionRuleScheduler();
            String chron = '0 0 23 * * ?';
            String jobid = System.schedule('testScheduledApex', chron, sch);

            sch.getStrategyengineRecords();

            System.assertEquals(bs.Opportunity__c, opp.Id);
            Test.stopTest();
        }
    }
}