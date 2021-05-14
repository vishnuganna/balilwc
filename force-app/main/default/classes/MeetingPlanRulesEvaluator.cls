public with sharing class MeetingPlanRulesEvaluator implements RulesEvaluator {
    public void evaluate(set<String> objectIds) {
        executeGreenSheetRules(objectIds);
    }

    private map<Id, List<KF_sell_best__c>> getAllGreenSheetBestActions(Set<String> ParentIds) {
        map<Id, List<KF_sell_best__c>> mapBestActionsPerBR = new Map<Id, List<KF_sell_best__c>>();
        String query =
            'SELECT Id,Name,Seller_Recommended_Action__c,Manager_Recommended_Action__c,' +
            'Business_Rules__c,BestActionRuleId__c,Green_Sheet__c,Green_Sheet_Buying_Influence__c,Getting_Commitment__c' +
            ' FROM KF_sell_best__c WHERE Green_Sheet__c IN :ParentIds';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('ParentIds', ParentIds);
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

    private List<Green_Sheet__c> getGreenSheetData(Set<String> greenSheetIds) {
        List<Green_Sheet__c> listGreenSheets = new List<Green_Sheet__c>();
        String query =
            'SELECT Id,Name,Meeting_Date__c,Opportunity__c,Reason__c' +
            ' FROM Green_Sheet__c WHERE Id IN: greenSheetIds';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('greenSheetIds', greenSheetIds);
        listGreenSheets = DataFactory.read(query, paramters);
        return listGreenSheets;
    }
    private List<Green_Sheet_Buying_Influence__c> getGreenSheetBIs(Set<String> greenSheetIds) {
        List<Green_Sheet_Buying_Influence__c> listGreenSheetBIs = new List<Green_Sheet_Buying_Influence__c>();
        String query =
            'SELECT Id,Name,Green_Sheet__c,Green_Sheet__r.Meeting_Date__c,Green_Sheet__r.Opportunity__c,Concept__c' +
            ' FROM Green_Sheet_Buying_Influence__c WHERE Green_Sheet__c IN: greenSheetIds';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('greenSheetIds', greenSheetIds);
        listGreenSheetBIs = DataFactory.read(query, paramters);

        return listGreenSheetBIs;
    }
    private List<Getting_Commitment__c> getCommitmentData(Set<String> greenSheetIds) {
        List<Getting_Commitment__c> listGreenSheetCommitments = new List<Getting_Commitment__c>();
        String query =
            'SELECT Id,Name,Green_Sheet__c,Green_Sheet__r.Meeting_Date__c,Green_Sheet__r.Opportunity__c,' +
            'Minimum_Acceptable_Action_Commit__c,Best_Action_Commitment__c' +
            ' FROM Getting_Commitment__c WHERE Green_Sheet__c IN: greenSheetIds';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('greenSheetIds', greenSheetIds);
        listGreenSheetCommitments = DataFactory.read(query, paramters);

        return listGreenSheetCommitments;
    }

    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts,PMD.CognitiveComplexity')
    private void executeGreenSheetRules(set<String> greenSheetIds) {
        Map<String, List<Business_Rules__c>> businessRuleMap = RulesEvaluationUtil.getBusinessRules();

        List<Business_Rules__c> listBusinessRules = new List<Business_Rules__c>();
        listBusinessRules = !businessRuleMap.isEmpty() ? businessRuleMap.get('Meeting Plan') : null;
        if (listBusinessRules != null && !listBusinessRules.isEmpty()) {
            List<KF_sell_best__c> listBestActionsToInsert = new List<KF_sell_best__c>();
            List<KF_sell_best__c> listBestActionsToUpdate = new List<KF_sell_best__c>();
            Map<String, List<AlertRecommendationsWrapper>> mapRuleMSg = new AlertRecommendationsMessages()
                .getAlertRecommendations();
            @SuppressWarnings('PMD.VariableNamingConventions')
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
            map<Id, List<KF_sell_best__c>> allBestActions = new Map<Id, List<KF_sell_best__c>>();
            allBestActions = getAllGreenSheetBestActions(greenSheetIds);
            GreenSheetRulesUtil.RuleParams parameters = new GreenSheetRulesUtil.RuleParams()
                .setAllBestActionsMap(allBestActions)
                .setBestActionLstToInsert(listBestActionsToInsert)
                .setBestActionLstToUpdate(listBestActionsToUpdate)
                .setMapRuleMSg(mapRuleMSg)
                .setBusinessRules(listBusinessRules)
                .setBalIdBrIdMap(BALandBRIdMap);

            executeGreenSheetRules(parameters, greenSheetIds);
            executeGreenSheetBIRules(parameters, greenSheetIds);
            executeGreenSheetCommitmentRules(parameters, greenSheetIds);

            GreenSheetRulesUtil.upsertBestActions(parameters);
        }
    }

    private void executeGreenSheetRules(GreenSheetRulesUtil.RuleParams ruleParameter, set<String> greenSheetIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Green_Sheet__c> greenSheets = getGreenSheetData(greenSheetIds);
        for (Green_Sheet__c greenSheet : greenSheets) {
            for (Business_Rules__c brObj : ruleParameter.businessRuleList) {
                if (greenSheet.Opportunity__c != null) {
                    bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                    ruleParameter = ruleParameter.setBrObj(brObj).setBestActionList(bestActionsForBR);
                    executeGreenSheetRule1(ruleParameter, greenSheet);
                }
            }
        }
    }
    private void executeGreenSheetRule1(GreenSheetRulesUtil.RuleParams ruleParameters, Green_Sheet__c greenSheet) {
        Datetime meetingDate = greenSheet.Meeting_Date__c;
        Date meetingDateVal;
        if (meetingDate != null) {
            meetingDateVal = Date.newinstance(meetingDate.year(), meetingDate.month(), meetingDate.day());
        }
        Date today = Date.Today();
        if (
            ruleParameters.brObj.Is_Valid_Business_Reason_Added__c &&
            ruleParameters.brObj.Number_of_Days_Before_Meeting__c != null &&
            meetingDateVal != null &&
            today.daysBetween(meetingDateVal) < ruleParameters.brObj.Number_of_Days_Before_Meeting__c &&
            (greenSheet.Reason__c == null ||
            greenSheet.Reason__c == '')
        ) {
            String balRuleId = 'BAL_27';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
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
            KF_Sell_Best__c bestActionRec = getGreenSheetBestActionRec(
                greenSheet.Id,
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
            bestActionRec.Green_Sheet__c = greenSheet.Id;
            bestActionRec.Opportunity__c = greenSheet.Opportunity__c;
            bestActionRec.Alert_Type__c = 'Greensheet';
            ruleParameters.listBestActionsToInsert.add(bestActionRec);
        } else {
            String balRuleId = 'BAL_27';
            ruleParameters = emptyGreenSheetBestActions(ruleParameters, balRuleId, greenSheet.Id);
        }
    }
    private void executeGreenSheetBIRules(GreenSheetRulesUtil.RuleParams ruleParameter, set<String> greenSheetIds) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Green_Sheet_Buying_Influence__c> greenBIs = getGreenSheetBIs(greenSheetIds);
        for (Green_Sheet_Buying_Influence__c BI : greenBIs) {
            for (Business_Rules__c brObj : ruleParameter.businessRuleList) {
                if (BI.Green_Sheet__r.Opportunity__c != null) {
                    bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                    ruleParameter = ruleParameter.setBrObj(brObj).setBestActionList(bestActionsForBR);
                    executeGreenSheetRule2(ruleParameter, BI);
                }
            }
        }
    }
    private void executeGreenSheetRule2(
        GreenSheetRulesUtil.RuleParams ruleParameters,
        Green_Sheet_Buying_Influence__c greenBI
    ) {
        Datetime meetingDate = greenBI.Green_Sheet__r.Meeting_Date__c;
        Date meetingDateVal;
        if (meetingDate != null) {
            meetingDateVal = Date.newinstance(meetingDate.year(), meetingDate.month(), meetingDate.day());
        }
        Date today = Date.Today();
        if (
            ruleParameters.brObj.Is_Concept_for_BI_Added__c &&
            ruleParameters.brObj.Number_of_Days_Before_Meeting__c != null &&
            meetingDateVal != null &&
            today.daysBetween(meetingDateVal) < ruleParameters.brObj.Number_of_Days_Before_Meeting__c &&
            (greenBI.Concept__c == null ||
            greenBI.Concept__c == '')
        ) {
            String balRuleId = 'BAL_28';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
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
            KF_Sell_Best__c bestActionRec = getGreenSheetBIBestActionRec(
                greenBI.Id,
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
            bestActionRec.Green_Sheet__c = greenBI.Green_Sheet__r.Id;
            bestActionRec.Green_Sheet_Buying_Influence__c = greenBI.Id;
            bestActionRec.Opportunity__c = greenBI.Green_Sheet__r.Opportunity__c;
            bestActionRec.Alert_Type__c = 'Greensheet';
            ruleParameters.listBestActionsToInsert.add(bestActionRec);
        } else {
            String balRuleId = 'BAL_28';
            ruleParameters = emptyGreenSheetBIBestActions(ruleParameters, balRuleId, greenBI.Id);
        }
    }
    private void executeGreenSheetCommitmentRules(
        GreenSheetRulesUtil.RuleParams ruleParameter,
        set<String> greenSheetIds
    ) {
        List<KF_sell_best__c> bestActionsForBR = new List<KF_sell_best__c>();
        List<Getting_Commitment__c> commitments = getCommitmentData(greenSheetIds);
        if (!commitments.isEmpty()) {
            for (Getting_Commitment__c com : commitments) {
                for (Business_Rules__c brObj : ruleParameter.businessRuleList) {
                    if (com.Green_Sheet__r.Opportunity__c != null) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj).setBestActionList(bestActionsForBR);
                        executeGreenSheetRule3(ruleParameter, com, null);
                        executeGreenSheetRule4(ruleParameter, com, null);
                    }
                }
            }
        } else {
            List<Green_Sheet__c> greenSheets = getGreenSheetData(greenSheetIds);
            for (Green_Sheet__c greenSheet : greenSheets) {
                for (Business_Rules__c brObj : ruleParameter.businessRuleList) {
                    if (greenSheet.Opportunity__c != null) {
                        bestActionsForBR = ruleParameter.allBestActionsMap.get(brObj.Id);
                        ruleParameter = ruleParameter.setBrObj(brObj).setBestActionList(bestActionsForBR);
                        executeGreenSheetRule3(ruleParameter, null, greenSheet);
                        executeGreenSheetRule4(ruleParameter, null, greenSheet);
                    }
                }
            }
        }
    }
    private void executeGreenSheetRule3(
        GreenSheetRulesUtil.RuleParams ruleParameters,
        Getting_Commitment__c commitment,
        Green_Sheet__c greenSheet
    ) {
        Datetime meetingDate;
        Id greenSheetId;
        if (commitment != null) {
            greenSheetId = commitment.Green_Sheet__r.Id;
        } else {
            greenSheetId = greenSheet.Id;
        }
        if (commitment != null) {
            meetingDate = commitment.Green_Sheet__r.Meeting_Date__c;
        } else {
            meetingDate = greenSheet.Meeting_Date__c;
        }
        Date meetingDateVal;
        if (meetingDate != null) {
            meetingDateVal = Date.newinstance(meetingDate.year(), meetingDate.month(), meetingDate.day());
        }
        Date today = Date.Today();
        if (
            ruleParameters.brObj.Is_Minimum_Action_Commitment_Added__c &&
            ruleParameters.brObj.Number_of_Days_Before_Meeting__c != null &&
            meetingDateVal != null &&
            today.daysBetween(meetingDateVal) < ruleParameters.brObj.Number_of_Days_Before_Meeting__c &&
            (commitment == null ||
            (commitment != null &&
            (commitment.Minimum_Acceptable_Action_Commit__c == null ||
            commitment.Minimum_Acceptable_Action_Commit__c == '')))
        ) {
            String balRuleId = 'BAL_25';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
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
            KF_Sell_Best__c bestActionRec = getGreenSheetBestActionRec(
                greenSheetId,
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
            bestActionRec.Green_Sheet__c = greenSheetId;
            //bestActionRec.Getting_Commitment__c = commitment.Id;
            bestActionRec.Opportunity__c = commitment != null
                ? commitment.Green_Sheet__r.Opportunity__c
                : greenSheet.Opportunity__c;
            bestActionRec.Alert_Type__c = 'Greensheet';
            ruleParameters.listBestActionsToInsert.add(bestActionRec);
        } else {
            String balRuleId = 'BAL_25';
            ruleParameters = emptyGreenSheetBestActions(ruleParameters, balRuleId, greenSheetId);
        }
    }
    private void executeGreenSheetRule4(
        GreenSheetRulesUtil.RuleParams ruleParameters,
        Getting_Commitment__c commitment,
        Green_Sheet__c greenSheet
    ) {
        Datetime meetingDate;
        Id greenSheetId;
        if (commitment != null) {
            greenSheetId = commitment.Green_Sheet__r.Id;
        } else {
            greenSheetId = greenSheet.Id;
        }
        if (commitment != null) {
            meetingDate = commitment.Green_Sheet__r.Meeting_Date__c;
        } else {
            meetingDate = greenSheet.Meeting_Date__c;
        }
        Date meetingDateVal;
        if (meetingDate != null) {
            meetingDateVal = Date.newinstance(meetingDate.year(), meetingDate.month(), meetingDate.day());
        }
        Date today = Date.Today();
        if (
            ruleParameters.brObj.Is_Best_Action_Commitment_Added__c &&
            ruleParameters.brObj.Number_of_Days_Before_Meeting__c != null &&
            meetingDateVal != null &&
            today.daysBetween(meetingDateVal) < ruleParameters.brObj.Number_of_Days_Before_Meeting__c &&
            (commitment == null ||
            (commitment != null &&
            (commitment.Best_Action_Commitment__c == null ||
            commitment.Best_Action_Commitment__c == '')))
        ) {
            String balRuleId = 'BAL_26';
            List<AlertRecommendationsWrapper> messageActionWrapperList = ruleParameters.mapRuleMSg.get(balRuleId);
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
            KF_Sell_Best__c bestActionRec = getGreenSheetBestActionRec(
                greenSheetId,
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
            bestActionRec.Green_Sheet__c = greenSheetId;
            //bestActionRec.Getting_Commitment__c = commitment.Id;
            bestActionRec.Opportunity__c = commitment != null
                ? commitment.Green_Sheet__r.Opportunity__c
                : greenSheet.Opportunity__c;
            bestActionRec.Alert_Type__c = 'Greensheet';
            ruleParameters.listBestActionsToInsert.add(bestActionRec);
        } else {
            String balRuleId = 'BAL_26';
            ruleParameters = emptyGreenSheetBestActions(ruleParameters, balRuleId, greenSheetId);
        }
    }
    private GreenSheetRulesUtil.RuleParams emptyGreenSheetBestActions(
        GreenSheetRulesUtil.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getGreenSheetBestActionRec(
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
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getGreenSheetBestActionRec(
        String recordId,
        List<KF_Sell_Best__c> bestActions,
        String BRId,
        String ruleId
    ) {
        KF_sell_best__c bestAction;
        if (bestActions != null && !bestActions.isEmpty()) {
            for (KF_Sell_Best__c bestAct : bestActions) {
                if (
                    bestAct.Business_Rules__c == BRId &&
                    bestAct.Green_Sheet__c == recordId &&
                    bestAct.BestActionRuleId__c == ruleId
                ) {
                    bestAction = bestAct;
                }
            }
        }
        return bestAction;
    }
    private GreenSheetRulesUtil.RuleParams emptyGreenSheetBIBestActions(
        GreenSheetRulesUtil.RuleParams ruleParameters,
        String balRuleId,
        Id recId
    ) {
        KF_Sell_Best__c bestActionRec = getGreenSheetBIBestActionRec(
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
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static KF_sell_best__c getGreenSheetBIBestActionRec(
        String recordId,
        List<KF_Sell_Best__c> bestActions,
        String BRId,
        String ruleId
    ) {
        KF_sell_best__c bestAction;
        if (bestActions != null && !bestActions.isEmpty()) {
            for (KF_Sell_Best__c bestAct : bestActions) {
                if (
                    bestAct.Business_Rules__c == BRId &&
                    bestAct.Green_Sheet_Buying_Influence__c == recordId &&
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