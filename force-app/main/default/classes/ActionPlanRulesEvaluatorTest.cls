@isTest
public with sharing class ActionPlanRulesEvaluatorTest {
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
        }
    }

    @isTest
    static void validatePerspectiveForInsights() {
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
            System.assertEquals(
                insightsList != null,
                true,
                'Checking size of Insight List' + insightsList.Blue_Sheet__c
            );
            Test.stopTest();
        }
    }
}