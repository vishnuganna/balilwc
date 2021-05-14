@isTest
public with sharing class CompetitorRulesEvaluatorTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
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
            br[1].Business_Rules_Group__c = brg.Id;
            insert br;
            List<Insight_Alert__c> alert = TestDataUtil.createInsightAlert(br, acc, true);
            Opportunity op = TestDataUtil.createOpportunity(acc, false);
            op.Amount = 1500;
            insert op;
            Blue_Sheet__c bs = TestDataUtil.createBluesheet(op, true);
        }
    }

    @isTest
    static void validateCompetitionForInsights() {
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

            List<Insight__c> insightsList = [
                SELECT
                    Id,
                    Name,
                    Blue_Sheet__c,
                    Business_Rules__c,
                    Competition__c,
                    Insight_Alert__c,
                    Insight_Alert__r.Insights__c,
                    Insight_Alert__r.Insights_Link__c,
                    Insight_Alert__r.Competitor__c,
                    Opportunity__c
                FROM Insight__c
                WHERE Competition__c = :comp.Id
                LIMIT 1
            ];
            System.assertEquals(insightsList.size(), 1, 'Checking size of Insight List');
            Test.stopTest();
        }
    }
}