//Apex class for logic on Field of Play Trend
public with sharing class FieldOfPlayTrend {
    //Method to create FoP Trend record
    @AuraEnabled
    public static void createFoPTrendRec(
        Map<String, String> foPTrend,
        String accId,
        Map<String, Map<String, Boolean>> rfsMap
    ) {
        List<Database.SaveResult> srList;
        String goldsheetQuery = 'SELECT Id FROM Gold_Sheet__c WHERE Id=:accId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('accId', accId);
        List<Gold_Sheet__c> goldsheet = DataFactory.read(goldsheetQuery, paramters);
        List<Field_of_Play_Trend__c> fopTrendList = new List<Field_of_Play_Trend__c>();
        if (!goldsheet.isEmpty()) {
            Field_of_Play_Trend__c trendfop = new Field_of_Play_Trend__c();
            trendfop.Gold_Sheet__c = goldsheet[0].id;
            trendfop.Trend__c = foPTrend.get('trendTitle');
            trendfop.Trend_Description__c = foPTrend.get('trendDescription');
            fopTrendList.add(trendfop);
            srList = DataFactory.create(fopTrendList);
            String parentId = goldsheet[0].Id;
            String objectApiName = util.getNamespaceWithUnderScores() == ''
                ? 'Field_of_Play_Trend__c'
                : util.getNamespaceWithUnderScores() + 'Field_of_Play_Trend__c';
            List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
                parentId,
                objectApiName,
                rfsMap
            );
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    DataFactory.create(markerList);
                }
            }
            List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
            for (Red_Flag_Strength_Marker__c marker : markerList) {
                marker.Source_ID__c = srList[0].getId();
                markerListUpdated.add(marker);
            }
            DataFactory.modify(markerListUpdated);
        }
    }

    /*Summary Mode*/

    @AuraEnabled
    public static FieldOfPlayTrendInfo getTrendsList(String goldSheetId, Integer queryLimit, Integer queryOffset) {
        return new FieldOfPlayTrendInfo(
            countTrendsRecords(goldSheetId),
            getTrendsRecords(goldSheetId, queryLimit, queryOffset)
        );
    }

    public class FieldOfPlayTrendInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<FieldOfPlayTrendWrapperClass> fopTrendsRecords { get; set; }

        public FieldOfPlayTrendInfo(Integer totalRecordCount, List<FieldOfPlayTrendWrapperClass> fopTrendsRecords) {
            this.totalRecordCount = totalRecordCount;
            this.fopTrendsRecords = fopTrendsRecords;
        }
    }

    //Method to count FoP Trend records
    @AuraEnabled
    public static Integer countTrendsRecords(String goldSheetId) {
        Integer trendsCount = 0;
        try {
            //formation of query
            String trendsQuery = 'SELECT count() FROM Field_of_Play_Trend__c WHERE Gold_Sheet__c=:goldSheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            trendsCount = DataFactory.countQuery(trendsQuery, paramters);
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FieldOfPlayTrendsException('Error occured while getting data from Field Of Play Trends');
        }
        //return list of wrapper containing all Field Of Play Trends data
        return trendsCount;
    }

    //Method to read FoP Trend records
    @AuraEnabled
    public static List<FieldOfPlayTrendWrapperClass> getTrendsRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset
    ) {
        Boolean isUpdatable = false;
        List<Field_of_Play_Trend__c> fopTrendsList = new List<Field_of_Play_Trend__c>();
        List<FieldOfPlayTrendWrapperClass> fieldOfPlayTrendsWrapperList = new List<FieldOfPlayTrendWrapperClass>();
        if (Schema.sObjectType.Field_of_Play_Trend__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            //formation of query
            String trendsQuery = 'Select Id, Name, Trend__c, Trend_Description__c, Gold_Sheet__c FROM Field_of_Play_Trend__c WHERE Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from Field Of Play Trends section
            fopTrendsList = DataFactory.read(trendsQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Field_of_Play_Trend__c trend : fopTrendsList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = trend.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                FieldOfPlayTrendWrapperClass wrapper = new FieldOfPlayTrendWrapperClass(trend, isUpdatable);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                fieldOfPlayTrendsWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FieldOfPlayTrendsException('Error occured while getting data from Field Of Play Trends');
        }
        //return list of wrapper containing all Field Of Play Trends data
        return fieldOfPlayTrendsWrapperList;
    }

    //Method to delete FoP Trend record
    @AuraEnabled
    public static void deleteFoPTrendRecord(String recordId) {
        String query = 'SELECT Id from Field_of_Play_Trend__c WHERE Id=:recordId';
        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<Field_of_Play_Trend__c> fopTrendRecord = DataFactory.read(query, params);
        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(recordId);
        try {
            List<Database.DeleteResult> delResultList = DataFactory.remove(fopTrendRecord);
            //delResultList will always have 1 record as delete is being done from UI
            if (delResultList[0].isSuccess()) {
                DataFactory.remove(rfsRecords);
            }
        } catch (Exception exp) {
            system.System.debug('exception ----' + exp.getMessage());
        }
    }

    //Method to update FoP Trend record
    @AuraEnabled
    public static Map<String, String> updateFoPTrendRecord(
        Map<String, String> foPTrend,
        Map<String, Map<String, Object>> rfsData,
        String goldSheetId
    ) {
        String objectName = util.getNamespaceWithUnderScores() == ''
            ? 'Field_of_Play_Trend__c'
            : util.getNamespaceWithUnderScores() + 'Field_of_Play_Trend__c';
        String trendId = foPTrend.get('recId');
        String query = 'select Id,Trend__c,Trend_Description__c from Field_of_Play_Trend__c where id=:trendId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('trendId', trendId);
        List<Field_of_Play_Trend__c> trendData = DataFactory.read(query, paramters);
        List<Database.SaveResult> srList;
        Map<String, String> resultMap = new Map<String, String>();
        try {
            if (!trendData.isEmpty()) {
                Field_of_Play_Trend__c trendObj = new Field_of_Play_Trend__c();
                trendObj.Id = foPTrend.get('recId');
                trendObj.Trend__c = foPTrend.get('trendTitle');
                trendObj.Trend_Description__c = foPTrend.get('trendDescription');
                srList = DataFactory.modify(trendObj);
                //srList will always have 1 record as update is being done from UI
                if (srList[0].isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    resultMap.put('recordId', srList[0].getId());
                    String sourceId = srList[0].getId();
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectName,
                        trendId,
                        goldSheetId,
                        rfsData
                    );
                }

                resultMap.put('status', System.Label.success_header);
                resultMap.put('msg', System.Label.success_header);
                system.System.debug('Sucess ----');
            }
        } catch (Exception ex) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', ex.getMessage());
            system.System.debug('exception ----' + ex);
        }
        return resultMap;
    }

    //Method to get access of FoP Trend oject
    @AuraEnabled
    public static Map<String, Boolean> getFoPTrendAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Field_of_Play_Trend__c'
            : util.getNamespaceWithUnderScores() + 'Field_of_Play_Trend__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    private class FieldOfPlayTrendsException extends Exception {
    }
}