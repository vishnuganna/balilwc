@isTest
public class ConverStringFromCustomLabelsTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            opportunity opp = TestDataUtil.createOpportunity(acc, true);
            List<Task> taskList = TestDataUtil.createTaskList(user, true);
            Green_Sheet__c greenSheet = TestDataUtil.createGreenSheet(taskList[0], true);
            //KF_Sell_Best__c kfSellBest = TestDataUtil.createKfSellBestAction(opp, greenSheet, true);
        }
    }

    @isTest
    static void testGetStringByLabels_BAL() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Opportunity opp = [SELECT Id, Name FROM Opportunity];
            Green_Sheet__c greenSheet = [SELECT Id FROM Green_Sheet__c];
            List<KF_Sell_Best__c> kfSellBest = TestDataUtil.createKfSellBestAction_BAL(opp, greenSheet, true);
            List<String> listStringRules = new List<String>();
            List<KFSellBestHelperWrapper> listRules = new List<KFSellBestHelperWrapper>();
            for (integer i = 1; i <= 28; i++) {
                String rule = 'BAL_' + i;
                listStringRules.add(rule);
            }
            List<KF_Sell_Best__c> bestAction = [
                SELECT
                    Id,
                    Action_Title__c,
                    Seller_Recommended_Action__c,
                    Seller_Email_Text__c,
                    Business_Rules__c,
                    Manager_Recommended_Action__c,
                    Action_Title_Seller__c,
                    Action_Title_Manager__c,
                    Seller_URL_Link__c,
                    Opportunity__c,
                    Green_Sheet__c,
                    Alert_Type__c,
                    Associated_Object__c
                FROM KF_Sell_Best__c
                WHERE BestActionRuleId__c IN :listStringRules
            ];
            for (integer i = 0; i <= 27; i++) {
                listRules.add(ConverStringFromCustomLabels.getStringByLabels(bestAction[i], true));
                listRules.add(ConverStringFromCustomLabels.getStringByLabels(bestAction[i], false));
            }
            system.assertEquals(true, listRules.size() > 0);
        }
    }
}