public with sharing class GoldSheetStrategyTabPDFController {
    public String goldSheetStrategyPDFData { get; set; }
    public static GoldSheetPDFWrapper goldSheetStrategyPDFWrapper { get; set; }

    public GoldSheetStrategyTabPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        goldSheetStrategyPDFWrapper = new GoldSheetPDFWrapper();
        if (recordId != null) {
            goldSheetStrategyPDFWrapper.buySellHierarchyData = getBusinessHierarchyData(recordId);
            goldSheetStrategyPDFWrapper.charterStatement = getCharterStatementData(recordId);
            goldSheetStrategyPDFWrapper.focusInvestments = getFocusInvestmentRecords(recordId);
            goldSheetStrategyPDFWrapper.stopInvestments = getStopInvestmentRecords(recordId);
            goldSheetStrategyPDFWrapper.relationshipGoals = getRelationshipGoals(recordId);
            goldSheetStrategyPDFData = JSON.serialize(goldSheetStrategyPDFWrapper);
        }
    }

    public static Map<String, RedFlagStrengthMarkerWrapper> convertRfsMarkerToPdfWrapper(
        List<RedFlagStrengthMarkerWrapper> rfsWrapperList
    ) {
        Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerMap = new Map<String, RedFlagStrengthMarkerWrapper>();
        for (RedFlagStrengthMarkerWrapper redFlagMarker : rfsWrapperList) {
            rfsMarkerMap.put(redFlagMarker.fieldApiName, redFlagMarker);
        }
        return rfsMarkerMap;
    }

    @AuraEnabled
    public static BuySellHierarchyWrapper getBusinessHierarchyData(String goldsheetId) {
        List<Gold_Sheet__c> listBuySellHierarchy = new List<Gold_Sheet__c>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Buy_Sell_Hierarchy__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            String query =
                'SELECT Id,Name,Custom_Date__c,FOP_Custom__c,FOP_Last_Year__c,FOP_Next_Year__c,FOP_This_Year__c,' +
                'Us_Custom__c,Us_Last_Year__c,Us_Next_Year__c,Us_This_Year__c FROM Gold_Sheet__c  WHERE Id =:goldsheetId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listBuySellHierarchy = DataFactory.read(query, paramters);
            BuySellHierarchyWrapper wrapper;
            if (!listBuySellHierarchy.isEmpty()) {
                wrapper = new BuySellHierarchyWrapper(listBuySellHierarchy[0], isUpdatable);
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = listBuySellHierarchy[0].Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
            }
            return wrapper;
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new BuySellHierarchyException('Error occured while getting data from Buy Sell Hierarchy');
        }
    }

    @AuraEnabled
    public static CharterStatementWrapper getCharterStatementData(String goldsheetId) {
        List<Gold_Sheet__c> listGoldSheet = new List<Gold_Sheet__c>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Gold_Sheet__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            String query = 'SELECT Id,Name, Charter_Statement__c FROM Gold_Sheet__c WHERE Id =:goldsheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listGoldSheet = DataFactory.read(query, paramters);
            CharterStatementWrapper wrapper;
            if (!listGoldSheet.isEmpty()) {
                wrapper = new CharterStatementWrapper(listGoldSheet[0], isUpdatable);
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = listGoldSheet[0].Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
            }
            return wrapper;
        } catch (Exception e) {
            throw new CharterStatementException('Error occured while getting data from charterStatement' + e);
        }
    }

    @AuraEnabled
    public static List<FocusInvestmentWrapper> getFocusInvestmentRecords(String goldSheetId) {
        Boolean isDeletable = false;
        List<Focus_Investment__c> fopFocInvestList = new List<Focus_Investment__c>();
        List<FocusInvestmentWrapper> fieldOfFocInvestWrapperList = new List<FocusInvestmentWrapper>();
        if (Schema.sObjectType.Focus_Investment__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String focInvestQuery;
            focInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Focus_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);

            //get data from Field Of Play Focus Investments section
            fopFocInvestList = DataFactory.read(focInvestQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Focus_Investment__c fInvest : fopFocInvestList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = fInvest.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                FocusInvestmentWrapper wrapper = new FocusInvestmentWrapper(fInvest, isDeletable);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                fieldOfFocInvestWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FieldOfFocInvestException('Error occured while getting data from Focus Investment');
        }
        //return list of wrapper containing all Focus Investment data
        return fieldOfFocInvestWrapperList;
    }

    @AuraEnabled
    public static List<StopInvestmentWrapper> getStopInvestmentRecords(String goldSheetId) {
        Boolean isDeletable = false;
        List<Stop_Investment__c> fopFocInvestList = new List<Stop_Investment__c>();
        List<StopInvestmentWrapper> stopInvestmentWrapperList = new List<StopInvestmentWrapper>();
        if (Schema.sObjectType.Stop_Investment__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String stopInvestQuery;
            stopInvestQuery = 'Select Id, Name, Investment_Title__c,Amount__c,Status__c,Description__c, Fields_of_Play_Gold_Sheet__c FROM Stop_Investment__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);

            //get data from Field Of Play Stop Investments section
            fopFocInvestList = DataFactory.read(stopInvestQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Stop_Investment__c fInvest : fopFocInvestList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = fInvest.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                StopInvestmentWrapper wrapper = new StopInvestmentWrapper(fInvest, isDeletable);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                stopInvestmentWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new StopInvestmentException('Error occured while getting data from Stop Investment');
        }
        //return list of wrapper containing all Stop Investment data
        return stopInvestmentWrapperList;
    }

    @AuraEnabled
    public static List<RelationshipGoalsWrapper> getRelationshipGoals(String goldsheetId) {
        List<RelationshipGoalsWrapper> relationshipGoalWrapperListToReturn = new List<RelationshipGoalsWrapper>();
        try {
            relationshipGoalWrapperListToReturn = RelationshipGoals.getRelationshipGoal(goldsheetId, 'Complete');
        } catch (Exception ex) {
            throw new relationshipGoalException('Error occured while getting data from relationshipGoal');
        }
        //return list of wrapper containing all relationshipGoal data

        return relationshipGoalWrapperListToReturn;
    }

    private class RelationshipGoalException extends Exception {
    }

    private class StopInvestmentException extends Exception {
    }

    private class FieldOfFocInvestException extends Exception {
    }

    private class CharterStatementException extends Exception {
    }

    private class BuySellHierarchyException extends Exception {
    }
}