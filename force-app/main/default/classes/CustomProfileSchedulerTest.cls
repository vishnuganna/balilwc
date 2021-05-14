/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-277 (part of main US KFS-277) : Test Class for CustomProfileScheduler
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-05-30
 * Note: if there is single quote in any msg, escape it in this class
 */
@isTest
public with sharing class CustomProfileSchedulerTest {
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

    static testMethod void testCPRecords() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT id, name FROM Opportunity LIMIT 1];
            Blue_Sheet__c bs = [SELECT id, Opportunity__c FROM Blue_Sheet__c LIMIT 1];
            Custom_profile__c cp1 = new Custom_profile__c();
            cp1.Name = 'TestProfile';
            cp1.Profile_id__c = 'cjnbihu878';
            insert cp1;
            Test.startTest();
            CustomProfileScheduler sch = new CustomProfileScheduler();
            String chron = '0 0 23 * * ?';
            String jobid = System.schedule('testScheduledApex', chron, sch);
            Custom_profile__c cp2 = [SELECT Id, Name FROM Custom_profile__c WHERE name = 'TestProfile'];
            System.assertEquals(cp2.Name, 'TestProfile');
            Test.stopTest();
        }
    }
}