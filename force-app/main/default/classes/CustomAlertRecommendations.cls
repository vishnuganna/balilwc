@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount')
public with sharing class CustomAlertRecommendations {
    @AuraEnabled
    public static void upsertCustomAlertRecord(AlertRecommendationsWrapper alertWrapper) {
        Alert_Recommendation__c alertRecommendations = new Alert_Recommendation__c();
        Alert_Template__c alertTemplate = new Alert_Template__c();
        try {
            if (alertWrapper != null) {
                List<Alert_Recommendation__c> brList = new List<Alert_Recommendation__c>();
                String bsRuleSId = alertWrapper.businessRulesId;
                String brQuery =
                    ' Select Id,Name,Seller_Email_Alert__c,Action_Alert__c,Manager_Email_Alert__c ' +
                    'FROM Alert_Recommendation__c WHERE Business_Rules__c=:bsRuleSId';
                Map<String, Object> paramters = new Map<String, Object>();
                paramters.put('bsRuleSId', bsRuleSId);
                brList = DataFactory.read(brQuery, paramters);
                if (alertWrapper.isUpdate && !brList.isEmpty()) {
                    if (alertWrapper.action != null) {
                        alertWrapper.action.alerId = brList[0].Action_Alert__c != null
                            ? brList[0].Action_Alert__c
                            : null;
                        if (alertWrapper.action.alerId == null) {
                            alertWrapper.isUpdate = false;
                        }
                    }
                    if (alertWrapper.managerEmail != null) {
                        alertWrapper.managerEmail.alerId = brList[0].Manager_Email_Alert__c != null
                            ? brList[0].Manager_Email_Alert__c
                            : null;
                        if (alertWrapper.managerEmail.alerId == null) {
                            alertWrapper.isUpdate = false;
                        }
                    }
                    if (alertWrapper.sellerEmail != null) {
                        alertWrapper.sellerEmail.alerId = brList[0].Seller_Email_Alert__c != null
                            ? brList[0].Seller_Email_Alert__c
                            : null;
                        if (alertWrapper.sellerEmail.alerId == null) {
                            alertWrapper.isUpdate = false;
                        }
                    }
                }
                if (alertWrapper != null && alertWrapper.action != null) {
                    alertRecommendations.Action_Alert__c = setActionField(
                        alertWrapper.action,
                        'Action',
                        !brList.isEmpty() && alertWrapper.isUpdate ? true : false
                    );
                } else {
                    if (!brList.isEmpty()) {
                        if (brlist[0].Action_Alert__c != null) {
                            DataFactory.remove(brlist[0].Action_Alert__c);
                        }
                        if (brlist[0].Manager_Email_Alert__c != null) {
                            DataFactory.remove(brlist[0].Manager_Email_Alert__c);
                        }
                        if (brlist[0].Seller_Email_Alert__c != null) {
                            DataFactory.remove(brlist[0].Seller_Email_Alert__c);
                        }
                    }
                }

                if (alertWrapper != null && alertWrapper.managerEmail != null) {
                    alertRecommendations.Manager_Email_Alert__c = setActionField(
                        alertWrapper.managerEmail,
                        'Manager Email',
                        !brList.isEmpty() && alertWrapper.isUpdate ? true : false
                    );
                }
                if (alertWrapper != null && alertWrapper.sellerEmail != null) {
                    alertRecommendations.Seller_Email_Alert__c = setActionField(
                        alertWrapper.sellerEmail,
                        'Seller Email',
                        !brList.isEmpty() && alertWrapper.isUpdate ? true : false
                    );
                }
                alertRecommendations.Business_Rules__c = alertWrapper.businessRulesId;
                alertRecommendations.BestActionRuleId__c = alertWrapper.balId;
                if (!brList.isEmpty()) {
                    alertRecommendations.Id = brList[0].Id;
                    if (alertRecommendations.Id != null) {
                        DataFactory.modify(alertRecommendations);
                    }
                } else {
                    DataFactory.create(alertRecommendations);
                }
            }
        } catch (Exception ec) {
            system.System.debug('exception ----' + ec);
            system.System.debug('exception line----' + ec.getLineNumber());
            throw new CustomAlertRecommendationsException(
                'Error occured while saving Alert_Recommendation__c data',
                ec
            );
        }
    }

    public static ID setActionField(AlertTemplateWrapper alertTemplateWrapper, String alertType, Boolean isUpdate) {
        try {
            Alert_Template__c alertTemplate = new Alert_Template__c();
            alertTemplate.Alert_Type__c = alertType;
            alertTemplate.BestActionRuleId__c = alertTemplateWrapper.balId;

            alertTemplate.Custom_Alert_Email_Header__c = alertTemplateWrapper.alertEnabled != null &&
                alertTemplateWrapper.alertEnabled &&
                alertTemplateWrapper.overrideHeader != null &&
                alertTemplateWrapper.overrideHeader
                ? alertTemplateWrapper.customAlertHeader
                : null;

            alertTemplate.Custom_Alert_Email_Text__c = alertTemplateWrapper.alertEnabled != null &&
                alertTemplateWrapper.alertEnabled &&
                alertTemplateWrapper.overrideMessage != null &&
                alertTemplateWrapper.overrideMessage
                ? alertTemplateWrapper.customAlertMessage
                : null;

            alertTemplate.Default_Alert_Email_Header__c = alertTemplateWrapper.defaultAlertHeader;
            alertTemplate.Default_Alert_Email_Text__c = alertTemplateWrapper.defaultAlertMessage;

            alertTemplate.Is_Alert_Enabled__c = alertTemplateWrapper.alertEnabled != null &&
                alertTemplateWrapper.alertEnabled
                ? true
                : false;
            alertTemplate.Override_Alert_Email_Header__c = alertTemplateWrapper.overrideHeader != null &&
                alertTemplateWrapper.overrideHeader
                ? true
                : false;
            alertTemplate.Override_Alert_Email_Text__c = alertTemplateWrapper.overrideMessage != null &&
                alertTemplateWrapper.overrideMessage
                ? true
                : false;
            List<Database.SaveResult> bluesheet;

            if (isUpdate) {
                alertTemplate.Id = alertTemplateWrapper.alerId;
                addUrlTextAndLink(alertTemplate);
                bluesheet = DataFactory.modify(alertTemplate);
            } else {
                Alert_Template__c finalATRec = addUrlTextAndLink(alertTemplate);
                bluesheet = DataFactory.create(finalATRec);
            }

            return bluesheet[0].getId();
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new CustomAlertRecommendationsException('Error occured while saving Alert_Template__c data', ex);
        }
    }

    private static Alert_Template__c addUrlTextAndLink(Alert_Template__c alertTemplateAdd) {
        RecommendationsActionMessages brActionMessages = new RecommendationsActionMessages();
        Map<String, RecommendationsActionWrapper> mapBrAlertMsg = brActionMessages.getRecommendationsActionMessages();
        RecommendationsActionWrapper brActionMsg = mapBrAlertMsg.get(alertTemplateAdd.BestActionRuleId__c);
        if (alertTemplateAdd.Alert_Type__c == 'Manager Email') {
            alertTemplateAdd.URL_Text__c = brActionMsg.managerUrlText;
            alertTemplateAdd.URL_Link__c = brActionMsg.managerUrlLink;
        } else if (alertTemplateAdd.Alert_Type__c == 'Seller Email') {
            alertTemplateAdd.URL_Text__c = brActionMsg.sellerUrlText;
            alertTemplateAdd.URL_Link__c = brActionMsg.sellerUrlLink;
        }
        return alertTemplateAdd;
    }

    @AuraEnabled
    public static AlertRecommendationsWrapper getRecommendationsAction(String balId) {
        AlertRecommendationsMessages ar = new AlertRecommendationsMessages();
        Map<String, List<AlertRecommendationsWrapper>> data = ar.getAlertRecommendations();
        AlertRecommendationsWrapper dataWrapper;
        if (data != null && !data.isEmpty()) {
            List<AlertRecommendationsWrapper> alertsList = data.get(balId);
            for (AlertRecommendationsWrapper arWrap : alertsList) {
                if (arWrap.action != null) {
                    dataWrapper = arWrap;
                }
            }
        }
        // AlertRecommendationsWrapper dataWrapper = data.get(balId)[0];
        return dataWrapper;
    }

    @AuraEnabled
    public static AlertRecommendationsWrapper getDefaultAlerts(String balId) {
        AlertRecommendationsMessages ar = new AlertRecommendationsMessages();
        Map<String, List<AlertRecommendationsWrapper>> data = ar.getDefaultAlertRecommendations();
        AlertRecommendationsWrapper dataWrapper = new AlertRecommendationsWrapper();
        if (data != null && !data.isEmpty()) {
            List<AlertRecommendationsWrapper> alertsList = data.get(balId);
            for (AlertRecommendationsWrapper arWrap : alertsList) {
                dataWrapper = arWrap;
            }
        }
        return dataWrapper;
    }

    @AuraEnabled
    public static AlertRecommendationsWrapper getRecommendationsActionByRuleId(String bsRuleId) {
        Alert_Recommendation__c alertRecommendations = new Alert_Recommendation__c();
        Alert_Template__c alertTemplate = new Alert_Template__c();
        List<Alert_Recommendation__c> alertRecommendationsList = new List<Alert_Recommendation__c>();
        AlertTemplateWrapper actionTemp;
        List<Alert_Template__c> actionList = new List<Alert_Template__c>();
        String brQuery =
            'Select Id,Name,Seller_Email_Alert__c,BestActionRuleId__c,Business_Rules__c,Action_Alert__c,Manager_Email_Alert__c ' +
            'FROM Alert_Recommendation__c WHERE Business_Rules__c=:bsRuleId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('bsRuleId', bsRuleId);

        //get data from Alert_Recommendation__c section
        alertRecommendationsList = DataFactory.read(brQuery, paramters);
        AlertRecommendationsWrapper data;
        List<String> actionRuleIdList = new List<String>();
        AlertRecommendationsWrapper arcList = new AlertRecommendationsWrapper();
        String managerRuleId;
        String actionRuleId;
        String sellerRuleId;
        for (Alert_Recommendation__c arc : alertRecommendationsList) {
            data = new AlertRecommendationsWrapper();
            data.businessRulesId = arc.BestActionRuleId__c;
            data.balId = arc.BestActionRuleId__c;
            actionRuleId = arc.Action_Alert__c;
            managerRuleId = arc.Manager_Email_Alert__c;
            sellerRuleId = arc.Seller_Email_Alert__c;
        }
        if (actionRuleId != null) {
            List<AlertTemplateWrapper> listOfAction = new List<AlertTemplateWrapper>();
            String query =
                'Select Id,Name,Alert_Type__c,BestActionRuleId__c,Custom_Alert_Email_Header__c,Custom_Alert_Email_Text__c,' +
                'Default_Alert_Email_Header__c,Default_Alert_Email_Text__c,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c' +
                ' FROM Alert_Template__c WHERE Id=:actionRuleId';
            Map<String, Object> paramter = new Map<String, Object>();
            paramter.put('actionRuleId', actionRuleId);
            actionList = DataFactory.read(query, paramter);

            for (Alert_Template__c alert : actionList) {
                actionTemp = new AlertTemplateWrapper(alert, false);
                KFSellBestHelperWrapper convertedString = ConverStringFromCustomLabels.getStringByLabels(actionTemp);
                actionTemp.defaultAlertHeader = convertedString.actionTitle;
                actionTemp.defaultAlertMessage = convertedString.sellerRecommendedAction;
                listOfAction.add(actionTemp);
            }
            data.action = listOfAction[0];
        }

        if (managerRuleId != null) {
            List<Alert_Template__c> managerInDB = new List<Alert_Template__c>();
            List<AlertTemplateWrapper> listOfManager = new List<AlertTemplateWrapper>();
            String queryForManager =
                'Select Id,Name,Alert_Type__c,BestActionRuleId__c,Custom_Alert_Email_Header__c,Custom_Alert_Email_Text__c,' +
                'Default_Alert_Email_Header__c,Default_Alert_Email_Text__c,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c' +
                ' FROM Alert_Template__c WHERE Id=:managerRuleId';
            Map<String, Object> managerParamter = new Map<String, Object>();
            managerParamter.put('managerRuleId', managerRuleId);
            managerInDB = DataFactory.read(queryForManager, managerParamter);
            for (Alert_Template__c alert : managerInDB) {
                actionTemp = new AlertTemplateWrapper(alert, false);
                listOfManager.add(actionTemp);
            }
            data.managerEmail = listOfManager[0];
        }

        if (sellerRuleId != null) {
            List<Alert_Template__c> sellerInDB = new List<Alert_Template__c>();
            List<AlertTemplateWrapper> listOfSeller = new List<AlertTemplateWrapper>();
            String queryForSeller =
                'Select Id,Name,Alert_Type__c,BestActionRuleId__c,Custom_Alert_Email_Header__c,Custom_Alert_Email_Text__c,' +
                'Default_Alert_Email_Header__c,Default_Alert_Email_Text__c,Is_Alert_Enabled__c,Override_Alert_Email_Header__c,Override_Alert_Email_Text__c' +
                ' FROM Alert_Template__c WHERE Id=:sellerRuleId';
            Map<String, Object> sellerParamter = new Map<String, Object>();
            sellerParamter.put('sellerRuleId', sellerRuleId);
            sellerInDB = DataFactory.read(queryForSeller, sellerParamter);
            for (Alert_Template__c alert : sellerInDB) {
                actionTemp = new AlertTemplateWrapper(alert, false);
                listOfSeller.add(actionTemp);
            }

            data.sellerEmail = listOfSeller[0];
            translateCustomLabelData(data);
        }

        return data;
    }

    public static void translateCustomLabelData(AlertRecommendationsWrapper alertData) {
        if (alertData.sellerEmail != null) {
            KFSellBestHelperWrapper sellerConvertedData = ConverStringFromCustomLabels.getStringByLabels(
                alertData.sellerEmail
            );
            alertData.sellerEmail.defaultAlertHeader = sellerConvertedData.sellerTitle;
            alertData.sellerEmail.defaultAlertMessage = sellerConvertedData.sellerEmailText;
        }

        if (alertData.action != null) {
            KFSellBestHelperWrapper actionConvertedData = ConverStringFromCustomLabels.getStringByLabels(
                alertData.action
            );
            alertData.action.defaultAlertHeader = actionConvertedData.actionTitle;
            alertData.action.defaultAlertMessage = actionConvertedData.sellerRecommendedAction;
        }
        if (alertData.managerEmail != null) {
            KFSellBestHelperWrapper managerConvertedData = ConverStringFromCustomLabels.getStringByLabels(
                alertData.managerEmail
            );
            alertData.managerEmail.defaultAlertHeader = managerConvertedData.managerTitle;
            alertData.managerEmail.defaultAlertMessage = managerConvertedData.managerRecommendedAction;
        }
    }

    private class CustomAlertRecommendationsException extends Exception {
    }
}