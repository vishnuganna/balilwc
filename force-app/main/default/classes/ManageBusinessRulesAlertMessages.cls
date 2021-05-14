//KFS-2735, sub-task - KFS-3150
public with sharing class ManageBusinessRulesAlertMessages {
    public void insertBusinessRulesMessages() {
        Map<String, Alert_Template__c> existingAlertTemplateMap = getExistingAlertTemplate();
        Map<String, Map<String, String>> existingAlertRecommendationsRecMap = getExistingAlertRecommendationsRec();

        RecommendationsActionMessages brActionMessages = new RecommendationsActionMessages();
        Map<String, RecommendationsActionWrapper> mapBrAlertMsg = brActionMessages.getRecommendationsActionMessages();
        List<Alert_Template__c> alertTemplateToUpdateLst = new List<Alert_Template__c>();
        List<Alert_Template__c> alertTemplateToInsertLst = new List<Alert_Template__c>();
        for (String balName : mapBrAlertMsg.keySet()) {
            Map<String, String> mapBALandAlertTemplate = existingAlertRecommendationsRecMap.get(balName);
            RecommendationsActionWrapper brActionMsg = mapBrAlertMsg.get(balName);
            if (mapBALandAlertTemplate == null || mapBALandAlertTemplate.isEmpty()) {
                // no AT exists, so no AR, create it
                alertTemplateToInsertLst.add(getManagerEmailATrecord(balName, brActionMsg, null));
                alertTemplateToInsertLst.add(getSellerEmailATrecord(balName, brActionMsg, null));
                alertTemplateToInsertLst.add(getActionATrecord(balName, brActionMsg, null));
            } else {
                // AT exists, compare each records to decide if there is need to create AR
                if (mapBALandAlertTemplate.containsKey('Action')) {
                    Alert_Template__c alertTemplateToUpdate = existingAlertTemplateMap.get(
                        mapBALandAlertTemplate.get('Action')
                    );
                    if (checkIfActionTypeIsChanged(alertTemplateToUpdate, brActionMsg)) {
                        // check if there is change in this field, if yes, update new values
                        alertTemplateToUpdateLst.add(getActionATrecord(balName, brActionMsg, alertTemplateToUpdate.Id));
                    }
                } else {
                    // Action rec doesn't exist, create it
                    alertTemplateToInsertLst.add(getActionATrecord(balName, brActionMsg, null));
                }

                if (mapBALandAlertTemplate.containsKey('Manager_Email_Alert')) {
                    Alert_Template__c alertTemplateToUpdate = existingAlertTemplateMap.get(
                        mapBALandAlertTemplate.get('Manager_Email_Alert')
                    );
                    if (checkIfManagerEmailTypeIsChanged(alertTemplateToUpdate, brActionMsg)) {
                        // check if there is change in this field, if yes, update new values
                        alertTemplateToUpdateLst.add(
                            getManagerEmailATrecord(balName, brActionMsg, alertTemplateToUpdate.Id)
                        );
                    }
                } else {
                    alertTemplateToInsertLst.add(getManagerEmailATrecord(balName, brActionMsg, null));
                }

                if (mapBALandAlertTemplate.containsKey('Seller_Email_Alert')) {
                    Alert_Template__c alertTemplateToUpdate = existingAlertTemplateMap.get(
                        mapBALandAlertTemplate.get('Seller_Email_Alert')
                    );
                    if (checkIfSellerEmailTypeIsChanged(alertTemplateToUpdate, brActionMsg)) {
                        // check if there is change in this field, if yes, update new values
                        alertTemplateToUpdateLst.add(
                            getSellerEmailATrecord(balName, brActionMsg, alertTemplateToUpdate.Id)
                        );
                    }
                } else {
                    alertTemplateToInsertLst.add(getSellerEmailATrecord(balName, brActionMsg, null));
                }
            }
        }
        createAlertTemplate(alertTemplateToInsertLst);
        updateAlertTemplate(alertTemplateToUpdateLst);
    }

    private void updateAlertTemplate(List<Alert_Template__c> alertTemplateToUpdateLst) {
        if (!alertTemplateToUpdateLst.isEmpty()) {
            DataFactory.modify(alertTemplateToUpdateLst);
        }
    }
    private ALert_Template__c getActionATrecord(String balName, RecommendationsActionWrapper brActionMsg, String id) {
        ALert_Template__c alertTemplateRec = getAlertTemplateObj(balName);
        if (id != null) {
            alertTemplateRec.Id = id;
        }
        alertTemplateRec.Alert_Type__c = 'Action';
        alertTemplateRec.Default_Alert_Email_Header__c = brActionMsg.actionMsg;
        alertTemplateRec.Default_Alert_Email_Text__c = brActionMsg.sellerRecommendedActionMessage;
        alertTemplateRec.Is_Default__c = true;
        return alertTemplateRec;
    }

    private ALert_Template__c getManagerEmailATrecord(
        String balName,
        RecommendationsActionWrapper brActionMsg,
        String id
    ) {
        ALert_Template__c alertTemplateRec = getAlertTemplateObj(balName);
        if (id != null) {
            alertTemplateRec.Id = id;
        }
        alertTemplateRec.Alert_Type__c = 'Manager Email';
        alertTemplateRec.Default_Alert_Email_Header__c = brActionMsg.actionMsg;
        alertTemplateRec.Default_Alert_Email_Text__c = brActionMsg.managerRecommendedActionMessage;
        alertTemplateRec.URL_Text__c = brActionMsg.managerUrlText;
        alertTemplateRec.URL_Link__c = brActionMsg.managerUrlLink;
        alertTemplateRec.Is_Default__c = true;
        return alertTemplateRec;
    }

    private ALert_Template__c getSellerEmailATrecord(
        String balName,
        RecommendationsActionWrapper brActionMsg,
        String id
    ) {
        ALert_Template__c alertTemplateRec = getAlertTemplateObj(balName);
        if (id != null) {
            alertTemplateRec.Id = id;
        }
        alertTemplateRec.Alert_Type__c = 'Seller Email';
        alertTemplateRec.Default_Alert_Email_Header__c = brActionMsg.actionMsg;
        alertTemplateRec.Default_Alert_Email_Text__c = brActionMsg.sellerEmailText;
        alertTemplateRec.URL_Text__c = brActionMsg.sellerUrlText;
        alertTemplateRec.URL_Link__c = brActionMsg.sellerUrlLink;
        alertTemplateRec.Is_Default__c = true;
        return alertTemplateRec;
    }

    private boolean checkIfActionTypeIsChanged(
        ALert_Template__c alertTemplateToUpdate,
        RecommendationsActionWrapper brActionMsg
    ) {
        if (
            alertTemplateToUpdate.Default_Alert_Email_Header__c != brActionMsg.actionMsg ||
            alertTemplateToUpdate.Default_Alert_Email_Text__c != brActionMsg.sellerRecommendedActionMessage
        ) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkIfManagerEmailTypeIsChanged(
        ALert_Template__c alertTemplateToUpdate,
        RecommendationsActionWrapper brActionMsg
    ) {
        if (
            alertTemplateToUpdate.Default_Alert_Email_Header__c != brActionMsg.actionMsg ||
            (alertTemplateToUpdate.Default_Alert_Email_Text__c != null &&
            alertTemplateToUpdate.Default_Alert_Email_Text__c != brActionMsg.managerRecommendedActionMessage) ||
            (alertTemplateToUpdate.URL_Link__c != null &&
            (alertTemplateToUpdate.URL_Text__c != brActionMsg.managerUrlText ||
            alertTemplateToUpdate.URL_Link__c != brActionMsg.managerUrlLink))
        ) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkIfSellerEmailTypeIsChanged(
        ALert_Template__c alertTemplateToUpdate,
        RecommendationsActionWrapper brActionMsg
    ) {
        if (
            alertTemplateToUpdate.Default_Alert_Email_Header__c != brActionMsg.actionMsg ||
            (alertTemplateToUpdate.Default_Alert_Email_Text__c != null &&
            alertTemplateToUpdate.Default_Alert_Email_Text__c != brActionMsg.sellerEmailText) ||
            (alertTemplateToUpdate.URL_Link__c != null &&
            (alertTemplateToUpdate.URL_Text__c != brActionMsg.sellerUrlText ||
            alertTemplateToUpdate.URL_Link__c != brActionMsg.sellerUrlLink))
        ) {
            return true;
        } else {
            return false;
        }
    }

    private void createAlertTemplate(List<ALert_Template__c> alertTemplateToInsertLst) {
        if (alertTemplateToInsertLst != null && !alertTemplateToInsertLst.isEmpty()) {
            List<Database.SaveResult> createResultLst = DataFactory.create(alertTemplateToInsertLst);
            Set<String> alertTemplateInsertedSet = new Set<String>();
            for (Database.SaveResult saveResultRec : createResultLst) {
                if (saveResultRec.isSuccess()) {
                    alertTemplateInsertedSet.add(saveResultRec.getId());
                }
            }
            createOrUpdateARrecords(alertTemplateInsertedSet);
        }
    }

    private void createOrUpdateARrecords(Set<String> alertTemplateInsertedSet) {
        if (!alertTemplateInsertedSet.isEmpty()) {
            Map<String, List<ALert_Template__c>> balNameandListOfATRecMap = getBalNameandListOfATRec(
                alertTemplateInsertedSet
            );
            Map<String, Alert_Recommendation__c> mapBalNAmeAndAlertRecommRec = getExistingBALNameAndAlertRecommendationsMap();
            List<Alert_Recommendation__c> alertRecommToUpsert = new List<Alert_Recommendation__c>();
            for (String balName : balNameandListOfATRecMap.keySet()) {
                Alert_Recommendation__c alertRecommRec = mapBalNAmeAndAlertRecommRec.get(balName);
                List<ALert_Template__c> alertTemplateLst = balNameandListOfATRecMap.get(balName);
                Alert_Recommendation__c alertRecommObj = getARrecord(balName, alertRecommRec, alertTemplateLst);
                alertRecommToUpsert.add(alertRecommObj);
            }

            if (!alertRecommToUpsert.isEmpty()) {
                DataFactory.upsurt(alertRecommToUpsert);
            }
        }
    }

    private Alert_Recommendation__c getARrecord(
        String balName,
        Alert_Recommendation__c alertRecommRec,
        List<ALert_Template__c> alertTemplateLst
    ) {
        Alert_Recommendation__c alertRecommObj = new Alert_Recommendation__c();
        alertRecommObj.BestActionRuleId__c = balName;
        alertRecommObj.Is_Default__c = true;
        if (alertRecommRec != null) {
            alertRecommObj.Id = alertRecommRec.Id;
        }
        for (ALert_Template__c alertTemplateObj : alertTemplateLst) {
            if (alertTemplateObj.Alert_Type__c == 'Seller Email') {
                alertRecommObj.Seller_Email_Alert__c = alertTemplateObj.Id;
            } else if (alertTemplateObj.Alert_Type__c == 'Manager Email') {
                alertRecommObj.Manager_Email_Alert__c = alertTemplateObj.Id;
            } else if (alertTemplateObj.Alert_Type__c == 'Action') {
                alertRecommObj.Action_Alert__c = alertTemplateObj.Id;
            }
        }
        return alertRecommObj;
    }

    private Map<String, List<ALert_Template__c>> getBAlNameandListOfATRec(Set<String> alertTemplateInsertedSet) {
        String sqlAlertTemplate = 'SELECT Id, BestActionRuleId__c, Alert_Type__c FROM ALert_Template__c WHERE id IN : alertTemplateInsertedSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('alertTemplateInsertedSet', alertTemplateInsertedSet);
        List<ALert_Template__c> alertTemplateLst2 = DataFactory.read(sqlAlertTemplate, paramters);
        Map<String, List<ALert_Template__c>> bAlNameandListOfATRec = new Map<String, List<ALert_Template__c>>();
        for (ALert_Template__c alertTemplateTmp : alertTemplateLst2) {
            if (bAlNameandListOfATRec.containsKey(alertTemplateTmp.BestActionRuleId__c)) {
                List<ALert_Template__c> atLst = bAlNameandListOfATRec.get(alertTemplateTmp.BestActionRuleId__c);
                atLst.add(alertTemplateTmp);
                bAlNameandListOfATRec.put(alertTemplateTmp.BestActionRuleId__c, atLst);
            } else {
                List<ALert_Template__c> atLst = new List<ALert_Template__c>();
                atLst.add(alertTemplateTmp);
                bAlNameandListOfATRec.put(alertTemplateTmp.BestActionRuleId__c, atLst);
            }
        }
        return bAlNameandListOfATRec;
    }
    private ALert_Template__c getAlertTemplateObj(String ruleName) {
        ALert_Template__c alertTemplateRec = new ALert_Template__c();
        alertTemplateRec.BestActionRuleId__c = ruleName;
        alertTemplateRec.Is_Alert_Enabled__c = true;
        alertTemplateRec.Override_Alert_Email_Header__c = false;
        alertTemplateRec.Override_Alert_Email_Text__c = false;
        return alertTemplateRec;
    }

    private Map<String, Alert_Template__c> getExistingAlertTemplate() {
        String sqlAlertTemplate = 'Select Id,name,Alert_Type__c,BestActionRuleId__c,Custom_Alert_Email_Header__c,Custom_Alert_Email_Text__c,Default_Alert_Email_Header__c,Default_Alert_Email_Text__c,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c,URL_Link__c,URL_Text__c from Alert_Template__c';
        Map<String, Object> paramters = new Map<String, Object>();
        List<ALert_Template__c> alertTemplateLst2 = DataFactory.read(sqlAlertTemplate, paramters);
        Map<String, ALert_Template__c> mapRuleAlertTemplate = new Map<String, ALert_Template__c>();
        for (ALert_Template__c alertTemplateObj : alertTemplateLst2) {
            mapRuleAlertTemplate.put(alertTemplateObj.Id, alertTemplateObj);
        }
        return mapRuleAlertTemplate;
    }

    private Map<String, Map<String, String>> getExistingAlertRecommendationsRec() {
        String alertRecommSql = 'select id, name,BestActionRuleId__c,Action_Alert__c,Business_Rules__c,Manager_Email_Alert__c,Seller_Email_Alert__c from Alert_Recommendation__c';
        Map<String, Object> paramters = new Map<String, Object>();
        List<Alert_Recommendation__c> alertRecommLst = DataFactory.read(alertRecommSql, paramters);
        Map<String, Map<String, String>> mapBalIdAndAlertRecommRec = new Map<String, Map<String, String>>();
        for (Alert_Recommendation__c alertRecomm : alertRecommLst) {
            Map<String, String> mapAlertTypeAndATId = new Map<String, String>();
            if (alertRecomm.Action_Alert__c != null) {
                mapAlertTypeAndATId.put('Action', alertRecomm.Action_Alert__c);
            }
            if (alertRecomm.Manager_Email_Alert__c != null) {
                mapAlertTypeAndATId.put('Manager_Email_Alert', alertRecomm.Manager_Email_Alert__c);
            }
            if (alertRecomm.Seller_Email_Alert__c != null) {
                mapAlertTypeAndATId.put('Seller_Email_Alert', alertRecomm.Seller_Email_Alert__c);
            }
            mapBalIdAndAlertRecommRec.put(alertRecomm.BestActionRuleId__c, mapAlertTypeAndATId);
        }
        return mapBalIdAndAlertRecommRec;
    }

    private Map<String, Alert_Recommendation__c> getExistingBALNameAndAlertRecommendationsMap() {
        String alertRecommSql = 'select id, name,BestActionRuleId__c,Action_Alert__c,Business_Rules__c,Manager_Email_Alert__c,Seller_Email_Alert__c from Alert_Recommendation__c';
        Map<String, Object> paramters = new Map<String, Object>();
        List<Alert_Recommendation__c> alertRecommLst = DataFactory.read(alertRecommSql, paramters);
        Map<String, Alert_Recommendation__c> mapBalIdAndAlertRecommRec = new Map<String, Alert_Recommendation__c>();
        for (Alert_Recommendation__c alertRecomm : alertRecommLst) {
            mapBalIdAndAlertRecommRec.put(alertRecomm.BestActionRuleId__c, alertRecomm);
        }
        return mapBalIdAndAlertRecommRec;
    }
}