@isTest
public with sharing class InsightsAlertRecommendationsTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Business_Rules_Group__c brg = new Business_Rules_Group__c();
            brg.name = 'EasterGrp';
            insert brg;
            Business_Rules_Group_Member__c brgm = new Business_Rules_Group_Member__c();
            brgm.Member_Name__c = user.Id;
            brgm.Business_Rules_Group__c = brg.Id;
            insert brgm;
            Account acc = TestDataUtil.createAccount(true);
            List<Business_Rules__c> br = TestDataUtil.createBusinessRulesRecords(false);
            br[0].Business_Rules_Group__c = brg.Id;
            insert br;
            List<Insight_Alert__c> alert = TestDataUtil.createInsightAlert(br, acc, true);
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.Amount = 1500;
            insert op;
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
        }
    }

    @isTest
    static void testUpsertPerspectiveInsightsAlerts() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Insight_Alert__c insightWrapper = new Insight_Alert__c();
            insightWrapper.Insights__c = 'insights text';
            insightWrapper.Insights_Link__c = 'insights linke';
            insightWrapper.Industry__c = 'Transportation';
            insightWrapper.Opportunity_Type__c = 'Existing Customer - Downgrade';
            InsightAlertsWrapper insightData = new InsightAlertsWrapper(insightWrapper);

            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Id businessRuleId = br[0].Id;
            InsightsAlertRecommendations.upsertCustomInsightsAlerts(insightData, businessRuleId, 'Competitor');
            List<Insight_Alert__c> insightAlert = [
                SELECT Id, Insights__c
                FROM Insight_Alert__c
                WHERE Business_Rules__c = :businessRuleId
                LIMIT 1
            ];
            System.assertEquals(insightAlert.size(), 1, 'Checking size of Insight List');
        }
    }

    @isTest
    static void testGetCustomInsightAlerts() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Insight_Alert__c insightWrapper = new Insight_Alert__c();
            insightWrapper.Insights__c = 'insights text';
            insightWrapper.Insights_Link__c = 'insights linke';
            insightWrapper.Industry__c = 'Transportation';
            insightWrapper.Opportunity_Type__c = 'Existing Customer - Downgrade';
            InsightAlertsWrapper insightData = new InsightAlertsWrapper(insightWrapper);

            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Id businessRuleId = br[0].Id;
            InsightsAlertRecommendations.upsertCustomInsightsAlerts(insightData, businessRuleId, 'Competitor');
            Map<String, InsightAlertsWrapper> ins = InsightsAlertRecommendations.getCustomInsightAlerts(
                businessRuleId,
                'Competitor'
            );
            System.assertEquals(ins.get(businessRuleId) != null, true, 'Checking size of Insight List');
        }
    }

    @isTest
    static void testGetInsights() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Business_Rules_Group__c brg = [SELECT Id, name FROM Business_Rules_Group__c LIMIT 1];
            Test.startTest();
            map<String, Object> newmapInsights = new Map<String, Object>();
            newmapInsights.put('insights', 'test insights');
            newmapInsights.put('insightsLink', 'https://www.kornferry.com/');
            newmapInsights.put('displayLinkAs', 'Korn Ferry link');
            newmapInsights.put('optyType', 'Existing Customer - Replacement');
            newmapInsights.put('industry', 'Transportation');

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test business rule');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Perspective');
            newmap.put('brGroup', brg.Id);
            newmap.put('customPerspectiveInsights', newmapInsights);

            String jsonstring = JSON.Serialize(newmap);
            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Map<String, Object> wrapper = BusinessRules.upsertBusinessRule(jsonstring);
            List<Business_Rules__c> br1 = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Opportunity op = TestDataUtil.createOpportunity(acc, true);

            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            System.assertEquals(true, bs != null, 'Checking size of Insight List' + bs.Id);
            List<InsightsWrapper> data = InsightsAlertRecommendations.getInsights(bs.Id, 'Perspective');
            System.assertEquals(data.size(), 1, 'Checking size of Insight List' + bs.Id);
        }
    }

    @isTest
    static void testDeleteInsightsForActionPlan() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Business_Rules_Group__c brg = [SELECT Id, name FROM Business_Rules_Group__c LIMIT 1];
            Test.startTest();
            map<String, Object> newmapInsights = new Map<String, Object>();
            newmapInsights.put('insights', 'test insights');
            newmapInsights.put('insightsLink', 'https://www.kornferry.com/');
            newmapInsights.put('displayLinkAs', 'Korn Ferry link');
            newmapInsights.put('optyType', 'Existing Customer - Replacement');
            newmapInsights.put('industry', 'Transportation');

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test business rule');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Perspective');
            newmap.put('brGroup', brg.Id);
            newmap.put('customPerspectiveInsights', newmapInsights);

            String jsonstring = JSON.Serialize(newmap);
            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Map<String, Object> wrapper = BusinessRules.upsertBusinessRule(jsonstring);
            List<Business_Rules__c> br1 = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Opportunity op = TestDataUtil.createOpportunity(acc, true);

            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
            System.assertEquals(true, bs != null, 'Checking size of Insight List' + bs.Id);
            Insight__c insightsList = [
                SELECT
                    Id,
                    Name,
                    Blue_Sheet__c,
                    Business_Rules__c,
                    Competition__c,
                    Insight_Alert__c,
                    Insight_Alert__r.Insights__c,
                    Insight_Alert__r.Insights_Link__c,
                    Opportunity__c
                FROM Insight__c
                WHERE Blue_Sheet__c = :bs.Id
                LIMIT 1
            ];
            System.assertEquals(true, insightsList != null, 'Checking size of Blue Sheet' + bs.Id);
            List<Blue_Sheet__c> bsInDb = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];
            InsightsAlertRecommendations.deleteInsightsForActionPlan(bsInDb);
            List<InsightsWrapper> data = InsightsAlertRecommendations.getInsights(bs.Id, 'Perspective');
            System.assertEquals(data.size() > 0, true, 'Checking size of Blue Sheet After Delete');
        }
    }

    @isTest
    static void testDeleteInsightsForCompetition() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id, name FROM Account LIMIT 1];
            Blue_Sheet__c bs = [SELECT Id, Name FROM Blue_Sheet__c LIMIT 1];

            Test.startTest();
            map<String, Object> newmapInsights = new Map<String, Object>();
            newmapInsights.put('insights', 'test insights');
            newmapInsights.put('insightsLink', 'test insights link');
            newmapInsights.put('accountId', acc.Id);

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test business rule');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Competitor');
            newmap.put('customCompetitorInsights', newmapInsights);

            String jsonstring = JSON.Serialize(newmap);
            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Map<String, Object> wrapper = BusinessRules.upsertBusinessRule(jsonstring);
            List<Business_Rules__c> br1 = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            System.assertEquals(br.size(), 2, 'Checking Size of Business Rules');
            System.assertEquals(br1.size(), 3, 'Checking Size of Business Rules');

            Competition__c comp = TestDataUtil.createCompetition(bs, acc, false);
            comp.Account__c = acc.Id;
            comp.Competitor_Type__c = 'Buying from Someone Else';
            insert comp;

            List<Competition__c> competitionInDb = [SELECT Id, Name FROM Competition__c LIMIT 1];

            InsightsAlertRecommendations.deleteInsightsForCompetition(competitionInDb);
            List<InsightsWrapper> data = InsightsAlertRecommendations.getInsights(bs.Id, 'Competitor');
            System.assertEquals(data.size(), 0, 'Checking size of Blue Sheet After Delete');
        }
    }
}