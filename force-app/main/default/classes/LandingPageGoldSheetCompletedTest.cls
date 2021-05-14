// test class for LandingPageGoldSheetCompletedActivities
@isTest
public with sharing class LandingPageGoldSheetCompletedTest {
    @testSetup
    static void testData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Contact con = TestDataUtil.createContact(acc, true);
            Gold_Sheet__c gs = TestDataUtil.createGoldSheet(acc, true);
        }
    }

    @isTest
    static void test_1() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Gold_Sheet__c gs = [SELECT Id FROM Gold_Sheet__c LIMIT 1];
            List<Information_Needed__c> fc = TestDataUtil.createInformationNeeded(gs, false);
            Information_Needed__c info = fc[0];
            info.Due_Date__c = System.today() - 10;
            info.Status__c = 'Complete';
            insert info;
            List<Action__c> actionLst = TestDataUtil.createActions(gs, false);
            Action__c act = actionLst[0];
            act.Due_Date__c = System.today() - 10;
            act.Status__c = 'Complete';
            insert act;
            KF_Sell_Best__c b = [
                SELECT Id
                FROM KF_Sell_Best__c
                WHERE Gold_Sheet_Action__c = :act.Id AND Alert_Type__c = 'Gold_Sheet_Completed_Activities'
            ];
            System.assertEquals(b != null, true, 'Alert record created for Action');
            act.Status__c = 'Incomplete';
            update act;

            List<Investment_Program__c> invLst = TestDataUtil.createInvProgram(gs, false);
            Investment_Program__c inv = invLst[0];
            inv.Due_Date__c = System.today() - 10;
            inv.Status__c = 'Complete';
            insert inv;

            List<Stop_Investment__c> siLst = TestDataUtil.createStopInvestment(gs, false);
            Stop_Investment__c si = siLst[0];
            si.Status__c = 'Complete';
            insert si;

            List<Focus_Investment__c> fiLst = TestDataUtil.createFocusInvestment(gs, false);
            Focus_Investment__c fi = fiLst[0];
            fi.Status__c = 'Complete';
            insert fi;

            KF_Sell_Best__c b1 = [
                SELECT Id
                FROM KF_Sell_Best__c
                WHERE Gold_Sheet_Focus_Investment__c = :fi.Id AND Alert_Type__c = 'Gold_Sheet_Completed_Activities'
            ];
            System.assertEquals(b1 != null, true, 'Alert record created for Focus Investment');
            delete si;
            delete fi;
            List<String> userIdSet = new List<String>();
            userIdSet.add(user.Id);
            Integer queryLimit = 10;
            Integer queryOffset = 0;
            LandingPageGoldSheetCompletedActivities.getFoPActivityRecords(userIdSet, queryLimit, queryOffset);
        }
    }
}