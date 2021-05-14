public with sharing class BluesheetPromptsMessages {
    public class MessagesWrapper {
        @AuraEnabled
        public String entryMessage { get; set; }
        @AuraEnabled
        public String exitMessage { get; set; }
    }

    @AuraEnabled
    public static MessagesWrapper getModulePromptsMessages(String moduleSection) {
        MessagesWrapper messageData;
        switch on moduleSection {
            when 'SummaryOfMyPosition' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptSOMP;
                messageData.exitMessage = System.Label.ExitPromptSOMP;
            }
            when 'CustomerStatedObjective' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptCSO;
                messageData.exitMessage = System.Label.ExitPromptCSO;
            }
            when 'SingleSalesObjective' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.ExitPromptSSO;
                messageData.exitMessage = System.Label.ExitPromptSSO;
            }
            when 'CurrentPosition' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptCP;
                messageData.exitMessage = System.Label.ExitPromptCP;
            }
            when 'BuyingInfluence' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptBI;
                messageData.exitMessage = System.Label.ExitPromptBI;
            }
            when 'BuyingInfluenceCoach' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptBICoach;
                messageData.exitMessage = System.Label.ExitPromptBICoach;
            }
            when 'BuyingInfluenceDegree' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptBIDegree;
                messageData.exitMessage = System.Label.ExitPromptBIDegree;
            }
            when 'BuyingInfluenceMode' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptBIModes;
                messageData.exitMessage = System.Label.ExitPromptBIModes;
            }
            when 'BuyingInfluenceRatings' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptRatings;
                messageData.exitMessage = System.Label.ExitPromptRatings;
            }
            when 'Scorecard' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptOppScorecard;
                messageData.exitMessage = System.Label.ExitPromptOppScorecard;
            }
            when 'BuyingInfluenceWinsOrResults' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptWinResults;
                messageData.exitMessage = System.Label.ExitPromptWinResults;
            }
            when 'CompetitivePreference' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptCompAltPref;
                messageData.exitMessage = System.Label.ExitPromptCompAltPref;
            }
            when 'MyPositionVsCompetitor' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptPosComp;
                messageData.exitMessage = System.Label.ExitPrompPosComp;
            }
            when 'StrengthRedFlag' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptSompos;
                messageData.exitMessage = System.Label.ExitPromptSompos;
            }
            when 'ActionPlan' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptStratToAct;
                messageData.exitMessage = System.Label.ExitPromptStratToAct;
            }
            when 'ActionPlanStrategicAnalysis' {
                messageData = new MessagesWrapper();
                messageData.entryMessage = System.Label.EntryPromptStratAnalysis;
                messageData.exitMessage = System.Label.ExitPromptStratAnalysis;
            }
        }
        return messageData;
    }
}