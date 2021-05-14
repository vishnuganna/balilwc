/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-2725 : Class to fetch the Default and Custom Alerts from database
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Sushma Bharti
 * @created        2020-12-08
 * Note: if there is single quote in any msg, escape it in this class
 */

@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public with sharing class AlertRecommendationsMessages {
    public Map<String, List<AlertRecommendationsWrapper>> getAlertRecommendations() {
        String alertQuery = 'SELECT Id,Name,BestActionRuleId__c,Action_Alert__c,Manager_Email_Alert__c,Seller_Email_Alert__c,Business_Rules__c FROM Alert_Recommendation__c';
        Map<String, Object> parameters = new Map<String, Object>();
        List<Alert_Recommendation__c> alertList = DataFactory.read(alertQuery, parameters);
        List<Id> alertTemplateIdList = new List<Id>();
        if (alertList != null && !alertList.isEmpty()) {
            for (Alert_Recommendation__c alert : alertList) {
                if (alert.Action_Alert__c != null) {
                    alertTemplateIdList.add(alert.Action_Alert__c);
                }
                if (alert.Seller_Email_Alert__c != null) {
                    alertTemplateIdList.add(alert.Seller_Email_Alert__c);
                }
                if (alert.Manager_Email_Alert__c != null) {
                    alertTemplateIdList.add(alert.Manager_Email_Alert__c);
                }
            }
        }
        String alertTemplateQuery = 'SELECT Id,Name,BestActionRuleId__c,Alert_Type__c,Custom_Alert_Email_Header__c,Custom_Alert_Email_Text__c,Default_Alert_Email_Header__c,Default_Alert_Email_Text__c,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c,URL_Link__c,URL_Text__c FROM Alert_Template__c WHERE Id IN :alertTemplateIdList ';
        Map<String, Object> params = new Map<String, Object>();
        params.put('alertTemplateIdList', alertTemplateIdList);
        List<Alert_Template__c> alertTemplateList = DataFactory.read(alertTemplateQuery, params);
        Map<String, Alert_Template__c> mapOfATIdAndRecord = new Map<String, Alert_Template__c>();
        if (alertTemplateList != null && !alertTemplateList.isEmpty()) {
            for (Alert_Template__c alertTemp : alertTemplateList) {
                mapOfATIdAndRecord.put(alertTemp.id, alertTemp);
            }
        }
        Map<String, List<Alert_Recommendation__c>> mapOfBALIdAndAlertRecommRec = getMapOfBALIdAndAlertRecommRec(
            alertList
        );
        Map<String, List<AlertRecommendationsWrapper>> alertRecommendationsWrapper = buildAlertRecommendationsWrapper(
            mapOfBALIdAndAlertRecommRec,
            mapOfATIdAndRecord
        );

        return alertRecommendationsWrapper;
    }

    private Map<String, List<AlertRecommendationsWrapper>> buildAlertRecommendationsWrapper(
        Map<String, List<Alert_Recommendation__c>> mapOfBALIdAndAlertRecommRec,
        Map<String, Alert_Template__c> mapOfATIdAndRecord
    ) {
        Map<String, List<AlertRecommendationsWrapper>> mapRuleAndARWrapper = new Map<String, List<AlertRecommendationsWrapper>>();
        for (String key : mapOfBALIdAndAlertRecommRec.keySet()) {
            List<Alert_Recommendation__c> arLst = mapOfBALIdAndAlertRecommRec.get(key);
            List<AlertRecommendationsWrapper> alertRecommendationsWrapperLst = convertAlertRecommendationObjToWrapper(
                arLst,
                mapOfATIdAndRecord
            );
            mapRuleAndARWrapper.put(key, alertRecommendationsWrapperLst);
        }
        return mapRuleAndARWrapper;
    }

    private List<AlertRecommendationsWrapper> convertAlertRecommendationObjToWrapper(
        List<Alert_Recommendation__c> arLst,
        Map<String, Alert_Template__c> mapOfATIdAndRecord
    ) {
        List<AlertRecommendationsWrapper> arWrapper = new List<AlertRecommendationsWrapper>();
        for (Alert_Recommendation__c alert : arLst) {
            AlertRecommendationsWrapper msgWrapper = new AlertRecommendationsWrapper();
            msgWrapper.balId = alert.BestActionRuleId__c;
            msgWrapper.businessRulesId = alert.Business_Rules__c;
            Alert_Template__c actionTemplate = new Alert_Template__c();
            if (alert.Action_Alert__c != null) {
                actionTemplate = mapOfATIdAndRecord.get(alert.Action_Alert__c);
                msgWrapper.action = new AlertTemplateWrapper(actionTemplate);
            }
            Alert_Template__c managerTemplate = new Alert_Template__c();
            if (alert.Manager_Email_Alert__c != null) {
                managerTemplate = mapOfATIdAndRecord.get(alert.Manager_Email_Alert__c);
                msgWrapper.managerEmail = new AlertTemplateWrapper(managerTemplate);
            }
            Alert_Template__c sellerTemplate = new Alert_Template__c();
            if (alert.Seller_Email_Alert__c != null) {
                sellerTemplate = mapOfATIdAndRecord.get(alert.Seller_Email_Alert__c);
                msgWrapper.sellerEmail = new AlertTemplateWrapper(sellerTemplate);
            }
            //KFS-4205 - added this line to translate the labels
            CustomAlertRecommendations.translateCustomLabelData(msgWrapper);
            arWrapper.add(msgWrapper);
        }
        return arWrapper;
    }
    private Map<String, List<Alert_Recommendation__c>> getMapOfBALIdAndAlertRecommRec(
        List<Alert_Recommendation__c> alertRecommList
    ) {
        Map<String, List<Alert_Recommendation__c>> mapOfBALIdAndAlertRecommRec = new Map<String, List<Alert_Recommendation__c>>();
        if (alertRecommList != null && !alertRecommList.isEmpty()) {
            for (Alert_Recommendation__c alert : alertRecommList) {
                if (mapOfBALIdAndAlertRecommRec.containsKey(alert.BestActionRuleId__c)) {
                    List<Alert_Recommendation__c> arlRecomm = mapOfBALIdAndAlertRecommRec.get(
                        alert.BestActionRuleId__c
                    );
                    arlRecomm.add(alert);
                    mapOfBALIdAndAlertRecommRec.put(alert.BestActionRuleId__c, arlRecomm);
                } else {
                    List<Alert_Recommendation__c> arlRecomm = new List<Alert_Recommendation__c>();
                    arlRecomm.add(alert);
                    mapOfBALIdAndAlertRecommRec.put(alert.BestActionRuleId__c, arlRecomm);
                }
            }
        }
        return mapOfBALIdAndAlertRecommRec;
    }

    public Map<String, List<AlertRecommendationsWrapper>> getDefaultAlertRecommendations() {
        String alertQuery = 'SELECT Id,Name,BestActionRuleId__c,Action_Alert__c,Manager_Email_Alert__c,Seller_Email_Alert__c,Business_Rules__c FROM Alert_Recommendation__c where Is_Default__c = true';
        Map<String, Object> parameters = new Map<String, Object>();
        List<Alert_Recommendation__c> alertList = DataFactory.read(alertQuery, parameters);
        List<Id> alertTemplateIdList = new List<Id>();
        if (alertList != null && !alertList.isEmpty()) {
            for (Alert_Recommendation__c alert : alertList) {
                if (alert.Action_Alert__c != null) {
                    alertTemplateIdList.add(alert.Action_Alert__c);
                }
                if (alert.Seller_Email_Alert__c != null) {
                    alertTemplateIdList.add(alert.Seller_Email_Alert__c);
                }
                if (alert.Manager_Email_Alert__c != null) {
                    alertTemplateIdList.add(alert.Manager_Email_Alert__c);
                }
            }
        }
        String alertTemplateQuery = 'SELECT Id,Name,BestActionRuleId__c,Alert_Type__c,Custom_Alert_Email_Header__c,Custom_Alert_Email_Text__c,Default_Alert_Email_Header__c,Default_Alert_Email_Text__c,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c,URL_Link__c,URL_Text__c FROM Alert_Template__c WHERE Id IN :alertTemplateIdList ';
        Map<String, Object> params = new Map<String, Object>();
        params.put('alertTemplateIdList', alertTemplateIdList);
        List<Alert_Template__c> alertTemplateList = DataFactory.read(alertTemplateQuery, params);
        Map<String, Alert_Template__c> mapOfATIdAndRecord = new Map<String, Alert_Template__c>();
        if (alertTemplateList != null && !alertTemplateList.isEmpty()) {
            for (Alert_Template__c alertTemp : alertTemplateList) {
                mapOfATIdAndRecord.put(alertTemp.id, alertTemp);
            }
        }
        Map<String, List<Alert_Recommendation__c>> mapOfBALIdAndAlertRecommRec = getMapOfBALIdAndAlertRecommRec(
            alertList
        );
        Map<String, List<AlertRecommendationsWrapper>> alertRecommendationsWrapper = buildAlertRecommendationsWrapper(
            mapOfBALIdAndAlertRecommRec,
            mapOfATIdAndRecord
        );
        return alertRecommendationsWrapper;
    }
}