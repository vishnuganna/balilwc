@isTest
public with sharing class CustomAlertRecommendationsTest {
    @testSetup
    static void setup() {
        User user = UserTest.createUserWithPerms();
    }

    // @isTest
    // static void upsertCustomAlertRecordTest() {
    //     map<String, Object> newmap = new Map<String, Object>();
    //     newmap.put('brName', 'Business Rule');
    //     newmap.put('isActive', true);
    //     newmap.put('brCategory', 'Opportunity');
    //     newmap.put('globalOptyStage', 'Closed Lost');
    //     newmap.put('isClosedDatePast', true);
    //     newmap.put('isClosedDatePast', true);
    //     map<String, Object> customRecommendationAction = new Map<String, Object>();
    //     map<String, Object> action = new Map<String, Object>();
    //     action.put('balId', 'BAL_4');
    //     action.put('alertEnabled', true);
    //     action.put('customAlertHeader', 'Custom Header');
    //     action.put('customAlertMessage', 'Custom Text');
    //     action.put('defaultAlertHeader', 'Default Alert header data');
    //     action.put('defaultAlertMessage', 'Default Alert Text data');
    //     action.put('overrideHeader', true);
    //     action.put('overrideMessage', true);
    //     customRecommendationAction.put('balId', 'BAL_4');
    //     customRecommendationAction.put('action', action);
    //     newmap.put('customRecommendationAction', customRecommendationAction);
    //     String jsonsObjecttringUpdate = JSON.Serialize(newmap);
    //     Map<String, Object> dataReturn = BusinessRules.upsertBusinessRule(jsonsObjecttringUpdate);
    //     String statusUpdate = (String) dataReturn.get('status');
    //     system.assertEquals(statusUpdate, 'Success');

    //     //check for Update
    //     Business_Rules__c businessRuleUpdate = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
    //     map<String, Object> newmapUpdate = new Map<String, Object>();
    //     newmapUpdate.put('id', businessRuleUpdate.Id);
    //     newmapUpdate.put('brName', 'Business Rule');
    //     newmapUpdate.put('isActive', true);
    //     newmapUpdate.put('brCategory', 'Opportunity');
    //     newmapUpdate.put('globalOptyStage', 'Closed Lost');
    //     newmapUpdate.put('isClosedDatePast', true);
    //     newmapUpdate.put('isClosedDatePast', true);
    //     map<String, Object> customRecommendationActionUpdate = new Map<String, Object>();
    //     map<String, Object> actionUpdate = new Map<String, Object>();
    //     actionUpdate.put('balId', 'BAL_4');
    //     actionUpdate.put('alertEnabled', true);
    //     actionUpdate.put('customAlertHeader', 'Custom Header');
    //     actionUpdate.put('customAlertMessage', 'Custom Text');
    //     actionUpdate.put('defaultAlertHeader', 'Default Alert header data');
    //     actionUpdate.put('defaultAlertMessage', 'Default Alert Text data');
    //     actionUpdate.put('overrideHeader', true);
    //     actionUpdate.put('overrideMessage', true);
    //     customRecommendationActionUpdate.put('balId', 'BAL_4');
    //     customRecommendationActionUpdate.put('action', actionUpdate);
    //     newmapUpdate.put('customRecommendationAction', customRecommendationActionUpdate);
    //     String jsonsObjecttring = JSON.Serialize(newmapUpdate);
    //     Map<String, Object> dataRetunrn = BusinessRules.upsertBusinessRule(jsonsObjecttring);
    //     String status = (String) dataRetunrn.get('status');
    //     system.assertEquals(status, 'Success');
    // }

    // @isTest
    // static void getCustomAlertRecordTest() {
    //     map<String, Object> newmap = new Map<String, Object>();
    //     newmap.put('brName', 'Business Rule');
    //     newmap.put('isActive', true);
    //     newmap.put('brCategory', 'Opportunity');
    //     newmap.put('globalOptyStage', 'Closed Lost');
    //     newmap.put('isClosedDatePast', true);
    //     newmap.put('isClosedDatePast', true);
    //     map<String, Object> customRecommendationAction = new Map<String, Object>();
    //     map<String, Object> action = new Map<String, Object>();
    //     action.put('balId', 'BAL_4');
    //     action.put('alertEnabled', true);
    //     action.put('customAlertHeader', 'Custom Header');
    //     action.put('customAlertMessage', 'Custom Text');
    //     action.put('defaultAlertHeader', 'Default Alert header data');
    //     action.put('defaultAlertMessage', 'Default Alert Text data');
    //     action.put('overrideHeader', true);
    //     action.put('overrideMessage', true);
    //     customRecommendationAction.put('balId', 'BAL_4');
    //     customRecommendationAction.put('action', action);
    //     newmap.put('customRecommendationAction', customRecommendationAction);
    //     String jsonsObjecttring = JSON.Serialize(newmap);
    //     Map<String, Object> dataRetunrn = BusinessRules.upsertBusinessRule(jsonsObjecttring);
    //     Business_Rules__c businessRule = [SELECT Id, Name FROM Business_Rules__c LIMIT 1];
    //     AlertRecommendationsWrapper alertRecomDataRetunrn = CustomAlertRecommendations.getRecommendationsActionByRuleId(
    //         businessRule.Id
    //     );
    //     system.assert(alertRecomDataRetunrn != null);
    //     system.assertEquals(alertRecomDataRetunrn.action.overrideMessage, true);
    //     system.assertEquals(alertRecomDataRetunrn.action.defaultAlertMessage, 'Default Alert Text data');
    // }

    // @isTest
    // static void getRecommendationsActionTest() {
    //     AlertRecommendationsWrapper data = CustomAlertRecommendations.getRecommendationsAction('BAL_4');
    //     system.assertEquals(data, null);
    // }
}