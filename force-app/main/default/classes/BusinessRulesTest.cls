@isTest
public with sharing class BusinessRulesTest {
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
    static void testGetBusinessRule() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            BusinessRules.BusinessRulesWrapper businessWrapper = BusinessRules.getBusinessRule(br[0].Id);
            System.assertEquals(
                br[0].Business_Rule_Name__c,
                'Competitior Business Rule 1',
                'VerifyingBusiness rule name on BusinessRules Class'
            );
            System.assertEquals(
                br[1].Business_Rule_Name__c,
                'Competitior Business Rule 2',
                'VerifyingBusiness rule name on BusinessRules Class'
            );
            BusinessRules.getOpportunityStagePicklistValues();
            BusinessRules.getBusinessRulesGroupName();
        }
    }

    @isTest
    static void testUpsertBusinessRule() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id FROM Account LIMIT 1];
            List<Business_Rules__c> bRule = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            List<Insight_Alert__c> alert = [
                SELECT Id, Business_Rules__c, Competitor__c, Insights__c, Insights_Link__c
                FROM Insight_Alert__c
                WHERE Business_Rules__c = :bRule[0].Id
            ];

            map<String, Object> newmapInsights = new Map<String, Object>();
            newmapInsights.put('insights', 'test insights');
            newmapInsights.put('insightsLink', 'test insights link');
            newmapInsights.put('accountId', acc.Id);
            newmapInsights.put('id', alert[0].Id);

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test business rule');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Competitor');
            newmap.put('id', bRule[0].Id);
            newmap.put('customCompetitorInsights', newmapInsights);

            String jsonstring = JSON.Serialize(newmap);
            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Map<String, Object> wrapper = BusinessRules.upsertBusinessRule(jsonstring);
            List<Business_Rules__c> br1 = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            System.assertEquals(br.size(), 2, 'Checking Size of Business Rules');
            System.assertEquals(br1.size(), 2, 'Checking Size of Business Rules');
            BusinessRules.getCompetitiorLookup();
            BusinessRules.getCurrencyFields();
        }
    }

    @isTest
    static void testUpsertBusinessRule2() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Account acc = [SELECT Id FROM Account LIMIT 1];

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
            BusinessRules.getCompetitiorLookup();
            BusinessRules.getCurrencyFields();
        }
    }
    @isTest
    static void testUpsertGreenSheetBusinessRule() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test green business rule');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Meeting PLan');
            newmap.put('isMinActCommitAdded', true);
            newmap.put('isBestActCommitAdded', true);
            newmap.put('isVBRAdded', true);
            newmap.put('isConceptForBIAdded', true);
            newmap.put('numDaysBeforeMeeting', 10);

            String jsonstring = JSON.Serialize(newmap);
            List<Business_Rules__c> br = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c];
            Map<String, Object> wrapper = BusinessRules.upsertGreenSheetBusinessRule(jsonstring);
            List<Business_Rules__c> br1 = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Name__c = 'test green business rule'
            ];
            System.assertEquals(br1.size(), 1, 'Checking Size of Business Rules');
        }
    }
    @isTest
    static void testGetGreenSheetBRData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test green business rule');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Meeting PLan');
            newmap.put('isMinActCommitAdded', true);
            newmap.put('isBestActCommitAdded', true);
            newmap.put('isVBRAdded', true);
            newmap.put('isConceptForBIAdded', true);
            newmap.put('numDaysBeforeMeeting', 10);

            String jsonstring = JSON.Serialize(newmap);
            Map<String, Object> wrapper = BusinessRules.upsertGreenSheetBusinessRule(jsonstring);
            List<Business_Rules__c> br = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Name__c = 'test green business rule'
            ];
            BusinessRules.BusinessRulesWrapper businessWrapper = BusinessRules.getBusinessRule(br[0].Id);
            System.assertEquals(
                br[0].Business_Rule_Name__c,
                'test green business rule',
                'VerifyingBusiness rule name on BusinessRules Class'
            );
        }
    }
    @isTest
    static void testotherGreenSheetBRData() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String data = BusinessRules.getBRCategoryPicklistValues();
            system.assertEquals(data.contains('Meeting Plan'), true, 'Check Business rule data for Meeting Plan');
        }
    }

    @isTest
    static void validateDeleteInsightsForCompetition() {
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
            List<Competition__c> compList = [
                SELECT Id, Name, Blue_Sheet__r.Opportunity__c, Blue_Sheet__c
                FROM Competition__c
                LIMIT 1
            ];
            String compId = compList[0].Id;
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
                WHERE Competition__c = :compId
                LIMIT 1
            ];
            System.assertEquals(insightsList.size(), 1, 'Checking size of Insight List');

            if (compList != null && !compList.isEmpty()) {
                DataFactory.remove(compList);
            }

            List<Insight__c> insightsListNew = [
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
                WHERE Competition__c = :compId
                LIMIT 1
            ];
            System.assertEquals(insightsListNew.size(), 0, 'Checking size of Insight List is also deleted');

            Test.stopTest();
        }
    }

    @isTest
    static void testUpsertCustomAlertRecord() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            Map<String, Object> actionAlertObject = new Map<String, Object>();
            actionAlertObject.put('balId', 'BAL_1');
            actionAlertObject.put('defaultAlertHeader', 'test default header');
            actionAlertObject.put('defaultAlertMessage', 'test default text');
            actionAlertObject.put('customAlertHeader', 'test custom header');
            actionAlertObject.put('customAlertMessage', 'test custom text');
            actionAlertObject.put('alertEnabled', true);
            actionAlertObject.put('overrideHeader', true);
            actionAlertObject.put('overrideMessage', true);

            Map<String, Object> customRecommendationActionObject = new Map<String, Object>();
            customRecommendationActionObject.put('action', actionAlertObject);
            customRecommendationActionObject.put('managerEmail', actionAlertObject);
            customRecommendationActionObject.put('sellerEmail', actionAlertObject);
            customRecommendationActionObject.put('balId', 'BAL_1');

            Map<String, Object> brMap = new Map<String, Object>();
            brMap.put('brName', 'test business rule');
            brMap.put('isActive', true);
            brMap.put('brCategory', 'Opportunity');
            brMap.put('bsReq', 'Yes');
            brMap.put('customRecommendationAction', customRecommendationActionObject);

            String jsonstring = JSON.Serialize(brMap);
            Map<String, Object> wrapper = BusinessRules.upsertBusinessRule(jsonstring);
            List<Business_Rules__c> bRule = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
            ];
            System.assertEquals(bRule.size(), 1, 'Checking whether Business rule is inserted');

            Map<String, Object> brMapToUpdate = new Map<String, Object>();
            brMapToUpdate.put('Id', bRule[0].Id);
            brMapToUpdate.put('brName', 'test business rule update');
            brMapToUpdate.put('isActive', true);
            brMapToUpdate.put('brCategory', 'Opportunity');
            brMapToUpdate.put('bsReq', 'Yes');
            brMapToUpdate.put('customRecommendationAction', customRecommendationActionObject);

            String jsonstringUpdate = JSON.Serialize(brMapToUpdate);
            Map<String, Object> wrapperToUpdate = BusinessRules.upsertBusinessRule(jsonstringUpdate);

            List<Business_Rules__c> bRuleUpdated = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Opportunity'
            ];
            System.assertEquals(
                bRuleUpdated[0].Business_Rule_Name__c,
                'test business rule update',
                'Checking whether Business rule is updated'
            );

            CustomAlertRecommendations.getRecommendationsActionByRuleId(bRuleUpdated[0].Id);
            BusinessRules.businessRuleDeleteBefore(bRuleUpdated);
            BusinessRules.businessRuleDeleteAfter();

            Test.stopTest();
        }
    }

    @isTest
    static void testgetIndustryPicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String data = BusinessRules.getIndustryPicklistValues();
            system.assertEquals(data.contains('Agriculture'), true, 'Check Industry picklist values');
        }
    }

    @isTest
    static void testgetOptyTypePicklistValues() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            String data = BusinessRules.getOptyTypePicklistValues();
            system.assertEquals(data.contains('New Customer'), true, 'Check Type picklist values');
        }
    }

    @isTest
    static void testgetActionAlertDetails() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();

            List<Business_Rules__c> brList = TestDataUtil.createBusinessRulesRecords(false);
            brList[0].Business_Rule_Name__c = 'Opportunity Business Rule 1';
            brList[0].Business_Rule_Catagory__c = 'Opportunity';
            brList[0].is_closed_date_past__c = true;
            brList[1].Business_Rule_Name__c = 'Opportunity Business Rule 2';
            brList[1].Business_Rule_Catagory__c = 'Opportunity';
            brList[1].is_closed_date_past__c = true;
            insert brList;

            List<Business_Rules__c> bsRule = [SELECT Id, name, Business_Rule_Name__c FROM Business_Rules__c LIMIT 1];

            Alert_Template__c at = new Alert_Template__c();
            at.Alert_Type__c = 'Action';
            at.BestActionRuleId__c = 'BAL_4';
            at.Default_Alert_Email_Header__c = 'Test header default';
            at.Default_Alert_Email_Text__c = 'Test msg custom';
            at.Custom_Alert_Email_Header__c = 'Test header default';
            at.Custom_Alert_Email_Text__c = 'Test msg custom';
            at.Is_Alert_Enabled__c = true;
            at.Override_Alert_Email_Header__c = true;
            at.Override_Alert_Email_Text__c = true;
            insert at;

            List<Alert_Template__c> alertTemplateList = [
                SELECT
                    Id,
                    Name,
                    Alert_Type__c,
                    BestActionRuleId__c,
                    Custom_Alert_Email_Header__c,
                    Custom_Alert_Email_Text__c,
                    Default_Alert_Email_Header__c,
                    Default_Alert_Email_Text__c,
                    Is_Alert_Enabled__c,
                    Override_Alert_Email_Header__c,
                    Override_Alert_Email_Text__c,
                    URL_Link__c,
                    URL_Text__c
                FROM Alert_Template__c
                WHERE BestActionRuleId__c = 'BAL_4' AND Alert_Type__c = 'Action'
            ];

            Alert_Recommendation__c arRec = new Alert_Recommendation__c();
            arRec.Action_Alert__c = alertTemplateList[0].Id;
            arRec.BestActionRuleId__c = 'BAL_4';
            arRec.Business_Rules__c = bsRule[0].Id;
            insert arRec;

            List<Alert_Recommendation__c> alertRecommList = [
                SELECT
                    Id,
                    Name,
                    Action_Alert__c,
                    BestActionRuleId__c,
                    Business_Rules__c,
                    Manager_Email_Alert__c,
                    Seller_Email_Alert__c
                FROM Alert_Recommendation__c
                WHERE BestActionRuleId__c = 'BAL_4'
            ];

            List<AlertTemplateWrapper> alertWrapperList = BusinessRules.getActionAlertDetails(bsRule[0].Id);
            System.assertEquals(alertRecommList.size() > 0, true, 'Check size of alert recommendation list');
            Test.stopTest();
        }
    }

    @isTest
    static void testUpsertBusinessRuleForPerspective() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            List<Business_Rules__c> brList = TestDataUtil.createBusinessRulesRecords(false);
            brList[0].Business_Rule_Name__c = 'Perspective Business Rule 1';
            brList[0].Business_Rule_Catagory__c = 'Perspective';
            brList[1].Business_Rule_Name__c = 'Perspective Business Rule 2';
            brList[1].Business_Rule_Catagory__c = 'Perspective';
            insert brList;

            List<Business_Rules__c> bRule = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Perspective'
            ];

            List<Insight_Alert__c> alertPersp = TestDataUtil.createInsightAlertPerspective(bRule, true);
            List<Insight_Alert__c> alert = [
                SELECT Id, Business_Rules__c, Insights__c, Insights_Link__c, Industry__c, Opportunity_Type__c
                FROM Insight_Alert__c
                WHERE Business_Rules__c = :bRule[0].Id
            ];

            map<String, Object> insightObjectPersp = new Map<String, Object>();
            insightObjectPersp.put('insights', 'test insights');
            insightObjectPersp.put('insightsLink', 'test insights link');
            insightObjectPersp.put('industry', 'Agriculture');
            insightObjectPersp.put('optyType', 'New Customer');
            insightObjectPersp.put('id', alert[0].Id);

            map<String, Object> newmap = new Map<String, Object>();
            newmap.put('brName', 'test business rule Perspective');
            newmap.put('isActive', true);
            newmap.put('brCategory', 'Perspective');
            newmap.put('id', bRule[0].Id);
            newmap.put('customPerspectiveInsights', insightObjectPersp);

            String jsonstring = JSON.Serialize(newmap);
            List<Business_Rules__c> br = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Perspective'
            ];
            Map<String, Object> wrapper = BusinessRules.upsertBusinessRule(jsonstring);
            List<Business_Rules__c> br1 = [
                SELECT Id, name, Business_Rule_Name__c
                FROM Business_Rules__c
                WHERE Business_Rule_Catagory__c = 'Perspective'
            ];
            System.assertEquals(br.size(), 2, 'Checking Size of Business Rules');
            System.assertEquals(br1.size(), 2, 'Checking Size of Business Rules');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetRecommendationsAction() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
            String balId = 'BAL_1';
            AlertRecommendationsWrapper dataWrapper = CustomAlertRecommendations.getRecommendationsAction(balId);
            System.assertEquals(dataWrapper != null, true, 'Check alert recommendation in database');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetDefaultAlerts() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            Test.startTest();
            ManageBusinessRulesAlertMessages insertBusinessRulesMsg = new ManageBusinessRulesAlertMessages();
            insertBusinessRulesMsg.insertBusinessRulesMessages();
            String balId = 'BAL_1';
            String alertType = 'Manager Email';
            AlertRecommendationsWrapper dataWrapper = CustomAlertRecommendations.getDefaultAlerts(balId);
            alertType = 'Seller Email';
            AlertRecommendationsWrapper dataWrapperSeller = CustomAlertRecommendations.getDefaultAlerts(balId);
            alertType = 'Action';
            AlertRecommendationsWrapper dataWrapperAction = CustomAlertRecommendations.getDefaultAlerts(balId);
            System.assertEquals(dataWrapper != null, true, 'Check alert recommendation in database');
            Test.stopTest();
        }
    }
}