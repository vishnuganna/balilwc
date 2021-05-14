public with sharing class LandingPageGoldSheetCompletedActivities {
    public static List<KF_Sell_Best__c> bestActionLstDeleteStopInv = new List<KF_Sell_Best__c>();
    public static List<KF_Sell_Best__c> bestActionLstDeleteFocusInv = new List<KF_Sell_Best__c>();
    public static void actionGSCompletedActivities(
        List<Action__c> actionLst,
        Map<Id, Action__c> oldMap,
        String typeStr
    ) {
        //List<KF_Sell_Best__c
        List<FOPWrapper> wrapLst = new List<FOPWrapper>();
        for (Action__c action : actionLst) {
            // oldMap is null, means new record, so proceed
            Action__c oldRec = (oldMap == null ? null : oldMap.get(action.Id));
            if (oldRec == null || (action.Due_Date__c != oldRec.Due_Date__c || action.Status__c != oldRec.Status__c)) {
                // value changed
                FOPWrapper wrap = new FOPWrapper();
                wrap.recordId = action.Id;
                wrap.actionType = typeStr;
                wrap.dueDate = action.Due_Date__c;
                wrap.status = action.Status__c;
                wrap.goldSheetId = action.Fields_of_Play_Gold_Sheet__c;
                wrapLst.add(wrap);
            }
        }
        if (!wrapLst.isEmpty()) {
            processGoldSheetCompleteActivities(wrapLst, typeStr);
        }
    }

    public static void stopInvestmentGSCompletedActivities(
        List<Stop_Investment__c> stopInvLst,
        Map<Id, Stop_Investment__c> oldMap,
        String typeStr
    ) {
        //List<KF_Sell_Best__c
        List<FOPWrapper> wrapLst = new List<FOPWrapper>();
        for (Stop_Investment__c stopInv : stopInvLst) {
            // oldMap is null, means new record, so proceed
            Stop_Investment__c oldRec = (oldMap == null ? null : oldMap.get(stopInv.Id));
            if (oldRec == null || stopInv.Status__c != oldRec.Status__c) {
                // value changed
                FOPWrapper wrap = new FOPWrapper();
                wrap.recordId = stopInv.Id;
                wrap.actionType = typeStr;
                wrap.dueDate = null;
                wrap.status = stopInv.Status__c;
                wrap.goldSheetId = stopInv.Fields_of_Play_Gold_Sheet__c;
                wrapLst.add(wrap);
            }
        }
        if (!wrapLst.isEmpty()) {
            processGoldSheetCompleteActivities(wrapLst, typeStr);
        }
    }

    public static void focusInvestmentGSCompletedActivities(
        List<Focus_Investment__c> focusInvLst,
        Map<Id, Focus_Investment__c> oldMap,
        String typeStr
    ) {
        //List<KF_Sell_Best__c
        List<FOPWrapper> wrapLst = new List<FOPWrapper>();
        for (Focus_Investment__c focusInv : focusInvLst) {
            // oldMap is null, means new record, so proceed
            Focus_Investment__c oldRec = (oldMap == null ? null : oldMap.get(focusInv.Id));
            if (oldRec == null || focusInv.Status__c != oldRec.Status__c) {
                // value changed
                FOPWrapper wrap = new FOPWrapper();
                wrap.recordId = focusInv.Id;
                wrap.actionType = typeStr;
                wrap.dueDate = null;
                wrap.status = focusInv.Status__c;
                wrap.goldSheetId = focusInv.Fields_of_Play_Gold_Sheet__c;
                wrapLst.add(wrap);
            }
        }
        if (!wrapLst.isEmpty()) {
            processGoldSheetCompleteActivities(wrapLst, typeStr);
        }
    }

    public static void investmentProgGSCompletedActivities(
        List<Investment_Program__c> ipLst,
        Map<Id, Investment_Program__c> oldMap,
        String typeStr
    ) {
        //List<KF_Sell_Best__c
        List<FOPWrapper> wrapLst = new List<FOPWrapper>();
        for (Investment_Program__c investmentProg : ipLst) {
            // oldMap is null, means new record, so proceed
            Investment_Program__c oldRec = (oldMap == null ? null : oldMap.get(investmentProg.Id));
            if (
                oldRec == null ||
                (investmentProg.Due_Date__c != oldRec.Due_Date__c ||
                investmentProg.Status__c != oldRec.Status__c)
            ) {
                // value changed
                FOPWrapper wrap = new FOPWrapper();
                wrap.recordId = investmentProg.Id;
                wrap.actionType = typeStr;
                wrap.dueDate = investmentProg.Due_Date__c;
                wrap.status = investmentProg.Status__c;
                wrap.goldSheetId = investmentProg.Fields_of_Play_Gold_Sheet__c;

                wrapLst.add(wrap);
            }
        }
        if (!wrapLst.isEmpty()) {
            processGoldSheetCompleteActivities(wrapLst, typeStr);
        }
    }

    public static void infoNeededGSCompletedActivities(
        List<Information_Needed__c> infoNeededLst,
        Map<Id, Information_Needed__c> oldMap,
        String typeStr
    ) {
        //List<KF_Sell_Best__c
        List<FOPWrapper> wrapLst = new List<FOPWrapper>();
        for (Information_Needed__c infoNeeded : infoNeededLst) {
            Information_Needed__c oldRec = (oldMap == null ? null : oldMap.get(infoNeeded.Id));
            if (
                oldRec == null ||
                (infoNeeded.Due_Date__c != oldRec.Due_Date__c ||
                infoNeeded.Status__c != oldRec.Status__c)
            ) {
                // value changed
                FOPWrapper wrap = new FOPWrapper();
                wrap.recordId = infoNeeded.Id;
                wrap.actionType = typeStr;
                wrap.dueDate = infoNeeded.Due_Date__c;
                wrap.status = infoNeeded.Status__c;
                wrap.goldSheetId = infoNeeded.Fields_of_Play_Gold_Sheet__c;
                wrapLst.add(wrap);
            }
        }
        if (!wrapLst.isEmpty()) {
            processGoldSheetCompleteActivities(wrapLst, typeStr);
        }
    }

    public static void processGoldSheetCompleteActivities(List<FOPWrapper> objLst, String typeStr) {
        Set<String> idSet = new Set<String>();
        for (FOPWrapper wrap : objLst) {
            idSet.add(wrap.recordId);
        }
        Map<String, String> mapExistingAlertRec = getExistingBestActionRecord(idSet);
        Date date90DaysBefore = Date.today() - 90;
        List<KF_Sell_Best__c> lstToInsert = new List<KF_Sell_Best__c>();
        Set<String> lstToDelete = new Set<String>();
        for (FOPWrapper wrap : objLst) {
            //wrap.dueDate == null, means Stop Investment or Focus Investment
            if (
                wrap.status == 'Complete' &&
                (wrap.dueDate == null || (wrap.dueDate >= date90DaysBefore && wrap.dueDate <= Date.today()))
            ) {
                String existingAlertRecId = mapExistingAlertRec.get(wrap.recordId);
                if (existingAlertRecId == null) {
                    lstToInsert.add(getAlertToCreate(wrap, typeStr));
                }
            } else {
                //delete alert
                lstToDelete.add(wrap.recordId);
            }
        }

        if (!lstToInsert.isEmpty()) {
            DataFactory.create(lstToInsert);
        }
        if (!lstToDelete.isEmpty()) {
            deleteRecords(lstToDelete);
        }
    }

    private static KF_Sell_Best__c getAlertToCreate(FOPWrapper wrap, String typeStr) {
        KF_Sell_Best__c bestAction = new KF_Sell_Best__c();
        switch on typeStr {
            when 'Action' {
                bestAction.Gold_Sheet_Action__c = wrap.recordId;
            }
            when 'Information Needed' {
                bestAction.Gold_Sheet_InfoNeeded__c = wrap.recordId;
            }
            when 'Investment Program' {
                bestAction.Gold_Sheet_Investment_Program__c = wrap.recordId;
            }
            when 'Stop Investment' {
                bestAction.Gold_Sheet_Stop_Investment__c = wrap.recordId;
            }
            when 'Focus Investment' {
                bestAction.Gold_Sheet_Focus_Investment__c = wrap.recordId;
            }
        }
        bestAction.Associated_Object__c = typeStr;
        bestAction.Alert_Type__c = 'Gold_Sheet_Completed_Activities';
        bestAction.Date_Completed__c = wrap.dueDate;
        bestAction.Fields_of_Play_Gold_Sheet__c = wrap.goldSheetId;
        return bestAction;
    }
    private static Map<String, String> getExistingBestActionRecord(Set<String> idSet) {
        List<KF_Sell_Best__c> bestActionRec = getBestActionRecords(idSet);
        Map<String, String> mapExistingRec = new Map<String, String>();
        for (KF_Sell_Best__c bestActionObj : bestActionRec) {
            if (bestActionObj.Gold_Sheet_Action__c != null) {
                mapExistingRec.put(bestActionObj.Gold_Sheet_Action__c, bestActionObj.Id);
            }
            if (bestActionObj.Gold_Sheet_InfoNeeded__c != null) {
                mapExistingRec.put(bestActionObj.Gold_Sheet_InfoNeeded__c, bestActionObj.Id);
            }
            if (bestActionObj.Gold_Sheet_Investment_Program__c != null) {
                mapExistingRec.put(bestActionObj.Gold_Sheet_Investment_Program__c, bestActionObj.Id);
            }
            if (bestActionObj.Gold_Sheet_Stop_Investment__c != null) {
                mapExistingRec.put(bestActionObj.Gold_Sheet_Stop_Investment__c, bestActionObj.Id);
            }
            if (bestActionObj.Gold_Sheet_Focus_Investment__c != null) {
                mapExistingRec.put(bestActionObj.Gold_Sheet_Focus_Investment__c, bestActionObj.Id);
            }
        }
        return mapExistingRec;
    }
    private static void deleteRecords(Set<String> idSet) {
        List<KF_Sell_Best__c> lstBestActionDelete = getBestActionRecords(idSet);
        if (!lstBestActionDelete.isEmpty()) {
            DataFactory.remove(lstBestActionDelete);
        }
    }

    private static List<KF_Sell_Best__c> getBestActionRecords(Set<String> idSet) {
        String soql = 'Select Id,Gold_Sheet_InfoNeeded__c,Gold_Sheet_Action__c,Gold_Sheet_Investment_Program__c,Gold_Sheet_Stop_Investment__c,Gold_Sheet_Focus_Investment__c from KF_Sell_Best__c where alert_Type__c = \'Gold_Sheet_Completed_Activities\' AND (Gold_Sheet_InfoNeeded__c = : idSet OR  Gold_Sheet_Action__c =: idSet OR Gold_Sheet_Investment_Program__c =: idSet OR Gold_Sheet_Stop_Investment__c =: idSet OR Gold_Sheet_Focus_Investment__c =: idSet)';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('idSet', idSet);
        return DataFactory.read(soql, paramters);
    }

    public static void deleteStopInvestmentBefore(List<Stop_Investment__c> stopInvLst) {
        Set<String> idSet = ApexCommonUtil.getSetOfIdFromList(stopInvLst);
        String query = 'Select Id from KF_Sell_Best__c where Gold_Sheet_Stop_Investment__c =: idSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('idSet', idSet);
        LandingPageGoldSheetCompletedActivities.bestActionLstDeleteStopInv = DataFactory.read(query, paramters);
    }
    public static void deleteStopInvestmentAfter() {
        if (!LandingPageGoldSheetCompletedActivities.bestActionLstDeleteStopInv.isEmpty()) {
            DataFactory.remove(LandingPageGoldSheetCompletedActivities.bestActionLstDeleteStopInv);
        }
    }

    public static void deleteFocusInvestmentBefore(List<Focus_Investment__c> stopInvLst) {
        Set<String> idSet = ApexCommonUtil.getSetOfIdFromList(stopInvLst);
        String query = 'Select Id from KF_Sell_Best__c where Gold_Sheet_Focus_Investment__c =: idSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('idSet', idSet);
        LandingPageGoldSheetCompletedActivities.bestActionLstDeleteFocusInv = DataFactory.read(query, paramters);
    }
    public static void deleteFocusInvestmentAfter() {
        if (!LandingPageGoldSheetCompletedActivities.bestActionLstDeleteFocusInv.isEmpty()) {
            DataFactory.remove(LandingPageGoldSheetCompletedActivities.bestActionLstDeleteFocusInv);
        }
    }

    @AuraEnabled
    public static List<LandingFOPActivitiesWrapper> getFoPActivityRecordData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<LandingFOPActivitiesWrapper> activityListToReturn = new List<LandingFOPActivitiesWrapper>();
        try {
            String query = 'SELECT Id, Associated_Object__c, Fields_of_Play_Gold_Sheet__c, Fields_of_Play_Gold_Sheet__r.FOP_Name__c, Fields_of_Play_Gold_Sheet__r.Id, Fields_of_Play_Gold_Sheet__r.Account__r.Name, Gold_Sheet_AccountOwner__c, Fields_of_Play_Gold_Sheet__r.Owner.Name, Fields_of_Play_Gold_Sheet__r.Account__r.Id,Date_Completed__c  FROM KF_Sell_Best__c WHERE Alert_Type__c = \'Gold_Sheet_Completed_Activities\' AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset ';
            Map<String, Object> params = new Map<String, Object>();
            params.put('userIdSet', userIdSet);
            params.put('queryLimit', queryLimit);
            params.put('queryOffset', queryOffset);
            List<KF_Sell_Best__c> fopList = DataFactory.read(query, params);
            for (KF_Sell_Best__c bestAct : fopList) {
                LandingFOPActivitiesWrapper wrapperObj = new LandingFOPActivitiesWrapper();
                wrapperObj.fopName = bestAct.Fields_of_Play_Gold_Sheet__r.FOP_Name__c;
                wrapperObj.fopId = bestAct.Fields_of_Play_Gold_Sheet__c;
                wrapperObj.dateField = String.valueOf(bestAct.Date_Completed__c);
                wrapperObj.accOwnerName = bestAct.Fields_of_Play_Gold_Sheet__r.Owner.Name;
                wrapperObj.objName = bestAct.Associated_Object__c;
                activityListToReturn.add(wrapperObj);
                //activityListToReturn = GoldSheetLandingPageAction.getActivityTitle(fopList);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new LandingPageGoldSheetCompletedActivitiesException(
                'Error occured while getting Field of Play record'
            );
        }
        return activityListToReturn;
    }

    @AuraEnabled
    public static LandingGoldSheetCompletedActivities getFoPActivityRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingGoldSheetCompletedActivities(
            countGoldSheetCompletedActivitiesData(userIdSet),
            getFoPActivityRecordData(userIdSet, queryLimit, queryOffset)
        );
    }
    @AuraEnabled
    public static Integer countGoldSheetCompletedActivitiesData(List<String> userIdSet) {
        Integer milestoneCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM KF_Sell_Best__c WHERE Alert_Type__c = \'Gold_Sheet_Completed_Activities\' AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        milestoneCount = DataFactory.countQuery(query, paramters);
        return milestoneCount;
    }

    private class LandingPageGoldSheetCompletedActivitiesException extends Exception {
    }

    public class LandingGoldSheetCompletedActivities {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<LandingFOPActivitiesWrapper> activityRecords { get; set; }

        public LandingGoldSheetCompletedActivities(
            Integer totalRecordCount,
            List<LandingFOPActivitiesWrapper> activityRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.activityRecords = activityRecords;
        }
    }
    /*
    @AuraEnabled
    public static Integer countGoldSheetCompletedActivities(List<String> userIdSet) {
        Integer gsCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM KF_Sell_Best__c WHERE Alert_Type__c = \'Gold_Sheet_Completed_Activities\' AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        gsCount = DataFactory.countQuery(query, paramters);
        return gsCount;
    }*/
}