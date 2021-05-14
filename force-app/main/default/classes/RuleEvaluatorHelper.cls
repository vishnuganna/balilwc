public with sharing class RuleEvaluatorHelper {
    public static string getOppOwnerName(String OppId) {
        String oppQuery = 'SELECT Id,Name,Owner.Name FROM Opportunity where Id =: OppId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('OppId', OppId);
        List<Opportunity> opportunityRec = DataFactory.read(oppQuery, paramters);
        String oppOwnername = opportunityRec[0].Owner.Name;
        return oppOwnername;
    }

    // get opp owner id
    public static Map<String, String> getOppOwnerId(Set<String> oppIdSet) {
        Map<String, String> mapOppIdAndOwnerId = new Map<String, String>();
        String soqlOpp = 'Select Id,OwnerId from Opportunity where id =: oppIdSet';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppIdSet', oppIdSet);
        List<Opportunity> oppLst = DataFactory.read(soqlOpp, parameters);
        for (Opportunity op1 : oppLst) {
            mapOppIdAndOwnerId.put(op1.Id, op1.OwnerId);
        }
        return mapOppIdAndOwnerId;
    }

    // get opp owner profile id
    public static Map<String, String> getUserProfileId(Set<String> oppOwnerId) {
        Map<String, String> mapUserProfileId = new Map<String, String>();
        String soqlProfile = 'Select Id,ProfileId from User where id =: oppOwnerId';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('oppOwnerId', oppOwnerId);
        List<User> userLst = DataFactory.read(soqlProfile, parameters);
        for (User user1 : userLst) {
            mapUserProfileId.put(user1.Id, user1.ProfileId);
        }
        return mapUserProfileId;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static boolean isAuthorized(
        Business_Rules__c brObj,
        Id OpportunityId,
        Map<String, String> mapOppOwnerId,
        Map<String, String> mapUserProfileId,
        Map<String, Set<String>> brGrpIdAndMembers
    ) {
        system.debug('start autherization');
        boolean result = false;
        if (brObj.Business_Rules_Group__c != null) {
            system.debug('grp not null');
            Set<String> brGrpMemIdsSet = brGrpIdAndMembers.get(brObj.Business_Rules_Group__c);
            String ownerId = mapOppOwnerId.get(OpportunityId);
            String profileId = mapUserProfileId.get(ownerId);
            system.debug('ownerId' + ownerId);
            system.debug('profileId' + profileId);
            if (brGrpMemIdsSet != null && (brGrpMemIdsSet.contains(ownerId) || brGrpMemIdsSet.contains(profileId))) {
                result = true;
            }
        }
        return result;
    }

    @TestVisible
    public static boolean isStageApplicable(Set<String> applicableStages, String stageName) {
        return (applicableStages == null || applicableStages.isEmpty()) ? true : applicableStages.contains(stageName);
    }

    /*public static boolean isInCurrencyRange(BuyingInfluenceEvaluator.RuleParams ruleParams) {
        Business_Rules__c businessRule = ruleParams.brObj;
        String fieldName = businessRule.Opportunity_Currency_Fields__c;
        //  fieldName = 'Blue_Sheet__r.Opportunity__r.'+fieldName;
        Double minValue = (Double) businessRule.Minimum_Range__c;
        Double maxValue = (Double) businessRule.Maximum_Range__c;
        Boolean result = true;
        Double fieldValue = null;
        if (fieldName != null) {
            fieldValue = (Double) ruleParams.buyingInfluence.getSobject('Blue_Sheet__r')
                .getSobject('Opportunity__r')
                .get(fieldName);
            // fieldValue = (Double) ruleParams.buyingInfluence.get(fieldName);
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
        return result;
    }*/
    public static boolean isInCurrencyRange(Business_Rules__c businessRule, Opportunity opportunity) {
        String fieldName = businessRule.Opportunity_Currency_Fields__c;
        Double minValue = (Double) businessRule.Minimum_Range__c;
        Double maxValue = (Double) businessRule.Maximum_Range__c;
        Boolean result = true;
        Double fieldValue = null;

        if (fieldName != null) {
            fieldValue = (Double) Opportunity.get(fieldName);
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
        return result;
    }

    public static List<String> getCurrencyFieldsAsList() {
        List<String> fields = new List<String>();
        SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        Map<String, Schema.SObjectField> mfieldsMap = objType.getDescribe().fields.getMap();

        for (Schema.SObjectField fld : mfieldsMap.values()) {
            DescribeFieldResult fieldDescribe = fld.getDescribe();
            if (fld.getDescribe().getType() == Schema.DisplayType.CURRENCY && fieldDescribe.isAccessible()) {
                fields.add(fld.getDescribe().getName());
            }
        }
        return fields;
    }

    //get Grp id
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
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static KF_Sell_Best__c mappingBestActionRecordFields(
        Business_Rules__c brObj,
        RecommendationsActionWrapper MessageActionWrapper,
        String ruleId,
        KF_Sell_Best__c bestActionRec
    ) {
        bestActionRec.Manager_Recommended_Action__c = MessageActionWrapper.managerRecommendedActionMessage;
        bestActionRec.Seller_Recommended_Action__c = MessageActionWrapper.sellerRecommendedActionMessage;
        bestActionRec.Manager_URL_Text__c = MessageActionWrapper.managerUrlText;
        bestActionRec.Manager_URL_Link__c = MessageActionWrapper.managerUrlLink;
        bestActionRec.Seller_URL_Link__c = MessageActionWrapper.sellerUrlLink;
        bestActionRec.Seller_URL_Text__c = MessageActionWrapper.sellerUrlText;
        bestActionRec.Action_Title__c = MessageActionWrapper.actionMsg;
        bestActionRec.Seller_Email_Text__c = MessageActionWrapper.sellerEmailText;
        bestActionRec.Associated_Object__c = MessageActionWrapper.associatedObject;
        bestActionRec.BestActionRuleId__c = ruleId;

        if (brObj != null) {
            bestActionRec.Business_Rules__c = brObj.Id;
        }

        return bestActionRec;
    }

    public static KF_Sell_Best__c mappingBestActionRecordFieldsToUpdate(
        KF_Sell_Best__c bestActionRecord,
        RecommendationsActionWrapper MessageActionWrapper
    ) {
        KF_Sell_Best__c bestActionRec = new KF_Sell_Best__c(id = bestActionRecord.Id);
        bestActionRec.Manager_Recommended_Action__c = MessageActionWrapper.managerRecommendedActionMessage;
        bestActionRec.Seller_Recommended_Action__c = MessageActionWrapper.sellerRecommendedActionMessage;
        bestActionRec.Seller_Email_Text__c = MessageActionWrapper.sellerEmailText;
        bestActionRec.Action_Title__c = MessageActionWrapper.actionMsg;
        bestActionRec.Seller_URL_Text__c = MessageActionWrapper.sellerUrlText;
        bestActionRec.Seller_URL_Link__c = MessageActionWrapper.sellerUrlLink;
        bestActionRec.Manager_URL_Text__c = MessageActionWrapper.managerUrlText;
        bestActionRec.Manager_URL_Link__c = MessageActionWrapper.managerUrlLink;

        return bestActionRec;
    }

    public static KF_Sell_Best__c mappingBestActionFieldsToEmpty(KF_Sell_Best__c bestActionRecord) {
        KF_Sell_Best__c bestActionRec = new KF_Sell_Best__c(id = bestActionRecord.Id);
        bestActionRec.Manager_Recommended_Action__c = '';
        bestActionRec.Seller_Recommended_Action__c = '';
        bestActionRec.Seller_Email_Text__c = '';
        bestActionRec.Action_Title__c = '';
        bestActionRec.Seller_URL_Text__c = '';
        bestActionRec.Seller_URL_Link__c = '';
        bestActionRec.Manager_URL_Text__c = '';
        bestActionRec.Manager_URL_Link__c = '';

        return bestActionRec;
    }
}