public with sharing class InsightsAlertRecommendations {
    @AuraEnabled
    public static void upsertCustomInsightsAlerts(
        InsightAlertsWrapper insightWrapper,
        Id businessRulesId,
        String category
    ) {
        try {
            List<Database.SaveResult> srList;
            Insight_Alert__c insightAlert = new Insight_Alert__c();
            insightAlert.Insights__c = insightWrapper.insights;
            insightAlert.Insights_Link__c = insightWrapper.insightsLink;
            insightAlert.Industry__c = insightWrapper.industry;
            insightAlert.Display_Link_As__c = insightWrapper.displayLinkAs;
            insightAlert.Opportunity_Type__c = insightWrapper.optyType;
            insightAlert.Business_Rules__c = businessRulesId;
            insightAlert.Business_Rule_Category__c = category;
            insightAlert.Competitor__c = insightWrapper.accountId;

            if (insightWrapper.id == '' || insightWrapper.id == null) {
                srList = DataFactory.create(insightAlert);
            } else {
                insightAlert.Id = insightWrapper.id;
                srList = DataFactory.modify(insightAlert);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line in insight alert save----' + ex.getLineNumber());
            throw new PerspectiveInsightsException('Error occured while saving ' + category + ' Insights data', ex);
        }
    }

    @AuraEnabled
    public static Map<String, InsightAlertsWrapper> getCustomInsightAlerts(String brId, String ruleCategory) {
        List<Insight_Alert__c> insightAlertsList = new List<Insight_Alert__c>();
        Map<String, InsightAlertsWrapper> insightAlertsListWrapperMap = new Map<String, InsightAlertsWrapper>();
        try {
            String insightAlertsQuery = ' Select Id,Name,Insights__c,Insights_Link__c,Competitor__c,Competitor__r.Name,Business_Rules__c,Business_Rule_Category__c,Opportunity_Type__c,Display_Link_As__c,Industry__c FROM Insight_Alert__c WHERE Business_Rules__c=:brId AND Business_Rule_Category__c=:ruleCategory';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('brId', brId);
            paramters.put('ruleCategory', ruleCategory);
            insightAlertsList = DataFactory.read(insightAlertsQuery, paramters);
            for (Insight_Alert__c alert : insightAlertsList) {
                InsightAlertsWrapper insightWrapper = new InsightAlertsWrapper(alert);
                insightAlertsListWrapperMap.put(alert.Business_Rules__c, insightWrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new InsightsException('Error occured while getting data from Insight Alerts for Competitor');
        }
        return insightAlertsListWrapperMap;
    }

    @AuraEnabled
    public static List<InsightsWrapper> getInsights(String bluesheetId, String ruleCategory) {
        List<Insight__c> insightsList = new List<Insight__c>();
        List<InsightsWrapper> insightsWrapperList = new List<InsightsWrapper>();
        try {
            ruleCategory = ruleCategory.replace('\"', '');
            String insightsQuery = ' SELECT Id, Name, Blue_Sheet__c, Business_Rules__c, Competition__c, Insight_Alert__c, Insight_Alert__r.Insights__c, Insight_Alert__r.Insights_Link__c,Insight_Alert__r.Display_Link_As__c, Insight_Alert__r.Competitor__c, Insight_Alert__r.Business_Rule_Category__c, Opportunity__c FROM Insight__c WHERE Blue_Sheet__c=:bluesheetId AND Insight_Alert__r.Business_Rule_Category__c=:ruleCategory';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('bluesheetId', bluesheetId);
            paramters.put('ruleCategory', ruleCategory);
            insightsList = DataFactory.read(insightsQuery, paramters);
            for (Insight__c insight : insightsList) {
                InsightsWrapper insightWrapper = new InsightsWrapper(insight);
                insightsWrapperList.add(insightWrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new InsightsException('Error occured while getting data from Insights for ' + ruleCategory);
        }
        return insightsWrapperList;
    }

    public static void deleteInsightsForCompetition(List<Competition__c> competitions) {
        Set<Id> recordIds = new Set<Id>();
        for (Competition__c comp : competitions) {
            recordIds.add(comp.Id);
        }

        String soql = 'SELECT Id,Name,Competition__c from Insight__c WHERE Competition__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<Insight__c> insightsList = DataFactory.read(soql, soqlParamMap);

        if (!insightsList.isEmpty()) {
            DataFactory.remove(insightsList);
        }
    }

    public static void deleteInsightsForActionPlan(List<Blue_Sheet__c> actionPlan) {
        Set<Id> recordIds = new Set<Id>();
        for (Blue_Sheet__c comp : actionPlan) {
            recordIds.add(comp.Id);
        }
        String soql = 'SELECT Id,Name from Insight__c WHERE Blue_Sheet__c IN: recordIds AND Competition__c = null';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<Insight__c> insightsList = DataFactory.read(soql, soqlParamMap);
        if (!insightsList.isEmpty()) {
            DataFactory.remove(insightsList);
        }
    }

    private class PerspectiveInsightsException extends Exception {
    }
    private class CompetitorInsightsException extends Exception {
    }
    private class InsightsException extends Exception {
    }
}