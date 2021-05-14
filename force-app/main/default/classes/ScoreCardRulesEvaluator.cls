@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public with sharing class ScoreCardRulesEvaluator implements RulesEvaluator {
    private Map<String, Set<String>> brGrpIdAndMembers;
    public static Boolean ScorecardRulesEvaluatorInsertFlag = true;
    public static Boolean ScorecardRulesEvaluatorUpdateFlag = true;

    public ScoreCardRulesEvaluator() {
        brGrpIdAndMembers = RulesEvaluationUtil.getBRGrpMembers();
    }
    public void evaluate(set<String> objectIds) {
        Set<String> opptyIds = getOpportunityIdsFromBluesheet(objectIds);
        executeAllScoreCardRules(opptyIds);
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

    private void executeAllScoreCardRules(Set<String> oppIds) {
        Map<Id, Opportunity> oppsMap = ApexCommonUtil.getOpportunityRecord(oppIds);

        List<Opportunity> opportunities = oppsMap.values();
        List<Business_Rules__c> listBusinessRules = new List<Business_Rules__c>();
        Map<String, List<Business_Rules__c>> businessRuleMap = RulesEvaluationUtil.getBusinessRules();
        listBusinessRules = !businessRuleMap.isEmpty() ? businessRuleMap.get('Scorecard') : null;
        if (listBusinessRules != null && !listBusinessRules.isEmpty()) {
            List<KF_sell_best__c> listBestActionsToInsert = new List<KF_sell_best__c>();
            List<KF_sell_best__c> listBestActionsToUpdate = new List<KF_sell_best__c>();
            // Map<String, RecommendationsActionWrapper> mapRuleMSg = new RecommendationsActionMessages()
            //     .getRecommendationsActionMessages();
            Map<String, List<AlertRecommendationsWrapper>> mapRuleMSg = new AlertRecommendationsMessages()
                .getAlertRecommendations();

            Map<String, List<String>> BALandBRIdMap = new Map<String, List<String>>();
            if (mapRuleMSg != null && !mapRuleMSg.isEmpty()) {
                for (String ruleId : mapRuleMSg.keySet()) {
                    List<AlertRecommendationsWrapper> arList = mapRuleMSg.get(ruleId);
                    for (AlertRecommendationsWrapper alert : arList) {
                        if (alert.businessRulesId != null) {
                            if (BALandBRIdMap.containsKey(ruleId)) {
                                BALandBRIdMap.get(ruleId).add(alert.businessRulesId);
                            } else {
                                BALandBRIdMap.put(ruleId, new List<String>{ alert.businessRulesId });
                            }
                        }
                    }
                }
            }

            Set<String> opportunityIds = (Set<String>) JSON.deserialize(
                JSON.serialize(oppsMap.keySet()),
                Set<String>.class
            );
            Map<String, List<Score_Card__c>> scoreCardMap = getScoreCards(opportunityIds);
            List<Score_Card__c> scoreCards = new List<Score_Card__c>();
            for (String optyId : scoreCardMap.keyset()) {
                scoreCards.addAll(scoreCardMap.get(optyId));
            }
            Map<Id, List<KF_sell_best__c>> allBestActions = new Map<Id, List<KF_sell_best__c>>();
            allBestActions = RulesEvaluationUtil.getAllBestActions(opportunityIds);
            List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
            RulesEngineConfig.RuleParams ruleParameter = new RulesEngineConfig.RuleParams()
                .setAllBestActionsMap(allBestActions)
                .setBestActionLstToInsert(listBestActionsToInsert)
                .setBestActionLstToUpdate(listBestActionsToUpdate)
                .setMapRuleMSg(mapRuleMSg)
                .setOpportunityMap(oppsMap)
                .setBusinessRules(businessRuleMap)
                .setBalIdBrIdMap(BALandBRIdMap);

            for (Score_Card__c card : scoreCards) {
                Opportunity opportunity = ruleParameter.oppsMap.get(card.Blue_Sheet__r.Opportunity__c);
                for (Business_Rules__c brObj : listBusinessRules) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj)
                            .setBestActionList(bestActionsForBR)
                            .setOpportunityRec(opportunity);

                        executeScoreCardRule14(ruleParameter, card);
                        executeScoreCardRule15(ruleParameter, card);
                        executeScoreCardRule16(ruleParameter, card);
                        executeScoreCardRule17(ruleParameter, card);
                    }
                }
            }
            RulesEvaluationUtil.upsertBestActions(ruleParameter);
        }
    }

    public void executeScoreCardRule14(RulesEngineConfig.RuleParams ruleParameters, Score_Card__c scoreCard) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        Datetime cardLastModDate = scoreCard.LastModifiedDate;
        Date scoreCardLastModDate;
        if (cardLastModDate != null) {
            scoreCardLastModDate = Date.newinstance(
                cardLastModDate.year(),
                cardLastModDate.month(),
                cardLastModDate.day()
            );
        }
        Date todayDt1 = Date.today();
        if (
            ruleParameters.brObj.Check_Scorecard_Last_Modified__c == true &&
            ruleParameters.brObj.Scorecard_Number_of_Days_Updated__c != null &&
            scoreCardLastModDate.daysBetween(todayDt1) > ruleParameters.brObj.Scorecard_Number_of_Days_Updated__c &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            String balRuleId = 'BAL_14';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
            if (messageActionWrapperList != null && !messageActionWrapperList.isEmpty()) {
                List<String> businessRuleIds = ruleParameters.BALandBRIdMap.get(balRuleId);
                AlertRecommendationsWrapper arwrap = null;
                if (
                    businessRuleIds == null || businessRuleIds.isEmpty() ||
                    !businessRuleIds.contains(ruleParameters.brObj.Id)
                ) {
                    // standard only
                    arwrap = getStandardAlertRecommendationsWrapper(messageActionWrapperList);
                } else if (businessRuleIds.contains(ruleParameters.brObj.Id)) {
                    arwrap = getMatchedAlertRecommendationsRec(messageActionWrapperList, ruleParameters.brObj.Id);
                }
                KF_Sell_Best__c bestActionRec = getBestActionRec(
                    scoreCard.Id,
                    ruleParameters.allBestActions,
                    ruleParameters.brObj.Id,
                    balRuleId
                );
                if (bestActionRec == null) {
                    bestActionRec = new KF_Sell_Best__c();
                }
                bestActionRec = RulesEvaluationUtil.mappingBestActionRecordFields(
                    ruleParameters.brObj,
                    arwrap,
                    balRuleId,
                    bestActionRec
                );
                AlertTemplateWrapper managerEmailAlert;
                if (arwrap != null && arwrap.managerEmail != null) {
                    managerEmailAlert = arwrap.managerEmail;
                    if (managerEmailAlert.urlText != null) {
                        String msg = managerEmailAlert.urlText;
                        String oppOwnerName = ruleParameters.opportunity.Owner.Name;
                        msg = msg.replace('{sellerName}', oppOwnerName);
                        bestActionRec.Manager_URL_Text__c = msg;
                    }
                }
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                bestActionRec.Score_Card__c = scoreCard.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_14';
            ruleParameters = emptyScoreCardBestActions(ruleParameters, balRuleId, scoreCard.Id);
        }
    }

    public void executeScoreCardRule15(RulesEngineConfig.RuleParams ruleParameters, Score_Card__c scoreCard) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            ruleParameters.brObj.Check_Total_Score__c == true &&
            ruleParameters.brObj.Minimum_Score__c != null &&
            scoreCard.Total_Score__c >= ruleParameters.brObj.Minimum_Score__c &&
            ruleParameters.brObj.Maximum_Score__c != null &&
            scoreCard.Total_Score__c <= ruleParameters.brObj.Maximum_Score__c &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            String balRuleId = 'BAL_15';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
            if (messageActionWrapperList != null && !messageActionWrapperList.isEmpty()) {
                List<String> businessRuleIds = ruleParameters.BALandBRIdMap.get(balRuleId);
                AlertRecommendationsWrapper arwrap = null;
                if (
                    businessRuleIds == null || businessRuleIds.isEmpty() ||
                    !businessRuleIds.contains(ruleParameters.brObj.Id)
                ) {
                    // standard only
                    arwrap = getStandardAlertRecommendationsWrapper(messageActionWrapperList);
                } else if (businessRuleIds.contains(ruleParameters.brObj.Id)) {
                    arwrap = getMatchedAlertRecommendationsRec(messageActionWrapperList, ruleParameters.brObj.Id);
                }
                KF_Sell_Best__c bestActionRec = getBestActionRec(
                    scoreCard.Id,
                    ruleParameters.allBestActions,
                    ruleParameters.brObj.Id,
                    balRuleId
                );
                if (bestActionRec == null) {
                    bestActionRec = new KF_Sell_Best__c();
                }
                bestActionRec = RulesEvaluationUtil.mappingBestActionRecordFields(
                    ruleParameters.brObj,
                    arwrap,
                    balRuleId,
                    bestActionRec
                );
                AlertTemplateWrapper managerEmailAlert;
                if (arwrap != null && arwrap.managerEmail != null) {
                    managerEmailAlert = arwrap.managerEmail;
                    if (managerEmailAlert.urlText != null) {
                        String msg = managerEmailAlert.urlText;
                        String oppOwnerName = ruleParameters.opportunity.Owner.Name;
                        msg = msg.replace('{sellerName}', oppOwnerName);
                        bestActionRec.Manager_URL_Text__c = msg;
                    }
                }
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                bestActionRec.Score_Card__c = scoreCard.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_15';
            ruleParameters = emptyScoreCardBestActions(ruleParameters, balRuleId, scoreCard.Id);
        }
    }

    public void executeScoreCardRule16(RulesEngineConfig.RuleParams ruleParameters, Score_Card__c scoreCard) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            ruleParameters.brObj.Check_Opportunity_Score__c == true &&
            ruleParameters.brObj.OpportunityCriteria_Minimum_Score__c != null &&
            scoreCard.OpportunityCriteria_Score__c >= ruleParameters.brObj.OpportunityCriteria_Minimum_Score__c &&
            ruleParameters.brObj.OpportunityCriteria_Maximum_Score__c != null &&
            scoreCard.OpportunityCriteria_Score__c <= ruleParameters.brObj.OpportunityCriteria_Maximum_Score__c &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            String balRuleId = 'BAL_16';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
            if (messageActionWrapperList != null && !messageActionWrapperList.isEmpty()) {
                List<String> businessRuleIds = ruleParameters.BALandBRIdMap.get(balRuleId);
                AlertRecommendationsWrapper arwrap = null;
                if (
                    businessRuleIds == null || businessRuleIds.isEmpty() ||
                    !businessRuleIds.contains(ruleParameters.brObj.Id)
                ) {
                    // standard only
                    arwrap = getStandardAlertRecommendationsWrapper(messageActionWrapperList);
                } else if (businessRuleIds.contains(ruleParameters.brObj.Id)) {
                    arwrap = getMatchedAlertRecommendationsRec(messageActionWrapperList, ruleParameters.brObj.Id);
                }
                KF_Sell_Best__c bestActionRec = getBestActionRec(
                    scoreCard.Id,
                    ruleParameters.allBestActions,
                    ruleParameters.brObj.Id,
                    balRuleId
                );
                if (bestActionRec == null) {
                    bestActionRec = new KF_Sell_Best__c();
                }
                bestActionRec = RulesEvaluationUtil.mappingBestActionRecordFields(
                    ruleParameters.brObj,
                    arwrap,
                    balRuleId,
                    bestActionRec
                );
                AlertTemplateWrapper managerEmailAlert;
                if (arwrap != null && arwrap.managerEmail != null) {
                    managerEmailAlert = arwrap.managerEmail;
                    if (managerEmailAlert.urlText != null) {
                        String msg = managerEmailAlert.urlText;
                        String oppOwnerName = ruleParameters.opportunity.Owner.Name;
                        msg = msg.replace('{sellerName}', oppOwnerName);
                        bestActionRec.Manager_URL_Text__c = msg;
                    }
                }
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                bestActionRec.Score_Card__c = scoreCard.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_16';
            ruleParameters = emptyScoreCardBestActions(ruleParameters, balRuleId, scoreCard.Id);
        }
    }

    public void executeScoreCardRule17(RulesEngineConfig.RuleParams ruleParameters, Score_Card__c scoreCard) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            ruleParameters.brObj.Check_Business_Criteria_Score__c == true &&
            ruleParameters.brObj.BusinessCriteria_Minimum_Score__c != null &&
            scoreCard.BusinessCriteria_Score__c >= ruleParameters.brObj.BusinessCriteria_Minimum_Score__c &&
            ruleParameters.brObj.BusinessCriteria_Maximum_Score__c != null &&
            scoreCard.BusinessCriteria_Score__c <= ruleParameters.brObj.BusinessCriteria_Maximum_Score__c &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            String balRuleId = 'BAL_17';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
            if (messageActionWrapperList != null && !messageActionWrapperList.isEmpty()) {
                List<String> businessRuleIds = ruleParameters.BALandBRIdMap.get(balRuleId);
                AlertRecommendationsWrapper arwrap = null;
                if (
                    businessRuleIds == null || businessRuleIds.isEmpty() ||
                    !businessRuleIds.contains(ruleParameters.brObj.Id)
                ) {
                    // standard only
                    arwrap = getStandardAlertRecommendationsWrapper(messageActionWrapperList);
                } else if (businessRuleIds.contains(ruleParameters.brObj.Id)) {
                    arwrap = getMatchedAlertRecommendationsRec(messageActionWrapperList, ruleParameters.brObj.Id);
                }
                KF_Sell_Best__c bestActionRec = getBestActionRec(
                    scoreCard.Id,
                    ruleParameters.allBestActions,
                    ruleParameters.brObj.Id,
                    balRuleId
                );
                if (bestActionRec == null) {
                    bestActionRec = new KF_Sell_Best__c();
                }
                bestActionRec = RulesEvaluationUtil.mappingBestActionRecordFields(
                    ruleParameters.brObj,
                    arwrap,
                    balRuleId,
                    bestActionRec
                );
                AlertTemplateWrapper managerEmailAlert;
                if (arwrap != null && arwrap.managerEmail != null) {
                    managerEmailAlert = arwrap.managerEmail;
                    if (managerEmailAlert.urlText != null) {
                        String msg = managerEmailAlert.urlText;
                        String oppOwnerName = ruleParameters.opportunity.Owner.Name;
                        msg = msg.replace('{sellerName}', oppOwnerName);
                        bestActionRec.Manager_URL_Text__c = msg;
                    }
                }
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                bestActionRec.Score_Card__c = scoreCard.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_17';
            ruleParameters = emptyScoreCardBestActions(ruleParameters, balRuleId, scoreCard.Id);
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getBestActionRec(
        String scoreCardId,
        List<KF_Sell_Best__c> bestActions,
        String businessRuleId,
        String ruleId
    ) {
        KF_sell_best__c bestAction;
        if (bestActions != null && !bestActions.isEmpty()) {
            for (KF_Sell_Best__c bestAct : bestActions) {
                if (
                    bestAct.Business_Rules__c == businessRuleId &&
                    bestAct.Score_Card__c == scoreCardId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private RulesEngineConfig.RuleParams emptyScoreCardBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getBestActionRec(
            recId,
            ruleParameters.allBestActions,
            ruleParameters.brObj.Id,
            balRuleId
        );
        if (bestActionRec != null) {
            bestActionRec = RulesEvaluationUtil.mappingBestActionFieldsToEmpty(bestActionRec);
            ruleParameters.listBestActionsToUpdate.add(bestActionRec);
        }
        return ruleParameters;
    }

    public Map<String, List<Score_Card__c>> getScoreCards(Set<String> oppIds) {
        Map<String, List<Score_Card__c>> mapScoreCardWithParentId = new Map<String, List<Score_Card__c>>();
        String scorecardQuery =
            'SELECT Id,Name,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c,BusinessCriteria_Score__c,' +
            'OpportunityCriteria_Score__c,Total_Score__c,Potential_Score__c,LastModifiedDate ' +
            ' FROM Score_Card__c WHERE Blue_sheet__r.Opportunity__c IN :oppIds';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIds', oppIds);
        List<Score_Card__c> scorecardList = DataFactory.read(scorecardQuery, parameters);
        for (Score_Card__c card : scorecardList) {
            if (!mapScoreCardWithParentId.containsKey(card.Blue_Sheet__r.Opportunity__c)) {
                mapScoreCardWithParentId.put(card.Blue_Sheet__r.Opportunity__c, new List<Score_Card__c>{ card });
            } else {
                mapScoreCardWithParentId.get(card.Blue_Sheet__r.Opportunity__c).add(card);
            }
        }
        return mapScoreCardWithParentId;
    }
    private AlertRecommendationsWrapper getStandardAlertRecommendationsWrapper(
        List<AlertRecommendationsWrapper> messageActionWrapperList
    ) {
        AlertRecommendationsWrapper arwrapperToReturn = null;
        for (AlertRecommendationsWrapper arwrapper : messageActionWrapperList) {
            if (arwrapper.businessRulesId == null) {
                arwrapperToReturn = arwrapper;
                break;
            }
        }
        return arwrapperToReturn;
    }
    private AlertRecommendationsWrapper getMatchedAlertRecommendationsRec(
        List<AlertRecommendationsWrapper> messageActionWrapperList,
        String currentBRId
    ) {
        AlertRecommendationsWrapper arwrapperToReturn = null;
        for (AlertRecommendationsWrapper arwrapper : messageActionWrapperList) {
            if (arwrapper.businessRulesId == currentBRId) {
                arwrapperToReturn = arwrapper;
                break;
            }
        }
        return arwrapperToReturn;
    }
}