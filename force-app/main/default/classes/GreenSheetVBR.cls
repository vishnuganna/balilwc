//Apex class for VBR
public with sharing class GreenSheetVBR {
    //Method to fetch greensheet details
    @AuraEnabled
    public static List<GreenSheetWrapper> getGreenSheetVBR(String greenSheetId) {
        List<Green_Sheet__c> greenSheetList = new List<Green_Sheet__c>();
        List<GreenSheetWrapper> greenSheetWrapperList = new List<GreenSheetWrapper>();

        try {
            String greenSheetQuery = 'SELECT Id,Name,Credibility__c,Reason__c,To_Increase_Credibility__c FROM Green_Sheet__c WHERE Id =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            greenSheetList = DataFactory.read(greenSheetQuery, gsParams);

            Boolean isUpdatable = false;
            if (Schema.sObjectType.Green_Sheet__c.isUpdateable()) {
                isUpdatable = true;
            }

            if (greenSheetList != null && !greenSheetList.isEmpty()) {
                for (Green_Sheet__c gs : greenSheetList) {
                    GreenSheetWrapper gsWrap = new GreenSheetWrapper(gs);
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                    String sourceId = gs.Id;
                    rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                    gsWrap.rfsMarkerWrapper = rfsWrapperList;
                    greenSheetWrapperList.add(gsWrap);
                }
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
            System.debug('exception line----' + ex.getLineNumber());
            throw new GreenSheetVBRException('Error occured while getting data from Green Sheet');
        }
        return greenSheetWrapperList;
    }

    //Method to upsert green sheet VBR record
    @AuraEnabled
    public static void upsertVBR(String jsonString, Map<String, Map<String, Object>> rfsMap) {
        GreenSheetWrapper greenWrapper = (GreenSheetWrapper) JSON.deserialize(jsonString, GreenSheetWrapper.class);
        List<Database.UpsertResult> srList;
        String greenSheetId = greenWrapper.id;
        List<Green_Sheet__c> greenSheetList = new List<Green_Sheet__c>();

        if (greenSheetId != null) {
            Green_Sheet__c greensheet = new Green_Sheet__c();
            greensheet.Id = greenWrapper.id;
            greensheet.Reason__c = greenWrapper.reason;
            greensheet.Credibility__c = greenWrapper.credibility;
            greensheet.To_Increase_Credibility__c = greenWrapper.toIncreaseCredibility;
            greensheet.Last_Updated__c = (DateTime) System.now();
            greenSheetList.add(greensheet);

            srList = DataFactory.upsurt(greenSheetList);
        }

        if (srList[0].isSuccess()) {
            List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
            // Operation was successful, so get the ID of the record that was processed
            // resultMap.put('recordId', srList[0].getId());
            String sourceId = srList[0].getId();
            rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);

            String objectName = util.getNamespaceWithUnderScores() == ''
                ? 'Green_Sheet__c'
                : util.getNamespaceWithUnderScores() + 'Green_Sheet__c';

            if (rfsWrapperList != null && !rfsWrapperList.isEmpty()) {
                ApexCommonUtil.convertMarkerMap(rfsWrapperList, rfsMap);
                rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectName,
                    greenSheetId,
                    greenSheetId,
                    rfsMap
                );
            } else {
                List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
                    greenSheetId,
                    objectName,
                    rfsMap
                );
                DataFactory.create(markerList);

                List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                for (Red_Flag_Strength_Marker__c marker : markerList) {
                    marker.Source_ID__c = srList[0].getId();
                    markerListUpdated.add(marker);
                }
                DataFactory.modify(markerListUpdated);
            }
        }
    }

    // Method to Delete VBR Record
    @AuraEnabled
    public static void deleteVBR(String greenSheetId) {
        List<Green_Sheet__c> greenSheet = new List<Green_Sheet__c>();
        String query = 'SELECT Id,Name,Credibility__c,Reason__c,To_Increase_Credibility__c FROM Green_Sheet__c WHERE Id =:greenSheetId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('greenSheetId', greenSheetId);
        greenSheet = DataFactory.read(query, paramters);
        if (greenSheet != null) {
            greenSheet[0].Credibility__c = '';
            greenSheet[0].Reason__c = '';
            greenSheet[0].To_Increase_Credibility__c = '';
            greensheet[0].Last_Updated__c = (DateTime) System.now();
        }
        List<Database.SaveResult> srList = DataFactory.modify(greenSheet);

        //Delete red flag/Strength marker record from backend
        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(greenSheet[0].Id);
        List<Red_Flag_Strength_Marker__c> rfsRecordsUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c rfsRecord : rfsRecords) {
            if (rfsRecord.Field_API_Name__c == 'ReasonVBR' || rfsRecord.Field_API_Name__c == 'CredibilityVBR') {
                rfsRecordsUpdated.add(rfsRecord);
            }
        }
        //This list srList will have only one record at a time
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                DataFactory.remove(rfsRecordsUpdated);
            }
        }
    }

    //Method to get access of Green Sheet object
    @AuraEnabled
    public static Map<String, Boolean> getGreenSheetAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Green_Sheet__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    private class GreenSheetVBRException extends Exception {
    }
}