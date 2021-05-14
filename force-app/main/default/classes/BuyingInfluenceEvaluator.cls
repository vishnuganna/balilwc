@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public with sharing class BuyingInfluenceEvaluator implements RulesEvaluator {
    private Map<String, Set<String>> brGrpIdAndMembers;
    public BuyingInfluenceEvaluator() {
        brGrpIdAndMembers = RulesEvaluationUtil.getBRGrpMembers();
    }
    public void evaluate(set<String> objectIds) {
        Set<String> opptyIds = getOpportunityIdsFromBluesheet(objectIds);
        executeBuyingInfluenceRules(opptyIds);
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
    public Map<String, List<Buying_Influence__c>> getBuyingInfluences(Set<String> oppIds) {
        Map<String, List<Buying_Influence__c>> mapBuyingInfleucesWithParentId = new Map<String, List<Buying_Influence__c>>();

        List<String> fields = RuleEvaluatorHelper.getCurrencyFieldsAsList();
        String currencyFields = '';
        for (String f : fields) {
            f = f.trim();
            if (f != '' && f != null) {
                currencyFields = currencyFields + ', ' + 'Blue_Sheet__r.Opportunity__r.' + f;
            }
        }

        String queryBI =
            'SELECT Id,Name,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c,Blue_sheet__r.Customer_Timing_for_Priorities__c,' +
            'Personal_Wins__c, Growth__c, Rating__c, Even_Keel__c, High__c,Coach__c,Economic__c,User__c, ' +
            'Over_Confident__c, Trouble__c, Rating_Evidence__c, Business_Results__c,Blue_sheet__r.EBI_Count__c,Contact__c,' +
            'Buying_from_Someone_Else__c, Technical__c,Low__c, Medium__c,Blue_Sheet__r.Opportunity__r.StageName  ' +
            currencyFields +
            '  FROM Buying_Influence__c WHERE Blue_sheet__r.Opportunity__c IN :oppIds';
        if (Schema.sObjectType.Opportunity.fields.Probability.isAccessible()) {
            queryBI =
                'SELECT Id,Name,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c,Blue_sheet__r.Customer_Timing_for_Priorities__c,' +
                'Personal_Wins__c, Growth__c, Rating__c, Even_Keel__c, High__c,Coach__c,Economic__c,User__c, ' +
                'Over_Confident__c, Trouble__c, Rating_Evidence__c, Business_Results__c,Blue_sheet__r.EBI_Count__c,Contact__c,' +
                'Buying_from_Someone_Else__c, Technical__c,Low__c, Medium__c,Blue_Sheet__r.Opportunity__r.StageName, Blue_Sheet__r.Opportunity__r.Probability  ' +
                currencyFields +
                '  FROM Buying_Influence__c WHERE Blue_sheet__r.Opportunity__c IN :oppIds';
        }

        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIds', oppIds);
        List<Buying_Influence__c> listBuyingInfluence = DataFactory.read(queryBI, parameters);
        for (Buying_Influence__c bi : listBuyingInfluence) {
            if (!mapBuyingInfleucesWithParentId.containsKey(bi.Blue_Sheet__r.Opportunity__c)) {
                mapBuyingInfleucesWithParentId.put(
                    bi.Blue_Sheet__r.Opportunity__c,
                    new List<Buying_Influence__c>{ bi }
                );
            } else {
                mapBuyingInfleucesWithParentId.get(bi.Blue_Sheet__r.Opportunity__c).add(bi);
            }
        }
        return mapBuyingInfleucesWithParentId;
    }

    public static set<String> getActionsPlansAssignedToContact(List<Buying_Influence__c> buyingInfluences) {
        set<Id> contacts = new Set<Id>();
        set<String> actionPlanContacts = new Set<String>();
        for (Buying_Influence__c bi : buyingInfluences) {
            contacts.add(bi.Contact__c);
        }
        String query = 'SELECT Id,Name,Contact__c from Action_plan__c where Contact__c IN: contacts';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('contacts', contacts);
        List<Action_Plan__c> actionPlans = DataFactory.read(query, parameters);
        for (Action_Plan__c act : actionPlans) {
            actionPlanContacts.add(act.Contact__c);
        }
        return actionPlanContacts;
    }

    public void executeBuyingInfluenceRules(Set<String> oppIds) {
        Map<Id, Opportunity> oppsMap = ApexCommonUtil.getOpportunityRecord(oppIds);

        List<Opportunity> opportunities = oppsMap.values();
        List<Business_Rules__c> listBusinessRules = new List<Business_Rules__c>();
        Map<String, List<Business_Rules__c>> businessRuleMap = RulesEvaluationUtil.getBusinessRules();
        listBusinessRules = !businessRuleMap.isEmpty() ? businessRuleMap.get('Buying Influences') : null;
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
            // List<Buying_Influence__c> buyingInfluences = getBuyingInfluences(opportunityIds);
            Map<String, List<Buying_Influence__c>> mapBuyingInfluences = getBuyingInfluences(opportunityIds);
            List<Buying_Influence__c> buyingInfluences = new List<Buying_Influence__c>();
            for (String optyId : mapBuyingInfluences.keyset()) {
                buyingInfluences.addAll(mapBuyingInfluences.get(optyId));
            }
            Set<String> setActionPlanContacts = getActionsPlansAssignedToContact(buyingInfluences);
            map<Id, List<KF_sell_best__c>> allBestActions = new Map<Id, List<KF_sell_best__c>>();
            allBestActions = getAllBestActions(opportunityIds);
            List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
            RulesEngineConfig.RuleParams ruleParameter = new RulesEngineConfig.RuleParams()
                .setAllBestActionsMap(allBestActions)
                .setBestActionLstToInsert(listBestActionsToInsert)
                .setBestActionLstToUpdate(listBestActionsToUpdate)
                .setMapRuleMSg(mapRuleMSg)
                .setOpportunityMap(oppsMap)
                .setBusinessRules(businessRuleMap)
                .setBalIdBrIdMap(BALandBRIdMap);

            for (Buying_Influence__c bi : buyingInfluences) {
                Opportunity opportunity = ruleParameter.oppsMap.get(bi.Blue_Sheet__r.Opportunity__c);
                for (Business_Rules__c brObj : listBusinessRules) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj)
                            .setBestActionList(bestActionsForBR)
                            .setOpportunityRec(opportunity);

                        executeBuyingInflueneRule18(ruleParameter, bi, setActionPlanContacts);
                        executeBuyingInflueneRule19(ruleParameter, bi, buyingInfluences);
                        executeBuyingInflueneRule20(ruleParameter, bi);
                        executeBuyingInflueneRule21(ruleParameter, bi);
                        executeBuyingInflueneRule23(ruleParameter, bi);
                        executeBuyingInflueneRule24(ruleParameter, bi);
                    }
                }
            }
            RulesEvaluationUtil.upsertBestActions(ruleParameter);
        }
    }

    private static map<Id, List<KF_sell_best__c>> getAllBestActions(set<String> OpportunityIds) {
        map<Id, List<KF_sell_best__c>> mapBestActionsPerBR = new Map<Id, List<KF_sell_best__c>>();
        String query =
            'SELECT Id,Name,Seller_Recommended_Action__c,Manager_Recommended_Action__c,Seller_Email_Text__c,' +
            'Buying_Influence__c,Business_Rules__c,BestActionRuleId__c,Opportunity__c' +
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
        String BuyingInfluId,
        List<KF_Sell_Best__c> bestActions,
        String BRId,
        String ruleId
    ) {
        KF_sell_best__c bestAction;
        if (bestActions != null && !bestActions.isEmpty()) {
            for (KF_Sell_Best__c bestAct : bestActions) {
                if (
                    bestAct.Business_Rules__c == BRId &&
                    bestAct.Buying_Influence__c == BuyingInfluId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }
    private RulesEngineConfig.RuleParams emptyBuyingInfluenceBestActions(
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
    @SuppressWarnings('PMD.NcssMethodCount,PMD.CognitiveComplexity')
    public void executeBuyingInflueneRule18(
        RulesEngineConfig.RuleParams ruleParameters,
        Buying_Influence__c buyingInfluence,
        Set<String> actionPlansWithContacts
    ) {
        set<String> ratings = new Set<String>{ '-5', '-4', '-3', '-2', '-1', '0', '+1' };
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            ruleParameters.brObj.is_negative_rating__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ratings.contains(buyingInfluence.Rating__c) &&
            (buyingInfluence.Rating_Evidence__c == null &&
            (actionPlansWithContacts != null && !actionPlansWithContacts.contains(buyingInfluence.Contact__c) ||
            actionPlansWithContacts == null))
        ) {
            String buyingInfluRole;
            List<String> roleList = new List<String>();
            if (buyingInfluence.Coach__c) {
                roleList.add('Coach');
            }
            if (buyingInfluence.User__c) {
                roleList.add('User');
            }
            if (buyingInfluence.Technical__c) {
                roleList.add('Technical');
            }
            if (buyingInfluence.Economic__c) {
                roleList.add('Economic');
            }
            buyingInfluRole = string.join(roleList, ',');
            // create recommendation record
            String balRuleId = 'BAL_18';
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
                    buyingInfluence.Id,
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
                        msg = msg.replace('{BIRole}', buyingInfluRole);
                        bestActionRec.Manager_URL_Text__c = msg;
                    }
                }
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                bestActionRec.Buying_Influence__c = buyingInfluence.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_18';
            ruleParameters = emptyBuyingInfluenceBestActions(ruleParameters, balRuleId, buyingInfluence.Id);
        }
    }
    public void executeBuyingInflueneRule19(
        RulesEngineConfig.RuleParams ruleParameters,
        Buying_Influence__c buyingInfluence,
        List<Buying_Influence__c> allBuyingInfluences
    ) {
        boolean isCoach = checkIfAnyBIHasCoach(allBuyingInfluences);
        set<String> ratings = new Set<String>{ '+5', '+4', '+3' };
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            ruleParameters.brObj.is_high_rated_BI_no_coach__c == true &&
            isCoach == false &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ratings.contains(buyingInfluence.Rating__c)
        ) {
            String balRuleId = 'BAL_19';
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
                    buyingInfluence.Id,
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
                bestActionRec.Buying_Influence__c = buyingInfluence.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_19';
            ruleParameters = emptyBuyingInfluenceBestActions(ruleParameters, balRuleId, buyingInfluence.Id);
        }
    }

    public void executeBuyingInflueneRule20(
        RulesEngineConfig.RuleParams ruleParameters,
        Buying_Influence__c buyingInfluence
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            (buyingInfluence.Personal_Wins__c == null ||
            buyingInfluence.Personal_Wins__c == '') &&
            ruleParameters.brObj.is_person_win_identified__c == true
        ) {
            String balRuleId = 'BAL_20';
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
                    buyingInfluence.Id,
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
                bestActionRec.Buying_Influence__c = buyingInfluence.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            String balRuleId = 'BAL_20';
            ruleParameters = emptyBuyingInfluenceBestActions(ruleParameters, balRuleId, buyingInfluence.Id);
        }
    }
    public void executeBuyingInflueneRule21(
        RulesEngineConfig.RuleParams ruleParameters,
        Buying_Influence__c buyingInfluence
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            (buyingInfluence.Business_Results__c == null ||
            buyingInfluence.Business_Results__c == '') &&
            ruleParameters.brObj.is_business_result_identified__c == true
        ) {
            String balRuleId = 'BAL_21';
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
                    buyingInfluence.Id,
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
                bestActionRec.Buying_Influence__c = buyingInfluence.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            String balRuleId = 'BAL_21';
            ruleParameters = emptyBuyingInfluenceBestActions(ruleParameters, balRuleId, buyingInfluence.Id);
        }
    }
    public void executeBuyingInflueneRule22(
        RulesEngineConfig.RuleParams ruleParameters,
        Integer buyingInfluenceCount // Buying_Influence__c buyingInfluence
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ruleParameters.brObj.Min_Number_Buying_Influence_Contacts__c != null &&
            (buyingInfluenceCount < ruleParameters.brObj.Min_Number_Buying_Influence_Contacts__c) // (buyingInfluence.Blue_Sheet__r.EBI_Count__c < ruleParameters.brObj.Min_Number_Buying_Influence_Contacts__c)
        ) {
            String balRuleId = 'BAL_22';
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
                KF_Sell_Best__c bestActionRec = getOpportunityBestActionRec(
                    // buyingInfluence.Id,
                    ruleParameters.opportunity.id,
                    ruleParameters.allBestActions,
                    ruleParameters.brObj.Id,
                    balRuleId
                );
                if (bestActionRec == null) {
                    bestActionRec = new KF_Sell_Best__c();
                }
                System.debug('bestActionRec>>>>' + bestActionRec);
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
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            String balRuleId = 'BAL_22';
            ruleParameters = emptyOpportunityBestActions(ruleParameters, balRuleId);
        }
    }
    public void executeBuyingInflueneRule23(
        RulesEngineConfig.RuleParams ruleParameters,
        Buying_Influence__c buyingInfluence
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ruleParameters.brObj.is_coach_with_low_BI__c == true &&
            buyingInfluence.Coach__c == true &&
            buyingInfluence.Low__c == true
        ) {
            String balRuleId = 'BAL_23';
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
                    buyingInfluence.Id,
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
                bestActionRec.Buying_Influence__c = buyingInfluence.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            String balRuleId = 'BAL_23';
            ruleParameters = emptyBuyingInfluenceBestActions(ruleParameters, balRuleId, buyingInfluence.Id);
        }
    }
    public void executeBuyingInflueneRule24(
        RulesEngineConfig.RuleParams ruleParameters,
        Buying_Influence__c buyingInfluence
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        String customerTiming = buyingInfluence.Blue_Sheet__r.Customer_Timing_for_Priorities__c;
        if (
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ruleParameters.brObj.is_discon_mode_cust_timing__c == true &&
            (buyingInfluence.Over_Confident__c == true ||
            buyingInfluence.Even_Keel__c == true) &&
            (customerTiming != null &&
            customerTiming != '' &&
            (customerTiming.toLowerCase() == 'active' ||
            customerTiming.toLowerCase() == 'urgent'))
        ) {
            String balRuleId = 'BAL_24';
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
                    buyingInfluence.Id,
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
                bestActionRec.Buying_Influence__c = buyingInfluence.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            String balRuleId = 'BAL_24';
            ruleParameters = emptyBuyingInfluenceBestActions(ruleParameters, balRuleId, buyingInfluence.Id);
        }
    }

    public void executeBuyingInflueneRule12(
        RulesEngineConfig.RuleParams ruleParameters,
        List<Buying_Influence__c> buyingInfluences
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        boolean ruleRoleResult = processBIRoleRule(buyingInfluences, ruleParameters.brObj.Buying_Influence_Role__c);
        if (
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            ruleRoleResult
        ) {
            String balRuleId = 'BAL_12';
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
                    System.debug('in if arWrap>>>' + arWrap);
                } else if (businessRuleIds.contains(ruleParameters.brObj.Id)) {
                    arwrap = getMatchedAlertRecommendationsRec(messageActionWrapperList, ruleParameters.brObj.Id);
                }
                KF_Sell_Best__c bestActionRec = getOpportunityBestActionRec(
                    ruleParameters.opportunity.id,
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
                AlertTemplateWrapper actionAlert;
                if (arwrap != null && arwrap.action != null) {
                    actionAlert = arwrap.action;
                    if (actionAlert.overrideMessage == false) {
                        String msg = actionAlert.defaultAlertMessage;
                        msg = msg.replace(
                            '{Business_Rules__c.Buying_Influence_Role__c}',
                            String.valueOf(ruleParameters.brObj.Buying_Influence_Role__c)
                        );
                        bestActionRec.Seller_Recommended_Action__c = msg;
                    }
                }
                AlertTemplateWrapper sellerEmailAlert;
                if (arwrap != null && arwrap.sellerEmail != null) {
                    sellerEmailAlert = arwrap.sellerEmail;
                    if (sellerEmailAlert.overrideMessage == false) {
                        String msg = sellerEmailAlert.defaultAlertMessage;
                        msg = msg.replace(
                            '{BI.Role__c}',
                            String.valueOf(ruleParameters.brObj.Buying_Influence_Role__c)
                        );
                        bestActionRec.Seller_Email_Text__c = msg;
                    }
                }
                AlertTemplateWrapper managerEmailAlert;
                if (arwrap != null && arwrap.managerEmail != null) {
                    managerEmailAlert = arwrap.managerEmail;
                    if (managerEmailAlert.overrideMessage == false) {
                        String msg = managerEmailAlert.defaultAlertMessage;
                        msg = msg.replace(
                            '{BI.Role__c}',
                            String.valueOf(ruleParameters.brObj.Buying_Influence_Role__c)
                        );
                        bestActionRec.Manager_Recommended_Action__c = msg;
                    }
                }
                bestActionRec.Opportunity__c = ruleParameters.opportunity.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            String balRuleId = 'BAL_12';
            ruleParameters = emptyOpportunityBestActions(ruleParameters, balRuleId);
        }
    }

    private static boolean processBIRoleRule(List<Buying_Influence__c> buyingInfluences, String roleStrBR) {
        boolean finalResult = true;
        for (Buying_Influence__c bi : buyingInfluences) {
            String buyingInfluRole;
            List<String> roleList = new List<String>();
            if (bi.Coach__c) {
                roleList.add('Coach');
            }
            if (bi.User__c) {
                roleList.add('User');
            }
            if (bi.Technical__c) {
                roleList.add('Technical');
            }
            if (bi.Economic__c) {
                roleList.add('Economic');
            }
            buyingInfluRole = string.join(roleList, ',');
            if (roleStrBR == null || roleStrBR == '') {
                finalResult = false;
                break;
            }
            if (
                roleStrBR != null &&
                roleStrBR != '' &&
                buyingInfluRole != null &&
                buyingInfluRole.contains(roleStrBR)
            ) {
                finalResult = false;
                break;
            }
        }
        return finalResult;
    }

    private static boolean checkIfAnyBIHasCoach(List<Buying_Influence__c> buyingInfluences) {
        boolean finalResult = true;
        List<String> roleList = new List<String>();
        for (Buying_Influence__c bi : buyingInfluences) {
            String buyingInfluRole;
            if (bi.Coach__c) {
                roleList.add('Coach');
            }
        }
        if (roleList.isEmpty()) {
            finalResult = false;
        } else {
            finalResult = true;
        }
        return finalResult;
    }

    private RulesEngineConfig.RuleParams emptyOpportunityBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId
    ) {
        KF_Sell_Best__c bestActionRec = getOpportunityBestActionRec(
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

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getOpportunityBestActionRec(
        String recId,
        List<KF_Sell_Best__c> bestActions,
        String BRId,
        String ruleId
    ) {
        KF_sell_best__c bestAction;
        if (bestActions != null && !bestActions.isEmpty()) {
            for (KF_Sell_Best__c bestAct : bestActions) {
                if (
                    bestAct.Business_Rules__c == BRId &&
                    bestAct.Opportunity__c == recId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
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