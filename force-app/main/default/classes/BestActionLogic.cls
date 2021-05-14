/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-277 (part of main US KFS-277) : Class to execute Best Action logic considering StrategyEngine & BusinessRule records and create Recommedation record along with seller and manager messages
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-05-30
 *
 */
@SuppressWarnings(
    'PMD.AvoidDeeplyNestedIfStmts,PMD.EmptyStatementBlock,PMD.NcssMethodCount,PMD.ExcessiveClassLength,PMD.CognitiveComplexity'
)
public with sharing class BestActionLogic {
    public static Boolean bestActionLogicInsertFlag = true;
    public static Boolean bestActionLogicUpdateFlag = true;
    public static Boolean bestActionLogicInsertSEFlag = true;
    public static Boolean bestActionLogicUpdateSEFlag = true;

    public static void upsertRecommendations(String opptyId) {
        /*String opptyQuery =
            'Select Id,Name,StageName,Amount,LastModifiedDate,CloseDate,Blue_Sheet_Count__c,AccountId,Account.Name,ExpectedRevenue' +
            ' FROM Opportunity WHERE Id =:opptyId LIMIT 1';
        if (Schema.sObjectType.Opportunity.fields.Probability.isAccessible()) {
            opptyQuery =
                'Select Id,Name,StageName,LastModifiedDate,CloseDate,Blue_Sheet_Count__c,AccountId,Account.Name,Probability' +
                currencyFields +
                ' FROM Opportunity WHERE Id =:opptyId LIMIT 1';
        }
        Map<String, Object> opptyparamters = new Map<String, Object>();
        opptyparamters.put('opptyId', opptyId);
        List<opportunity> opptyList = DataFactory.read(opptyQuery, opptyparamters);
        upsertRecommendationsRecforBS(opptyList);*/
    }

    public static void upsertRecommendationsRecforBS(List<Opportunity> oppList) {
        /*if (Schema.sObjectType.Blue_Sheet__c.fields.Action_Plan_Progress__c.isUpdateable()) {
            Map<String, RecommendationsActionWrapper> mapRuleMSg = new Map<String, RecommendationsActionWrapper>();
            RecommendationsActionMessages recomActionMsgObj = new RecommendationsActionMessages();
            mapRuleMSg = recomActionMsgObj.getRecommendationsActionMessages();
            List<Recommendations__c> recommedationsRectoUpsert = new List<Recommendations__c>();
            Map<String, Set<String>> brGrpIdAndMembers = getBRGrpMembers();
            List<Business_Rules__c> listBusinessRules = getBusinessRulesRecords();
            Set<String> oppIdSet = new Set<String>();
            Set<String> applicableStages = new Set<String>();
            for (Opportunity oppObj : oppList) {
                oppIdSet.add(oppObj.Id);
            }

            String soqlBluesheet = 'Select Id,Name,Opportunity__c from Blue_Sheet__c where Opportunity__c=:oppIdSet';
            Map<String, Object> parameters = new Map<String, Object>();
            parameters.put('oppIdSet', oppIdSet);
            List<Blue_Sheet__c> bsLst = DataFactory.read(soqlBluesheet, parameters);
            Map<String, String> bsOppMap = new Map<String, String>();
            for (Blue_Sheet__c bs : bsLst) {
                bsOppMap.put(bs.Opportunity__c, bs.id);
            }

            Map<String, String> mapOppOwnerId = getOppOwnerId(oppIdSet);
            Map<String, String> mapUserProfileId = new Map<String, String>();
            if (!mapOppOwnerId.isEmpty()) {
                mapUserProfileId = getUserProfileId(new Set<String>(mapOppOwnerId.values()));
            }

            // 1 SE record may apply to 1 or many BR records
            // 1 BR record may apply to 1 or many SE records
            //Map<String, Map<String,Recommendations__c>> masterSEIDRecommendationRec = getRecommendationRecs(seIdSet);
            // this map will have set of BR ids for each SE id
            Map<String, Set<String>> mapSEidBrIds = getOppidBRids(oppIdSet);
            Map<String, List<Recommendations__c>> mapBrRecommenRecsforBS = getBrIdRecomLstforBS(oppIdSet);
            List<Recommendations__c> recomLstToInsert = new List<Recommendations__c>();
            List<Recommendations__c> recomLstToUpdate = new List<Recommendations__c>();
            for (Opportunity opp : oppList) {
                if (!listBusinessRules.isEmpty()) {
                    for (Business_Rules__c brObj : listBusinessRules) {
                        Set<String> brGrpMemIdsSet = brGrpIdAndMembers.get(brObj.Business_Rules_Group__c);
                        String ownerId = mapOppOwnerId.get(opp.id);
                        String profileId = mapUserProfileId.get(ownerId);
                        //KFS-863 - new stage picklist field update
                        if (brObj.Opportunity_Stage_Global__c != null && brObj.Opportunity_Stage_Global__c != '') {
                            applicableStages = (Set<String>) ApexCommonUtil.convertStringToSetOrList(
                                brObj.Opportunity_Stage_Global__c,
                                ',',
                                'set'
                            );
                        }

                        if (
                            brGrpMemIdsSet != null &&
                            (brGrpMemIdsSet.contains(ownerId) || brGrpMemIdsSet.contains(profileId))
                        ) {
                            List<Recommendations__c> recommedationLstAll = mapBrRecommenRecsforBS.get(brObj.id);
                            if (
                                brObj.Is_a_Blue_Sheet_required__c == 'Yes' && isInCurrencyRange(brObj, opp) &&
                                isStageApplicable(applicableStages, opp.StageName) &&
                                bsOppMap.get(opp.Id) == null
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_1';
                                Recommendations__c recommObj = getRecommRecforBS(
                                    recommedationLstAll,
                                    balRuleId,
                                    opp.Id
                                );
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreateforBS(
                                        brObj,
                                        opp,
                                        recommObj,
                                        recommenActionWrapper,
                                        balRuleId
                                    );
                                    //recommObj.Blue_Sheet__c = seObj.Blue_Sheet__c;
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_1';
                                Recommendations__c recommObj = getRecommRecforBS(
                                    recommedationLstAll,
                                    balRuleId,
                                    opp.Id
                                );
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }
                        }
                    }
                }
            }

            if (recomLstToInsert != null && !recomLstToInsert.isEmpty()) {
                DataFactory.create(recomLstToInsert);
            }
            if (recomLstToUpdate != null && !recomLstToUpdate.isEmpty()) {
                DataFactory.modify(recomLstToUpdate);
            }
        }*/
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static Recommendations__c recommedationObjectCreateforBS(
        Business_Rules__c brObj,
        Opportunity opp,
        Recommendations__c recommObj,
        RecommendationsActionWrapper recommenActionWrapper,
        String balRuleId
    ) {
        Recommendations__c recObj = new Recommendations__c();
        /*recObj.Business_Rules__c = brObj.Id;
        recObj.Manager_Recommended_Action_Message__c = recommenActionWrapper.managerRecommendedActionMessage;
        recObj.Seller_Recommended_Action_Message__c = recommenActionWrapper.sellerRecommendedActionMessage;
        recObj.Seller_Email_Text__c = recommenActionWrapper.sellerEmailText;
        recObj.Action_Title__c = recommenActionWrapper.actionMsg;
        recObj.Seller_URL_Text__c = recommenActionWrapper.sellerUrlText;
        recObj.Seller_URL_Link__c = recommenActionWrapper.sellerUrlLink;
        recObj.Manager_URL_Text__c = recommenActionWrapper.managerUrlText;
        recObj.Manager_URL_Link__c = recommenActionWrapper.managerUrlLink;
        recObj.BestActionLogic__c = balRuleId;
        recObj.Opportunity__c = opp.Id;
        */
        return recObj;
    }

    private static Recommendations__c getRecommRecforBS(
        List<Recommendations__c> recommedationLstAll,
        String balId,
        String oppId
    ) {
        Recommendations__c recommTmp = null;
        /*if (recommedationLstAll != null && !recommedationLstAll.isEmpty()) {
            // Recommedation rec exists, this list might belong to many SEs, fetch only this Id
            List<Recommendations__c> thiOppIdRecommLst = getRecommendationLstOfThisOppId(recommedationLstAll, oppId);
            if (thiOppIdRecommLst != null && !thiOppIdRecommLst.isEmpty()) {
                // recommedation record exists
                // check if recommedation record exists for this BR rule
                for (Recommendations__c recommFinal : thiOppIdRecommLst) {
                    if (recommFinal.BestActionLogic__c == balId) {
                        recommTmp = recommFinal;
                    }
                }
            }
        }*/
        return recommTmp;
    }

    // This list has recommedations record of many SEs, so filter to specific single opp id
    private static List<Recommendations__c> getRecommendationLstOfThisOppId(
        List<Recommendations__c> allRecomm,
        String oppId
    ) {
        List<Recommendations__c> thiOppIdRecommLst = new List<Recommendations__c>();
        /*for (Recommendations__c recom : allRecomm) {
            if (recom.Opportunity__c == oppId) {
                thiOppIdRecommLst.add(recom);
            }
        }*/
        return thiOppIdRecommLst;
    }

    public static Map<String, List<Recommendations__c>> getBrIdRecomLstforBS(Set<String> oppIdSet) {
        Map<String, List<Recommendations__c>> mapBrRecommenRecsforBS = new Map<String, List<Recommendations__c>>();
        /*String soqlRecommedations = 'Select Id,BestActionLogic__c,Business_Rules__c,Seller_Recommended_Action_Message__c,Manager_Recommended_Action_Message__c,Strategy_Engine__c,Opportunity__c from Recommendations__c where Opportunity__c=:oppIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        List<Recommendations__c> recommendationsLst = DataFactory.read(soqlRecommedations, parameters);

        List<Recommendations__c> recommenLst = new List<Recommendations__c>();
        for (Recommendations__c recommen : recommendationsLst) {
            if (mapBrRecommenRecsforBS.containsKey(recommen.Business_Rules__c)) {
                recommenLst = mapBrRecommenRecsforBS.get(recommen.Business_Rules__c);
                recommenLst.add(recommen);
            } else {
                recommenLst = new List<Recommendations__c>();
                recommenLst.add(recommen);
            }
            mapBrRecommenRecsforBS.put(recommen.Business_Rules__c, recommenLst);
        }*/
        return mapBrRecommenRecsforBS;
    }

    public static Map<String, Set<String>> getOppidBRids(Set<String> oppIdSet) {
        Map<String, Set<String>> mapOppidBrRecs = new Map<String, Set<String>>();
        /*String soqlRecommedations = 'Select Id,Business_Rules__c,Strategy_Engine__c,Opportunity__c from Recommendations__c where Opportunity__c=:oppIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        List<Recommendations__c> recommendationsLst = DataFactory.read(soqlRecommedations, parameters);

        Set<String> brIsSet = new Set<String>();
        for (Recommendations__c recommen : recommendationsLst) {
            if (mapOppidBrRecs.containsKey(recommen.Opportunity__c)) {
                brIsSet = mapOppidBrRecs.get(recommen.Opportunity__c);
                brIsSet.add(recommen.Business_Rules__c);
            } else {
                brIsSet = new Set<String>();
                brIsSet.add(recommen.Business_Rules__c);
            }
            mapOppidBrRecs.put(recommen.Opportunity__c, brIsSet);
        }*/
        return mapOppidBrRecs;
    }

    public static void upsertRecommendationsRec(List<Strategy_Engine__c> strategyEngineLst) {
        /*Map<String, RecommendationsActionWrapper> mapRuleMSg = new Map<String, RecommendationsActionWrapper>();
        RecommendationsActionMessages recomActionMsgObj = new RecommendationsActionMessages();
        mapRuleMSg = recomActionMsgObj.getRecommendationsActionMessages();
        List<Recommendations__c> recommedationsRectoUpsert = new List<Recommendations__c>();
        List<Business_Rules__c> listBusinessRules = getBusinessRulesRecords();
        Map<String, Set<String>> brGrpIdAndMembers = getBRGrpMembers();
        Set<String> seIdSet = new Set<String>();
        Set<String> oppIdSet = new Set<String>();
        Set<String> blueSheetIds = new Set<String>();
        for (Strategy_Engine__c seObj : strategyEngineLst) {
            seIdSet.add(seObj.Id);
            if (seObj.Opportunity__c != null) {
                oppIdSet.add(seObj.Opportunity__c);
            }
            if (seObj.Blue_Sheet__c != null) {
                blueSheetIds.add(seObj.Blue_Sheet__c);
            }
        }

        //Monika - Changing this code and adding new method
        Map<String, Opportunity> mapOpportunityWithIds = getOppForStrategyEngine(oppIdSet);
        Map<String, String> mapUserProfileId = new Map<String, String>();
        Set<String> oppOwnerIds = new Set<String>();
        for (Opportunity op : mapOpportunityWithIds.values()) {
            oppOwnerIds.add(op.OwnerId);
        }
        if (!mapOpportunityWithIds.isEmpty()) {
            mapUserProfileId = getUserProfileId(oppOwnerIds);
        }

        Map<String, Set<String>> mapSEidBrIds = getSEidBRids(seIdSet);
        Map<String, List<Recommendations__c>> mapBrRecommenRecs = getBrIdRecomLst(seIdSet);
        List<Recommendations__c> recomLstToInsert = new List<Recommendations__c>();
        List<Recommendations__c> recomLstToUpdate = new List<Recommendations__c>();
        Map<String, List<Recommendations__c>> mapSEidAndRecommLst = getSEIdAndRecommLst(seIdSet);
        Map<String, List<Strategy_Engine__c>> mapOppidAndSELst = getOppsSERec(oppIdSet);
        Map<String, List<Recommendations__c>> mapOppIdANdRecommRec = getOppsRecommRec(oppIdSet);
        Set<String> idDupCheckSetForRule12 = new Set<string>();

        for (Strategy_Engine__c seObj : strategyEngineLst) {
            List<Recommendations__c> recommedationLstAllNoBR = mapSEidAndRecommLst.get(seObj.Id);
            if (!listBusinessRules.isEmpty()) {
                // Execute rules which are associated with Business Rules records
                for (Business_Rules__c brObj : listBusinessRules) {
                    if (brObj.Business_Rules_Group__c != null) {
                        Set<String> applicableStages = new Set<String>();
                        Set<String> brGrpMemIdsSet = brGrpIdAndMembers.get(brObj.Business_Rules_Group__c);
                        //String ownerId = mapOppOwnerId.get(seObj.Opportunity__c);
                        String ownerId = mapOpportunityWithIds.get(seObj.Opportunity__c).OwnerId;
                        String profileId = mapUserProfileId.get(ownerId);

                        if (
                            brGrpMemIdsSet != null &&
                            (brGrpMemIdsSet.contains(ownerId) || brGrpMemIdsSet.contains(profileId))
                        ) {
                            List<Recommendations__c> recommedationLstAll = mapBrRecommenRecs.get(brObj.Id);
                            //KFS-863 - new stage picklist field update
                            if (brObj.Opportunity_Stage_Global__c != null && brObj.Opportunity_Stage_Global__c != '') {
                                applicableStages = (Set<String>) ApexCommonUtil.convertStringToSetOrList(
                                    brObj.Opportunity_Stage_Global__c,
                                    ',',
                                    'set'
                                );
                            }

                            Datetime bsLastModDate = seObj.Bluesheet_Last_Modified_Date__c;
                            if (bsLastModDate != null) {
                                Date bsLastModDateDate = Date.newinstance(
                                    bsLastModDate.year(),
                                    bsLastModDate.month(),
                                    bsLastModDate.day()
                                );
                                Date todayDt1 = Date.today();
                                if (
                                    bsLastModDateDate.daysBetween(todayDt1) >
                                    brObj.Max_Days_Allowed_Since_Last_BS_Update__c &&
                                    isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                    isStageApplicable(applicableStages, seObj.place_in_sales_funnel__c) &&
                                    seObj.Is_Master__c == true
                                ) {
                                    // create recommendation record
                                    String balRuleId = 'BAL_3';
                                    Recommendations__c recommObj = getRecommRec(
                                        recommedationLstAll,
                                        balRuleId,
                                        seObj.Id
                                    );
                                    if (recommObj == null) {
                                        // no recommedation record exists, create one
                                        recommObj = new Recommendations__c();
                                        //recommObj.Business_Rules__c = brObj.Id;
                                        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                        recommObj = recommedationObjectCreate(
                                            brObj,
                                            recommObj,
                                            recommenActionWrapper,
                                            seObj,
                                            balRuleId
                                        );

                                        recomLstToInsert.add(recommObj);
                                    } else {
                                        // recommendation record exists, update it
                                        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                        recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                        recomLstToUpdate.add(recommObj);
                                    }
                                } else {
                                    // rule is not satified, Insert : Dont create record, update : remove the messages
                                    String balRuleId = 'BAL_3';
                                    Recommendations__c recommObj = getRecommRec(
                                        recommedationLstAll,
                                        balRuleId,
                                        seObj.Id
                                    );
                                    if (recommObj != null) {
                                        recommObj = recommedationObjectUpdateEmpty(recommObj);
                                        recomLstToUpdate.add(recommObj);
                                    }
                                }
                            }

                            Datetime optyStageLastModi = seObj.Opty_Stage_Last_Modified_Date__c;
                            if (optyStageLastModi != null) {
                                Date optyStageLastModiDate = Date.newinstance(
                                    optyStageLastModi.year(),
                                    optyStageLastModi.month(),
                                    optyStageLastModi.day()
                                );
                                Date todayDt = Date.today();
                                if (
                                    optyStageLastModiDate.daysBetween(todayDt) >
                                    brObj.Max_Days_Allowed_in_a_Opty_Stage__c &&
                                    isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                    isStageApplicable(applicableStages, seObj.place_in_sales_funnel__c) &&
                                    seObj.Is_Master__c == true
                                ) {
                                    // create recommendation record
                                    String balRuleId = 'BAL_5';
                                    Recommendations__c recommObj = getRecommRec(
                                        recommedationLstAll,
                                        balRuleId,
                                        seObj.Id
                                    );
                                    if (recommObj == null) {
                                        // no recommedation record exists, create one
                                        recommObj = new Recommendations__c();
                                        //recommObj.Business_Rules__c = brObj.Id;
                                        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                        recommObj = recommedationObjectCreate(
                                            brObj,
                                            recommObj,
                                            recommenActionWrapper,
                                            seObj,
                                            balRuleId
                                        );
                                        recomLstToInsert.add(recommObj);
                                    } else {
                                        // recommendation record exists, update it
                                        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                        recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                        recomLstToUpdate.add(recommObj);
                                    }
                                } else {
                                    // rule is not satified, Insert : Dont create record, update : remove the messages
                                    String balRuleId = 'BAL_5';
                                    Recommendations__c recommObj = getRecommRec(
                                        recommedationLstAll,
                                        balRuleId,
                                        seObj.Id
                                    );
                                    if (recommObj != null) {
                                        recommObj = recommedationObjectUpdateEmpty(recommObj);
                                        recomLstToUpdate.add(recommObj);
                                    }
                                }
                            }

                            if (
                                seObj.Bluesheet_Count_Actions__c < brObj.Min_Number_of_Actions_for_a_Opty_Stage__c &&
                                isStageApplicable(applicableStages, seObj.place_in_sales_funnel__c) &&
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                seObj.Bluesheet_Count_Actions__c > 0
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_6';
                                Recommendations__c recommObj = getRecommRec(recommedationLstAll, balRuleId, seObj.Id);
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        brObj,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_6';
                                Recommendations__c recommObj = getRecommRec(recommedationLstAll, balRuleId, seObj.Id);
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }

                            if (
                                brObj.Scorecard_Required__c == 'Yes' &&
                                seObj.Score_Card__c == null &&
                                seObj.Is_Master__c == true &&
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                isStageApplicable(applicableStages, seObj.place_in_sales_funnel__c)
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_11';
                                Recommendations__c recommObj = getRecommRec(recommedationLstAll, balRuleId, seObj.Id);
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        brObj,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_11';
                                Recommendations__c recommObj = getRecommRec(recommedationLstAll, balRuleId, seObj.Id);
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }

                            List<Strategy_Engine__c> seLst = mapOppidAndSELst.get(seObj.Opportunity__c);
                            if (
                                brObj.Buying_Influence_Role__c != null &&
                                brObj.Buying_Influence_Role__c != '' &&
                                seLst != null
                            ) {
                                boolean ruleRoleResult = processBIRoleRule(seLst, brObj.Buying_Influence_Role__c);
                                if (
                                    ruleRoleResult &&
                                    isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                    isStageApplicable(applicableStages, seObj.place_in_sales_funnel__c)
                                ) {
                                    // create recommendation record
                                    String balRuleId = 'BAL_12';
                                    List<Recommendations__c> recommLstOpp = mapOppIdANdRecommRec.get(
                                        seObj.Opportunity__c
                                    );
                                    Recommendations__c recommObj = null;
                                    recommObj = getRecommRecForBIRoleRule(recommLstOpp, balRuleId, brObj.Id);

                                    if (recommObj == null) {
                                        // no recommedation record exists, create one
                                        recommObj = new Recommendations__c();
                                        //recommObj.Business_Rules__c = brObj.Id;
                                        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                        recommObj = recommedationObjectCreate(
                                            brObj,
                                            recommObj,
                                            recommenActionWrapper,
                                            seObj,
                                            balRuleId
                                        );
                                        String msg = recommenActionWrapper.sellerRecommendedActionMessage;
                                        msg = msg.replace(
                                            '{Business_Rules__c.Buying_Influence_Role__c}',
                                            String.valueOf(brObj.Buying_Influence_Role__c)
                                        );
                                        recommObj.Seller_Recommended_Action_Message__c = msg;

                                        msg = recommenActionWrapper.managerRecommendedActionMessage;
                                        msg = msg.replace(
                                            '{BI.Role__c}',
                                            String.valueOf(brObj.Buying_Influence_Role__c)
                                        );
                                        recommObj.Manager_Recommended_Action_Message__c = msg;
                                        msg = recommenActionWrapper.sellerEmailText;
                                        msg = msg.replace(
                                            '{BI.Role__c}',
                                            String.valueOf(brObj.Buying_Influence_Role__c)
                                        );
                                        recommObj.Seller_Email_Text__c = msg;
                                        if (!isAlreadyExist(recomLstToInsert, recommObj)) {
                                            recomLstToInsert.add(recommObj);
                                        }
                                    } else {
                                        // recommendation record exists, update it
                                        RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                        recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                        String msg = recommenActionWrapper.sellerRecommendedActionMessage;
                                        msg = msg.replace(
                                            '{Business_Rules__c.Buying_Influence_Role__c}',
                                            String.valueOf(brObj.Buying_Influence_Role__c)
                                        );
                                        recommObj.Seller_Recommended_Action_Message__c = msg;
                                        msg = recommenActionWrapper.managerRecommendedActionMessage;
                                        msg = msg.replace(
                                            '{BI.Role__c}',
                                            String.valueOf(brObj.Buying_Influence_Role__c)
                                        );
                                        recommObj.Manager_Recommended_Action_Message__c = msg;
                                        msg = recommenActionWrapper.sellerEmailText;
                                        msg = msg.replace(
                                            '{BI.Role__c}',
                                            String.valueOf(brObj.Buying_Influence_Role__c)
                                        );
                                        recommObj.Seller_Email_Text__c = msg;
                                        if (!idDupCheckSetForRule12.contains(recommObj.Id)) {
                                            recomLstToUpdate.add(recommObj);
                                            idDupCheckSetForRule12.add(recommObj.Id);
                                        }
                                    }
                                } else {
                                    // rule is not satified, Insert : Dont create record, update : remove the messages
                                    String balRuleId = 'BAL_12';
                                    List<Recommendations__c> recommLstOpp = mapOppIdANdRecommRec.get(
                                        seObj.Opportunity__c
                                    );
                                    Recommendations__c recommObj = null;
                                    recommObj = getRecommRecForBIRoleRule(recommLstOpp, balRuleId, brObj.Id);
                                    if (recommObj != null) {
                                        recommObj = recommedationObjectUpdateEmpty(recommObj);
                                        if (!idDupCheckSetForRule12.contains(recommObj.Id)) {
                                            recomLstToUpdate.add(recommObj);
                                            idDupCheckSetForRule12.add(recommObj.Id);
                                        }
                                    }
                                }
                            }

                            RuleParams ruleParams = new ruleParams()
                                .setSeObj(seObj)
                                .setBrObj(brObj)
                                .setApplicableStages(applicableStages)
                                .setOpportunityRec(mapOpportunityWithIds.get(seObj.Opportunity__c))
                                .setRecommedationLstAll(recommedationLstAll)
                                .setMapRuleMSg(mapRuleMSg)
                                .setRecomLstToInsert(recomLstToInsert)
                                .setRecomLstToUpdate(recomLstToUpdate);
                            if (brObj.is_cust_time_later__c == true) {
                                executeRule13(ruleParams);
                            }
                            //  executeRule14(ruleParams);
                        }

                        if (brObj.is_closed_date_past__c == true) {
                            if (
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                Date.today() > seObj.Opty_Close_Date__c &&
                                seObj.Is_Master__c == true
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_4';

                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        null,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_4';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }
                        }

                        if (brObj.is_past_action_due__c == true) {
                            if (
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                Date.today() > seObj.Best_Action_Due_Date__c &&
                                seObj.AP_IsBestAction__c == true
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_7';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        null,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_7';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }
                        }

                        if (brObj.is_curr_pos_negative__c == true) {
                            List<String> cpNegativeValues = new List<String>{
                                'Concern',
                                'Discomfort',
                                'Worry',
                                'Fear',
                                'Panic'
                            };
                            if (
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                cpNegativeValues.contains(seObj.Current_Position__c)
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_8';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        null,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_8';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }
                        }

                        if (brObj.is_competitor_identified__c) {
                            if (
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                seObj.Competition__c != null &&
                                seObj.Competitor__c != 'Buying From Someone Else'
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_9';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        null,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_9';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }
                        }

                        if (brObj.is_pos_competition_zero__c == true) {
                            if (
                                isInCurrencyRange(brObj, mapOpportunityWithIds.get(seObj.Opportunity__c)) &&
                                (seObj.Position_vs_Competition__c == 'Shared' ||
                                seObj.Position_vs_Competition__c == 'Zero')
                            ) {
                                // create recommendation record
                                String balRuleId = 'BAL_10';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj == null) {
                                    // no recommedation record exists, create one
                                    recommObj = new Recommendations__c();
                                    //recommObj.Business_Rules__c = brObj.Id;
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectCreate(
                                        null,
                                        recommObj,
                                        recommenActionWrapper,
                                        seObj,
                                        balRuleId
                                    );
                                    recomLstToInsert.add(recommObj);
                                } else {
                                    // recommendation record exists, update it
                                    RecommendationsActionWrapper recommenActionWrapper = mapRuleMSg.get(balRuleId);
                                    recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                                    recomLstToUpdate.add(recommObj);
                                }
                            } else {
                                // rule is not satified, Insert : Dont create record, update : remove the messages
                                String balRuleId = 'BAL_10';
                                Recommendations__c recommObj = getRecommRec(
                                    recommedationLstAllNoBR,
                                    balRuleId,
                                    seObj.Id
                                );
                                if (recommObj != null) {
                                    recommObj = recommedationObjectUpdateEmpty(recommObj);
                                    recomLstToUpdate.add(recommObj);
                                }
                            }
                        }
                    }
                }
            }
        }

        if (recomLstToInsert != null && !recomLstToInsert.isEmpty()) {
            DataFactory.create(recomLstToInsert);
        }
        if (recomLstToUpdate != null && !recomLstToUpdate.isEmpty()) {
            DataFactory.modify(recomLstToUpdate);
        }*/
    }

    private static boolean isAlreadyExist(List<Recommendations__c> recomLstToInsert, Recommendations__c recom) {
        boolean result = false;
        /*for (Recommendations__c recomToInsert : recomLstToInsert) {
            if (
                recomToInsert.BestActionLogic__c == recom.BestActionLogic__c &&
                recomToInsert.Blue_Sheet__c == recom.Blue_Sheet__c
            ) {
                result = true;
                break;
            }
        }*/
        return result;
    }
    // get Business Rules records
    @TestVisible
    private static List<Business_Rules__c> getBusinessRulesRecords() {
        String brId = '';
        String brSoql =
            'Select Opportunity_Currency_Fields__c, Maximum_Range__c, Minimum_Range__c,Opportunity_Stage_Global__c,Is_a_Blue_Sheet_required__c,' +
            'Best_Action_Due_Date__c,BS_Req_for_certain_Rev_Range__c,Max_Days_Allowed_in_a_Opty_Stage__c,' +
            'Max_Days_Allowed_Since_Last_BS_Update__c,Min_Number_of_Actions_For_a_Opty_Stage__c,Opty_Amount_1__c,' +
            'Opty_Amount_2__c,Stage_BS_Req__r.Name,Stage_BS_Req_Rev_Range__r.Name,Stage_Min_Poss_Action__r.Name,' +
            'Stage_Scorecard_req__r.Name,Stage_BI_Role__r.Name,Stage_BS_Last_Updated__r.Name,Long_SSO_Sales_Stage__r.Name,' +
            'Scorecard_Required__c,Buying_Influence_Role__c,Business_Rules_Group__c,OptyStage_BI_Role__c,OptyStage_Min_Poss_Action__c,' +
            'OptyStage_Scorecard_req__c,OptyStage_BS_Last_Updated__c,OptyStage_Long_SSO_Sales_Stage__c,OptyStage_BS_Req__c,' +
            'OptyStage_BS_Req_Rev_Range__c,is_competitor_identified__c,is_pos_competition_zero__c, is_closed_date_past__c, is_cust_time_later__c, is_past_action_due__c, is_curr_pos_negative__c from Business_Rules__c  where IsActive__c=true';
        Map<String, Object> parameters = new Map<String, Object>();
        //parameters.put('brId', brId);
        List<Business_Rules__c> listBusinesRules = new List<Business_Rules__c>();
        listBusinesRules = DataFactory.read(brSoql, parameters);
        return listBusinesRules;
    }

    //@TestVisible
    /* Map of BR_ID : List of its  recommendations records for SE_Ids
    This List of recommendation records needs to be filtered for each SE_Id
    */
    public static Map<String, List<Recommendations__c>> getBrIdRecomLst(Set<String> seIdSet) {
        Map<String, List<Recommendations__c>> mapBrRecommenRecs = new Map<String, List<Recommendations__c>>();
        /*String soqlRecommedations = 'Select Id,BestActionLogic__c,Business_Rules__c,Seller_Recommended_Action_Message__c,Manager_Recommended_Action_Message__c,Strategy_Engine__c from Recommendations__c where Strategy_Engine__c=:seIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('seIdSet', seIdSet);
        List<Recommendations__c> recommendationsLst = DataFactory.read(soqlRecommedations, parameters);

        List<Recommendations__c> recommenLst = new List<Recommendations__c>();
        for (Recommendations__c recommen : recommendationsLst) {
            if (mapBrRecommenRecs.containsKey(recommen.Business_Rules__c)) {
                recommenLst = mapBrRecommenRecs.get(recommen.Business_Rules__c);
                recommenLst.add(recommen);
            } else {
                recommenLst = new List<Recommendations__c>();
                recommenLst.add(recommen);
            }
            mapBrRecommenRecs.put(recommen.Business_Rules__c, recommenLst);
        }*/
        return mapBrRecommenRecs;
    }

    // This list has recommedations record of many SEs, so filter to specific single SE id
    private static List<Recommendations__c> getRecommendationLstOfThisSEid(
        List<Recommendations__c> allRecomm,
        String seId
    ) {
        List<Recommendations__c> thiSEidRecommLst = new List<Recommendations__c>();
        /*for (Recommendations__c recom : allRecomm) {
            if (recom.Strategy_Engine__c == seId) {
                thiSEidRecommLst.add(recom);
            }
        }*/
        return thiSEidRecommLst;
    }
    /*
    Map<SE_ID, Set<BR_IDs>
    */
    public static Map<String, Set<String>> getSEidBRids(Set<String> seIdSet) {
        Map<String, Set<String>> mapSEidBrRecs = new Map<String, Set<String>>();
        /*String soqlRecommedations = 'Select Id,Business_Rules__c,Strategy_Engine__c from Recommendations__c where Strategy_Engine__c=:seIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('seIdSet', seIdSet);
        List<Recommendations__c> recommendationsLst = DataFactory.read(soqlRecommedations, parameters);

        Set<String> brIsSet = new Set<String>();
        for (Recommendations__c recommen : recommendationsLst) {
            if (mapSEidBrRecs.containsKey(recommen.Strategy_Engine__c)) {
                brIsSet = mapSEidBrRecs.get(recommen.Strategy_Engine__c);
                brIsSet.add(recommen.Business_Rules__c);
            } else {
                brIsSet = new Set<String>();
                brIsSet.add(recommen.Business_Rules__c);
            }
            mapSEidBrRecs.put(recommen.Strategy_Engine__c, brIsSet);
        }*/
        return mapSEidBrRecs;
    }

    // get Recommedation record for this rule, SE , BR
    private static Recommendations__c getRecommRec(
        List<Recommendations__c> recommedationLstAll,
        String balId,
        String seId
    ) {
        Recommendations__c recommTmp = null;
        /*if (recommedationLstAll != null && !recommedationLstAll.isEmpty()) {
            // Recommedation rec exists, this list might belong to many SEs, fetch only this Id
            List<Recommendations__c> thisSEidRecomlst = getRecommendationLstOfThisSEid(recommedationLstAll, seId);
            if (thisSEidRecomlst != null && !thisSEidRecomlst.isEmpty()) {
                // recommedation record exists
                // check if recommedation record exists for this BR rule
                for (Recommendations__c recommFinal : thisSEidRecomlst) {
                    if (recommFinal.BestActionLogic__c == balId) {
                        recommTmp = recommFinal;
                    }
                }
            }
        }*/
        return recommTmp;
    }

    private static Recommendations__c getRecommRecForBIRoleRule(
        List<Recommendations__c> recommedationLstAll,
        String balId,
        String brId
    ) {
        Recommendations__c recommTmp = null;
        /*if (recommedationLstAll != null && !recommedationLstAll.isEmpty()) {
            // check if recommedation record exists for this BR rule
            for (Recommendations__c recommFinal : recommedationLstAll) {
                if (recommFinal.BestActionLogic__c == balId && recommFinal.Business_Rules__c == brId) {
                    recommTmp = recommFinal;
                }
            }
        }*/
        return recommTmp;
    }

    private static Recommendations__c recommedationObjectUpdate(
        Recommendations__c recommObj,
        RecommendationsActionWrapper recommenActionWrapper
    ) {
        Recommendations__c recObj = new Recommendations__c(id = recommObj.id);
        /*recObj.Manager_Recommended_Action_Message__c = recommenActionWrapper.managerRecommendedActionMessage;
        recObj.Seller_Recommended_Action_Message__c = recommenActionWrapper.sellerRecommendedActionMessage;
        recObj.Seller_Email_Text__c = recommenActionWrapper.sellerEmailText;
        recObj.Action_Title__c = recommenActionWrapper.actionMsg;
        recObj.Seller_URL_Text__c = recommenActionWrapper.sellerUrlText;
        recObj.Seller_URL_Link__c = recommenActionWrapper.sellerUrlLink;
        recObj.Manager_URL_Text__c = recommenActionWrapper.managerUrlText;
        recObj.Manager_URL_Link__c = recommenActionWrapper.managerUrlLink;*/
        return recObj;
    }

    private static Recommendations__c recommedationObjectUpdateEmpty(Recommendations__c recommObj) {
        Recommendations__c recObj = new Recommendations__c(id = recommObj.id);
        /*recObj.Manager_Recommended_Action_Message__c = '';
        recObj.Seller_Recommended_Action_Message__c = '';
        recObj.Seller_Email_Text__c = '';
        recObj.Action_Title__c = '';
        recObj.Seller_URL_Text__c = '';
        recObj.Seller_URL_Link__c = '';
        recObj.Manager_URL_Text__c = '';
        recObj.Manager_URL_Link__c = '';*/
        return recObj;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static Recommendations__c recommedationObjectCreate(
        Business_Rules__c brObj,
        Recommendations__c recommObj,
        RecommendationsActionWrapper recommenActionWrapper,
        Strategy_Engine__c seObj,
        String balRuleId
    ) {
        Recommendations__c recObj = new Recommendations__c();
        /*recObj.Business_Rules__c = (brObj == null ? null : brObj.Id);
        recObj.Manager_Recommended_Action_Message__c = recommenActionWrapper.managerRecommendedActionMessage;
        recObj.Seller_Recommended_Action_Message__c = recommenActionWrapper.sellerRecommendedActionMessage;
        recObj.Seller_Email_Text__c = recommenActionWrapper.sellerEmailText;
        recObj.Action_Title__c = recommenActionWrapper.actionMsg;
        recObj.Seller_URL_Text__c = recommenActionWrapper.sellerUrlText;
        recObj.Seller_URL_Link__c = recommenActionWrapper.sellerUrlLink;
        recObj.Manager_URL_Text__c = recommenActionWrapper.managerUrlText;
        recObj.Manager_URL_Link__c = recommenActionWrapper.managerUrlLink;
        recObj.BestActionLogic__c = balRuleId;
        recObj.Associated_Object__c = recommenActionWrapper.associatedObject;
        if (seObj.Id != null) {
            recObj.Strategy_Engine__c = seObj.Id;
        }
        if (seObj.Blue_Sheet__c != null) {
            recObj.Blue_Sheet__c = seObj.Blue_Sheet__c;
        }
        if (seObj.Opportunity__c != null) {
            recObj.Opportunity__c = seObj.Opportunity__c;
        }
        if (seObj.CurrentPosition__c != null) {
            recObj.Current_Position__c = seObj.CurrentPosition__c;
        }
        if (seObj.Action_Plan__c != null) {
            recObj.Action_Plan__c = seObj.Action_Plan__c;
        }
        if (seObj.Competition__c != null) {
            recObj.Competition__c = seObj.Competition__c;
        }
        if (seObj.Score_Card__c != null) {
            recObj.Score_Card__c = seObj.Score_Card__c;
        }
        if (seObj.Buying_Influence__c != null) {
            recObj.Buying_Influence__c = seObj.Buying_Influence__c;
        }*/
        return recObj;
    }

    //get Grp id
    public static Map<String, Set<String>> getBRGrpMembers() {
        // for a BR Grp Member, get all of its users and profiles
        Map<String, Set<String>> mapBrGrpMemIdUserIdProfileId = new Map<String, Set<String>>();
        /*Map<String, List<Business_Rules_Group_Member__c>> mapBrGrpIdAndMembers = getBrGrpMemrecords();
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
        }*/
        return mapBrGrpMemIdUserIdProfileId;
    }

    // Grp member id and its list of record
    public static Map<String, List<Business_Rules_Group_Member__c>> getBrGrpMemrecords() {
        Map<String, List<Business_Rules_Group_Member__c>> mapBrGrpIdAndMembers = new Map<String, List<Business_Rules_Group_Member__c>>();
        /*String soqlBRGrpMember = 'Select Member_Profile__r.Profile_id__c,Business_Rules_Group__c,Member_Name__c from Business_Rules_Group_Member__c';
        Map<String, Object> parameters = new Map<String, Object>();
        //parameters.put('brGrpIdSet', brGrpIdSet);
        List<Business_Rules_Group_Member__c> brGrpMemLst = DataFactory.read(soqlBRGrpMember, parameters);
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
        }*/
        return mapBrGrpIdAndMembers;
    }
    // get opp owner id
    public static Map<String, String> getOppOwnerId(Set<String> oppIdSet) {
        Map<String, String> mapOppIdAndOwnerId = new Map<String, String>();
        /*String soqlOpp = 'Select Id,OwnerId from Opportunity where id =: oppIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        List<Opportunity> oppLst = DataFactory.read(soqlOpp, parameters);
        for (Opportunity op1 : oppLst) {
            mapOppIdAndOwnerId.put(op1.Id, op1.OwnerId);
        }*/
        return mapOppIdAndOwnerId;
    }
    public static Map<String, Opportunity> getOppForStrategyEngine(Set<String> oppIdSet) {
        Map<String, Opportunity> mapOppIdAndOpportunity = new Map<String, Opportunity>();
        /*String soqlOpp = 'Select Id,OwnerId,Owner.Name,StageName,Amount,ExpectedRevenue from Opportunity where id =: oppIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        try {
            oppLst = DataFactory.read(soqlOpp, parameters);
        } catch (Exception e) {
            throw new OpportunityException('Error occured while getting data from Opportunity');
        }
        for (Opportunity op1 : oppLst) {
            mapOppIdAndOpportunity.put(op1.Id, op1);
        }*/
        return mapOppIdAndOpportunity;
    }

    // get opp owner profile id
    public static Map<String, String> getUserProfileId(Set<String> oppOwnerId) {
        Map<String, String> mapUserProfileId = new Map<String, String>();
        /*String soqlProfile = 'Select Id,ProfileId from User where id =: oppOwnerId';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppOwnerId', oppOwnerId);
        List<User> userLst = DataFactory.read(soqlProfile, parameters);
        for (User user1 : userLst) {
            mapUserProfileId.put(user1.Id, user1.ProfileId);
        }*/
        return mapUserProfileId;
    }

    // get map of SE_ID(key): list of Recommendation records(values)
    public static Map<String, List<Recommendations__c>> getSEIdAndRecommLst(Set<String> seIdSet) {
        Map<String, List<Recommendations__c>> mapSEidAndRecommLst = new Map<String, List<Recommendations__c>>();
        /*String soqlSEidAndRecommLst = 'Select Strategy_Engine__c,Action_Plan__c,Action_Title__c,BestActionLogic__c,Blue_Sheet__c,Buying_Influence__c,Competition__c,Current_Position__c,Manager_Recommended_Action_Message__c,Manager_URL_Link__c,Manager_URL_Text__c,Opportunity__c,Score_Card__c,Seller_Email_Text__c,Seller_Recommended_Action_Message__c,Seller_URL_Link__c,Seller_URL_Text__c from Recommendations__c where Strategy_Engine__c =:seIdSet and Business_Rules__c = null';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('seIdSet', seIdSet);
        List<Recommendations__c> recommLst = DataFactory.read(soqlSEidAndRecommLst, parameters);
        List<Recommendations__c> recommLstTmp = new List<Recommendations__c>();
        for (Recommendations__c recomObj : recommLst) {
            if (mapSEidAndRecommLst.containsKey(recomObj.Strategy_Engine__c)) {
                recommLstTmp = mapSEidAndRecommLst.get(recomObj.Strategy_Engine__c);
                recommLstTmp.add(recomObj);
            } else {
                recommLstTmp = new List<Recommendations__c>();
                recommLstTmp.add(recomObj);
            }
            mapSEidAndRecommLst.put(recomObj.Strategy_Engine__c, recommLstTmp);
        }*/
        return mapSEidAndRecommLst;
    }
    //map of OppId & its BI's SE recs
    public static Map<String, List<Strategy_Engine__c>> getOppsSERec(Set<String> oppIdSet) {
        Map<String, List<Strategy_Engine__c>> mapOppidAndSELst = new Map<String, List<Strategy_Engine__c>>();
        /*String seSoql = 'Select Id,Buying_Influence_Role__c,Opportunity__c from Strategy_Engine__c where Opportunity__c =: oppIdSet AND Buying_Influence__c != null';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        List<Strategy_Engine__c> seLst = DataFactory.read(seSoql, parameters);
        List<Strategy_Engine__c> seObjLstTmp = new List<Strategy_Engine__c>();
        for (Strategy_Engine__c seObj : seLst) {
            if (mapOppidAndSELst.containsKey(seObj.Opportunity__c)) {
                seObjLstTmp = mapOppidAndSELst.get(seObj.Opportunity__c);
                seObjLstTmp.add(seObj);
            } else {
                seObjLstTmp = new List<Strategy_Engine__c>();
                seObjLstTmp.add(seObj);
            }
            mapOppidAndSELst.put(seObj.Opportunity__c, seObjLstTmp);
        }*/
        return mapOppidAndSELst;
    }

    public static boolean processBIRoleRule(List<Strategy_Engine__c> seLst, String roleStrBR) {
        // Rule-12 , BI Role rule
        boolean finalResult = false;
        // if all the BI records have null value in role and BR role has value, then show alert
        /*if (seLst != null & !seLst.isEmpty()) {
            boolean isAllRoleEmpty = true;
            for (Strategy_Engine__c seObj : seLst) {
                if (seObj.Buying_Influence_Role__c != null) {
                    //at least one has BI card has role value
                    isAllRoleEmpty = false;
                }
            }
            if (isAllRoleEmpty) {
                finalResult = true;
            } else {
                Set<String> brRoleMatch = new Set<String>();
                for (Strategy_Engine__c seObj : seLst) {
                    if (seObj.Buying_Influence_Role__c != null) {
                        List<String> roleSELst = new List<String>();
                        List<String> roleBRLst = new List<String>();
                        String roleStrSE = seObj.Buying_Influence_Role__c;
                        roleSELst = roleStrSE.split(',');
                        roleBRLst = roleStrBR.split(',');
                        boolean roleDiff = false;
                        String resRoleTmp = 'All Found';
                        for (String roleSingleBR : roleBRLst) {
                            roleSingleBR = roleSingleBR.trim();

                            if (!roleSELst.contains(roleSingleBR)) {
                                //if BI role does not contain any one BR role items, create recom
                                resRoleTmp = 'One not found';
                                break;
                            }
                        }
                        brRoleMatch.add(resRoleTmp);
                    }
                }
                if (brRoleMatch.contains('All Found')) {
                    // means at least 1 BR of the Opp meets the BR.Role valaues, so no alert
                    finalResult = false;
                } else {
                    // means none BR of opp meets the BR.Role valaues, so create alert
                    finalResult = true;
                }
            }
        }*/
        return finalResult;
    }

    //map of oppid and its recommendations
    public static Map<String, List<Recommendations__c>> getOppsRecommRec(Set<String> oppIdSet) {
        Map<String, List<Recommendations__c>> mapOppidAndRecommLst = new Map<String, List<Recommendations__c>>();
        /*String recommSoql = 'Select Strategy_Engine__c,Action_Plan__c,Action_Title__c,BestActionLogic__c,Blue_Sheet__c,Buying_Influence__c,Competition__c,Current_Position__c,Manager_Recommended_Action_Message__c,Manager_URL_Link__c,Manager_URL_Text__c,Opportunity__c,Score_Card__c,Seller_Email_Text__c,Seller_Recommended_Action_Message__c,Seller_URL_Link__c,Seller_URL_Text__c,Business_Rules__c from Recommendations__c where Opportunity__c =: oppIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        List<Recommendations__c> recommLst = DataFactory.read(recommSoql, parameters);
        List<Recommendations__c> recommObjLstTmp = new List<Recommendations__c>();
        for (Recommendations__c recommObj : recommLst) {
            if (mapOppidAndRecommLst.containsKey(recommObj.Opportunity__c)) {
                recommObjLstTmp = mapOppidAndRecommLst.get(recommObj.Opportunity__c);
                recommObjLstTmp.add(recommObj);
            } else {
                recommObjLstTmp = new List<Recommendations__c>();
                recommObjLstTmp.add(recommObj);
            }
            mapOppidAndRecommLst.put(recommObj.Opportunity__c, recommObjLstTmp);
        }*/
        return mapOppidAndRecommLst;
    }

    @TestVisible
    private static boolean isStageApplicable(Set<String> applicableStages, String stageName) {
        return (applicableStages == null || applicableStages.isEmpty()) ? true : applicableStages.contains(stageName);
    }

    @TestVisible
    private static boolean isInCurrencyRange(Business_Rules__c businessRule, Opportunity opportunity) {
        Boolean result = true;
        /*String fieldName = businessRule.Opportunity_Currency_Fields__c;
        Double minValue = (Double) businessRule.Minimum_Range__c;
        Double maxValue = (Double) businessRule.Maximum_Range__c;
        
        Double fieldValue = null;

        try {
            if (fieldName != null) {
                if (fieldName == 'ExpectedRevenue') {
                    fieldValue = ((Double) Opportunity.get('Amount') * (Double) Opportunity.get('Probability')) / 100;
                } else {
                    fieldValue = (Double) Opportunity.get(fieldName);
                }
            }
            if (fieldValue != null) {
                if (maxValue == null) {
                    maxValue = fieldValue + 1;
                }

                if (minValue == null) {
                    minValue = fieldValue - 1;
                }

                if (fieldValue < minValue || fieldValue > maxValue) {
                    result = false;
                }
            }
        }*/
        return result;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @TestVisible
    private static void executeRule13(RuleParams ruleParams) {
        if (
            isInCurrencyRange(ruleParams.brObj, ruleParams.opportunity) &&
            isStageApplicable(ruleParams.applicableStages, ruleParams.seObj.place_in_sales_funnel__c) &&
            (ruleParams.seObj.Customer_Timing_for_Priorities__c != null &&
            (ruleParams.seObj.Customer_Timing_for_Priorities__c).toLowerCase() == 'negative')
        ) {
            // create recommendation record
            String balRuleId = 'BAL_13';
            Recommendations__c recommObj = getRecommRec(ruleParams.recommedationLstAll, balRuleId, ruleParams.seObj.Id);
            if (recommObj == null) {
                // no recommedation record exists, create one
                recommObj = new Recommendations__c();
                //recommObj.Business_Rules__c = brObj.Id;
                RecommendationsActionWrapper recommenActionWrapper = ruleParams.mapRuleMSg.get(balRuleId);
                String msg = recommenActionWrapper.managerUrlText;
                //String oppOwnerName = getOppOwnerName(ruleParams.seObj.Opportunity__c);
                String oppOwnerName = ruleParams.opportunity.Owner.Name;
                msg = msg.replace('{sellerName}', oppOwnerName);
                recommObj = recommedationObjectCreate(
                    ruleParams.brObj,
                    recommObj,
                    recommenActionWrapper,
                    ruleParams.seObj,
                    balRuleId
                );
                recommObj.Manager_URL_Text__c = msg;
                ruleParams.recomLstToInsert.add(recommObj);
            } else {
                // recommendation record exists, update it
                RecommendationsActionWrapper recommenActionWrapper = ruleParams.mapRuleMSg.get(balRuleId);
                String msg = recommenActionWrapper.managerUrlText;
                //String oppOwnerName = getOppOwnerName(ruleParams.seObj.Opportunity__c);
                String oppOwnerName = ruleParams.opportunity.Owner.Name;
                msg = msg.replace('{sellerName}', oppOwnerName);
                recommObj = recommedationObjectUpdate(recommObj, recommenActionWrapper);
                recommObj.Manager_URL_Text__c = msg;
                ruleParams.recomLstToUpdate.add(recommObj);
            }
        } else {
            // rule is not satified, Insert : Dont create record, update : remove the messages
            String balRuleId = 'BAL_13';
            Recommendations__c recommObj = getRecommRec(ruleParams.recommedationLstAll, balRuleId, ruleParams.seObj.Id);
            if (recommObj != null) {
                recommObj = recommedationObjectUpdateEmpty(recommObj);
                ruleParams.recomLstToUpdate.add(recommObj);
            }
        }
    }

    static List<Buying_Influence__c> getBuyingInfluences(Set<String> blueSheetId) {
        String query =
            'SELECT Id, Name, Blue_Sheet__r.Opportunity__c, ' +
            'Personal_Wins__c, Growth__c, Rating__c, Over_Confident__c, Even_Keel__c,Blue_Sheet__c, High__c, ' +
            'Over_Confident__c, Trouble__c, Rating_Evidence__c, Business_Results__c,' +
            'Buying_from_Someone_Else__c, Technical__c,Low__c, Medium__c FROM Buying_Influence__c,Blue_Sheet__r.Opportunity__r.StageName ' +
            'where Blue_Sheet__c in :bluesheetIds ';

        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('bluesheetIds', blueSheetId);
        List<Buying_Influence__c> buyingInfluences = DataFactory.read(query, paramters);
        return buyingInfluences;
    }

    @TestVisible
    private class RuleParams {
        Strategy_Engine__c seObj;
        Business_Rules__c brObj;
        Set<String> applicableStages;
        List<Recommendations__c> recommedationLstAll;
        Map<String, RecommendationsActionWrapper> mapRuleMSg;
        List<Recommendations__c> recomLstToInsert;
        List<Recommendations__c> recomLstToUpdate;
        Buying_Influence__c buyingInfluence;
        List<KF_Sell_Best__c> allBestActions;
        List<KF_Sell_Best__c> listBestActionsToInsert;
        List<KF_Sell_Best__c> listBestActionsToUpdate;
        Opportunity opportunity;

        RUleParams setOpportunityRec(Opportunity opportunity) {
            this.opportunity = opportunity;
            return this;
        }

        RuleParams setBestActionLstToInsert(List<KF_Sell_Best__c> listBestActionsToInsert) {
            this.listBestActionsToInsert = listBestActionsToInsert;
            return this;
        }

        RuleParams setBestActionLstToUpdate(List<KF_Sell_Best__c> listBestActionsToUpdate) {
            this.listBestActionsToUpdate = listBestActionsToUpdate;
            return this;
        }

        RuleParams setSeObj(Strategy_Engine__c seObj) {
            this.seObj = seObj;
            return this;
        }

        RuleParams setBrObj(Business_Rules__c brObj) {
            this.brObj = brObj;
            return this;
        }

        RuleParams setApplicableStages(Set<String> applicableStages) {
            this.applicableStages = applicableStages;
            return this;
        }

        RuleParams setRecommedationLstAll(List<Recommendations__c> recommedationLstAll) {
            this.recommedationLstAll = recommedationLstAll;
            return this;
        }

        RuleParams setMapRuleMSg(Map<String, RecommendationsActionWrapper> mapRuleMSg) {
            this.mapRuleMSg = mapRuleMSg;
            return this;
        }

        RuleParams setRecomLstToInsert(List<Recommendations__c> recomLstToInsert) {
            this.recomLstToInsert = recomLstToInsert;
            return this;
        }

        RuleParams setRecomLstToUpdate(List<Recommendations__c> recomLstToUpdate) {
            this.recomLstToUpdate = recomLstToUpdate;
            return this;
        }

        RuleParams setBuyingInfluenceRec(Buying_Influence__c buyingInfluence) {
            this.buyingInfluence = buyingInfluence;
            return this;
        }

        RuleParams setBestActionList(List<KF_Sell_Best__c> allBestActions) {
            this.allBestActions = allBestActions;
            return this;
        }
    }

    private class OpportunityException extends Exception {
    }
    private class CurrencyException extends Exception {
    }
}