public with sharing class BusinessRules {
    public static List<String> alertTemplateIdLst = new List<String>();
    public static List<Alert_Recommendation__c> alertRecommendationsList = new List<Alert_Recommendation__c>();
    @AuraEnabled
    public static Map<String, Object> upsertBusinessRule(String busRule) {
        Map<String, Object> resultMap = new Map<String, Object>();
        BusinessRulesWrapperClass brWrapper = (BusinessRulesWrapperClass) JSON.deserialize(
            busRule,
            BusinessRulesWrapperClass.class
        );
        InsightAlertsWrapper brInsightAlertWrapper = brWrapper != null &&
            brWrapper.customCompetitorInsights != null
            ? brWrapper.customCompetitorInsights
            : null;
        InsightAlertsWrapper brInsightPerspectiveWrapper = brWrapper != null &&
            brWrapper.customPerspectiveInsights != null
            ? brWrapper.customPerspectiveInsights
            : null;
        AlertRecommendationsWrapper bralertWrapper = brWrapper != null &&
            brWrapper.customRecommendationAction != null
            ? brWrapper.customRecommendationAction
            : null;
        Business_Rules__c brObj = BusinessRulesWrapperClass.convertWrapperToObject(brWrapper);
        List<Database.SaveResult> srList;

        try {
            if (brWrapper.id == '' || brWrapper.id == null) {
                srList = DataFactory.create(brObj);
                if (bralertWrapper != null) {
                    bralertWrapper.businessRulesId = srList[0].getId();
                    bralertWrapper.isUpdate = false;
                    CustomAlertRecommendations.upsertCustomAlertRecord(bralertWrapper);
                }
            } else {
                brObj.Id = brWrapper.id;
                srList = DataFactory.modify(brObj);
                if (bralertWrapper != null) {
                    bralertWrapper.businessRulesId = srList[0].getId();
                    bralertWrapper.isUpdate = true;
                    CustomAlertRecommendations.upsertCustomAlertRecord(bralertWrapper);
                }
            }

            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    resultMap.put('recordId', sr.getId());
                    if (brWrapper.brCategory == 'Competitor') {
                        InsightsAlertRecommendations.upsertCustomInsightsAlerts(
                            brInsightAlertWrapper,
                            sr.getId(),
                            brWrapper.brCategory
                        );
                    }
                    if (brWrapper.brCategory == 'Perspective') {
                        InsightsAlertRecommendations.upsertCustomInsightsAlerts(
                            brInsightPerspectiveWrapper,
                            sr.getId(),
                            brWrapper.brCategory
                        );
                    }
                }
            }

            resultMap.put('status', System.Label.success_header);
            resultMap.put('msg', System.Label.success_header);
        } catch (Exception ex) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', ex.getMessage());
            system.System.debug('exception ----' + ex.getLineNumber());
        }
        return resultMap;
    }

    @AuraEnabled
    public static Map<String, Object> upsertGreenSheetBusinessRule(String busRule) {
        Map<String, Object> resultMap = new Map<String, Object>();
        system.debug('busRule----' + busRule);
        BusinessRulesGreenSheetWrapperClass brWrapper = (BusinessRulesGreenSheetWrapperClass) JSON.deserialize(
            busRule,
            BusinessRulesGreenSheetWrapperClass.class
        );
        AlertRecommendationsWrapper brGreenAlertWrapper = brWrapper != null &&
            brWrapper.customRecommendationAction != null
            ? brWrapper.customRecommendationAction
            : null;
        Business_Rules__c brObj = BusinessRulesGreenSheetWrapperClass.convertWrapperToObject(brWrapper);
        List<Database.SaveResult> srList;
        system.debug('brObj---' + brObj);
        try {
            if (brWrapper.id == '' || brWrapper.id == null) {
                srList = DataFactory.create(brObj);
                if (brGreenAlertWrapper != null) {
                    brGreenAlertWrapper.businessRulesId = srList[0].getId();
                    brGreenAlertWrapper.isUpdate = false;
                    CustomAlertRecommendations.upsertCustomAlertRecord(brGreenAlertWrapper);
                }
            } else {
                brObj.Id = brWrapper.id;
                srList = DataFactory.modify(brObj);
                if (brGreenAlertWrapper != null) {
                    brGreenAlertWrapper.businessRulesId = srList[0].getId();
                    brGreenAlertWrapper.isUpdate = true;
                    CustomAlertRecommendations.upsertCustomAlertRecord(brGreenAlertWrapper);
                }
            }

            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    resultMap.put('recordId', sr.getId());
                }
            }

            resultMap.put('status', System.Label.success_header);
            resultMap.put('msg', System.Label.success_header);
        } catch (Exception ex) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', ex.getMessage());
            system.System.debug('exception ----' + ex);
        }
        return resultMap;
    }

    private class BrException extends Exception {
    }

    //Below method added for KFS-2704
    @AuraEnabled
    public static List<AlertTemplateWrapper> getActionAlertDetails(String brId) {
        List<Alert_Template__c> alertList = new List<Alert_Template__c>();
        List<AlertTemplateWrapper> alertWrapperListToReturn = new List<AlertTemplateWrapper>();
        try {
            List<Alert_Recommendation__c> alertData = new List<Alert_Recommendation__c>();
            String alertRecommendationQuery =
                ' Select id, Business_Rules__c, Action_Alert__c ' +
                ' FROM Alert_Recommendation__c WHERE Business_Rules__c=:brId';

            Map<String, Object> paramtersForAlert = new Map<String, Object>();
            paramtersForAlert.put('brId', brId);
            alertData = DataFactory.read(alertRecommendationQuery, paramtersForAlert);
            string alertTemplateId = alertData[0].Action_Alert__c;

            String alertQuery =
                ' Select Id,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c,Custom_Alert_Email_Header__c,' +
                ' Custom_Alert_Email_Text__c,Default_Alert_Email_Header__c,Default_Alert_Email_Text__c' +
                ' FROM Alert_Template__c WHERE Id=:alertTemplateId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('alertTemplateId', alertTemplateId);
            //get data from cometition section
            alertList = DataFactory.read(alertQuery, paramters);
            for (Alert_Template__c al : alertList) {
                AlertTemplateWrapper wrapper = new AlertTemplateWrapper(al);
                alertWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
        }
        return alertWrapperListToReturn;
    }
    /* @AuraEnabled
    public static void deleteRecomAlertForBusinessrules(List<Business_Rules__c> businessRules) {
        set<Id> recordIds = new Set<Id>();
        for (Business_Rules__c alertRecom : businessRules) {
            recordIds.add(alertRecom.Id);
        }

        String soql = 'SELECT Id,Business_Rules__c from Alert_Recommendation__c WHERE Business_Rules__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<Alert_Recommendation__c> alertRecomList = DataFactory.read(soql, soqlParamMap);

        if (!alertRecomList.isEmpty()) {
            DataFactory.remove(alertRecomList);
        }
    }*/

    //KFS-2704
    public static void businessRuleDeleteBefore(List<Business_Rules__c> businessRuleLst) {
        Set<String> brIdSet = ApexCommonUtil.getSetOfIdFromList(businessRuleLst);
        String queryForAlertRecommendation = 'Select Id,Seller_Email_Alert__c,Action_Alert__c,Manager_Email_Alert__c FROM Alert_Recommendation__c WHERE Business_Rules__c =: brIdSet';
        Map<String, Object> paramtersAlertRecomm = new Map<String, Object>();
        paramtersAlertRecomm.put('brIdSet', brIdSet);
        BusinessRules.alertRecommendationsList = DataFactory.read(queryForAlertRecommendation, paramtersAlertRecomm);

        Set<String> alertTemplateRecs = new Set<String>();
        for (Alert_Recommendation__c alertRecomm : BusinessRules.alertRecommendationsList) {
            if (alertRecomm.Action_Alert__c != null) {
                alertTemplateRecs.add(alertRecomm.Action_Alert__c);
            }

            if (alertRecomm.Manager_Email_Alert__c != null) {
                alertTemplateRecs.add(alertRecomm.Manager_Email_Alert__c);
            }

            if (alertRecomm.Seller_Email_Alert__c != null) {
                alertTemplateRecs.add(alertRecomm.Seller_Email_Alert__c);
            }
        }

        if (!alertTemplateRecs.isEmpty()) {
            BusinessRules.alertTemplateIdLst = new List<String>(alertTemplateRecs);
        }
    }

    public static void businessRuleDeleteAfter() {
        if (!BusinessRules.alertTemplateIdLst.isEmpty()) {
            DataFactory.remove(BusinessRules.alertTemplateIdLst);
        }

        if (!BusinessRules.alertRecommendationsList.isEmpty()) {
            DataFactory.remove(BusinessRules.alertRecommendationsList);
        }
    }

    @AuraEnabled
    public static BusinessRulesWrapper getBusinessRule(String brId) {
        List<Business_Rules__c> brList = new List<Business_Rules__c>();
        //List<BusinessRulesWrapperClass> brWrapperListToReturn = new List<BusinessRulesWrapperClass>();
        //List<BusinessRulesWrapper> wrapperToReturn = new List<BusinessRulesWrapper>();
        BusinessRulesWrapper bRWrapper = new BusinessRulesWrapper();
        try {
            //formation of query
            //KFS-863 - updated query to add new fields created as a part of this story
            String brQuery =
                ' Select Id,Name,BS_Req_for_certain_Rev_Range__c,Business_Rule_Name__c,Business_Rules_Group__c,' +
                ' Business_Rules_Group__r.Name,Buying_Influence_Role__c,Is_a_Blue_Sheet_required__c,IsActive__c,' +
                ' Max_Days_Allowed_in_a_Opty_Stage__c,Max_Days_Allowed_Since_Last_BS_Update__c,OwnerId,Owner.Name,' +
                ' Min_Number_of_Actions_For_a_Opty_Stage__c, Opty_Amount_1__c,Opty_Amount_2__c,Opty_Stage_1__c,' +
                ' Opty_Stage_2__c,Scorecard_Required__c,RecordTypeId,OptyStage_BS_Req__c,OptyStage_Min_Poss_Action__c,' +
                ' OptyStage_BI_Role__c,OptyStage_Scorecard_req__c,OptyStage_BS_Last_Updated__c,OptyStage_Long_SSO_Sales_Stage__c,' +
                ' Opportunity_Currency_Fields__c,Minimum_Range__c,Maximum_Range__c,Business_Rule_Catagory__c,Opportunity_Stage_Global__c,' +
                ' LastModifiedById,CreatedById,CreatedBy.Name,createdDate,LastModifiedBy.Name,LastModifiedDate,' +
                ' OptyStage_BS_Req_Rev_Range__c,Min_Number_Buying_Influence_Contacts__c,trigger_bluesheet_required__c,' +
                'is_closed_date_past__c, is_past_action_due__c, is_curr_pos_negative__c,is_competitor_identified__c,' +
                ' is_pos_competition_zero__c, is_cust_time_later__c,is_person_win_identified__c,is_business_result_identified__c,' +
                ' is_negative_rating__c, is_high_rated_BI_no_coach__c, is_coach_with_low_BI__c, is_discon_mode_cust_timing__c,' +
                ' Scorecard_Number_of_Days_Updated__c,Minimum_Score__c,Maximum_Score__c,OpportunityCriteria_Minimum_Score__c,' +
                'OpportunityCriteria_Maximum_Score__c,BusinessCriteria_Minimum_Score__c,BusinessCriteria_Maximum_Score__c,' +
                'Check_Scorecard_Last_Modified__c,Check_Total_Score__c,Check_Opportunity_Score__c,Check_Business_Criteria_Score__c, ' +
                'Is_Concept_for_BI_Added__c,Is_Minimum_Action_Commitment_Added__c,Is_Valid_Business_Reason_Added__c,' +
                'Is_Best_Action_Commitment_Added__c,Number_of_Days_Before_Meeting__c' +
                ' FROM Business_Rules__c WHERE Id=:brId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('brId', brId);
            //get data from cometition section
            brList = DataFactory.read(brQuery, paramters);
            for (Business_Rules__c br : brList) {
                if (br.Business_Rule_Catagory__c != 'Meeting Plan') {
                    BusinessRulesWrapperClass wrapper = new BusinessRulesWrapperClass(br);
                    if (br.Business_Rule_Catagory__c == 'Competitor' || br.Business_Rule_Catagory__c == 'Perspective') {
                        Map<String, InsightAlertsWrapper> insightAlertsMapCompetitor = InsightsAlertRecommendations.getCustomInsightAlerts(
                            brId,
                            br.Business_Rule_Catagory__c
                        );
                        Map<String, InsightAlertsWrapper> insightAlertsMapPerspective = InsightsAlertRecommendations.getCustomInsightAlerts(
                            brId,
                            br.Business_Rule_Catagory__c
                        );
                        wrapper.customCompetitorInsights = br.Business_Rule_Catagory__c == 'Competitor'
                            ? insightAlertsMapCompetitor.get(br.id)
                            : null;
                        wrapper.customPerspectiveInsights = br.Business_Rule_Catagory__c == 'Perspective'
                            ? insightAlertsMapPerspective.get(br.id)
                            : null;
                    }
                    bRWrapper.blueSheetRuleWrapper = wrapper;
                } else if (br.Business_Rule_Catagory__c == 'Meeting Plan') {
                    BusinessRulesGreenSheetWrapperClass wrapperGeenSheetFields = new BusinessRulesGreenSheetWrapperClass(
                        br
                    );
                    bRWrapper.greenSheetRuleWrapper = wrapperGeenSheetFields;
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new BrException('Error occured while getting data from br');
        }
        //return list of wrapper containing all br data
        //return bRWrapperListToReturn;
        return bRWrapper;
    }

    @AuraEnabled(cacheable=true)
    public static String getOpportunityStagePicklistValues() {
        String oppStagePicklist = ApexCommonUtil.getPicklistValues('Opportunity', 'StageName');
        return oppStagePicklist;
    }

    @AuraEnabled(cacheable=true)
    public static String getBRCategoryPicklistValues() {
        String categoryPicklist = ApexCommonUtil.getPicklistValues('Business_Rules__c', 'Business_Rule_Catagory__c');
        return categoryPicklist;
    }

    @AuraEnabled(cacheable=true)
    public static String getIndustryPicklistValues() {
        String industryPicklist = ApexCommonUtil.getPicklistValues('Account', 'Industry');
        return industryPicklist;
    }

    @AuraEnabled(cacheable=true)
    public static String getOptyTypePicklistValues() {
        String optyTypePicklist = ApexCommonUtil.getPicklistValues('Opportunity', 'Type');
        return optyTypePicklist;
    }

    @AuraEnabled
    public static WrapperLookupObject getBusinessRulesGroupName() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace('Business_Rules__c');
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace('Business_Rules_Group__c');
        return wrapper;
    }
    @AuraEnabled
    public static WrapperLookupObject getCompetitiorLookup() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace('Insight_Alert__c');
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace('Competitor__c');
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static String getCurrencyFields() {
        map<String, String> fields = new Map<String, String>();
        SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        Map<String, Schema.SObjectField> mfieldsMap = objType.getDescribe().fields.getMap();

        for (Schema.SObjectField fld : mfieldsMap.values()) {
            if (fld.getDescribe().getType() == Schema.DisplayType.CURRENCY) {
                fields.put(fld.getDescribe().getName(), fld.getDescribe().getLabel());
            }
        }
        return JSON.serialize(fields);
    }

    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }
    public class BusinessRulesWrapper {
        @AuraEnabled
        public BusinessRulesWrapperClass blueSheetRuleWrapper;
        @AuraEnabled
        public BusinessRulesGreenSheetWrapperClass greenSheetRuleWrapper;
    }
    private class BusinessRuleException extends Exception {
    }
}