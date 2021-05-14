@isTest
public with sharing class BluesheetPromptsMessagesTest {
    @isTest
    static void testGetModulePromptsMessages() {
        User user = UserTest.createUserWithPerms();
        System.runAs(user) {
            BluesheetPromptsMessages.MessagesWrapper messageData;
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('SummaryOfMyPosition');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('CustomerStatedObjective');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('SingleSalesObjective');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('CurrentPosition');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('BuyingInfluence');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('BuyingInfluenceCoach');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('BuyingInfluenceDegree');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('BuyingInfluenceMode');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('BuyingInfluenceRatings');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('Scorecard');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('BuyingInfluenceWinsOrResults');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('CompetitivePreference');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('MyPositionVsCompetitor');
            messageData = BluesheetPromptsMessages.getModulePromptsMessages('StrengthRedFlag');
            System.assertEquals(messageData != null, true, 'Prompts are not null');
        }
    }
}