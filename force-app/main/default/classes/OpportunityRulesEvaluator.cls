@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public with sharing class OpportunityRulesEvaluator implements RulesEvaluator {
    private Map<String, Set<String>> brGrpIdAndMembers;
    public static Boolean OpportunityRulesEvaluatorInsertFlag = true;
    public static Boolean OpportunityRulesEvaluatorUpdateFlag = true;

    public void evaluate(Set<String> objectIds) {
        executeAllOpportunityRules(objectIds);
    }
    private void executeAllOpportunityRules(Set<String> oppIds) {
        Map<Id, Opportunity> oppsMap = ApexCommonUtil.getOpportunityRecord(oppIds);
        List<Opportunity> opportunities = oppsMap.values();
        List<Business_Rules__c> listBusinessRules = new List<Business_Rules__c>();
        Map<String, List<Business_Rules__c>> businessRuleMap = RulesEvaluationUtil.getBusinessRules();
        listBusinessRules = !businessRuleMap.isEmpty() ? businessRuleMap.get('Opportunity') : null;

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
            //oppsMap.keySet();

            List<Blue_Sheet__c> bsLst = RulesEvaluationUtil.getBlueSheets(opportunityIds);
            Map<String, String> bsOppMap = new Map<String, String>();
            for (Blue_Sheet__c bs : bsLst) {
                bsOppMap.put(bs.Opportunity__c, bs.id);
            }

            map<Id, List<KF_sell_best__c>> allBestActions = new Map<Id, List<KF_sell_best__c>>();
            allBestActions = getAllBestActions(opportunityIds);
            List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
            RulesEngineConfig.RuleParams ruleParameter;
            for (Opportunity opp : opportunities) {
                for (Business_Rules__c brObj : listBusinessRules) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opp, brGrpIdAndMembers)) {
                        bestActionsForBR = allBestActions.get(brObj.Id);

                        ruleParameter = new RulesEngineConfig.RuleParams()
                            .setOpportunityRec(opp)
                            .setBrObj(brObj)
                            .setBestActionList(bestActionsForBR)
                            .setMapRuleMSg(mapRuleMSg)
                            .setBestActionLstToInsert(listBestActionsToInsert)
                            .setBestActionLstToUpdate(listBestActionsToUpdate)
                            .setBSOppMap(bsOppMap)
                            .setBalIdBrIdMap(BALandBRIdMap);
                        executeOpportunityRule1(ruleParameter);
                        executeOpportunityRule4(ruleParameter);
                        executeOpportunityRule5(ruleParameter);
                    }
                }
            }

            RulesEvaluationUtil.upsertBestActions(ruleParameter);
        }
    }
    public void executeOpportunityRule1(RulesEngineConfig.RuleParams ruleParameters) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);

        if (
            ruleParameters.brObj.Is_a_Blue_Sheet_required__c == 'Yes' &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ruleParameters.bsOppMap.get(ruleParameters.opportunity.Id) == null
        ) {
            // create recommendation record
            String balRuleId = 'BAL_1';
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
                    ruleParameters.opportunity.Id,
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
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                // System.debug('ADDING ACTION REC ' + bestActionRec);
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_1';
            //System.debug('RULE WAS FAIL.. DELETING REC..');
            ruleParameters = emptyBestActions(ruleParameters, balRuleId);
        }
    }
    public void executeOpportunityRule4(RulesEngineConfig.RuleParams ruleParameters) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            ruleParameters.brObj.is_closed_date_past__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ruleParameters.opportunity.CloseDate < Date.today()
        ) {
            // create recommendation record
            String balRuleId = 'BAL_4';
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
                    ruleParameters.opportunity.Id,
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
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_4';
            ruleParameters = emptyBestActions(ruleParameters, balRuleId);
        }
    }

    public void executeOpportunityRule5(RulesEngineConfig.RuleParams ruleParameters) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        Date optyStageLastModiDate;
        if (ruleParameters.opportunity.Stage_Last_ModifiedOn__c != null) {
            optyStageLastModiDate = Date.newinstance(
                ruleParameters.opportunity.Stage_Last_ModifiedOn__c.year(),
                ruleParameters.opportunity.Stage_Last_ModifiedOn__c.month(),
                ruleParameters.opportunity.Stage_Last_ModifiedOn__c.day()
            );
        }

        Date todayDt = Date.today();
        if (
            optyStageLastModiDate != null &&
            ruleParameters.brObj.Max_Days_Allowed_in_a_Opty_Stage__c != null &&
            optyStageLastModiDate.daysBetween(todayDt) > ruleParameters.brObj.Max_Days_Allowed_in_a_Opty_Stage__c &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            // create recommendation record
            String balRuleId = 'BAL_5';
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
                    ruleParameters.opportunity.Id,
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
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_5';
            ruleParameters = emptyBestActions(ruleParameters, balRuleId);
        }
    }
    private RulesEngineConfig.RuleParams emptyBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId
    ) {
        KF_Sell_Best__c bestActionRec = getBestActionRec(
            ruleParameters.opportunity.Id,
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
    private static map<Id, List<KF_sell_best__c>> getAllBestActions(Set<String> OpportunityIds) {
        map<Id, List<KF_sell_best__c>> mapBestActionsPerBR = new Map<Id, List<KF_sell_best__c>>();
        String query =
            'SELECT Id,Name,Seller_Recommended_Action__c,Manager_Recommended_Action__c,' +
            'Opportunity__c,Business_Rules__c,BestActionRuleId__c' +
            ' FROM KF_sell_best__c WHERE Opportunity__c IN :OpportunityIds';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('OpportunityIds', OpportunityIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(query, parameters);
        for (KF_sell_best__c bestAct : bestActionList) {
            if (!mapBestActionsPerBR.containsKey(bestAct.Business_Rules__c)) {
                mapBestActionsPerBR.put(bestAct.Business_Rules__c, new List<KF_sell_best__c>{ bestAct });
            } else {
                mapBestActionsPerBR.get(bestAct.Business_Rules__c).add(bestAct);
            }
        }
        return mapBestActionsPerBR;
    }
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getBestActionRec(
        String OptyId,
        List<KF_Sell_Best__c> bestActions,
        String BRId,
        String ruleId
    ) {
        KF_sell_best__c bestAction;
        if (bestActions != null && !bestActions.isEmpty()) {
            for (KF_Sell_Best__c bestAct : bestActions) {
                if (
                    bestAct.Business_Rules__c == BRId &&
                    bestAct.Opportunity__c == OptyId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }
    public OpportunityRulesEvaluator() {
        brGrpIdAndMembers = RulesEvaluationUtil.getBRGrpMembers();
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