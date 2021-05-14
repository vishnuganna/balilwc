public with sharing class SingleSalesObjectiveBlueSheet {
    @AuraEnabled
    public static SingleSalesObjectiveBSWrapper saveSingleSalesObjective(
        String inputString,
        Map<String, Map<String, Object>> rfsMap
    ) {
        List<Blue_Sheet__c> bluesheetRec = new List<Blue_Sheet__c>();
        SingleSalesObjectiveBSWrapper wrapper = new SingleSalesObjectiveBSWrapper();
        wrapper = (SingleSalesObjectiveBSWrapper) System.JSON.deserialize(
            inputString,
            SingleSalesObjectiveBSWrapper.class
        );
        String bluesheetId = wrapper.blueSheetId;
        try {
            String query = 'SELECT Id,Name,Single_Sales_Objective__c FROM Blue_Sheet__c WHERE Id =:bluesheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('bluesheetId', bluesheetId);
            bluesheetRec = DataFactory.read(query, paramters);
            if (!bluesheetRec.isEmpty()) {
                bluesheetRec[0].Single_Sales_Objective__c = wrapper.singleSalesObjectiveBS;
            }
            List<Database.SaveResult> srList = DataFactory.modify(bluesheetRec);
            List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
            rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(bluesheetRec[0].Id);
            String objectApiName = util.getNamespaceWithUnderScores() == ''
                ? 'Blue_Sheet__c'
                : util.getNamespaceWithUnderScores() + 'Blue_Sheet__c';
            if (!rfsWrapperList.isEmpty()) {
                ApexCommonUtil.convertMarkerMap(rfsWrapperList, rfsMap);
                rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    bluesheetId,
                    bluesheetId,
                    rfsMap
                );
            } else {
                List<Red_Flag_Strength_Marker__c> markerLists = RedFlagStrengthData.createRFSrecords(
                    bluesheetId,
                    objectApiName,
                    rfsMap
                );
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
            return getSingleSalesObjective(bluesheetId);
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
            System.debug('exception line----' + ex.getLineNumber());
            throw new SingleSalesObjectiveBlueSheetException('error in updating record');
        }
    }

    @AuraEnabled
    public static SingleSalesObjectiveBSWrapper getSingleSalesObjective(String bluesheetId) {
        List<Blue_Sheet__c> listBlueSheet = new List<Blue_Sheet__c>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Blue_Sheet__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            String query = 'SELECT Id,Name, Single_Sales_Objective__c FROM Blue_Sheet__c WHERE Id =:bluesheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('bluesheetId', bluesheetId);
            listBlueSheet = DataFactory.read(query, paramters);
            SingleSalesObjectiveBSWrapper wrapper;
            if (!listBlueSheet.isEmpty()) {
                wrapper = new SingleSalesObjectiveBSWrapper(listBlueSheet[0], isUpdatable);
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = listBlueSheet[0].Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
            }
            return wrapper;
        } catch (Exception e) {
            System.debug('exception ----' + e);
            System.debug('exception line----' + e.getLineNumber());
            throw new SingleSalesObjectiveBlueSheetException(
                'Error occured while getting data from Single Sales Objective'
            );
        }
    }

    @AuraEnabled
    public static Map<String, Boolean> getSingleSalesObjectiveAccess() {
        try {
            Map<String, Boolean> accessMap = new Map<String, Boolean>();
            String objName = util.getNamespaceWithUnderScores() == ''
                ? 'Blue_Sheet__c'
                : util.getNamespaceWithUnderScores() + 'Blue_Sheet__c';
            Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
            Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
            Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
            accessMap.put('isCreateable', isCreateableObj);
            accessMap.put('isUpdateable', isUpdateableObj);
            accessMap.put('isDeletable', isDeletableObj);
            return accessMap;
        } catch (Exception e) {
            System.debug('exception ----' + e);
            System.debug('exception line----' + e.getLineNumber());
            throw new SingleSalesObjectiveBlueSheetException(
                'Error occured while getting Permission of  Single Sales Objective'
            );
        }
    }

    private class SingleSalesObjectiveBlueSheetException extends Exception {
    }
}