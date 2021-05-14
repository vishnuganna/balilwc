@isTest
public with sharing class ScoreCardTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = TestDataUtil.createAccount(true);
            Opportunity op = TestDataUtil.createOpportunity(acc, true);
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            Admin_Score_Card__c admin = TestDataUtil.createAdminScoreCard(true);
            List<Admin_Scorecard_Criteria__c> adminCriteria = TestDataUtil.createAdminScoreCardCriteris(admin, true);
            Score_Card__c scoreCard = TestDataUtil.createScoreCard(bs, true);
            Score_Card_Detail__c scoreCardDetail = TestDataUtil.createScoreCardDetails(scoreCard, true);
        }
    }
    static testMethod void testGetAllScoreCard() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<scoreCardOpptyWrapper> scoreWrap = ScoreCard.getAllScoreCard();
            System.assertEquals(scoreWrap[0].Name, 'Strategy Selling ScoreCard');
        }
    }
    static testMethod void testGetScoreCardTemplateCriteria() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String scoreCardId = [SELECT Id FROM Admin_Score_Card__c].Id;
            scoreCardOpptyWrapper scoreWrap = ScoreCard.getScoreCardTemplateCriteria(scoreCardId);
            System.assertEquals(scoreWrap.templateCriteria[0].pointValue, 20);
        }
    }
    static testMethod void testSaveScoreCardData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String scoreCardId = [SELECT Id FROM Admin_Score_Card__c].Id;
            String opptyId = [SELECT Id FROM Opportunity].Id;
            Integer Potentailscore = 60;

            String inputString = '{"templateCriteria":[{"criteriaDef": "We have at least one Coach.","pointValue": 20,"section": "Opportunity","title": "We have at least one Coach.","currentScore": 0,"isOpptySection": true}]}';

            ScoreCard.saveScoreCardData(inputString, opptyId, Potentailscore);
            List<Score_Card__c> scoreCard = [SELECT Id FROM Score_Card__c];
            System.assertEquals(scoreCard.size(), 2);
        }
    }
    static testMethod void testGetScoreCardForOppty() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String opptyId = [SELECT Id FROM Opportunity].Id;
            scoreCardOpptyWrapper scoreWrap = ScoreCard.getScoreCardForOppty(opptyId);
            System.assertEquals(scoreWrap.potentialScore, 60);
        }
    }

    static testMethod void testDeleteScoreCard() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String scoreCardId = [SELECT Id FROM Score_Card__c].Id;
            ScoreCard.deleteScoreCard(scoreCardId);
            List<Score_Card__c> scoreCard = [SELECT Id FROM Score_Card__c];
            System.assertEquals(scoreCard.size(), 0);
        }
    }
    static testMethod void testGetOpptyName() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String opptyId = [SELECT Id FROM Opportunity].Id;
            String opptyName = ScoreCard.getOpptyName(opptyId);
            System.assertEquals(opptyName, 'Test Opportunity');
        }
    }
}