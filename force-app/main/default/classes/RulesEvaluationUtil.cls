public with sharing class RulesEvaluationUtil {
    public static List<Blue_Sheet__c> getBlueSheets(Set<String> oppIds) {
        String soql = 'Select Id,Name,Opportunity__c from Blue_Sheet__c where  Opportunity__c=:oppIds';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIds', oppIds);
        List<Blue_Sheet__c> bsLst = DataFactory.read(soql, parameters);
        return bsLst;
    }

    public static boolean isMemberOf(
        Business_Rules__c brObj,
        Opportunity opportunity,
        Map<String, Set<String>> brGrpIdAndMembers
    ) {
        boolean result = false;
        if (brObj.Business_Rules_Group__c == null) {
            return result;
        }

        Set<String> brGrpMemIdsSet = brGrpIdAndMembers.get(brObj.Business_Rules_Group__c);
        String ownerId = opportunity.OwnerId;
        String profileId = opportunity.Owner.ProfileId;

        if (brGrpMemIdsSet != null && (brGrpMemIdsSet.contains(ownerId) || brGrpMemIdsSet.contains(profileId))) {
            result = true;
        }

        return result;
    }

    public static Map<String, List<Business_Rules__c>> getBusinessRules() {
        String brSoql =
            'Select Id,Name, Opportunity_Currency_Fields__c, Maximum_Range__c, Minimum_Range__c,Opportunity_Stage_Global__c,Is_a_Blue_Sheet_required__c,' +
            'Best_Action_Due_Date__c,BS_Req_for_certain_Rev_Range__c,Max_Days_Allowed_in_a_Opty_Stage__c,' +
            'Max_Days_Allowed_Since_Last_BS_Update__c,Min_Number_of_Actions_For_a_Opty_Stage__c,Opty_Amount_1__c,' +
            'Opty_Amount_2__c,Stage_BS_Req__r.Name,Stage_BS_Req_Rev_Range__r.Name,Stage_Min_Poss_Action__r.Name,' +
            'Stage_Scorecard_req__r.Name,Stage_BI_Role__r.Name,Stage_BS_Last_Updated__r.Name,Long_SSO_Sales_Stage__r.Name,' +
            'Scorecard_Required__c,Buying_Influence_Role__c,Business_Rules_Group__c,OptyStage_BI_Role__c,OptyStage_Min_Poss_Action__c,' +
            'OptyStage_Scorecard_req__c,OptyStage_BS_Last_Updated__c,OptyStage_Long_SSO_Sales_Stage__c,OptyStage_BS_Req__c,' +
            'OptyStage_BS_Req_Rev_Range__c,Min_Number_Buying_Influence_Contacts__c,Business_Rule_Catagory__c,is_closed_date_past__c,' +
            'is_competitor_identified__c,is_pos_competition_zero__c,is_curr_pos_negative__c,is_past_action_due__c,is_cust_time_later__c,' +
            'is_negative_rating__c,is_high_rated_BI_no_coach__c,is_person_win_identified__c,is_business_result_identified__c,' +
            'is_coach_with_low_BI__c,is_discon_mode_cust_timing__c,Scorecard_Number_of_Days_Updated__c,Minimum_Score__c,' +
            'Maximum_Score__c,OpportunityCriteria_Minimum_Score__c,OpportunityCriteria_Maximum_Score__c,BusinessCriteria_Minimum_Score__c,' +
            'BusinessCriteria_Maximum_Score__c,Check_Scorecard_Last_Modified__c,Check_Total_Score__c,Check_Opportunity_Score__c,' +
            'Check_Business_Criteria_Score__c,Number_of_Days_Before_Meeting__c,' +
            'Is_Minimum_Action_Commitment_Added__c,Is_Concept_for_BI_Added__c,Is_Valid_Business_Reason_Added__c,Is_Best_Action_Commitment_Added__c' +
            ' FROM Business_Rules__c where  Business_Rule_Catagory__c!=NULL AND IsActive__c=true';
        Map<String, Object> parameters = new Map<String, Object>();
        // parameters.put('category', category);
        List<Business_Rules__c> listBusinesRules = new List<Business_Rules__c>();
        listBusinesRules = DataFactory.read(brSoql, parameters);
        Map<String, List<Business_Rules__c>> businessRulesMap = new Map<String, List<Business_Rules__c>>();
        if (!listBusinesRules.isEmpty()) {
            for (Business_Rules__c br : listBusinesRules) {
                if (!businessRulesMap.containsKey(br.Business_Rule_Catagory__c)) {
                    businessRulesMap.put(br.Business_Rule_Catagory__c, new List<Business_Rules__c>{ br });
                } else {
                    businessRulesMap.get(br.Business_Rule_Catagory__c).add(br);
                }
            }
        }
        return businessRulesMap;
    }

    public static Map<String, Set<String>> getBRGrpMembers() {
        // for a BR Grp Member, get all of its users and profiles
        Map<String, Set<String>> mapBrGrpMemIdUserIdProfileId = new Map<String, Set<String>>();
        Map<String, List<Business_Rules_Group_Member__c>> mapBrGrpIdAndMembers = getBrGrpMemrecords();
        for (String brGrpId : mapBrGrpIdAndMembers.keySet()) {
            List<Business_Rules_Group_Member__c> brGrpMemLst = mapBrGrpIdAndMembers.get(brGrpId);
            if (brGrpMemLst != null && !brGrpMemLst.isEmpty()) {
                Set<String> userAndProfileIdsSet = new Set<String>();
                for (Business_Rules_Group_Member__c brGrpMem : brGrpMemLst) {
                    if (brGrpMem.Member_Profile__c != null) {
                        userAndProfileIdsSet.add(brGrpMem.Member_Profile__r.Profile_id__c);
                    }
                    if (brGrpMem.Member_Name__c != null) {
                        userAndProfileIdsSet.add(brGrpMem.Member_Name__c);
                    }
                }
                mapBrGrpMemIdUserIdProfileId.put(brGrpId, userAndProfileIdsSet);
            }
        }
        return mapBrGrpMemIdUserIdProfileId;
    }

    // Grp member id and its list of record
    public static Map<String, List<Business_Rules_Group_Member__c>> getBrGrpMemrecords() {
        String soqlBRGrpMember = 'Select Member_Profile__r.Profile_id__c,Business_Rules_Group__c,Member_Name__c from Business_Rules_Group_Member__c';
        Map<String, Object> parameters = new Map<String, Object>();
        //parameters.put('brGrpIdSet', brGrpIdSet);
        List<Business_Rules_Group_Member__c> brGrpMemLst = DataFactory.read(soqlBRGrpMember, parameters);
        Map<String, List<Business_Rules_Group_Member__c>> mapBrGrpIdAndMembers = new Map<String, List<Business_Rules_Group_Member__c>>();
        List<Business_Rules_Group_Member__c> brGrpMemLstTmp = new List<Business_Rules_Group_Member__c>();
        for (Business_Rules_Group_Member__c brGrpMem : brGrpMemLst) {
            if (mapBrGrpIdAndMembers.containsKey(brGrpMem.Business_Rules_Group__c)) {
                brGrpMemLstTmp = mapBrGrpIdAndMembers.get(brGrpMem.Business_Rules_Group__c);
                brGrpMemLstTmp.add(brGrpMem);
            } else {
                brGrpMemLstTmp = new List<Business_Rules_Group_Member__c>();
                brGrpMemLstTmp.add(brGrpMem);
            }
            mapBrGrpIdAndMembers.put(brGrpMem.Business_Rules_Group__c, brGrpMemLstTmp);
        }
        return mapBrGrpIdAndMembers;
    }

    public static void upsertBestActions(RulesEngineConfig.RuleParams ruleParameter) {
        if (ruleParameter == null) {
            return;
        }
        if (!ruleParameter.listBestActionsToInsert.isEmpty()) {
            DataFactory.upsurt(ruleParameter.listBestActionsToInsert);
        }

        if (!ruleParameter.listBestActionsToUpdate.isEmpty()) {
            List<KF_sell_best__c> bestActionsToUpdate = removeDupes(ruleParameter.listBestActionsToUpdate);
            DataFactory.modify(bestActionsToUpdate);
        }
    }

    private static List<KF_sell_best__c> removeDupes(List<KF_sell_best__c> recomLst) {
        List<KF_sell_best__c> seLstToUpdate = new List<KF_sell_best__c>();
        Map<String, KF_sell_best__c> mapRecomm = new Map<String, KF_sell_best__c>();
        for (KF_sell_best__c recomm : recomLst) {
            if (!mapRecomm.containsKey(recomm.Id)) {
                mapRecomm.put(recomm.Id, recomm);
            }
        }
        return mapRecomm.values();
    }

    public static Set<String> getApplicableStages(RulesEngineConfig.RuleParams ruleParameters) {
        Set<String> applicableStages = new Set<String>();
        if (
            ruleParameters.brObj.Opportunity_Stage_Global__c != null &&
            ruleParameters.brObj.Opportunity_Stage_Global__c != ''
        ) {
            applicableStages = (Set<String>) ApexCommonUtil.convertStringToSetOrList(
                ruleParameters.brObj.Opportunity_Stage_Global__c,
                ',',
                'set'
            );
        }

        return applicableStages;
    }
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static KF_Sell_Best__c mappingBestActionRecordFields(
        Business_Rules__c brObj,
        AlertRecommendationsWrapper MessageActionWrapper,
        String ruleId,
        KF_Sell_Best__c bestActionRec
    ) {
        if (MessageActionWrapper != null) {
            AlertTemplateWrapper actionAlert;
            AlertTemplateWrapper sellerEmailAlert;
            AlertTemplateWrapper managerEmailAlert;

            if (MessageActionWrapper.action != null) {
                actionAlert = MessageActionWrapper.action;
                bestActionRec.Associated_Object__c = actionAlert.associatedObject;
            }
            if (actionAlert != null && actionAlert.alertEnabled == true) {
                if (actionAlert.overrideHeader == true) {
                    bestActionRec.Action_Title__c = actionAlert.customAlertHeader;
                } else {
                    bestActionRec.Action_Title__c = actionAlert.defaultAlertHeader;
                }
                if (actionAlert.overrideMessage == true) {
                    bestActionRec.Seller_Recommended_Action__c = actionAlert.customAlertMessage;
                } else {
                    bestActionRec.Seller_Recommended_Action__c = actionAlert.defaultAlertMessage;
                }
            }
            if (MessageActionWrapper.sellerEmail != null) {
                sellerEmailAlert = MessageActionWrapper.sellerEmail;
                bestActionRec.Associated_Object__c = sellerEmailAlert.associatedObject;
            }
            if (sellerEmailAlert != null && sellerEmailAlert.alertEnabled == true) {
                if (sellerEmailAlert.overrideHeader == true) {
                    bestActionRec.Action_Title_Seller__c = sellerEmailAlert.customAlertHeader;
                } else {
                    bestActionRec.Action_Title_Seller__c = sellerEmailAlert.defaultAlertHeader;
                }
                if (sellerEmailAlert.overrideMessage == true) {
                    bestActionRec.Seller_Email_Text__c = sellerEmailAlert.customAlertMessage;
                } else {
                    bestActionRec.Seller_Email_Text__c = sellerEmailAlert.defaultAlertMessage;
                }
                bestActionRec.Seller_URL_Text__c = sellerEmailAlert.urlText;
                bestActionRec.Seller_URL_Link__c = sellerEmailAlert.urlLink;
            }
            if (MessageActionWrapper.managerEmail != null) {
                managerEmailAlert = MessageActionWrapper.managerEmail;
                bestActionRec.Associated_Object__c = managerEmailAlert.associatedObject;
            }
            if (managerEmailAlert != null && managerEmailAlert.alertEnabled == true) {
                if (managerEmailAlert.overrideHeader == true) {
                    bestActionRec.Action_Title_Manager__c = managerEmailAlert.customAlertHeader;
                } else {
                    bestActionRec.Action_Title_Manager__c = managerEmailAlert.defaultAlertHeader;
                }
                if (managerEmailAlert.overrideMessage == true) {
                    bestActionRec.Manager_Recommended_Action__c = managerEmailAlert.customAlertMessage;
                } else {
                    bestActionRec.Manager_Recommended_Action__c = managerEmailAlert.defaultAlertMessage;
                }
                bestActionRec.Manager_URL_Text__c = managerEmailAlert.urlText;
                bestActionRec.Manager_URL_Link__c = managerEmailAlert.urlLink;
            }
        }
        bestActionRec.BestActionRuleId__c = ruleId;

        if (brObj != null) {
            bestActionRec.Business_Rules__c = brObj.Id;
        }
        return bestActionRec;
    }
    public static KF_Sell_Best__c mappingBestActionFieldsToEmpty(KF_Sell_Best__c bestActionRecord) {
        KF_Sell_Best__c bestActionRec = new KF_Sell_Best__c(id = bestActionRecord.Id);
        bestActionRec.Manager_Recommended_Action__c = '';
        bestActionRec.Seller_Recommended_Action__c = '';
        bestActionRec.Seller_Email_Text__c = '';
        bestActionRec.Action_Title__c = '';
        bestActionRec.Action_Title_Manager__c = '';
        bestActionRec.Action_Title_Seller__c = '';
        bestActionRec.Seller_URL_Text__c = '';
        bestActionRec.Seller_URL_Link__c = '';
        bestActionRec.Manager_URL_Text__c = '';
        bestActionRec.Manager_URL_Link__c = '';

        return bestActionRec;
    }

    //TODO: Too many conditions inside. Needs refractor.
    public static boolean isInCurrencyRange(Business_Rules__c businessRule, Opportunity opportunity) {
        String fieldName = businessRule.Opportunity_Currency_Fields__c;
        Double minValue = (Double) businessRule.Minimum_Range__c;
        Double maxValue = (Double) businessRule.Maximum_Range__c;
        Boolean result = true;
        Double fieldValue = null;

        if (fieldName != null) {
            if (fieldName == 'ExpectedRevenue') {
                // Special case for expected revenue.

                if (Opportunity.get('Amount') != null) {
                    fieldValue = ((Double) Opportunity.get('Amount') * (Double) Opportunity.get('Probability')) / 100;
                } else {
                    fieldValue = 0;
                }
            } else if (Opportunity.get(fieldName) != null) {
                // Handles all the fields except Expected revenue.
                fieldValue = ((Double) Opportunity.get(fieldName));
            } else {
                fieldValue = 0;
            }
        }
        if (fieldValue != null) {
            if (maxValue == null) {
                maxValue = fieldValue + 1;
            }

            if (minValue == null) {
                minValue = fieldValue - 1;
            }

            if ((fieldValue < minValue) || (fieldValue > maxValue)) {
                result = false;
            }
        }
        return result;
    }
    @TestVisible
    public static boolean isStageApplicable(Set<String> applicableStages, String stageName) {
        return (applicableStages == null || applicableStages.isEmpty()) ? true : applicableStages.contains(stageName);
    }

    public static map<Id, List<KF_sell_best__c>> getAllBestActions(set<String> OpportunityIds) {
        map<Id, List<KF_sell_best__c>> mapBestActionsPerBR = new Map<Id, List<KF_sell_best__c>>();
        String query =
            'SELECT Id,Name,Seller_Recommended_Action__c,Manager_Recommended_Action__c,' +
            'Buying_Influence__c,Business_Rules__c,BestActionRuleId__c,Opportunity__c,Competition__c,Action_Plan__c,Blue_Sheet__c,' +
            'Single_Sales_Objective__c,Score_Card__c,Current_Position__c' +
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

    public static Map<Id, List<Insight__c>> getAllInsights(Set<String> OpportunityIds) {
        Map<Id, List<Insight__c>> mapInsightPerBR = new Map<Id, List<Insight__c>>();
        String query =
            'SELECT Id,Name,Blue_Sheet__c,Business_Rules__c,Competition__c,Insight_Alert__c,Opportunity__c' +
            ' FROM Insight__c WHERE Opportunity__c IN :OpportunityIds';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('OpportunityIds', OpportunityIds);
        List<Insight__c> insightsList = DataFactory.read(query, parameters);
        for (Insight__c insightObj : insightsList) {
            if (!mapInsightPerBR.containsKey(insightObj.Business_Rules__c)) {
                mapInsightPerBR.put(insightObj.Business_Rules__c, new List<Insight__c>{ insightObj });
            } else {
                mapInsightPerBR.get(insightObj.Business_Rules__c).add(insightObj);
            }
        }
        return mapInsightPerBR;
    }

    public static Insight__c mappingInsightFieldsToEmpty(Insight__c insightRecord) {
        Insight__c insightRec = new Insight__c(id = insightRecord.Id);
        // insightRec.Competition__c = null;
        insightRec.Insight_Alert__c = null;
        insightRec.Blue_Sheet__c = null;
        insightRec.Opportunity__c = null;
        return insightRec;
    }

    public static void upsertInsights(RulesEngineConfig.RuleParams ruleParameter) {
        if (ruleParameter == null) {
            return;
        }
        if (!ruleParameter.listInsightsToInsert.isEmpty()) {
            DataFactory.upsurt(ruleParameter.listInsightsToInsert);
        }

        if (!ruleParameter.listInsightsToUpdate.isEmpty()) {
            DataFactory.modify(ruleParameter.listInsightsToUpdate);
        }
    }
}