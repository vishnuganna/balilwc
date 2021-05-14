/*******************************************************************************************
 * @Name         BuySellHierarchyController
 * @Author       Keerthana Mohanasundaram
 * @Date         2020-07-21
 * @Group
 * @Description  KFS-332 - This class contains all methods related to create,get and update Buy SellHierarchy record
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Keerthana Mohanasundaram     2021-08-04          Initial Creation
 *********************************************************************
 */
public with sharing class BuySellHierarchyController {
    @AuraEnabled
    public static Map<String, Boolean> getObjectPermission() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Strategic_Player__c'
            : util.getNamespaceWithUnderScores() + 'Strategic_Player__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
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

                wrapper.rfsMarkerWrapper = rfsWrapperList;
            }
            return wrapper;
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new BuySellHierarchyException('Error occured while getting data from Buy Sell Hierarchy');
        }
    }
    @AuraEnabled
    public static BuySellHierarchyWrapper saveBuySellHierarchyData(
        String inputString,
        Map<String, Map<String, Object>> rfsMap
    ) {
        List<Gold_Sheet__c> goldsheetRec = new List<Gold_Sheet__c>();
        BuySellHierarchyWrapper wrapper = (BuySellHierarchyWrapper) System.JSON.deserialize(
            inputString,
            BuySellHierarchyWrapper.class
        );
        String goldSheetId = wrapper.goldsheetId;
        if (goldsheetId != null) {
            String query =
                'SELECT Id,Name,Custom_Date__c,FOP_Custom__c,FOP_Last_Year__c,FOP_Next_Year__c,FOP_This_Year__c,' +
                'Us_Custom__c,Us_Last_Year__c,Us_Next_Year__c,Us_This_Year__c FROM Gold_Sheet__c  WHERE Id =:goldsheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            goldsheetRec = DataFactory.read(query, paramters);
            if (goldsheetRec != null) {
                goldsheetRec[0].FOP_Custom__c = wrapper.fieldOfPlayCustomYear;
                goldsheetRec[0].FOP_Last_Year__c = wrapper.fieldOfPlayLastYear;
                goldsheetRec[0].FOP_Next_Year__c = wrapper.fieldOfPlayNextYear;
                goldsheetRec[0].FOP_This_Year__c = wrapper.fieldOfPlayThisYear;
                goldsheetRec[0].Us_Custom__c = wrapper.usCustomYear;
                goldsheetRec[0].Us_Last_Year__c = wrapper.usLastYear;
                goldsheetRec[0].Us_Next_Year__c = wrapper.usNextYear;
                goldsheetRec[0].Us_This_Year__c = wrapper.usThisYear;
                goldsheetRec[0].Custom_Date__c = wrapper.buySellhierarchyDate;
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
                List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
                    goldsheetId,
                    objectApiName,
                    rfsMap
                );
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        DataFactory.create(markerList);
                    }
                    List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                    for (Red_Flag_Strength_Marker__c marker : markerList) {
                        marker.Source_ID__c = srList[0].getId();
                        markerListUpdated.add(marker);
                    }
                    DataFactory.modify(markerListUpdated);
                }
            }
            wrapper = getBusinessHierarchyData(goldsheetId);
            return wrapper;
        } else {
            throw new BuySellHierarchyException('Error occured while saving data to Buy Sell Hierarchy');
        }
    }

    @AuraEnabled(cacheable=true)
    public static string getPicklistValues() {
        String objName = 'Gold_Sheet__c';
        String fieldAPIName = 'FOP_Custom__c';
        String pickListvalues = ApexCommonUtil.getPicklistValues(objName, fieldAPIName);
        return pickListvalues;
    }
    private class BuySellHierarchyException extends Exception {
    }
}