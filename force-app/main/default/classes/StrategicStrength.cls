public with sharing class StrategicStrength {
    //Method to create FoP Strategic Strength record
    @AuraEnabled
    public static void createFoPSSRec(
        Map<String, String> foPSS,
        String accId,
        Map<String, Map<String, Boolean>> rfsMap
    ) {
        List<Database.SaveResult> srList;
        String goldsheetQuery = 'SELECT Id FROM Gold_Sheet__c WHERE Id=:accId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('accId', accId);
        List<Gold_Sheet__c> goldsheet = DataFactory.read(goldsheetQuery, paramters);
        List<FOP_Strategic_Strength__c> foPSSList = new List<FOP_Strategic_Strength__c>();
        if (!goldsheet.isEmpty()) {
            FOP_Strategic_Strength__c ssfop = new FOP_Strategic_Strength__c();
            ssfop.Gold_Sheet__c = goldsheet[0].id;
            ssfop.Strength__c = foPSS.get('StrategicStrengthTitle');
            ssfop.Strength_Description__c = foPSS.get('ssDescription');
            //DataFactory.create(ssfop);
            foPSSList.add(ssfop);
            srList = DataFactory.create(foPSSList);
            String parentId = goldsheet[0].Id;
            String objectApiName = util.getNamespaceWithUnderScores() == ''
                ? 'FOP_Strategic_Strength__c'
                : util.getNamespaceWithUnderScores() + 'FOP_Strategic_Strength__c';
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

    //Method to fetch data from FieldOfPlayStrategicStrengths table and show it on UI under FieldOfPlayStrategicStrengths section of gold sheet
    @AuraEnabled
    public static FOPStrategicstrengthInfo getStrategicStrengthList(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new FOPStrategicstrengthInfo(
            countStrategicStrengthRecords(goldSheetId),
            getStrategicStrengthRecords(goldSheetId, queryLimit, queryOffset)
        );
    }
    public class FOPStrategicstrengthInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<StrategicStrengthWrapper> fopStrategicStrengthRecords { get; set; }

        public FOPStrategicstrengthInfo(
            Integer totalRecordCount,
            List<StrategicStrengthWrapper> fopStrategicStrengthRecords
        ) {
            this.totalRecordCount = totalRecordCount;
            this.fopStrategicStrengthRecords = fopStrategicStrengthRecords;
        }
    }

    //Method to count FoP Strategic Strength records
    @AuraEnabled
    public static Integer countStrategicStrengthRecords(String goldSheetId) {
        Integer strategicStrengthCount = 0;
        try {
            //formation of query
            String ssQuery = 'SELECT count() FROM FOP_Strategic_Strength__c WHERE Gold_Sheet__c=:goldSheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            strategicStrengthCount = DataFactory.countQuery(ssQuery, paramters);
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FOPStrategicStrengthException('Error occured while getting data from StrategicStrengths');
        }
        //return list of wrapper containing all Field Of Play Strategic Strengths data
        return strategicStrengthCount;
    }

    @AuraEnabled
    public static List<StrategicStrengthWrapper> getStrategicStrengthRecords(
        String goldSheetId,
        Integer queryLimit,
        Integer queryOffset
    ) {
        Boolean isUpdatable = false;
        List<FOP_Strategic_Strength__c> fopStrategicStrengthList = new List<FOP_Strategic_Strength__c>();
        List<StrategicStrengthWrapper> fieldOfPlayWrapperList = new List<StrategicStrengthWrapper>();
        if (Schema.sObjectType.account.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            //formation of query
            String strategicStrengthQuery = 'Select Id, Name, Strength__c, Strength_Description__c, Gold_Sheet__c FROM FOP_Strategic_Strength__c WHERE Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            //get data from Field Of Play StrategicStrengths section
            fopStrategicStrengthList = DataFactory.read(strategicStrengthQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (FOP_Strategic_Strength__c strategicStrength : fopStrategicStrengthList) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = strategicStrength.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                StrategicStrengthWrapper wrapper = new StrategicStrengthWrapper(strategicStrength, isUpdatable);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                fieldOfPlayWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new FOPStrategicStrengthException(
                'Error occured while getting data from Field Of Play StrategicStrengths'
            );
        }
        //return list of wrapper containing all Field Of Play StrategicStrengths data
        return fieldOfPlayWrapperList;
    }

    private class FOPStrategicStrengthException extends Exception {
    }

    @AuraEnabled
    public static Map<String, String> updateFoPStrategicStrengthRecord(
        Map<String, String> fopSS,
        Map<String, Map<String, Object>> rfsData,
        String goldSheetId
    ) {
        String objectName = util.getNamespaceWithUnderScores() == ''
            ? 'FOP_Strategic_Strength__c'
            : util.getNamespaceWithUnderScores() + 'FOP_Strategic_Strength__c';

        String strategicStrengthId = fopSS.get('recId');
        String query = 'select Id,Strength__c,Strength_Description__c from FOP_Strategic_Strength__c where id=:strategicStrengthId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('strategicStrengthId', strategicStrengthId);
        List<FOP_Strategic_Strength__c> strategicStrengthData = DataFactory.read(query, paramters);
        List<Database.SaveResult> srList;
        Map<String, String> resultMap = new Map<String, String>();
        try {
            if (!strategicStrengthData.isEmpty()) {
                FOP_Strategic_Strength__c strategicStrengthObj = new FOP_Strategic_Strength__c();
                strategicStrengthObj.Id = fopSS.get('recId');
                strategicStrengthObj.Strength__c = fopSS.get('StrategicStrengthTitle');
                strategicStrengthObj.Strength_Description__c = fopSS.get('ssDescription');
                srList = DataFactory.modify(strategicStrengthObj);
                //srList will always have 1 record as update is being done from UI
                if (srList[0].isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    resultMap.put('recordId', srList[0].getId());
                    String sourceId = srList[0].getId();
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectName,
                        strategicStrengthId,
                        goldSheetId,
                        rfsData
                    );
                }

                resultMap.put('status', System.Label.success_header);
                resultMap.put('msg', System.Label.success_header);
            }
        } catch (Exception ex) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', ex.getMessage());
            system.System.debug('exception ----' + ex);
        }
        return resultMap;
    }

    @AuraEnabled
    public static Map<String, Boolean> getFoPSSAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'FOP_Strategic_Strength__c'
            : util.getNamespaceWithUnderScores() + 'FOP_Strategic_Strength__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    @AuraEnabled
    public static void deleteFoPSSRecord(String recordId) {
        String query = 'SELECT Id from FOP_Strategic_Strength__c WHERE Id=:recordId';
        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<FOP_Strategic_Strength__c> foPSSRecord = DataFactory.read(query, params);
        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(recordId);
        try {
            List<Database.DeleteResult> delResultList = DataFactory.remove(foPSSRecord);
            //delResultList will always have 1 record as delete is being done from UI
            if (delResultList[0].isSuccess()) {
                DataFactory.remove(rfsRecords);
            }
        } catch (Exception exp) {
            system.System.debug('exception ----' + exp.getMessage());
        }
    }
}