@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessiveParameterList,PMD.NcssMethodCount')
public with sharing class EmailAlertTemplateUtility {
    public static void createAlertTemplate(List<EmailSellerWrapper> sellerWrappers) {
        if (!sellerWrappers.isEmpty()) {
            List<EmailTemplate> emailTemplateData = new List<EmailTemplate>();
            emailTemplateData = EmailAlertTemplateUtility.getEmailTemplateData();
            List<OrgWideEmailAddress> orgWideEmailAddList = new List<OrgWideEmailAddress>();
            orgWideEmailAddList = EmailAlertTemplateUtility.getOrgWideEmailAddList();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();

            for (EmailSellerWrapper seller : sellerWrappers) {
                try {
                    Map<String, EmailAlertTemplateUtilityWrapper> listOfAction = getAllRecommendationsActions(
                        seller.templateWrappers,
                        seller.name,
                        false
                    );
                    // && !listOfAction.isEmpty()
                    if (listOfAction != null && !listOfAction.isEmpty()) {
                        String templateUI =
                            getTableTopSection() +
                            createEmailTemplateData(listOfAction.values()) +
                            getTableBottomSection();

                        Messaging.SingleEmailMessage email = SendEmailForKFAlert.sendEmaill(
                            seller.userId,
                            templateUI,
                            seller.subject,
                            emailTemplateData,
                            orgWideEmailAddList
                        );
                        allMails.add(email);
                        // sendEmailToSeller(seller.email, templateUI, seller.subject,emailTemplateData, orgWideEmailAddList);
                    }
                } catch (Exception ex) {
                    system.System.debug('exception ----' + ex);
                    system.System.debug('exception line----' + ex.getLineNumber());
                    throw new EmailAlertTemplateUtilityException('Error occured while setting email seller data');
                }
            }
            if (allMails != null && !allMails.isEmpty()) {
                SendEmailForKFAlert.sendOutEmails(allMails);
            }
        }
    }

    public static void createAlertTemplateManager(List<EmailManagerWrapper> managerWrappers) {
        if (!managerWrappers.isEmpty()) {
            List<EmailTemplate> emailTemplateData = new List<EmailTemplate>();
            emailTemplateData = EmailAlertTemplateUtility.getEmailTemplateData();
            List<OrgWideEmailAddress> orgWideEmailAddList = new List<OrgWideEmailAddress>();
            orgWideEmailAddList = EmailAlertTemplateUtility.getOrgWideEmailAddList();
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();

            for (EmailManagerWrapper manager : managerWrappers) {
                List<EmailAlertTemplateUtilityWrapper> managerEmailData = new List<EmailAlertTemplateUtilityWrapper>();
                try {
                    for (EmailSellerWrapper managerSeller : manager.sellerWrappers) {
                        Map<String, EmailAlertTemplateUtilityWrapper> listOfActionForManager = getAllRecommendationsActions(
                            managerSeller.templateWrappers,
                            managerSeller.name,
                            true
                        );
                        managerEmailData.addAll(listOfActionForManager.values());
                    }
                    String templateUI =
                        getTableTopSection() +
                        createEmailTemplateData(managerEmailData) +
                        getTableBottomSection();
                    // sendEmailToSeller(manager.email, templateUI, manager.subject,emailTemplateData, orgWideEmailAddList);
                    Messaging.SingleEmailMessage email = SendEmailForKFAlert.sendEmaill(
                        manager.userId,
                        templateUI,
                        manager.subject,
                        emailTemplateData,
                        orgWideEmailAddList
                    );
                    allMails.add(email);
                } catch (Exception ex) {
                    system.System.debug('exception ----' + ex);
                    system.System.debug('exception line----' + ex.getLineNumber());
                    throw new EmailAlertTemplateUtilityException('Error occured while setting email manager data');
                }
            }
            if (allMails != null && !allMails.isEmpty()) {
                SendEmailForKFAlert.sendOutEmails(allMails);
            }
        }
    }

    // public static void sendEmailToSeller(List<String> toRecipients, String template, String emailSubject, List<EmailTemplate> emailTemplateData, List<OrgWideEmailAddress> orgWideEmailAddList) {
    //     // SendEmailForKFAlert.sendEmaill(toRecipients, template, emailSubject);
    //     SendEmailForKFAlert.sendEmaill(toRecipients, template, emailSubject, emailTemplateData, orgWideEmailAddList);
    // }

    public static String createEmailTemplateData(List<EmailAlertTemplateUtilityWrapper> actionDataForEmail) {
        String alertDataForRow = '';
        for (EmailAlertTemplateUtilityWrapper alertData : actionDataForEmail) {
            alertData.opportunities = removesDuplicateOpp(alertData.opportunities);
            alertDataForRow += createTempalte(alertData);
        }
        return alertDataForRow;
    }

    private static List<EmailAlertOpportunityWrapper> removesDuplicateOpp(
        List<EmailAlertOpportunityWrapper> opportunities
    ) {
        Set<String> idSet = new Set<String>();
        List<EmailAlertOpportunityWrapper> opportunitiesFinal = new List<EmailAlertOpportunityWrapper>();
        if (opportunities != null) {
            for (EmailAlertOpportunityWrapper wrap : opportunities) {
                if (!idSet.contains(wrap.id)) {
                    opportunitiesFinal.add(wrap);
                    idSet.add(wrap.id);
                }
            }
        }
        return opportunitiesFinal;
    }

    private static Map<String, EmailAlertTemplateUtilityWrapper> getAllRecommendationsActions(
        List<TemplateWrapper> emailSellerWrapper,
        String sellerName,
        Boolean isManager
    ) {
        RecommendationsActionMessages rcom = new RecommendationsActionMessages();
        Map<String, RecommendationsActionWrapper> data = rcom.getRecommendationsActionMessages();

        Map<String, EmailAlertTemplateUtilityWrapper> listOfRecommendationsAction = new Map<String, EmailAlertTemplateUtilityWrapper>();
        for (TemplateWrapper templateWrapperData : emailSellerWrapper) {
            RecommendationsActionWrapper recommendationsAction = data.get(templateWrapperData.ruleId);
            if (recommendationsAction != null) {
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_1')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_1';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_2')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_2';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_3')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_3';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_4')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_4';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_5')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_5';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_6')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_6';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_7')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_7';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_8')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_8';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_9')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_9';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                //Addition for Green Sheet Rules to be done here

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_10')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_10';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_11')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_11';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }

                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_12')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_12';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_13')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_13';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_14')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_14';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_15')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_15';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_16')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_16';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_17')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_17';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_18')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_18';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_19')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_19';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_20')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_20';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_21')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_21';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_22')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_22';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_23')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_23';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_24')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_24';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_25')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_25';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_26')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_26';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_27')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_27';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
                if (templateWrapperData.ruleId.equalsIgnoreCase('BAL_28')) {
                    RecommendationsActionBindData recommendationsActionData = new RecommendationsActionBindData();
                    recommendationsActionData.keyName = 'BAL_28';
                    recommendationsActionData.isManager = isManager;
                    recommendationsActionData.listOfRecommendationsAction = listOfRecommendationsAction;
                    recommendationsActionData.recommendationsAction = recommendationsAction;
                    recommendationsActionData.sellerName = sellerName;
                    recommendationsActionData.templateWrapperData = templateWrapperData;
                    addRecommendationsActionInWrapper(recommendationsActionData);
                }
            }
        }
        return listOfRecommendationsAction;
    }

    public static void addRecommendationsActionInWrapper(RecommendationsActionBindData dataForRecommendation) {
        if (dataForRecommendation.isManager) {
            EmailAlertTemplateUtilityWrapper blueSheetRequired = dataForRecommendation.listOfRecommendationsAction.get(
                dataForRecommendation.keyName
            );
            if (blueSheetRequired == null) {
                blueSheetRequired = new EmailAlertTemplateUtilityWrapper();
            }

            List<String> managerRecommendedAction = new List<String>();
            if (
                dataForRecommendation.templateWrapperData.managerMsgBody != null &&
                dataForRecommendation.templateWrapperData.managerMsgBody != ''
            ) {
                managerRecommendedAction = dataForRecommendation.templateWrapperData.managerMsgBody.split('\n');
                //removeExtraWordFromtext(managerRecommendedAction);
            }

            List<String> actionMsgManager = new List<String>(blueSheetRequired.textBody);
            String managerBodyInDB;
            if (dataForRecommendation.templateWrapperData.managerMsgBody != null) {
                actionMsgManager.addAll(managerRecommendedAction);

                Set<String> actionMsgSetManager = new Set<String>();
                actionMsgSetManager.addAll(actionMsgManager);
                actionMsgManager.clear();
                actionMsgManager.addAll(actionMsgSetManager);
            }

            // new data

            List<String> actionMsg = new List<String>(blueSheetRequired.actionName);
            String managerTitleInDB;
            if (dataForRecommendation.templateWrapperData.actionTitleManager != null) {
                actionMsg.add(dataForRecommendation.templateWrapperData.actionTitleManager);
                Set<String> actionMsgSet = new Set<String>();
                actionMsgSet.addAll(actionMsg);
                actionMsg.clear();
                actionMsg.addAll(actionMsgSet);
            }
            string managerTitleMerge = string.join(actionMsg, ' <br> ');

            blueSheetRequired.actionName = actionMsg;
            blueSheetRequired.textBody = actionMsgManager;
            blueSheetRequired.actionTitle = managerTitleMerge;
            blueSheetRequired.videoURLs = dataForRecommendation.templateWrapperData.managerVideoUrl != null &&
                dataForRecommendation.templateWrapperData.managerVideoUrl != ''
                ? dataForRecommendation.templateWrapperData.managerVideoUrl
                : '';
            blueSheetRequired.videoURLsName = dataForRecommendation.templateWrapperData.managerVideoText != null &&
                dataForRecommendation.templateWrapperData.managerVideoText != ''
                ? dataForRecommendation.templateWrapperData.managerVideoText
                : '';
            blueSheetRequired.isManager = true;
            blueSheetRequired.sellerName = dataForRecommendation.sellerName;
            if (dataForRecommendation.templateWrapperData.sellerOpportunityWrappers.size() > 0) {
                blueSheetRequired.isHaveOpportunities = true;
                List<EmailAlertOpportunityWrapper> consolidateOpportunity = new List<EmailAlertOpportunityWrapper>(
                    blueSheetRequired.opportunities
                );
                consolidateOpportunity.addAll(dataForRecommendation.templateWrapperData.sellerOpportunityWrappers);
                blueSheetRequired.opportunities = consolidateOpportunity;
            } //Add Greensheet code
            if (dataForRecommendation.templateWrapperData.sellerGreenSheetWrappers.size() > 0) {
                blueSheetRequired.isHaveGreenSheets = true;
                List<EmailAlertGreenSheetWrapper> consolidateGreenSheet = new List<EmailAlertGreenSheetWrapper>(
                    blueSheetRequired.greenSheets
                );
                consolidateGreenSheet.addAll(dataForRecommendation.templateWrapperData.sellerGreenSheetWrappers);
                blueSheetRequired.greenSheets = consolidateGreenSheet;
            }

            dataForRecommendation.listOfRecommendationsAction.put(dataForRecommendation.keyName, blueSheetRequired);
        } else {
            EmailAlertTemplateUtilityWrapper blueSheetRequired = dataForRecommendation.listOfRecommendationsAction.get(
                dataForRecommendation.keyName
            );
            if (blueSheetRequired == null) {
                blueSheetRequired = new EmailAlertTemplateUtilityWrapper();
            }
            List<String> sellerRecommendedActionMessageData = new List<String>();
            if (
                dataForRecommendation.templateWrapperData.sellerMsgBody != null &&
                dataForRecommendation.templateWrapperData.sellerMsgBody != ''
            ) {
                sellerRecommendedActionMessageData = dataForRecommendation.templateWrapperData.sellerMsgBody.split(
                    '\n'
                );
                //removeExtraWordFromtext(sellerRecommendedActionMessageData);
            }

            List<String> sellerTextBody = new List<String>(blueSheetRequired.textBody);
            if (dataForRecommendation.templateWrapperData.managerMsgBody != null) {
                sellerTextBody.addAll(sellerRecommendedActionMessageData);

                Set<String> sellerTextBodySet = new Set<String>();
                sellerTextBodySet.addAll(sellerTextBody);
                sellerTextBody.clear();
                sellerTextBody.addAll(sellerTextBodySet);
            }

            List<String> masgTitleForSeller = new List<String>(blueSheetRequired.actionName);
            if (dataForRecommendation.templateWrapperData.actionTitleSeller != null) {
                masgTitleForSeller.add(dataForRecommendation.templateWrapperData.actionTitleSeller);
                Set<String> masgTitleForSellerSet = new Set<String>();
                masgTitleForSellerSet.addAll(masgTitleForSeller);
                masgTitleForSeller.clear();
                masgTitleForSeller.addAll(masgTitleForSellerSet);
            }
            string sellerTitleMerge = string.join(masgTitleForSeller, ' <br> ');
            blueSheetRequired.actionName = masgTitleForSeller;
            blueSheetRequired.textBody = sellerTextBody;
            blueSheetRequired.actionTitle = sellerTitleMerge;
            blueSheetRequired.videoURLs = dataForRecommendation.templateWrapperData.sellerVideoUrl != null &&
                dataForRecommendation.templateWrapperData.sellerVideoUrl != ''
                ? dataForRecommendation.templateWrapperData.sellerVideoUrl
                : '';
            blueSheetRequired.videoURLsName = dataForRecommendation.templateWrapperData.sellerVideoText != null &&
                dataForRecommendation.templateWrapperData.sellerVideoText != ''
                ? dataForRecommendation.templateWrapperData.sellerVideoText
                : '';

            if (dataForRecommendation.templateWrapperData.sellerOpportunityWrappers.size() > 0) {
                blueSheetRequired.isHaveOpportunities = true;
                List<EmailAlertOpportunityWrapper> consolidateOpportunityForSeller = new List<EmailAlertOpportunityWrapper>(
                    blueSheetRequired.opportunities
                );
                consolidateOpportunityForSeller.addAll(
                    dataForRecommendation.templateWrapperData.sellerOpportunityWrappers
                );
                blueSheetRequired.opportunities = consolidateOpportunityForSeller;
            } //Add greenSheet Code
            if (dataForRecommendation.templateWrapperData.sellerGreenSheetWrappers.size() > 0) {
                blueSheetRequired.isHaveGreenSheets = true;
                List<EmailAlertGreenSheetWrapper> consolidateGreenSheetSeller = new List<EmailAlertGreenSheetWrapper>(
                    blueSheetRequired.greenSheets
                );
                consolidateGreenSheetSeller.addAll(dataForRecommendation.templateWrapperData.sellerGreenSheetWrappers);
                blueSheetRequired.greenSheets = consolidateGreenSheetSeller;
            }
            dataForRecommendation.listOfRecommendationsAction.put(dataForRecommendation.keyName, blueSheetRequired);
        }
    }

    private static void removeExtraWordFromtext(List<String> recommendedActiontext) {
        for (Integer textIndex = 0; textIndex < recommendedActiontext.size(); textIndex++) {
            if (recommendedActiontext[textIndex].contains('Quick refresher:')) {
                recommendedActiontext.remove(textIndex);
            } else if (recommendedActiontext[textIndex].contains('LINK TO:')) {
                recommendedActiontext.remove(textIndex);
            }
        }
    }
    private static String createTempalte(EmailAlertTemplateUtilityWrapper emailAlert) {
        String template = '<tr>';
        String templateEnd = '</tr>';
        String row;
        String normalTextBody = '';
        String urlTextBody = '';
        String actionNameText = '';

        if (emailAlert.actionTitle != null) {
            row = +'<td>' + emailAlert.actionTitle + '</td>';
        }

        for (Integer textBodyIndex = 0; textBodyIndex < emailAlert.textBody.size(); textBodyIndex++) {
            // Create five new imaginary friends!
            if (emailAlert.textBody[textBodyIndex] != null) {
                if (emailAlert.sellerName != null && textBodyIndex == 0) {
                    normalTextBody +=
                        '<p class="details-tag">' +
                        emailAlert.sellerName +
                        ' ' +
                        emailAlert.textBody[textBodyIndex] +
                        '</p>';
                } else {
                    normalTextBody += '<p class="details-tag">' + emailAlert.textBody[textBodyIndex] + '</p>';
                }
            }
        }
        if (emailAlert.isHaveOpportunities) {
            if (emailAlert.videoURLs != null && emailAlert.videoURLs.length() > 1) {
                urlTextBody +=
                    '<h6 class="quick-referash"><a href="' +
                    emailAlert.videoURLs +
                    '">Quick Refresher<a></h6>';
            }
            for (EmailAlertOpportunityWrapper opportunity : emailAlert.opportunities) {
                urlTextBody +=
                    '<p>' +
                    //opportunity.name +
                    ' <a href="' +
                    opportunity.url +
                    '">' +
                    opportunity.name +
                    '</p>';
            }
        }

        //Add GreenSheet Code
        if (emailAlert.isHaveGreenSheets) {
            if (emailAlert.videoURLs != null && emailAlert.videoURLs.length() > 1) {
                urlTextBody +=
                    '<h6 class="quick-referash"><a href="' +
                    emailAlert.videoURLs +
                    '">Quick Refresher<a></h6>';
            }
            for (EmailAlertGreenSheetWrapper greensheet : emailAlert.greenSheets) {
                urlTextBody +=
                    '<p>' +
                    //opportunity.name +
                    ' <a href="' +
                    greensheet.url +
                    '">' +
                    greensheet.name +
                    '</p>';
            }
        }

        row += '<td>' + normalTextBody + urlTextBody + '</td>';
        String finalTemp = template + row + templateEnd;
        return finalTemp;
    }

    public static String getTableTopSection() {
        String topSection =
            '<!DOCTYPE html>' +
            '<html> <head> <meta http-equiv="X-UA-Compatible" content="IE=edge"><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1"><title>KF Sell Best Action Alert </title>' +
            '<style> html { width: 100%; } body { -webkit-text-size-adjust: none; -ms-text-size-adjust: none; margin: 0; padding: 0; }' +
            'table { border-spacing: 0; border-collapse: collapse; table-layout: fixed; margin: 0 auto; } table table table { table-layout: auto; }' +
            'h3{margin: 0px 0px 20px 0px;line-height: 1em;font-size: 14px;} table td table td{ border-collapse: collapse;vertical-align:top;border-right: solid 1px gray;padding: 5px; }' +
            'table td { border-collapse: collapse;vertical-align:top;border-right: solid 1px gray;border-bottom: solid 1px gray; }' +
            'table th {border-bottom: 1px solid gray;border-right: 1px solid gray; } a { color: #c86e6e; text-decoration: none; }' +
            ' p {margin:0px;} .quick-referash{margin: 6px 2px; font-size: 15px;} .details-tag{margin-bottom: 15px;}</style> </head> <body>' +
            '<table align="center" width="800" border="0" cellspacing="0" cellpadding="0" style="border:1px solid #ccc;"><tr><td>  ' +
            '<table align="center" width="100%" border="0" cellspacing="0" cellpadding="0" style="border:1px solid #ccc;">' +
            '<tr>  <th>' +
            System.Label.ActionsTitle +
            '</th> <th>' +
            System.Label.AlertDetails +
            '</th> </tr> <tr>';
        return topSection;
    }

    public static String getTableBottomSection() {
        String bottomSection = '</td></tr> </table></body> </html>';
        return bottomSection;
    }

    public class RecommendationsActionBindData {
        String keyName;
        RecommendationsActionWrapper recommendationsAction;
        Map<String, EmailAlertTemplateUtilityWrapper> listOfRecommendationsAction;
        TemplateWrapper templateWrapperData;
        String sellerName;
        Boolean isManager;
    }

    private class EmailAlertTemplateUtilityException extends Exception {
    }

    public static List<OrgWideEmailAddress> getOrgWideEmailAddList() {
        String noReply = 'noreply';
        List<OrgWideEmailAddress> orgWideEmailAddList = new List<OrgWideEmailAddress>();

        String orgWideEmailAddQuery = 'SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:noReply LIMIT 1';
        Map<String, Object> params = new Map<String, Object>();
        params.put('noReply', noReply);

        try {
            orgWideEmailAddList = DataFactory.read(orgWideEmailAddQuery, params);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
        return orgWideEmailAddList;
    }

    public static List<EmailTemplate> getEmailTemplateData() {
        String templateApiName = 'kf_alert_email';
        Id templateId;
        List<EmailTemplate> emailTemplateData = new List<EmailTemplate>();
        String emailDataQuery = 'Select Id,Name from EmailTemplate WHERE developername=:templateApiName';

        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('templateApiName', templateApiName);

        try {
            emailTemplateData = DataFactory.read(emailDataQuery, paramters);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
        return emailTemplateData;
    }
}