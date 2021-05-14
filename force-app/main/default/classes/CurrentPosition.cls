/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Apex controller class for fetching, saving and update of Current Position records.
*
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Rakesh Singh   
* @modifiedBy     Rakesh Singh 
* @maintainedBy   Rakesh Singh    
* @version        1.0
* @created        2020-04-22
* @modified       YYYY-MM-DD
* //@systemLayer    Invocation | Service | UtilityMethods | Selector | Domain | Test
//@systemLayer    LWC- buyingInfluence.js
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            Rakesh Singh 
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
*
* vX.X            Rakesh Singh 
* YYYY-MM-DD      Each change to this file should be documented by incrementing the version number,
*                 and adding a new entry to this @changes list. Note that there is a single blank
*                 line between each @changes entry.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class CurrentPosition {
    // get CP state
    @AuraEnabled
    public static string getCurrentPostion(string oppId) {
        string currentState = '';

        try {
            List<Current_Position__c> currentPositions = new List<Current_Position__c>();
            String cpQuery = 'Select Current_Position__c, Blue_Sheet__c from Current_Position__c where Blue_Sheet__r.Opportunity__c=:oppId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            currentPositions = DataFactory.read(cpQuery, paramters);

            if (!currentPositions.isEmpty()) {
                for (Current_Position__c cps : currentPositions) {
                    CurrentPositionWrapper wrapper = new CurrentPositionWrapper(cps);
                    currentState = cps.Current_Position__c;
                }
            }
        } catch (Exception exp) {
            system.debug('Error :' + exp);
        }

        return currentState;
    }
    // save CP state
    @AuraEnabled
    public static void saveCurrentPosition(String jsonString, String oppId) {
        try {
            List<Current_Position__c> currentPositions = new List<Current_Position__c>();
            String cpQuery = 'Select Current_Position__c, Blue_Sheet__c from Current_Position__c where Blue_Sheet__r.Opportunity__c=:oppId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            currentPositions = DataFactory.read(cpQuery, paramters);
            CurrentPositionWrapper cpWrapper = (CurrentPositionWrapper) JSON.deserialize(
                jsonString,
                CurrentPositionWrapper.class
            );

            if (!currentPositions.isEmpty()) {
                Current_Position__c cPosition = CurrentPositionWrapper.convertWrapperToObject(cpWrapper);
                cPosition.id = currentPositions[0].id;
                DataFactory.modify(cPosition);
            } else {
                // CP doesn't exists, create CP
                List<Blue_Sheet__c> blueSheetLst = new List<Blue_Sheet__c>();
                String bsQuery = 'Select id from Blue_Sheet__c where Opportunity__c =:oppId';
                Map<String, Object> params = new Map<String, Object>();
                params.put('oppId', oppId);
                blueSheetLst = DataFactory.read(bsQuery, params);
                if (blueSheetLst != null) {
                    String bsId = blueSheetLst[0].Id;
                    Current_Position__c cPosition = new Current_Position__c();
                    cPosition.Current_Position__c = cpWrapper.position;
                    cPosition.Blue_Sheet__c = blueSheetLst[0].Id;
                    DataFactory.create(cPosition);
                }
            }
        } catch (Exception exp) {
            system.debug('Error :' + exp);
        }
    }

    @AuraEnabled
    public static String getBlueSheetId(string oppId) {
        String bsID = '';
        List<Blue_Sheet__c> listBS = new List<Blue_Sheet__c>();
        try {
            String bsQuery = 'SELECT Id, Name FROM Blue_Sheet__c where Opportunity__c =: oppId limit 1';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from BI section
            listBS = DataFactory.read(bsQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Blue_Sheet__c bs : listBS) {
                BlueSheetWrapperClass wrapper = new BlueSheetWrapperClass(bs);
                bsID = string.valueof(wrapper.Id);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            //throw new Exception('Error occured while getting data from Blue Sheet');
        }
        return bsID;
    }

    @AuraEnabled
    public static Map<String, Boolean> getCurrentPositionAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        //String objName = 'Current_Position__c';
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Current_Position__c'
            : util.getNamespaceWithUnderScores() + 'Current_Position__c';
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        return accessMap;
    }
}