@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts,PMD.ExcessiveClassLength')
public with sharing class BlueSheetRulesEvaluator implements RulesEvaluator {
    private Map<String, Set<String>> brGrpIdAndMembers;
    public static Boolean BlueSheetRulesEvaluatorInsertFlag = true;
    public static Boolean BlueSheetRulesEvaluatorUpdateFlag = true;

    public BlueSheetRulesEvaluator() {
        brGrpIdAndMembers = RulesEvaluationUtil.getBRGrpMembers();
    }
    public void evaluate(set<String> objectIds) {
        Set<String> opptyIds = getOpportunityIdsFromBluesheet(objectIds);
        executeAllBluesheetRules(opptyIds);
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

    private Map<String, Blue_Sheet__c> getBlueSheetRecord(set<String> parentIds) {
        Map<String, Blue_Sheet__c> bluesheetWithParentIdMap = new Map<String, Blue_Sheet__c>();
        String soql = 'SELECT ID,Name,Opportunity__c,LastModifiedDate FROM Blue_Sheet__c WHERE Opportunity__c IN:parentIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('parentIds', parentIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(soql, soqlParamMap);
        for (Blue_Sheet__c bluesheet : bluesheetList) {
            bluesheetWithParentIdMap.put(bluesheet.Opportunity__c, bluesheet);
        }
        return bluesheetWithParentIdMap;
    }
    private Map<String, List<Action_plan__c>> getActionPlans(set<String> parentIds) {
        Map<String, List<Action_plan__c>> actionPlanWithParentIdMap = new Map<String, List<Action_plan__c>>();
        String soql =
            'SELECT Id,Name,Due_Date__c,Is_a_Best_Action__c,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c,Contact__c' +
            ' FROM Action_Plan__c WHERE Blue_Sheet__r.Opportunity__c IN: parentIds';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('parentIds', parentIds);
        List<Action_Plan__c> actionPlanList = DataFactory.read(soql, soqlParamMap);
        for (Action_Plan__c actionPlan : actionPlanList) {
            if (actionPlanWithParentIdMap.containsKey(actionPlan.Blue_Sheet__r.Opportunity__c)) {
                actionPlanWithParentIdMap.get(actionPlan.Blue_Sheet__r.Opportunity__c).add(actionPlan);
            } else {
                actionPlanWithParentIdMap.put(
                    actionPlan.Blue_Sheet__r.Opportunity__c,
                    new List<Action_Plan__c>{ actionPlan }
                );
            }
        }
        return actionPlanWithParentIdMap;
    }
    private Map<String, Current_Position__c> getCurrentPosition(set<String> parentIds) {
        Map<String, Current_Position__c> currentPositionWithParentIdMap = new Map<String, Current_Position__c>();

        String soql =
            'SELECT Id,Name,Current_Position__c,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c ' +
            ' FROM Current_Position__c WHERE  Blue_Sheet__r.Opportunity__c IN: parentIds';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('parentIds', parentIds);
        List<Current_Position__c> currentPosList = DataFactory.read(soql, soqlParamMap);
        for (Current_Position__c currentPos : currentPosList) {
            currentPositionWithParentIdMap.put(currentPos.Blue_Sheet__r.Opportunity__c, currentPos);
        }
        return currentPositionWithParentIdMap;
    }
    private Map<String, Single_Sales_Objective__c> getSingleSalesObjective(set<String> parentIds) {
        Map<String, Single_Sales_Objective__c> singleSalesObjectiveWithParentIdMap = new Map<String, Single_Sales_Objective__c>();
        String soql =
            'SELECT Id,Name,Customer_Timing_for_Priorities__c,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c ' +
            ' FROM Single_Sales_Objective__c WHERE  Blue_Sheet__r.Opportunity__c IN: parentIds';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('parentIds', parentIds);
        List<Single_Sales_Objective__c> ssoList = DataFactory.read(soql, soqlParamMap);
        for (Single_Sales_Objective__c sso : ssoList) {
            singleSalesObjectiveWithParentIdMap.put(sso.Blue_Sheet__r.Opportunity__c, sso);
        }
        return singleSalesObjectiveWithParentIdMap;
    }
    private Map<String, List<Competition__c>> getCompetitions(set<String> parentIds) {
        Map<String, List<Competition__c>> competitionsWithParentIdMap = new Map<String, List<Competition__c>>();
        String soql =
            'SELECT Id,Name,Competitor_Type__c,My_Position_Vs_Competitor__c,Competitior_Name__c,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c ' +
            ' FROM Competition__c WHERE  Blue_Sheet__r.Opportunity__c IN: parentIds';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('parentIds', parentIds);
        List<Competition__c> competitionList = DataFactory.read(soql, soqlParamMap);
        for (Competition__c competition : competitionList) {
            if (competitionsWithParentIdMap.containsKey(competition.Blue_Sheet__r.Opportunity__c)) {
                List<Competition__c> compLst = competitionsWithParentIdMap.get(
                    competition.Blue_Sheet__r.Opportunity__c
                );
                compLst.add(competition);
                competitionsWithParentIdMap.put(competition.Blue_Sheet__r.Opportunity__c, compLst);
            } else {
                List<Competition__c> compLst = new List<Competition__c>();
                compLst.add(competition);
                competitionsWithParentIdMap.put(competition.Blue_Sheet__r.Opportunity__c, compLst);
            }
        }
        return competitionsWithParentIdMap;
    }
    private Map<String, Score_Card__c> getScoreCard(set<String> parentIds) {
        Map<String, Score_Card__c> scorecardWithParentIdMap = new Map<String, Score_Card__c>();
        String soql =
            'SELECT Id,Name,Blue_Sheet__c,Blue_Sheet__r.Opportunity__c ' +
            ' FROM Score_Card__c WHERE  Blue_Sheet__r.Opportunity__c IN: parentIds';

        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('parentIds', parentIds);
        List<Score_Card__c> scorecardList = DataFactory.read(soql, soqlParamMap);
        for (Score_Card__c scorecard : scorecardList) {
            scorecardWithParentIdMap.put(scorecard.Blue_Sheet__r.Opportunity__c, scorecard);
        }
        return scorecardWithParentIdMap;
    }

    private void executeAllBluesheetRules(Set<String> oppIds) {
        Map<Id, Opportunity> oppsMap = ApexCommonUtil.getOpportunityRecord(oppIds);
        List<Opportunity> opportunities = oppsMap.values();
        Map<String, List<Business_Rules__c>> businessRuleMap = RulesEvaluationUtil.getBusinessRules();
        List<Business_Rules__c> listBusinessRules = new List<Business_Rules__c>();

        if (!businessRuleMap.isEmpty()) {
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

            map<Id, List<KF_sell_best__c>> allBestActions = new Map<Id, List<KF_sell_best__c>>();
            allBestActions = getAllBestActions(opportunityIds);
            List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
            RulesEngineConfig.RuleParams ruleParameter = new RulesEngineConfig.RuleParams()
                .setBusinessRules(businessRuleMap)
                .setAllBestActionsMap(allBestActions)
                .setBestActionLstToInsert(listBestActionsToInsert)
                .setBestActionLstToUpdate(listBestActionsToUpdate)
                .setMapRuleMSg(mapRuleMSg)
                .setOpportunityMap(oppsMap)
                .setBalIdBrIdMap(BALandBRIdMap);
            executeBlueSheetRules(ruleParameter, opportunityIds);
            executeCompetitionRules(ruleParameter, opportunityIds);
            executeActionPlanRules(ruleParameter, opportunityIds);
            executeCurrentPositionRules(ruleParameter, opportunityIds);
            executeSSORules(ruleParameter, opportunityIds);

            executeScoreCardRules(ruleParameter, opportunityIds);

            executeBuyingInfluenceRules(ruleParameter, opportunityIds);
            RulesEvaluationUtil.upsertBestActions(ruleParameter);
        }
    }
    public void executeBuyingInfluenceRules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        BuyingInfluenceEvaluator biEvaluator = new BuyingInfluenceEvaluator();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();

        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Buying Influences')
            : null;
        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, List<Buying_Influence__c>> mapBuyingInfluences = biEvaluator.getBuyingInfluences(
                opportunityIds
            );
            List<Buying_Influence__c> buyingInfluences = new List<Buying_Influence__c>();
            for (String optyId : mapBuyingInfluences.keyset()) {
                buyingInfluences.addAll(mapBuyingInfluences.get(optyId));
            }
            if (!mapBuyingInfluences.isEmpty()) {
                //code for rule 18 on action plan
                set<String> actionPlanContacts = BuyingInfluenceEvaluator.getActionsPlansAssignedToContact(
                    buyingInfluences
                );
                for (Buying_Influence__c bi : buyingInfluences) {
                    Opportunity opportunity = ruleParameter.oppsMap.get(bi.Blue_Sheet__r.Opportunity__c);
                    for (Business_Rules__c brObj : businessRuleList) {
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);
                            biEvaluator.executeBuyingInflueneRule18(ruleParameter, bi, actionPlanContacts);
                            biEvaluator.executeBuyingInflueneRule19(ruleParameter, bi, buyingInfluences);
                        }
                    }
                }
                //end of 18
                for (String optyId : mapBuyingInfluences.keyset()) {
                    Opportunity opportunity = ruleParameter.oppsMap.get(optyId);
                    Integer buyingInfluenceCountPerOpty = mapBuyingInfluences.get(optyId).size();
                    for (Business_Rules__c brObj : businessRuleList) {
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);
                            biEvaluator.executeBuyingInflueneRule22(ruleParameter, buyingInfluenceCountPerOpty);
                            biEvaluator.executeBuyingInflueneRule12(
                                ruleParameter,
                                mapBuyingInfluences.get(opportunity.Id)
                            );
                        }
                    }
                }
            } else {
                for (String optyId : opportunityIds) {
                    Id opprtunityId = (Id) optyId;
                    for (Business_Rules__c brObj : businessRuleList) {
                        Opportunity opportunity = ruleParameter.oppsMap.get(opprtunityId);
                        Integer buyingInfluenceCountPerOpty = 0;
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);
                            biEvaluator.executeBuyingInflueneRule22(ruleParameter, buyingInfluenceCountPerOpty);
                        }
                    }
                }
            }
        }
    }

    private void executeBlueSheetRules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();
        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Opportunity')
            : null;
        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, Blue_Sheet__c> bluesheetMap = getBlueSheetRecord(opportunityIds);
            for (Blue_Sheet__c bluesheet : bluesheetMap.values()) {
                Opportunity opportunity = ruleParameter.oppsMap.get(bluesheet.Opportunity__c);
                for (Business_Rules__c brObj : businessRuleList) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj)
                            .setBestActionList(bestActionsForBR)
                            .setOpportunityRec(opportunity);

                        executeBlueSheetRule3(ruleParameter, bluesheet);
                    }
                }
            }
        }
    }
    public void executeBlueSheetRule3(RulesEngineConfig.RuleParams ruleParameters, Blue_Sheet__c bluesheet) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        Datetime bsLastModDate = bluesheet.LastModifiedDate;
        Date bsLastModDateDate;
        if (bsLastModDate != null) {
            bsLastModDateDate = Date.newinstance(bsLastModDate.year(), bsLastModDate.month(), bsLastModDate.day());
        }
        Date todayDt1 = Date.today();
        if (
            bsLastModDateDate != null &&
            ruleParameters.brObj.Max_Days_Allowed_Since_Last_BS_Update__c != null &&
            ruleParameters.brObj.Max_Days_Allowed_Since_Last_BS_Update__c < bsLastModDateDate.daysBetween(todayDt1) &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            // create recommendation record
            String balRuleId = 'BAL_3';
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
            String balRuleId = 'BAL_3';
            ruleParameters = emptyOpportunityBestActions(ruleParameters, balRuleId);
        }
    }
    private void executeCompetitionRules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();
        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Opportunity')
            : null;
        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, List<Competition__c>> competitionMap = getCompetitions(opportunityIds);
            for (String key : competitionMap.keySet()) {
                List<Competition__c> compLst = competitionMap.get(key);
                if (!compLst.isEmpty()) {
                    for (Competition__c comp : compLst) {
                        Opportunity opportunity = ruleParameter.oppsMap.get(comp.Blue_Sheet__r.Opportunity__c);
                        for (Business_Rules__c brObj : businessRuleList) {
                            if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                                bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                                ruleParameter = ruleParameter.setBrObj(brObj)
                                    .setBestActionList(bestActionsForBR)
                                    .setOpportunityRec(opportunity);

                                executeOpportunityRule9(ruleParameter, comp);
                                executeOpportunityRule10(ruleParameter, comp);
                            }
                        }
                    }
                }
            }
        }
    }
    private void executeOpportunityRule9(RulesEngineConfig.RuleParams ruleParameters, Competition__c comp) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);

        if (
            ruleParameters.brObj.is_competitor_identified__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            comp.Competitor_Type__c != 'Buying From Someone Else'
        ) {
            // create recommendation record
            String balRuleId = 'BAL_9';
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
                KF_Sell_Best__c bestActionRec = getCompetitionBestActionRec(
                    comp.Id,
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
                bestActionRec.Competition__c = comp.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_9';
            ruleParameters = emptyCompetitionBestActions(ruleParameters, balRuleId, comp.Id);
        }
    }
    private void executeOpportunityRule10(RulesEngineConfig.RuleParams ruleParameters, Competition__c comp) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);

        if (
            ruleParameters.brObj.is_pos_competition_zero__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            (comp.My_Position_Vs_Competitor__c == 'Shared' ||
            comp.My_Position_Vs_Competitor__c == 'Zero')
        ) {
            // create recommendation record
            String balRuleId = 'BAL_10';
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
                KF_Sell_Best__c bestActionRec = getCompetitionBestActionRec(
                    comp.Id,
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
                bestActionRec.Competition__c = comp.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_10';
            ruleParameters = emptyCompetitionBestActions(ruleParameters, balRuleId, comp.Id);
        }
    }
    private void executeCurrentPositionRules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();
        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Opportunity')
            : null;

        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, Current_Position__c> competitionMap = getCurrentPosition(opportunityIds);
            for (Current_Position__c curPos : competitionMap.values()) {
                Opportunity opportunity = ruleParameter.oppsMap.get(curPos.Blue_Sheet__r.Opportunity__c);
                for (Business_Rules__c brObj : businessRuleList) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj)
                            .setBestActionList(bestActionsForBR)
                            .setOpportunityRec(opportunity);

                        executeOpportunityRule8(ruleParameter, curPos);
                    }
                }
            }
        }
    }
    private void executeOpportunityRule8(
        RulesEngineConfig.RuleParams ruleParameters,
        Current_Position__c currentPosition
    ) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        List<String> cpNegativeValues = new List<String>{ 'Concern', 'Discomfort', 'Worry', 'Fear', 'Panic' };
        if (
            ruleParameters.brObj.is_curr_pos_negative__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            cpNegativeValues.contains(currentPosition.Current_Position__c)
        ) {
            // create recommendation record
            String balRuleId = 'BAL_8';
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
                KF_Sell_Best__c bestActionRec = getCurrentPositionBestActionRec(
                    currentPosition.Id,
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
                bestActionRec.Current_Position__c = currentPosition.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_8';
            ruleParameters = emptyCurrentBestActions(ruleParameters, balRuleId, currentPosition.Id);
        }
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

    private void executeActionPlanRules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();

        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Opportunity')
            : null;
        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, List<Action_Plan__c>> actionPlanMap = getActionPlans(opportunityIds);
            List<Action_Plan__c> apList = new List<Action_Plan__c>();

            if (!actionPlanMap.isEmpty()) {
                for (String optyId : actionPlanMap.keyset()) {
                    apList.addAll(actionPlanMap.get(optyId));
                    Id opprtunityId = (Id) optyId;
                    for (Business_Rules__c brObj : businessRuleList) {
                        Opportunity opportunity = ruleParameter.oppsMap.get(opprtunityId);
                        Integer actionPlanCountPerOpty = actionPlanMap.get(opprtunityId).size();
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);
                            executeActionPlanRule6(ruleParameter, actionPlanCountPerOpty);
                        }
                    }
                }
                for (Action_Plan__c action : apList) {
                    //Integer actionPlanCountPerOpty = actionPlanMap.get(action.Blue_Sheet__r.Opportunity__c).size();
                    Opportunity opportunity = ruleParameter.oppsMap.get(action.Blue_Sheet__r.Opportunity__c);
                    for (Business_Rules__c brObj : businessRuleList) {
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);
                            executeActionPlanRule7(ruleParameter, action);
                        }
                    }
                }
            } else {
                for (String optyId : opportunityIds) {
                    Id opprtunityId = (Id) optyId;
                    for (Business_Rules__c brObj : businessRuleList) {
                        Opportunity opportunity = ruleParameter.oppsMap.get(opprtunityId);
                        Integer actionPlanCountPerOpty = 0;
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);
                            executeActionPlanRule6(ruleParameter, actionPlanCountPerOpty);
                        }
                    }
                }
            }
        }
    }
    private void executeActionPlanRule7(RulesEngineConfig.RuleParams ruleParameters, Action_Plan__c action) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);

        if (
            ruleParameters.brObj.is_past_action_due__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            Date.today() > action.Due_Date__c &&
            action.Is_a_Best_Action__c == true
        ) {
            // create recommendation record
            String balRuleId = 'BAL_7';
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
                KF_Sell_Best__c bestActionRec = getActionPlanBestActionRec(
                    action.Id,
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
                bestActionRec.Action_Plan__c = action.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_7';
            ruleParameters = emptyActionPlanBestActions(ruleParameters, balRuleId, action.Id);
        }
    }
    private void executeActionPlanRule6(RulesEngineConfig.RuleParams ruleParameters, Integer actionPlanCount) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);

        if (
            ruleParameters.brObj.Min_Number_of_Actions_for_a_Opty_Stage__c != null &&
            ruleParameters.brObj.Min_Number_of_Actions_for_a_Opty_Stage__c > actionPlanCount &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName)
        ) {
            // create recommendation record
            String balRuleId = 'BAL_6';
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
            String balRuleId = 'BAL_6';
            ruleParameters = emptyOpportunityBestActions(ruleParameters, balRuleId);
        }
    }

    private void executeScoreCardRules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();
        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Scorecard')
            : null;
        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, Score_Card__c> scorecardMap = getScoreCard(opportunityIds);
            if (scorecardMap != null && !scorecardMap.isEmpty()) {
                for (Score_Card__c scorecard : scorecardMap.values()) {
                    Opportunity opportunity = ruleParameter.oppsMap.get(scorecard.Blue_Sheet__r.Opportunity__c);
                    for (Business_Rules__c brObj : businessRuleList) {
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);

                            executeScorecardRule11(ruleParameter, scorecard);
                        }
                    }
                }
            } else {
                for (String oppId : opportunityIds) {
                    Opportunity opportunity = ruleParameter.oppsMap.get((Id) oppId);
                    for (Business_Rules__c brObj : businessRuleList) {
                        if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                            bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                            ruleParameter = ruleParameter.setBrObj(brObj)
                                .setBestActionList(bestActionsForBR)
                                .setOpportunityRec(opportunity);

                            Score_Card__c scorecard = null;
                            executeScorecardRule11(ruleParameter, scorecard);
                        }
                    }
                }
            }
        }
    }
    private void executeScorecardRule11(RulesEngineConfig.RuleParams ruleParameters, Score_Card__c scorecard) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);
        if (
            (ruleParameters.brObj.Scorecard_Required__c != null &&
            (ruleParameters.brObj.Scorecard_Required__c).toLowerCase() == 'yes') &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            scorecard == null
        ) {
            // create recommendation record
            String balRuleId = 'BAL_11';
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
            String balRuleId = 'BAL_11';
            ruleParameters = emptyOpportunityBestActions(ruleParameters, balRuleId);
        }
    }
    private void executeSSORules(RulesEngineConfig.RuleParams ruleParameter, Set<String> opportunityIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Business_Rules__c> businessRuleList = new List<Business_Rules__c>();
        businessRuleList = !ruleParameter.businessRuleMap.isEmpty()
            ? ruleParameter.businessRuleMap.get('Opportunity')
            : null;
        if (businessRuleList != null && !businessRuleList.isEmpty()) {
            Map<String, Single_Sales_Objective__c> SSOMap = getSingleSalesObjective(opportunityIds);
            for (Single_Sales_Objective__c sso : SSOMap.values()) {
                Opportunity opportunity = ruleParameter.oppsMap.get(sso.Blue_Sheet__r.Opportunity__c);
                for (Business_Rules__c brObj : businessRuleList) {
                    if (RulesEvaluationUtil.isMemberOf(brObj, opportunity, brGrpIdAndMembers)) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj)
                            .setBestActionList(bestActionsForBR)
                            .setOpportunityRec(opportunity);

                        executeOpportunityRule13(ruleParameter, sso);
                    }
                }
            }
        }
    }
    private void executeOpportunityRule13(RulesEngineConfig.RuleParams ruleParameters, Single_Sales_Objective__c sso) {
        Set<String> applicableStages = RulesEvaluationUtil.getApplicableStages(ruleParameters);

        if (
            ruleParameters.brObj.is_cust_time_later__c == true &&
            RulesEvaluationUtil.isInCurrencyRange(ruleParameters.brObj, ruleParameters.opportunity) &&
            RulesEvaluationUtil.isStageApplicable(applicableStages, ruleParameters.opportunity.StageName) &&
            (sso.Customer_Timing_for_Priorities__c == 'Work It In' ||
            sso.Customer_Timing_for_Priorities__c == 'Later')
        ) {
            // create recommendation record
            String balRuleId = 'BAL_13';
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
                KF_Sell_Best__c bestActionRec = getSSOBestActionRec(
                    sso.Id,
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
                bestActionRec.Single_sales_objective__c = sso.Id;
                ruleParameters.listBestActionsToInsert.add(bestActionRec);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_13';
            ruleParameters = emptySSOBestActions(ruleParameters, balRuleId, sso.Id);
        }
    }
    private RulesEngineConfig.RuleParams emptyActionPlanBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getActionPlanBestActionRec(
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
    private RulesEngineConfig.RuleParams emptyCurrentBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getCurrentPositionBestActionRec(
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
    private RulesEngineConfig.RuleParams emptyCompetitionBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getCompetitionBestActionRec(
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
    private RulesEngineConfig.RuleParams emptySSOBestActions(
        RulesEngineConfig.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getSSOBestActionRec(
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
    private static map<Id, List<KF_sell_best__c>> getAllBestActions(Set<String> OpportunityIds) {
        map<Id, List<KF_sell_best__c>> mapBestActionsPerBR = new Map<Id, List<KF_sell_best__c>>();
        String query =
            'SELECT Id,Name,Seller_Recommended_Action__c,Manager_Recommended_Action__c,' +
            'Opportunity__c,Business_Rules__c,BestActionRuleId__c,Competition__c,Action_Plan__c,Buying_Influence__c,' +
            'Single_Sales_Objective__c,Score_Card__c,Current_Position__c,Blue_Sheet__c' +
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
    private static KF_sell_best__c getCompetitionBestActionRec(
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
                    bestAct.Competition__c == recId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getCurrentPositionBestActionRec(
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
                    bestAct.Current_Position__c == recId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getSSOBestActionRec(
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
                    bestAct.Single_sales_objective__c == recId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getActionPlanBestActionRec(
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
                    bestAct.Action_Plan__c == recId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
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
}