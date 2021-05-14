public with sharing class ActionPlanRulesEvaluator implements RulesEvaluator {
    private Map<String, Set<String>> brGrpIdAndMembers;
    public static Boolean ActionPlanRulesEvaluatorInsertFlag = true;
    public static Boolean ActionPlanRulesEvaluatorUpdateFlag = true;
    public ActionPlanRulesEvaluator() {
        brGrpIdAndMembers = RulesEvaluationUtil.getBRGrpMembers();
    }

    public void evaluate(set<String> objectIds) {
        Set<String> opptyIds = getOpportunityIdsFromBluesheet(objectIds);
        executeActionPlanCategoryRules(opptyIds);
    }

    public Set<String> getOpportunityIdsFromBluesheet(Set<String> bluesheetIds) {
        Set<String> opportunityIds = new Set<String>();
        String soql = 'SELECT ID,Name,Opportunity__c FROM Blue_Sheet__c WHERE Id IN:bluesheetIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('bluesheetIds', bluesheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(soql, soqlParamMap);
        for (Blue_Sheet__c bs : bluesheetList) {
            opportunityIds.add(bs.Opportunity__c);
        }
        return opportunityIds;
    }

    private void executeActionPlanCategoryRules(Set<String> oppIds) {
        Map<Id, Opportunity> oppsMap = ApexCommonUtil.getOpportunityRecord(oppIds);

        List<Opportunity> opportunities = oppsMap.values();
        List<Business_Rules__c> listBusinessRules = new List<Business_Rules__c>();
        Map<String, List<Business_Rules__c>> businessRuleMap = RulesEvaluationUtil.getBusinessRules();
        listBusinessRules = !businessRuleMap.isEmpty() ? businessRuleMap.get('Perspective') : null;
        if (listBusinessRules != null && !listBusinessRules.isEmpty()) {
            List<Insight__c> listInsightsToInsert = new List<Insight__c>();
            List<Insight__c> listInsightsToUpdate = new List<Insight__c>();

            Set<String> opportunityIds = (Set<String>) JSON.deserialize(
                JSON.serialize(oppsMap.keySet()),
                Set<String>.class
            );
            Map<String, List<Blue_Sheet__c>> competitorMap = getActionPlan(opportunityIds);
            List<Blue_Sheet__c> competitors = new List<Blue_Sheet__c>();
            for (String optyId : competitorMap.keyset()) {
                competitors.addAll(competitorMap.get(optyId));
            }

            Set<String> brIds = new Set<String>();
            for (Business_Rules__c brObj : listBusinessRules) {
                brIds.add(brObj.Id);
            }

            String soqlInsightALert = 'SELECT ID,Name,Business_Rules__c,Competitor__c,Insights__c,Insights_Link__c, Opportunity_Type__c,Industry__c  FROM Insight_Alert__c WHERE Business_Rules__c IN:brIds';
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('brIds', brIds);
            List<Insight_Alert__c> insightAlertList = DataFactory.read(soqlInsightALert, soqlParamMap);

            Map<String, String> brCompIdMap = getBRCompIdMap(insightAlertList);
            Map<String, Insight_Alert__c> brInsightAlertMap = getInsightAlertBRMap(insightAlertList);

            Map<Id, List<Insight__c>> allInsightsMap = new Map<Id, List<Insight__c>>();
            allInsightsMap = RulesEvaluationUtil.getAllInsights(opportunityIds);
            List<Insight__c> insightsForBR = new List<Insight__c>();
            RulesEngineConfig.RuleParams ruleParameter = new RulesEngineConfig.RuleParams()
                .setAllInsightsMap(allInsightsMap)
                .setInsightsLstToInsert(listInsightsToInsert)
                .setInsightsLstToUpdate(listInsightsToUpdate)
                .setOpportunityMap(oppsMap)
                .setBRCompIdMap(brCompIdMap)
                .setInsightAlertBRMap(brInsightAlertMap);

            for (Blue_Sheet__c card : competitors) {
                Opportunity opportunity = ruleParameter.oppsMap.get(card.Opportunity__c);
                for (Business_Rules__c brObj : listBusinessRules) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                        insightsForBR = ruleParameter.allInsightsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj).setInsightsList(insightsForBR);
                        executeActionPlanRule(ruleParameter, card, opportunity);
                    }
                }
            }
            RulesEvaluationUtil.upsertInsights(ruleParameter);
        }
    }

    public Map<String, List<Blue_Sheet__c>> getActionPlan(Set<String> oppIds) {
        Map<String, List<Blue_Sheet__c>> mapActionPlanWithParentId = new Map<String, List<Blue_Sheet__c>>();
        String actionPlanQuery =
            'SELECT Id,Name,Opportunity__c' + ' FROM Blue_Sheet__c WHERE Opportunity__c IN :oppIds';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIds', oppIds);
        List<Blue_Sheet__c> actionPlanList = DataFactory.read(actionPlanQuery, parameters);
        for (Blue_Sheet__c card : actionPlanList) {
            if (!mapActionPlanWithParentId.containsKey(card.Opportunity__c)) {
                mapActionPlanWithParentId.put(card.Opportunity__c, new List<Blue_Sheet__c>{ card });
            } else {
                mapActionPlanWithParentId.get(card.Opportunity__c).add(card);
            }
        }
        return mapActionPlanWithParentId;
    }

    public void executeActionPlanRule(
        RulesEngineConfig.RuleParams ruleParameters,
        Blue_Sheet__c actionPlan,
        Opportunity opportunity
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        Map<String, String> brCompIdMap = ruleParameters.brCompIdMap;
        Map<String, Insight_Alert__c> brInsightAlertMap = ruleParameters.brInsightAlertMap;
        Boolean showInsight = false;
        String opportunityAccountIndustry = opportunity != null &&
            opportunity.Account != null &&
            opportunity.Account.Industry != null
            ? opportunity.Account.Industry
            : null;
        String alertIndustry = brInsightAlertMap.get(ruleParameters.brObj.Id) != null &&
            brInsightAlertMap.get(ruleParameters.brObj.Id).Industry__c != null
            ? brInsightAlertMap.get(ruleParameters.brObj.Id).Industry__c
            : null;
        if (
            brCompIdMap.get(ruleParameters.brObj.Id) == opportunity.Type &&
            opportunityAccountIndustry != null &&
            alertIndustry != null &&
            alertIndustry == opportunityAccountIndustry
        ) {
            showInsight = true;
        }

        if (
            showInsight == true && RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, opportunity.StageName)
        ) {
            String busRuleId = ruleParameters.brObj.Id;
            Insight_Alert__c insightAlertObj = brInsightAlertMap.get(busRuleId);
            Insight__c insightRec = getInsightRec(actionPlan.Id, ruleParameters.insightsList, ruleParameters.brObj.Id);
            if (insightRec == null) {
                insightRec = new Insight__c();
            }
            insightRec.Business_Rules__c = ruleParameters.brObj.Id;
            insightRec.Opportunity__c = actionPlan.Opportunity__c;
            insightRec.Blue_Sheet__c = actionPlan.Id;
            insightRec.Insight_Alert__c = insightAlertObj.Id;
            ruleParameters.listInsightsToInsert.add(insightRec);
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String busRuleId = ruleParameters.brObj.Id;
            Insight_Alert__c insightAlertObj = brInsightAlertMap.get(busRuleId);
            ruleParameters = emptyInsightRecords(ruleParameters, busRuleId, actionPlan.Id);
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private RulesEngineConfig.RuleParams emptyInsightRecords(
        RulesEngineConfig.RuleParams ruleParameters,
        String busRuleId,
        Id recId
    ) {
        Insight__c insightRec = getInsightRec(recId, ruleParameters.insightsList, ruleParameters.brObj.Id);
        if (insightRec != null) {
            insightRec = RulesEvaluationUtil.mappingInsightFieldsToEmpty(insightRec);
            ruleParameters.listInsightsToUpdate.add(insightRec);
        }
        return ruleParameters;
    }

    //FIX-ME
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static Insight__c getInsightRec(String actionPlanId, List<Insight__c> insightsList, String businessRuleId) {
        Insight__c insightObj;
        if (insightsList != null && !insightsList.isEmpty()) {
            for (Insight__c insight : insightsList) {
                if (insight.Business_Rules__c == businessRuleId && insight.Blue_Sheet__c == actionPlanId) {
                    insightObj = insight;
                }
            }
        }
        return insightObj;
    }

    public Map<String, String> getBRCompIdMap(List<Insight_Alert__c> insightAlertList) {
        Map<String, String> brCompIdMap = new Map<String, String>();
        for (Insight_Alert__c alertObj : insightAlertList) {
            brCompIdMap.put(alertObj.Business_Rules__c, alertObj.Opportunity_Type__c);
        }
        return brCompIdMap;
    }

    public Map<String, Insight_Alert__c> getInsightAlertBRMap(List<Insight_Alert__c> insightAlertList) {
        Map<String, Insight_Alert__c> brInsightAlertMap = new Map<String, Insight_Alert__c>();
        for (Insight_Alert__c alertObj : insightAlertList) {
            brInsightAlertMap.put(alertObj.Business_Rules__c, alertObj);
        }
        return brInsightAlertMap;
    }
}