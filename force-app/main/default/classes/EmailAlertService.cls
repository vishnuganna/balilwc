public with sharing class EmailAlertService implements Schedulable {
    public static final String SELLER_EMAIL_TEMPLATE = 'kf_alert_email';
    public static final String MAIL_SUBJECT = 'KF Sell Actions Report';

    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new EmailAlertBatchService(), 200);
    }

    public class EmailWrapperCollection {
        public List<EmailManagerWrapper> managerWrappers;
        public List<EmailSellerWrapper> sellerWrappers;

        public EmailWrapperCollection() {
            managerWrappers = new List<EmailManagerWrapper>();
            sellerWrappers = new List<EmailSellerWrapper>();
        }
    }

    public static void processTOSendEmail(List<KF_Sell_Best__c> kfSellBestActionList) {
        EmailWrapperCollection emailCollection = buildwrapperCollection(kfSellBestActionList);
        if (!emailCollection.sellerWrappers.isEmpty()) {
            EmailAlertTemplateUtility.createAlertTemplate(emailCollection.sellerWrappers);
        }
        if (!emailCollection.managerWrappers.isEmpty()) {
            Set<EmailManagerWrapper> managerData = new Set<EmailManagerWrapper>();
            managerData.addAll(emailCollection.managerWrappers);
            List<EmailManagerWrapper> fillterdata = new List<EmailManagerWrapper>();
            fillterdata.addAll(managerData);
            EmailAlertTemplateUtility.createAlertTemplateManager(fillterdata);
        }
    }

    private static EmailManagerWrapper getManagerWrapper(List<EmailManagerWrapper> managerWrappers, User manager) {
        EmailManagerWrapper mEmailId = new EmailManagerWrapper();
        for (EmailManagerWrapper managerEmail : managerWrappers) {
            String emailManager = managerEmail.email.get(0);
            if (emailManager == manager.Email) {
                mEmailId = managerEmail;
            } else {
                mEmailId = new EmailManagerWrapper();
            }
        }
        return mEmailId;
    }

    public static EmailWrapperCollection buildwrapperCollection(List<KF_Sell_Best__c> kfSellBestActionList) {
        EmailWrapperCollection wrapperCollection = new EmailWrapperCollection();
        Map<List<String>, List<EmailSellerWrapper>> mapEmailToSellers = new Map<List<String>, List<EmailSellerWrapper>>();
        Map<String, List<KF_Sell_Best__c>> mapOwnerIdBArecs = getKFSellBestActions(kfSellBestActionList);
        Set<String> recommendationSet = new Set<String>();
        Set<String> user = mapOwnerIdBArecs.keySet();
        Map<String, String> mapBestActionIdRecommendationId = new Map<String, String>();

        for (String userId : mapOwnerIdBArecs.keySet()) {
            //oppId.add(recommend.Opportunity__c);
            List<KF_Sell_Best__c> bestActionLst = mapOwnerIdBArecs.get(userId);
            // for (KF_Sell_Best__c bestAction : bestActionLst) {
            //     recommendationSet.add(bestAction.Recommendations__c);
            //     mapBestActionIdRecommendationId.put(bestAction.Id, bestAction.Recommendations__c);
            // }
        }
        Map<String, String> mapRecommIdBALId = new Map<String, String>(); // = getRuleIdForBestAction(recommendationSet);

        String getUsersQuery = 'SELECT Id, Name, ManagerId, Email FROM User WHERE Id IN :user';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('user', user);
        List<User> users = DataFactory.read(getUsersQuery, parameters);

        for (User userId : users) {
            List<KF_Sell_Best__c> recommedationLst = mapOwnerIdBArecs.get(userId.Id);
            EmailSellerWrapper sellerWrapper = new EmailSellerWrapper();
            sellerWrapper.email.add(userId.email);
            sellerWrapper.name = userId.Name;
            sellerWrapper.subject = MAIL_SUBJECT;
            sellerWrapper.userId = userId.Id;
            List<TemplateWrapper> templateWrappers = buildTemplateWrappers(
                userId.Id,
                recommedationLst,
                mapBestActionIdRecommendationId,
                mapRecommIdBALId
            );
            if (templateWrappers.size() < 1) {
                break;
            }
            sellerWrapper.templateWrappers = templateWrappers;
            wrapperCollection.sellerWrappers.add(sellerWrapper);
            if (userId.ManagerId != null) {
                User manager = getUserManager(userId.ManagerId);
                EmailManagerWrapper managerWrapper = getManagerWrapper(wrapperCollection.managerWrappers, manager);
                if (manager == null) {
                    break;
                }
                if (managerWrapper.email != null) {
                    managerWrapper.email.add(manager.Email);
                }
                managerWrapper.subject = MAIL_SUBJECT;
                managerWrapper.userId = manager.Id;
                managerWrapper.sellerWrappers.add(sellerWrapper);
                if (mapEmailToSellers.containsKey(managerWrapper.email)) {
                    for (EmailManagerWrapper managerWrap : wrapperCollection.managerWrappers) {
                        if (managerWrap.email == managerWrapper.email) {
                            managerWrap.sellerWrappers.add(sellerWrapper);
                        }
                    }
                } else {
                    wrapperCollection.managerWrappers.add(managerWrapper);
                }
                mapEmailToSellers.put(managerWrapper.email, managerWrapper.sellerWrappers);
            }
        }
        processEmailData(wrapperCollection.sellerWrappers, mapBestActionIdRecommendationId, mapRecommIdBALId);
        return wrapperCollection;
    }

    public static User getUserManager(Id managerId) {
        String getManagerQuery = 'SELECT Id, Name, Email FROM User WHERE Id = :managerId';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('managerId', managerId);
        List<User> manager = DataFactory.read(getManagerQuery, parameters);
        if (manager.size() != null) {
            return manager.get(0);
        }
        return null;
    }

    private static Map<String, List<KF_Sell_Best__c>> getKFSellBestActions(List<KF_Sell_Best__c> recommendationRec) {
        Map<String, List<KF_Sell_Best__c>> mapOwnerIdBArecs = new Map<String, List<KF_Sell_Best__c>>();
        List<KF_Sell_Best__c> recommendationsToSend = new List<KF_Sell_Best__c>();
        for (KF_Sell_Best__c bestAct : recommendationRec) {
            if (bestAct.Action_Title__c != null) {
                if (
                    mapOwnerIdBArecs.containsKey(bestAct.Opportunity__r.OwnerId) ||
                    mapOwnerIdBArecs.containsKey(bestAct.Green_Sheet__r.OwnerId)
                ) {
                    if (bestAct.Opportunity__c != null) {
                        recommendationsToSend = mapOwnerIdBArecs.get(bestAct.Opportunity__r.OwnerId);
                        recommendationsToSend.add(bestAct);
                        mapOwnerIdBArecs.put(bestAct.Opportunity__r.OwnerId, recommendationsToSend);
                    } else if (bestAct.Green_Sheet__c != null) {
                        recommendationsToSend = mapOwnerIdBArecs.get(bestAct.Green_Sheet__r.OwnerId);
                        recommendationsToSend.add(bestAct);
                        mapOwnerIdBArecs.put(bestAct.Green_Sheet__r.OwnerId, recommendationsToSend);
                    }
                } else {
                    if (bestAct.Opportunity__c != null) {
                        recommendationsToSend.add(bestAct);
                        mapOwnerIdBArecs.put(bestAct.Opportunity__r.OwnerId, recommendationsToSend);
                    } else if (bestAct.Green_Sheet__c != null) {
                        recommendationsToSend.add(bestAct);
                        mapOwnerIdBArecs.put(bestAct.Green_Sheet__r.OwnerId, recommendationsToSend);
                    }
                }
            }
        }
        return mapOwnerIdBArecs;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static List<TemplateWrapper> buildTemplateWrappers(
        Id user,
        List<KF_Sell_Best__c> recommendationLst,
        Map<String, String> mapBestActionIdRecommendationId,
        Map<String, String> mapRecommIdBALId
    ) {
        /*String getRecommendationsQuery = 'SELECT Id, BestActionLogic__c, Action_Title__c, Business_Rules__c, Seller_Email_Text__c, Seller_URL_Link__c, Seller_URL_Text__c, Manager_Recommended_Action_Message__c, Manager_URL_Link__c, Manager_URL_Text__c, Strategy_Engine__c, Opportunity__c, Opportunity__r.Name, Opportunity__r.OwnerId FROM Recommendations__c WHERE Id IN :recommendationId AND Opportunity__r.OwnerId = :user';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('recommendationId', recommendationId);
        parameters.put('user', user);
        List<Recommendations__c> recommendationsForUser = DataFactory.read(getRecommendationsQuery, parameters);*/
        List<TemplateWrapper> templateWrapList = new List<TemplateWrapper>();
        for (KF_Sell_Best__c recData : recommendationLst) {
            TemplateWrapper templateWrap = new TemplateWrapper();
            EmailAlertOpportunityWrapper opportunityWrapper = new EmailAlertOpportunityWrapper();
            EmailAlertGreenSheetWrapper greenSheetWrapper = new EmailAlertGreenSheetWrapper();
            if (recData.BestActionRuleId__c != null) {
                templateWrap.ruleId = recData.BestActionRuleId__c;
            }
            if (recData.Alert_Type__c != 'Greensheet') {
                KFSellBestHelperWrapper kfsconvertedString = ConverStringFromCustomLabels.getStringByLabels(
                    recData,
                    true
                );

                templateWrap.actionTitle = kfsconvertedString.actionTitle;
                templateWrap.actionTitleManager = kfsconvertedString.managerTitle;
                templateWrap.actionTitleSeller = kfsconvertedString.sellerTitle;
                // templateWrap.actionTitleManager = recData.Action_Title_Manager__c;
                // templateWrap.actionTitleSeller = recData.Action_Title_Seller__c;

                // templateWrap.sellerMsgBody = recData.Seller_Email_Text__c;
                templateWrap.sellerMsgBody = kfsconvertedString.sellerEmailText;
                templateWrap.sellerVideoUrl = recData.Seller_URL_Link__c;
                templateWrap.sellerVideoText = recData.Seller_URL_Text__c;

                // templateWrap.managerMsgBody = recData.Manager_Recommended_Action__c;
                templateWrap.managerMsgBody = kfsconvertedString.managerRecommendedAction;
                templateWrap.managerVideoUrl = recData.Manager_URL_Link__c;
                templateWrap.managerVideoText = recData.Manager_URL_Text__c;

                templateWrap.bestActionRecordId = recData.Id;
                opportunityWrapper.id = recData.Opportunity__c;
                opportunityWrapper.name = recData.Opportunity__r.Name;
                opportunityWrapper.url = createOpportunityUrlById(recData.Opportunity__c, 'Opportunity');
                templateWrap.sellerOpportunityWrappers.add(opportunityWrapper);
            }
            if (recData.Alert_Type__c == 'Greensheet') {
                templateWrap.actionTitle = recData.Action_Title__c;
                templateWrap.sellerMsgBody = recData.Seller_Email_Text__c;
                templateWrap.sellerVideoUrl = recData.Seller_URL_Link__c;
                templateWrap.sellerVideoText = recData.Seller_URL_Text__c;
                templateWrap.managerMsgBody = recData.Manager_Recommended_Action__c;
                templateWrap.managerVideoUrl = recData.Manager_URL_Link__c;
                templateWrap.managerVideoText = recData.Manager_URL_Text__c;
                templateWrap.bestActionRecordId = recData.Id;
                greenSheetWrapper.id = recData.Green_Sheet__c;
                greenSheetWrapper.name = recData.Green_Sheet__r.Task_Name__c;
                greenSheetWrapper.url = createOpportunityUrlById(recData.Green_Sheet__c, 'Green_Sheet__c');
                templateWrap.sellerGreenSheetWrappers.add(greenSheetWrapper);
            }
            templateWrapList.add(templateWrap);
        }
        return templateWrapList;
    }

    public static string createOpportunityUrlById(String oppId, String objectName) {
        String objName = ApexCommonUtil.getObjectwithNameSpace(objectName);
        return 'https://' + URL.getOrgDomainUrl().getHost() + '/lightning/r/' + objName + '/' + oppId + '/view';
    }
    public static void processEmailData(
        List<EmailSellerWrapper> templateWrapList,
        Map<String, String> mapBestActionIdRecommendationId,
        Map<String, String> mapRecommIdBALId
    ) {
        RecommendationsActionMessages recommendationsActionMessages = new RecommendationsActionMessages();
        Map<String, RecommendationsActionWrapper> listOfrecommendationsActionMessages = recommendationsActionMessages.getRecommendationsActionMessages();
        for (EmailSellerWrapper template : templateWrapList) {
            for (TemplateWrapper variable : template.templateWrappers) {
                String ruleId = variable.ruleId;
                if (ruleId != null) {
                    variable.ruleName = listOfrecommendationsActionMessages.get(ruleId).evaluation;
                }
            }
        }
    }
    /*
    private static Map<String, String> getRuleIdForBestAction(Set<String> recommendationIdSet) {
        String recommendationsQuery = 'SELECT Id, BestActionLogic__c FROM Recommendations__c WHERE Id IN :recommendationIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('recommendationIdSet', recommendationIdSet);
        List<Recommendations__c> recommendationsLst = DataFactory.read(recommendationsQuery, parameters);
        Map<String, String> mapRecommIdBALId = new Map<String, String>();
        for (Recommendations__c recomm : recommendationsLst) {
            mapRecommIdBALId.put(recomm.Id, recomm.BestActionLogic__c);
        }
        return mapRecommIdBALId;
    }*/
}