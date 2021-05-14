// In this class, write generic reusable methods
public with sharing class ApexCommonUtil {
    /* method to check access on any object*/
    @AuraEnabled
    public static Map<String, Boolean> getObjectAccess(String objApiName) {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? objApiName
            : util.getNamespaceWithUnderScores() + objApiName;
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        Boolean isViewableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isAccessible();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        accessMap.put('isViewable', isViewableObj);
        return accessMap;
    }

    /*Method to get picklist values for any field*/
    @AuraEnabled(cacheable=true)
    public static string getPicklistValues(String objName, String fieldAPIName) {
        objName = getObjectwithNameSpace(objName);
        fieldAPIName = getObjectwithNameSpace(fieldAPIName);
        map<string, string> options = new Map<string, string>();
        //List<String>

        Schema.SObjectType globalDescribe = Schema.getGlobalDescribe().get(objName);
        Schema.DescribeSObjectResult globalDescribeResult = globalDescribe.getDescribe();
        Map<String, Schema.SObjectField> fields = globalDescribeResult.fields.getMap();
        Schema.DescribeFieldResult describeFieldResult = fields.get(fieldAPIName).getDescribe();
        List<Schema.PicklistEntry> listOfPicklistEntrys = describeFieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : listOfPicklistEntrys) {
            options.put(picklistEntry.getValue(), picklistEntry.getLabel());
        }
        return JSON.serialize(options);
    }

    /* Method to return the count of records
        1. Present in any object
        2. Present in Gold Sheet Child object for a particular Gold Sheet recordId
    */
    public static Integer countOfObjectRecords(String goldSheetId, String objName, String fieldName) {
        Integer recordCount = 0;
        try {
            String query;
            //formation of query
            if (goldSheetId == null) {
                query = 'SELECT count() FROM ' + objName;
            } else {
                query = 'SELECT count() FROM ' + objName + ' WHERE ' + fieldName + '=:goldSheetId';
            }
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            recordCount = DataFactory.countQuery(query, paramters);
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new ApexCommonUtilException('Error occured while getting data from ' + objName);
        }
        return recordCount;
    }

    /* Method to return the object/fieldName with appropriate Namespace */
    public static String getObjectwithNameSpace(String apiName) {
        String reutrnNamespaceAPI = util.getNamespaceWithUnderScores() == ''
            ? apiName
            : util.getNamespaceWithUnderScores() + apiName;
        return reutrnNamespaceAPI;
    }

    /* Method to delete any Record */
    public static void deleteRecord(String recordId, String objName) {
        List<SObject> objList = new List<SObject>();
        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(recordId);
        try {
            //formation of query
            String deletequery = 'SELECT Id FROM ' + objName + ' WHERE Id =:recordId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('recordId', recordId);

            objList = DataFactory.read(deletequery, paramters);
            List<Database.DeleteResult> srList = DataFactory.remove(objList);
            if (srList[0].isSuccess()) {
                DataFactory.remove(rfsRecords);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new ApexCommonUtilException('Error occured while deleting data from ' + objName);
        }
    }

    /* Method to get User Title */
    @AuraEnabled
    public static String getUserTitle(String recordId) {
        String query = 'SELECT Id,Name,Title FROM user WHERE Id =:recordId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('recordId', recordId);
        List<User> userList = DataFactory.read(query, paramters);
        String userTitle = userList[0].title;
        return userTitle;
    }

    //this method will return list of BS records and its child objects like Competition, SSO, BI
    // You need to add child objects and field list here as needed.
    public static Map<String, Blue_Sheet__c> getBSAndChildRecs(Set<String> bsIdSet) {
        Map<String, Blue_Sheet__c> mapBsIdAndRecord = new Map<String, Blue_Sheet__c>();
        if (bsIdSet != null && !bsIdSet.isEmpty()) {
            String soqlBlueSheet = 'Select Id, (Select Id from Buying_Influences__r),(Select Id,BestActionLogic__c from Recommendations__r) from Blue_Sheet__c where Id =: bsIdSet';
            Map<String, Object> soqlParamMap = new Map<String, Object>();
            soqlParamMap.put('bsIdSet', bsIdSet);
            List<Blue_Sheet__c> bsLst = DataFactory.read(soqlBlueSheet, soqlParamMap);
            for (Blue_Sheet__c bsObj : bsLst) {
                mapBsIdAndRecord.put(bsObj.Id, bsObj);
            }
        }
        return mapBsIdAndRecord;
    }

    //this method will convert Set<Id> to Set<String>
    public static Set<String> getSetOfStringType(Set<Id> idSet) {
        Set<String> idSetString = new Set<String>();
        if (idSet != null && !idSet.isEmpty()) {
            for (Id idTmp : idSet) {
                idSetString.add(idTmp);
            }
        }
        return idSetString;
    }

    // this will call underlying modify method after checking if its not empty
    public static void modifyWithEmptyCheck(List<SObject> sObjectLst) {
        if (sObjectLst != null && !sObjectLst.isEmpty()) {
            DataFactory.modify(sObjectLst);
        }
    }

    // check if user is assigned a permission set from a list of permission set
    public static List<PermissionSetAssignment> getPermissionSetLst(Set<String> permissionSetNames, String userId) {
        List<PermissionSetAssignment> permissionSetsLst = new List<PermissionSetAssignment>();
        String soqlPermissionSet = 'SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSet.Name in : permissionSetNames';
        Map<String, Object> permissionSetparameters = new Map<String, Object>();
        permissionSetparameters.put('userId', userId);
        permissionSetparameters.put('permissionSetNames', permissionSetNames);
        permissionSetsLst = DataFactory.read(soqlPermissionSet, permissionSetparameters);
        return permissionSetsLst;
    }

    //method to convert comma separated string to set or list
    public static Object convertStringToSetOrList(String inpStr, String separator, String setOrListType) {
        String[] arr = inpStr.split(separator);
        if (setOrListType == 'set') {
            Set<String> valueSet = new Set<String>();
            valueSet.addAll(arr);
            return valueSet;
        } else if (setOrListType == 'list') {
            List<String> valueLst = new List<String>();
            valueLst.addAll(arr);
            return valueLst;
        }
        return null;
    }

    public static String getCurrencyFields() {
        String fields = '';
        SObjectType objType = Schema.getGlobalDescribe().get('Opportunity');
        Map<String, Schema.SObjectField> mfieldsMap = objType.getDescribe().fields.getMap();
        for (Schema.SObjectField fld : mfieldsMap.values()) {
            DescribeFieldResult fieldDescribe = fld.getDescribe();
            if (fld.getDescribe().getType() == Schema.DisplayType.CURRENCY && fieldDescribe.isAccessible()) {
                fields = fields + ', ' + fld.getDescribe().getName();
            }
        }
        return fields;
    }

    public static Map<Id, Opportunity> getOpportunityRecord(Set<String> opptIdSet) {
        Map<Id, Opportunity> oppInfoMap = new Map<Id, Opportunity>();
        List<Opportunity> oppList = new List<Opportunity>();
        String currencyFields = getCurrencyFields();
        try {
            String oppQuery;
            if (Schema.sObjectType.Opportunity.fields.Probability.isAccessible()) {
                oppQuery =
                    'SELECT Id,Name,Ownerid,Owner.name,Account.Industry,Owner.profileId,Probability,Green_Sheet_Count__c,' +
                    ' StageName,Type,Stage_Last_ModifiedOn__c,CloseDate,Last_Updated__c' +
                    currencyFields +
                    ' FROM Opportunity where Id =: opptIdSet';
            } else {
                oppQuery =
                    'SELECT Id,Name,Ownerid,Owner.name,Account.Industry,Owner.profileId,Green_Sheet_Count__c,' +
                    ' StageName,Type,Stage_Last_ModifiedOn__c,CloseDate,Last_Updated__c' +
                    currencyFields +
                    ' FROM Opportunity where Id =: opptIdSet';
            }

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('opptIdSet', opptIdSet);
            //get data from Opportunity
            oppList = DataFactory.read(oppQuery, paramters);
            if (oppList != null && !oppList.isEmpty()) {
                for (Opportunity opty : oppList) {
                    oppInfoMap.put(opty.id, opty);
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return oppInfoMap;
    }

    public static Map<Id, Opportunity> getOpportunityRecordForUpdate(Set<String> opptIdSet) {
        Map<Id, Opportunity> oppInfoMap = new Map<Id, Opportunity>();
        List<Opportunity> oppList = new List<Opportunity>();
        try {
            String oppQuery =
                'SELECT Id,Name,Ownerid,Owner.name,Owner.profileId,Green_Sheet_Count__c,' +
                ' StageName,Stage_Last_ModifiedOn__c,CloseDate,Last_Updated__c' +
                ' FROM Opportunity where Id =: opptIdSet';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('opptIdSet', opptIdSet);
            //get data from Opportunity
            oppList = DataFactory.read(oppQuery, paramters);
            if (oppList != null && !oppList.isEmpty()) {
                for (Opportunity opty : oppList) {
                    oppInfoMap.put(opty.id, opty);
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return oppInfoMap;
    }

    public static Map<Id, Blue_Sheet__c> getBluesheetRecord(Set<String> opptIdSet) {
        Map<Id, Blue_Sheet__c> bsInfoMap = new Map<Id, Blue_Sheet__c>();
        List<Blue_Sheet__c> bsList = new List<Blue_Sheet__c>();
        try {
            String bsQuery = 'SELECT Id, Name, Opportunity__c FROM Blue_Sheet__c where Opportunity__c =: opptIdSet';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('opptIdSet', opptIdSet);
            //get data from Blue_Sheet__c
            bsList = DataFactory.read(bsQuery, paramters);
            if (bsList != null && !bsList.isEmpty()) {
                for (Blue_Sheet__c bs : bsList) {
                    bsInfoMap.put(bs.Opportunity__c, bs);
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return bsInfoMap;
    }

    public static Map<Id, Blue_Sheet__c> getBlueSheetInfo(Set<String> blueSheetIdSet) {
        Map<Id, Blue_Sheet__c> bsInfoMap = new Map<Id, Blue_Sheet__c>();
        List<Blue_Sheet__c> bsList = new List<Blue_Sheet__c>();
        try {
            String bsQuery = 'Select Id,Name,LastModifiedDate,Count_Actions__c,Opportunity__c FROM Blue_Sheet__c WHERE Id =:blueSheetIdSet';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('blueSheetIdSet', blueSheetIdSet);
            //get data from Blue_Sheet__c
            bsList = DataFactory.read(bsQuery, paramters);
            if (bsList != null && !bsList.isEmpty()) {
                for (Blue_Sheet__c bs : bsList) {
                    bsInfoMap.put(bs.id, bs);
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return bsInfoMap;
    }

    public static void convertMarkerMap(
        List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper,
        Map<String, Map<String, Object>> rfsMap
    ) {
        for (RedFlagStrengthMarkerWrapper marker : rfsMarkerWrapper) {
            if (rfsMap.get(marker.fieldApiName) == null) {
                Map<String, Object> addMarker = new Map<String, Object>();
                addMarker.put('redFlagSelected', (Object) marker.redFlagSelected);
                addMarker.put('strengthSelected', (Object) marker.strengthSelected);
                addMarker.put('noneSelected', (Object) (!marker.redFlagSelected && !marker.strengthSelected));
                addMarker.put('fieldApiName', (Object) marker.fieldApiName);
                rfsMap.put(marker.fieldApiName, addMarker);
            }
        }
    }

    public static void pdfDownload(String oppName) {
        //figure out if we are forcing download or not.
        if (
            System.currentPageReference().getParameters().get('download') != null &&
            System.currentPageReference().getParameters().get('download') == 'true'
        ) {
            //setup a default file name

            // Date dToday = Date.today();
            // String dateStr = dToday.year() + '-' + dToday.month() + '-' + dToday.day();

            string fileName = oppName + '_' + System.now() + '.pdf';
            //here is were the magic happens. We have to set the content disposition as attachment.
            System.currentPageReference().getHeaders().put('content-disposition', 'attachemnt; filename=' + fileName);
        }
    }
    public static Set<String> getSetOfIdFromList(List<SObject> objLst) {
        Set<String> idSet = new Set<String>();
        for (SObject obj : objLst) {
            idSet.add(obj.Id);
        }
        return idSet;
    }
    public static Map<String, Boolean> getObjectAccessByObjectName(String objectName) {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? objectName
            : util.getNamespaceWithUnderScores() + objectName;
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }
    public static String getCustomSettingsForRevenue() {
        String fieldName;
        Configure_Expected_Revenue__c settings = Configure_Expected_Revenue__c.getInstance();
        if (settings.Field_Name__c != null) {
            fieldName = settings.Field_Name__c;
        } else {
            fieldName = 'ExpectedRevenue';
        }
        return fieldName;
    }
    private class ApexCommonUtilException extends Exception {
    }
}