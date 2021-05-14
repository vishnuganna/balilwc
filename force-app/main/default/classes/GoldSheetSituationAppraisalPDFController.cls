public with sharing class GoldSheetSituationAppraisalPDFController {
    public String goldSheetPDFData { get; set; }
    public Gold_Sheet__c goldSheet { get; set; }
    public static GoldSheetPDFWrapper goldSheetPDFWrapper { get; set; }

    public GoldSheetSituationAppraisalPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        goldSheetPDFWrapper = new GoldSheetPDFWrapper();
        if (recordId != null) {
            goldSheetPDFWrapper.strategicPlayers = getStrategicPlayerDataForPDF(recordId);
            goldSheetPDFWrapper.fopTrends = getTrendsRecordsForPDF(recordId);
            goldSheetPDFWrapper.fopOpportunities = getFopOpportunitiesForPDF(recordId);
            goldSheetPDFWrapper.strategicStrengths = getStrategicStrengthRecordsForPDF(recordId);
            goldSheetPDFWrapper.criticalVulnerability = getCriticalVulnerabilityRecordForPDF(recordId);
            goldSheetPDFData = JSON.serialize(goldSheetPDFWrapper);
        }
    }

    @AuraEnabled
    public static CriticalVulnerabilityWrapper getCriticalVulnerabilityRecordForPDF(String goldSheetId) {
        List<Gold_Sheet__c> listGoldSheet = new List<Gold_Sheet__c>();
        CriticalVulnerabilityWrapper wrapper;
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Gold_Sheet__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            String query = 'SELECT Id,Name,Critical_Vulnerability_Desc__c,Critical_Vulnerability_Title__c FROM Gold_Sheet__c WHERE Id =:goldsheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listGoldSheet = DataFactory.read(query, paramters);

            if (!listGoldSheet.isEmpty()) {
                wrapper = new CriticalVulnerabilityWrapper(listGoldSheet[0], isUpdatable);
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = listGoldSheet[0].Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                //wrapper.rfsMarkerWrapper = rfsWrapperList;
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
            }
        } catch (Exception ex) {
            throw new CriticalVulnerabilityException('Error occured while getting data from Critical Vulnerability');
        }
        return wrapper;
    }

    @AuraEnabled
    public static List<StrategicPlayerWrapper> getStrategicPlayerDataForPDF(String goldsheetId) {
        List<StrategicPlayerWrapper> wrapperToReturn = new List<StrategicPlayerWrapper>();
        List<Strategic_Player__c> listStrategicPlayers = new List<Strategic_Player__c>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Strategic_Player__c.isDeletable()) {
            isUpdatable = true;
        }
        try {
            String query = 'SELECT Id,Name,Buy_Sell_Position__c,Gold_Sheet__c,Team_Member__c,Team_Member__r.Name,Team_Member__r.title,Strategic_Player_Role__c,Strategic_Player__c,Strategic_Player__r.Name,Strategic_Player__r.FirstName,Strategic_Player__r.LastName,Strategic_Player__r.title FROM Strategic_Player__c WHERE Gold_Sheet__c =:goldsheetId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listStrategicPlayers = DataFactory.read(query, paramters);
            for (Strategic_Player__c player : listStrategicPlayers) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = player.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                StrategicPlayerWrapper wrapper = new StrategicPlayerWrapper(player, isUpdatable, false);
                //wrapper.rfsMarkerWrapper = rfsWrapperList;
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                wrapperToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            throw new StrategicPlayerException('Error occured while getting data from Strategic Players');
        }
        return wrapperToReturn.isEmpty() ? null : wrapperToReturn;
    }

    //Method to read FoP Trend records
    @AuraEnabled
    public static List<FieldOfPlayTrendWrapperClass> getTrendsRecordsForPDF(String goldSheetId) {
        Boolean isUpdatable = false;
        List<Field_of_Play_Trend__c> fopTrendsList = new List<Field_of_Play_Trend__c>();
        List<FieldOfPlayTrendWrapperClass> fieldOfPlayTrendsWrapperList = new List<FieldOfPlayTrendWrapperClass>();
        if (Schema.sObjectType.Account.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            //formation of query
            String trendsQuery = 'Select Id, Name, Trend__c, Trend_Description__c, Gold_Sheet__c FROM Field_of_Play_Trend__c WHERE Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            //get data from Field Of Play Trends section
            fopTrendsList = DataFactory.read(trendsQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Field_of_Play_Trend__c trend : fopTrendsList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = trend.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                FieldOfPlayTrendWrapperClass wrapper = new FieldOfPlayTrendWrapperClass(trend, isUpdatable);
                //wrapper.rfsMarkerWrapper = rfsWrapperList;
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                fieldOfPlayTrendsWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            throw new FieldOfPlayTrendsException('Error occured while getting data from Field Of Play Trends');
        }
        //return list of wrapper containing all Field Of Play Trends data
        return fieldOfPlayTrendsWrapperList.isEmpty() ? null : fieldOfPlayTrendsWrapperList;
    }

    @AuraEnabled
    public static List<StrategicStrengthWrapper> getStrategicStrengthRecordsForPDF(String goldSheetId) {
        Boolean isUpdatable = false;
        List<FOP_Strategic_Strength__c> fopStrategicStrengthList = new List<FOP_Strategic_Strength__c>();
        List<StrategicStrengthWrapper> fieldOfPlayWrapperList = new List<StrategicStrengthWrapper>();
        if (Schema.sObjectType.account.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            //formation of query
            String strategicStrengthQuery = 'Select Id, Name, Strength__c, Strength_Description__c, Gold_Sheet__c FROM FOP_Strategic_Strength__c WHERE Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            //get data from Field Of Play StrategicStrengths section
            fopStrategicStrengthList = DataFactory.read(strategicStrengthQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (FOP_Strategic_Strength__c strategicStrength : fopStrategicStrengthList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = strategicStrength.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                StrategicStrengthWrapper wrapper = new StrategicStrengthWrapper(strategicStrength, isUpdatable);
                //wrapper.rfsMarkerWrapper = rfsWrapperList;
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                fieldOfPlayWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            throw new FOPStrategicStrengthException(
                'Error occured while getting data from Field Of Play StrategicStrengths'
            );
        }
        //return list of wrapper containing all Field Of Play StrategicStrengths data
        return fieldOfPlayWrapperList.isEmpty() ? null : fieldOfPlayWrapperList;
    }

    @AuraEnabled
    public static List<FieldOfPlayOppController.PlayOppWrapper> getFopOpportunitiesForPDF(String goldSheetId) {
        List<Field_of_Play_Opportunity__c> fopoRecData = new List<Field_of_Play_Opportunity__c>();
        List<FieldOfPlayOppController.PlayOppWrapper> wrapDatatoReturn = new List<FieldOfPlayOppController.PlayOppWrapper>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Account.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            string fopoQuery = 'select id,Opportunity_Title__c, KPI__c,FOP_Owner__c,FOP_Owner__r.Name,FOP_Opportunity_Desc__c from Field_of_Play_Opportunity__c where Gold_Sheet__c=: goldSheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            fopoRecData = DataFactory.read(fopoQuery, paramters);
            for (Field_of_Play_Opportunity__c rec : fopoRecData) {
                FieldOfPlayOppController.PlayOppWrapper wrap = new FieldOfPlayOppController.PlayOppWrapper(
                    rec,
                    isUpdatable
                );
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = rec.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                //wrap.rfsMarkerWrapper = rfsWrapperList;
                wrap.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                wrapDatatoReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new FOPOException('Error occured while getting data from FOPO' + e);
        }
        return wrapDatatoReturn.isEmpty() ? null : wrapDatatoReturn;
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

    private class CriticalVulnerabilityException extends Exception {
    }

    private class StrategicPlayerException extends Exception {
    }

    private class FieldOfPlayTrendsException extends Exception {
    }

    private class FOPStrategicStrengthException extends Exception {
    }

    private class FOPOException extends Exception {
    }
}