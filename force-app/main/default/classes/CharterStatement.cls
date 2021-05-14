/*******************************************************************************************
 * @Name         CharterStatement
 * @Author       Janakiram Bali
 * @Date         2020-08-03
 * @Group
 * @Description  KFS-333 - This class contains all methods related to create,get and update Charter statement record update
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Janakiram Bali     2020-08-03          Initial Creation
 *********************************************************************
 */
public with sharing class CharterStatement {
    /* @Description this method is used to get the Charter Statement data*/
    /* @Return - it retuns data from wrapper*/
    //Method to read charter Statement records
    static String charterStatementApiName = 'charterStatementRfs';

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
                wrapper.rfsMarkerWrapper = rfsWrapperList;
            }
            return wrapper;
        } catch (Exception e) {
            throw new charterStatementException('Error occured while getting data from charterStatement' + e);
        }
    }

    /* @Description this method is used to save the Charter Statement data
     * @Return -  return wrapper to show data */

    @AuraEnabled
    public static CharterStatementWrapper saveCharterStatementData(
        String inputString,
        Map<String, Map<String, Object>> rfsMap
    ) {
        List<Gold_Sheet__c> goldsheetRec = new List<Gold_Sheet__c>();
        CharterStatementWrapper wrapper = new CharterStatementWrapper();
        wrapper = (CharterStatementWrapper) System.JSON.deserialize(inputString, CharterStatementWrapper.class);
        String goldsheetId = wrapper.goldsheetId;
        if (wrapper != null) {
            String query = 'SELECT Id,Name,Charter_Statement__c FROM Gold_Sheet__c WHERE Id =:goldsheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            goldsheetRec = DataFactory.read(query, paramters);
            if (goldsheetRec != null) {
                goldsheetRec[0].Charter_Statement__c = wrapper.charterStatement;
            }
            List<Database.SaveResult> srList = DataFactory.modify(goldsheetRec);
            List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
            rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(goldsheetRec[0].Id);
            String objectApiName = util.getNamespaceWithUnderScores() == ''
                ? 'Gold_Sheet__c'
                : util.getNamespaceWithUnderScores() + 'Gold_Sheet__c';
            if (!rfsWrapperList.isEmpty()) {
                ApexCommonUtil.convertMarkerMap(rfsWrapperList, rfsMap);
                rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    goldsheetId,
                    goldsheetId,
                    rfsMap
                );
            } else {
                List<Red_Flag_Strength_Marker__c> markerLists = RedFlagStrengthData.createRFSrecords(
                    goldsheetId,
                    objectApiName,
                    rfsMap
                );
                //This list srList will have only one record at a time
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        DataFactory.create(markerLists);
                    }
                    List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                    for (Red_Flag_Strength_Marker__c marker : markerLists) {
                        marker.Source_ID__c = srList[0].getId();
                        markerListUpdated.add(marker);
                    }
                    DataFactory.modify(markerListUpdated);
                }
            }
            wrapper = getCharterStatementData(goldsheetId);
            return wrapper;
        } else {
            throw new AuraHandledException('error in updating record');
        }
    }

    /* delete functionality to update the gold sheet record to null values */
    @AuraEnabled
    public static void deleteCharterStatement(String goldsheetId) {
        List<Gold_Sheet__c> goldsheetRec = new List<Gold_Sheet__c>();
        String query = 'SELECT Id,Name,Charter_Statement__c FROM Gold_Sheet__c WHERE Id =:goldsheetId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('goldsheetId', goldsheetId);
        goldsheetRec = DataFactory.read(query, paramters);
        if (goldsheetRec != null) {
            goldsheetRec[0].Charter_Statement__c = '';
        }
        List<Database.SaveResult> srList = DataFactory.modify(goldsheetRec);
        //Delete red flag/Strength marker record from backend
        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(goldsheetRec[0].Id);
        List<Red_Flag_Strength_Marker__c> rfsRecordsUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c rfsRecord : rfsRecords) {
            if (rfsRecord.Field_API_Name__c == charterStatementApiName) {
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
    //Method to get access of Gold Sheet oject
    @AuraEnabled
    public static Map<String, Boolean> getGoldSheetAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Gold_Sheet__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }
    private class charterStatementException extends Exception {
    }
}