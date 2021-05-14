public with sharing class ConverStringFromCustomLabels {
    public static KFSellBestHelperWrapper getStringByLabels(KF_Sell_Best__c kFSell, Boolean isCallForEmail) {
        KFSellBestHelperWrapper wrapper = new KFSellBestHelperWrapper();
        wrapper.actionTitle = kFSell.Action_Title__c;
        wrapper.brId = kFSell.Business_Rules__c != null ? kFSell.Business_Rules__c : null;
        if (!isCallForEmail) {
            wrapper.sellerRecommendedAction = kFSell.Seller_Recommended_Action__c;
        } else {
            wrapper.sellerEmailText = kFSell.Seller_Email_Text__c;
            wrapper.managerRecommendedAction = kFSell.Manager_Recommended_Action__c;
            wrapper.sellerTitle = kFSell.Action_Title_Seller__c;
            wrapper.managerTitle = kFSell.Action_Title_Manager__c;
        }
        translateLabelInString(wrapper, true);
        setOtherData(wrapper, kFSell, isCallForEmail);
        return wrapper;
    }

    public static String getBuyingInfluenceRoleName(String bRId) {
        String buyingInfluenceRoleName;
        try {
            String query = 'SELECT Buying_Influence_Role__c FROM Business_Rules__c  WHERE Id=:bRId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('bRId', bRId);
            List<Business_Rules__c> bIROle = new List<Business_Rules__c>();
            bIROle = DataFactory.read(query, paramters);
            buyingInfluenceRoleName = bIROle.size() > 0 &&
                bIROle[0].Buying_Influence_Role__c != null
                ? bIROle[0].Buying_Influence_Role__c
                : null;
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return buyingInfluenceRoleName;
    }

    public static KFSellBestHelperWrapper getStringByLabels(AlertTemplateWrapper aTWrapper) {
        KFSellBestHelperWrapper wrapper = new KFSellBestHelperWrapper();
        wrapper.actionTitle = aTWrapper.defaultAlertHeader;
        wrapper.sellerRecommendedAction = aTWrapper.defaultAlertMessage;
        wrapper.sellerTitle = aTWrapper.defaultAlertHeader;
        wrapper.sellerEmailText = aTWrapper.defaultAlertMessage;
        wrapper.managerTitle = aTWrapper.defaultAlertHeader;
        wrapper.managerRecommendedAction = aTWrapper.defaultAlertMessage;
        translateLabelInString(wrapper, false);
        return wrapper;
    }

    public static void translateLabelInString(KFSellBestHelperWrapper wrapper, Boolean isStringReplacementRequired) {
        getStringByLabelsForBAL_1(wrapper);
        getStringByLabelsForBAL_2(wrapper);
        getStringByLabelsForBAL_3(wrapper);
        getStringByLabelsForBAL_4(wrapper);
        getStringByLabelsForBAL_5(wrapper);
        getStringByLabelsForBAL_6(wrapper);
        getStringByLabelsForBAL_7(wrapper);
        getStringByLabelsForBAL_8(wrapper);
        getStringByLabelsForBAL_9(wrapper);
        getStringByLabelsForBAL_10(wrapper);
        getStringByLabelsForBAL_11(wrapper);
        getStringByLabelsForBAL_12(wrapper, isStringReplacementRequired);
        getStringByLabelsForBAL_13(wrapper);
        getStringByLabelsForBAL_14(wrapper);
        getStringByLabelsForBAL_15(wrapper);
        getStringByLabelsForBAL_16(wrapper);
        getStringByLabelsForBAL_17(wrapper);
        getStringByLabelsForBAL_18(wrapper);
        getStringByLabelsForBAL_19(wrapper);
        getStringByLabelsForBAL_20(wrapper);
        getStringByLabelsForBAL_21(wrapper);
        getStringByLabelsForBAL_22(wrapper);
        getStringByLabelsForBAL_23(wrapper);
        getStringByLabelsForBAL_24(wrapper);
        getStringByLabelsForBAL_25(wrapper);
        getStringByLabelsForBAL_26(wrapper);
        getStringByLabelsForBAL_27(wrapper);
        getStringByLabelsForBAL_28(wrapper);
    }

    private static void getStringByLabelsForBAL_1(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_1_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_1_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_1_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_1_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_1_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_1_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_1_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_1_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_1_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_1_SellerEmailText;
        }
        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_1_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_1_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_2(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_2_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_2_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_2_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_2_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_2_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_2_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_2_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_2_SellerMessage;
        }

        if (wrapper.sellerEmailText == 'RecomAction_BAL_2_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_2_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_2_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_2_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_3(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_3_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_3_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_3_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_3_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_3_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_3_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_3_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_3_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_3_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_3_SellerEmailText;
        }
        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_3_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_3_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_4(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_4_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_4_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_4_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_4_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_4_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_4_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_4_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_4_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_4_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_3_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_4_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_3_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_5(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_5_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_5_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_5_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_5_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_5_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_5_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_5_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_5_SellerMessage;
        }

        if (wrapper.sellerEmailText == 'RecomAction_BAL_5_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_5_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_5_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_5_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_6(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_6_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_6_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_6_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_6_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_6_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_6_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_6_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_6_SellerMessage;
        }

        if (wrapper.sellerEmailText == 'RecomAction_BAL_6_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_6_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_6_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_6_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_7(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_7_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_7_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_7_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_7_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_7_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_7_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_7_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_7_SellerMessage;
        }

        if (wrapper.sellerEmailText == 'RecomAction_BAL_7_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_7_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_7_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_7_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_8(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_8_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_8_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_8_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_8_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_8_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_8_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_8_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_8_SellerMessage;
        }

        if (wrapper.sellerEmailText == 'RecomAction_BAL_8_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_8_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_8_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_8_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_9(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_9_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_9_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_9_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_9_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_9_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_9_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_9_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_9_SellerMessage;
        }

        if (wrapper.sellerEmailText == 'RecomAction_BAL_9_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_9_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_9_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_9_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_10(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_10_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_10_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_10_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_10_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_10_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_10_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_10_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_10_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_10_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_10_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_10_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_10_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_11(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_11_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_11_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_11_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_11_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_11_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_11_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_11_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_11_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_11_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_11_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_11_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_11_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_12(
        KFSellBestHelperWrapper wrapper,
        Boolean isStringReplacementRequired
    ) {
        String bIRoleName;
        if (wrapper.brId != null && isStringReplacementRequired) {
            bIRoleName = getBuyingInfluenceRoleName(wrapper.brId);
        }

        if (wrapper.actionTitle == 'RecomAction_BAL_12_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_12_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_12_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_12_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_12_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_12_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_12_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_12_SellerMessage;
            if (bIRoleName != null) {
                wrapper.sellerRecommendedAction = wrapper.sellerRecommendedAction.replace(
                    '{Business_Rules__c.Buying_Influence_Role__c}',
                    bIRoleName
                );
            }
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_12_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_12_SellerEmailText;
            if (bIRoleName != null) {
                wrapper.sellerEmailText = wrapper.sellerEmailText.replace('{BI.Role__c}', bIRoleName);
            }
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_12_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_12_ManagerMessage;
            if (bIRoleName != null) {
                wrapper.managerRecommendedAction = wrapper.managerRecommendedAction.replace('{BI.Role__c}', bIRoleName);
            }
        }
    }
    private static void getStringByLabelsForBAL_13(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_13_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_13_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_13_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_13_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_13_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_13_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_13_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_13_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_13_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_13_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_13_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_13_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_14(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_14_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_14_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_14_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_14_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_14_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_14_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_14_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_14_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_14_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_14_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_14_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_14_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_15(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_15_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_15_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_15_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_15_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_15_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_15_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_15_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_15_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_15_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_15_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_15_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_15_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_16(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_16_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_16_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_16_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_16_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_16_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_16_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_16_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_16_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_16_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_16_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_16_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_16_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_17(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_17_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_17_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_17_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_17_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_17_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_17_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_17_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_17_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_17_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_17_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_17_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_17_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_18(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_18_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_18_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_18_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_18_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_18_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_18_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_18_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_18_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_18_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_18_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_18_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_18_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_19(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_19_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_19_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_19_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_19_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_19_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_19_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_19_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_19_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_19_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_19_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_19_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_19_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_20(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_20_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_20_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_20_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_20_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_20_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_20_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_20_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_20_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_20_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_20_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_20_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_20_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_21(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_21_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_21_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_21_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_21_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_21_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_21_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_21_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_21_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_21_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_21_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_21_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_21_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_22(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_22_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_22_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_22_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_22_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_22_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_22_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_22_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_22_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_22_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_22_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_22_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_22_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_23(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_23_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_23_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_23_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_23_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_23_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_23_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_23_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_23_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_23_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_23_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_23_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_23_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_24(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_24_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_24_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_24_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_24_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_24_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_24_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_24_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_24_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_24_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_24_SellerEmailText;
        }

        if (wrapper.managerRecommendedAction == 'RecomAction_BAL_24_ManagerMessage') {
            wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_24_ManagerMessage;
        }
    }
    private static void getStringByLabelsForBAL_25(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_25_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_25_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_25_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_25_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_25_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_25_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_25_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_25_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_25_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_25_SellerEmailText;
        }

        // if (wrapper.managerRecommendedAction == 'RecomAction_BAL_25_ManagerMessage') {
        //     wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_25_ManagerMessage;
        // }
    }
    private static void getStringByLabelsForBAL_26(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_26_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_26_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_26_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_26_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_26_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_26_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_26_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_26_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_26_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_26_SellerEmailText;
        }

        // if (wrapper.managerRecommendedAction == 'RecomAction_BAL_26_ManagerMessage') {
        //     wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_26_ManagerMessage;
        // }
    }
    private static void getStringByLabelsForBAL_27(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_27_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_27_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_27_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_27_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_27_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_27_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_27_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_27_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_27_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_27_SellerEmailText;
        }

        // if (wrapper.managerRecommendedAction == 'RecomAction_BAL_27_ManagerMessage') {
        //     wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_27_ManagerMessage;
        // }
    }
    private static void getStringByLabelsForBAL_28(KFSellBestHelperWrapper wrapper) {
        if (wrapper.actionTitle == 'RecomAction_BAL_28_actionMsg') {
            wrapper.actionTitle = System.Label.RecomAction_BAL_28_actionMsg;
        }
        if (wrapper.sellerTitle == 'RecomAction_BAL_28_actionMsg') {
            wrapper.sellerTitle = System.Label.RecomAction_BAL_28_actionMsg;
        }
        if (wrapper.managerTitle == 'RecomAction_BAL_28_actionMsg') {
            wrapper.managerTitle = System.Label.RecomAction_BAL_28_actionMsg;
        }
        if (wrapper.sellerRecommendedAction == 'RecomAction_BAL_28_SellerMessage') {
            wrapper.sellerRecommendedAction = System.Label.RecomAction_BAL_28_SellerMessage;
        }
        if (wrapper.sellerEmailText == 'RecomAction_BAL_28_SellerEmailText') {
            wrapper.sellerEmailText = System.Label.RecomAction_BAL_28_SellerEmailText;
        }

        // if (wrapper.managerRecommendedAction == 'RecomAction_BAL_28_ManagerMessage') {
        //     wrapper.managerRecommendedAction = System.Label.RecomAction_BAL_28_ManagerMessage;
        // }
    }
    private static void setOtherData(KFSellBestHelperWrapper wrapper, KF_Sell_Best__c KFSell, Boolean isCallForEmail) {
        // wrapper.sellerURLText=KFSell.Seller_URL_Text__c;
        if (!isCallForEmail) {
            wrapper.associatedObject = KFSell.Associated_Object__c;
        }
        wrapper.sellerURLLink = KFSell.Seller_URL_Link__c;
        wrapper.id = KFSell.Id;
        wrapper.opportunity = KFSell.Opportunity__c;
        wrapper.greenSheet = KFSell.Green_Sheet__c;
        wrapper.alertType = KFSell.Alert_Type__c;
    }
}