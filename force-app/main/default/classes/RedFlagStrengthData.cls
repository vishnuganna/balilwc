public with sharing class RedFlagStrengthData {
    @AuraEnabled
    public static List<Red_Flag_Strength_Marker__c> createRFSrecords(
        String parentId,
        String objectApiName,
        Map<String, Map<String, Object>> rfsMap
    ) {
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        for (String fld : rfsMap.keyset()) {
            if (rfsMap.get(fld).get('noneSelected') == false) {
                Red_Flag_Strength_Marker__c marker = new Red_Flag_Strength_Marker__c();
                marker.Field_API_Name__c = fld;
                marker.Is_Red_Flag_Selected__c = (Boolean) rfsMap.get(fld).get('redFlagSelected');
                marker.Is_Strength_Selected__c = (Boolean) rfsMap.get(fld).get('strengthSelected');
                marker.Parent_Id__c = parentId;
                marker.Object_API_Name__c = objectApiName;
                markerList.add(marker);
            }
        }
        return markerList;
    }

    @AuraEnabled
    public static List<RedFlagStrengthMarkerWrapper> getRFSWrapperList(String sourceId) {
        List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
        String rfsQuery = 'Select Id,Name,Parent_Id__c,Is_Red_Flag_Selected__c,Is_Strength_Selected__c,Field_API_Name__c,Object_API_Name__c,Source_ID__c from Red_Flag_Strength_Marker__c where Source_ID__c=:sourceId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('sourceId', sourceId);
        List<Red_Flag_Strength_Marker__c> rfsRecords = DataFactory.read(rfsQuery, paramters);

        for (Red_Flag_Strength_Marker__c rfs : rfsRecords) {
            RedFlagStrengthMarkerWrapper wrapper = new RedFlagStrengthMarkerWrapper(rfs);
            rfsWrapperList.add(wrapper);
        }
        return rfsWrapperList;
    }

    //Keeping legacy code with opp id to not touch all the existing components
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static List<RedFlagStrengthMarkerWrapper> updateRFSRecords(
        String objectName,
        String recordId,
        String oppId,
        Map<String, Map<String, Object>> rfsData
    ) {
        String bluesheetQuery = 'SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c =:oppId';
        Map<String, Object> params = new Map<String, Object>();
        params.put('oppId', oppId);
        List<Blue_Sheet__c> bluesheet = DataFactory.read(bluesheetQuery, params);
        String parentId = bluesheet[0].id;
        return updateRedFlagStrengthRecords(objectName, recordId, parentId, rfsData);
    }

    //recordId = field Id && parentId = Golsheet Id || Bluesheet Id || etc
    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static List<RedFlagStrengthMarkerWrapper> updateRedFlagStrengthRecords(
        String objectName,
        String recordId,
        String parentId,
        Map<String, Map<String, Object>> rfsData
    ) {
        List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
        String sourceId = recordId;
        String rfsQuery = 'Select Id,Name,Parent_Id__c,Is_Red_Flag_Selected__c,Is_Strength_Selected__c,Field_API_Name__c,Object_API_Name__c,Source_ID__c from Red_Flag_Strength_Marker__c where Source_ID__c=:sourceId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('sourceId', sourceId);
        List<Red_Flag_Strength_Marker__c> rfsRecords = DataFactory.read(rfsQuery, paramters);

        List<String> newFields = new List<String>();
        List<String> currentFields = new List<String>();
        for (Red_Flag_Strength_Marker__c rfs : rfsRecords) {
            currentFields.add(rfs.Field_API_Name__c);
        }
        for (String fld : rfsData.keySet()) {
            if (!currentFields.contains(fld)) {
                newFields.add(fld);
            }
        }

        List<Red_Flag_Strength_Marker__c> rfsUpdateList = new List<Red_Flag_Strength_Marker__c>();
        if (rfsRecords.size() > 0) {
            for (Red_Flag_Strength_Marker__c rfs : rfsRecords) {
                rfs.Is_Red_Flag_Selected__c = (Boolean) rfsData.get(rfs.Field_API_Name__c).get('redFlagSelected');
                rfs.Is_Strength_Selected__c = (Boolean) rfsData.get(rfs.Field_API_Name__c).get('strengthSelected');
                rfsUpdateList.add(rfs);
            }
            DataFactory.modify(rfsUpdateList);
            if (newFields.size() > 0) {
                List<Red_Flag_Strength_Marker__c> newFieldsRfsList = new List<Red_Flag_Strength_Marker__c>();
                for (String fld : newFields) {
                    if (rfsData.get(fld).get('noneSelected') == false) {
                        Red_Flag_Strength_Marker__c marker = createMarker(parentId, objectName, recordId, fld, rfsData);
                        newFieldsRfsList.add(marker);
                    }
                }
                DataFactory.create(newFieldsRfsList);
                rfsUpdateList.addAll(newFieldsRfsList);
            }
            rfsWrapperList = getRFSWrapperList(sourceId);
        } else {
            for (String fld : rfsData.keyset()) {
                if (rfsData.get(fld).get('noneSelected') == false) {
                    Red_Flag_Strength_Marker__c marker = createMarker(parentId, objectName, recordId, fld, rfsData);
                    rfsUpdateList.add(marker);
                }
            }
            DataFactory.create(rfsUpdateList);
            rfsWrapperList = getRFSWrapperList(recordId);
        }
        return rfsWrapperList;
    }

    @AuraEnabled
    public static List<Red_Flag_Strength_Marker__c> getRFSrecords(String recordId) {
        String rfsQuery = 'Select Id,Name,Parent_Id__c,Is_Red_Flag_Selected__c,Is_Strength_Selected__c,Field_API_Name__c,Object_API_Name__c,Source_ID__c from Red_Flag_Strength_Marker__c where Source_ID__c=:recordId';
        Map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<Red_Flag_Strength_Marker__c> rfsRecords = DataFactory.read(rfsQuery, params);
        return rfsRecords;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static Red_Flag_Strength_Marker__c createMarker(
        String parentId,
        String objectName,
        String recordId,
        String fld,
        Map<String, Map<String, Object>> rfsData
    ) {
        Red_Flag_Strength_Marker__c marker = new Red_Flag_Strength_Marker__c();
        marker.Field_API_Name__c = fld;
        marker.Is_Red_Flag_Selected__c = (Boolean) rfsData.get(fld).get('redFlagSelected');
        marker.Is_Strength_Selected__c = (Boolean) rfsData.get(fld).get('strengthSelected');
        marker.Parent_Id__c = parentId;
        marker.Object_API_Name__c = objectName;
        marker.Source_ID__c = recordId;
        return marker;
    }
}