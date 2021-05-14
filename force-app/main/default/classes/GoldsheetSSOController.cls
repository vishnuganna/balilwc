/*******************************************************************************************
 * @Name         GoldsheetSSOController
 * @Author       Monika Deshmukh,Keerthana Mohanasundaram
 * @Date         2020-08-27
 * @Group
 * @Description  KFS-335 - This class contains all methods related to create,get and update Single sales objectives on Gold Sheet object
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer                      Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0            Monika Deshmukh                  2020-08-13          Initial Creation
 ** 2.0            Keerthana Mohanasundaram         2020-08-14          Updates
 *********************************************************************
 */

public with sharing class GoldsheetSSOController {
    @AuraEnabled
    public static List<GoldSheetSSOWrapper> getSearchResult(
        string goldSheetId,
        String searchText,
        Boolean hasAllAccountsChecked
    ) {
        List<GoldSheetSSOWrapper> wrapperToReturn = new List<GoldSheetSSOWrapper>();
        String goldSheetQuery = 'SELECT Id,Account__c from Gold_Sheet__c WHERE Id=:goldSheetId';
        List<Gold_Sheet__c> listGoldSheets = DataFactory.read(
            goldSheetQuery,
            new Map<String, Object>{ 'goldSheetId' => goldSheetId }
        );
        String goldSheetAccountId = listGoldSheets[0].Account__c;
        String query;
        String fieldName = ApexCommonUtil.getCustomSettingsForRevenue();
        if (!hasAllAccountsChecked) {
            query =
                'SELECT Id,Name,AccountId,Account.Name,StageName,CloseDate,' +
                fieldName +
                ' FROM Opportunity Where Name like :searchString AND AccountId=:goldSheetAccountId';
        } else {
            query =
                'SELECT Id,Name,AccountId,Account.Name,StageName,CloseDate,' +
                fieldName +
                ' FROM Opportunity Where Name like :searchString';
        }
        String searchString = '%' + searchText + '%';
        map<String, Object> params = new Map<String, Object>();
        params.put('searchString', searchString);
        params.put('goldSheetAccountId', goldSheetAccountId);
        List<Opportunity> listOpportunities = DataFactory.read(query, params);
        for (Opportunity opp : listOpportunities) {
            GoldSheetSSOWrapper wrapper = new GoldSheetSSOWrapper(opp, fieldName);
            wrapperToReturn.add(wrapper);
        }
        return wrapperToReturn;
    }

    @AuraEnabled
    public static List<GoldSheetSSOWrapper> getSearchResultOnLoad(string goldsheetId) {
        List<GoldSheetSSOWrapper> wrapperToReturn = new List<GoldSheetSSOWrapper>();
        String goldSheetQuery = 'SELECT Id,Account__c from Gold_Sheet__c WHERE Id=:goldSheetId';
        List<Gold_Sheet__c> listGoldSheets = DataFactory.read(
            goldSheetQuery,
            new Map<String, Object>{ 'goldSheetId' => goldSheetId }
        );
        String goldSheetAccountId = listGoldSheets[0].Account__c;
        Configure_Expected_Revenue__c settings = Configure_Expected_Revenue__c.getInstance();
        String fieldName = ApexCommonUtil.getCustomSettingsForRevenue();
        String query =
            'SELECT Id,Name,AccountId,Account.Name,StageName,CloseDate,' +
            fieldName +
            ' FROM Opportunity Where AccountId=:goldSheetAccountId';

        map<String, Object> params = new Map<String, Object>();
        params.put('goldSheetAccountId', goldSheetAccountId);
        List<Opportunity> listOpportunities = DataFactory.read(query, params);
        for (Opportunity opp : listOpportunities) {
            GoldSheetSSOWrapper wrapper = new GoldSheetSSOWrapper(opp, fieldName);
            wrapperToReturn.add(wrapper);
        }
        return wrapperToReturn;
    }

    @AuraEnabled
    public static List<GoldSheetSSOWrapper> getGoldSheetSSOCsvExportData(string goldsheetId) {
        List<Gold_Sheet_Single_Sales_Objective__c> listGoldSheetSSo = new List<Gold_Sheet_Single_Sales_Objective__c>();
        List<GoldSheetSSOWrapper> goldSheetSSoWrapperListToReturn = new List<GoldSheetSSOWrapper>();
        String opptyField = ApexCommonUtil.getCustomSettingsForRevenue();
        String fieldName = 'Opportunity__r.' + opptyField;

        try {
            String query =
                'SELECT Opportunity__r.Name,Opportunity__r.Account.Name,Opportunity__r.StageName,Opportunity__r.CloseDate,' +
                fieldName +
                ' FROM Gold_Sheet_Single_Sales_Objective__c WHERE Gold_Sheet__c =:goldsheetId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listGoldSheetSSo = DataFactory.read(query, paramters);

            if (!listGoldSheetSSo.isEmpty()) {
                for (Gold_Sheet_Single_Sales_Objective__c sso : listGoldSheetSSo) {
                    GoldSheetSSOWrapper wrapper = new GoldSheetSSOWrapper(sso, opptyField);
                    goldSheetSSoWrapperListToReturn.add(wrapper);
                }
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
            System.debug('exception line----' + ex.getLineNumber());
            throw new GoldSheetSSOException('Error occured while getting data from Gold Sheet SSO');
        }
        return goldSheetSSoWrapperListToReturn;
    }

    @AuraEnabled
    public static List<GoldSheetSSOWrapper> getGoldSheetSSOData(String goldsheetId) {
        List<Gold_Sheet_Single_Sales_Objective__c> listGoldSheetSSo = new List<Gold_Sheet_Single_Sales_Objective__c>();
        List<GoldSheetSSOWrapper> goldSheetSSoWrapperListToReturn = new List<GoldSheetSSOWrapper>();
        Boolean isDeletable = false;
        String opptyField = ApexCommonUtil.getCustomSettingsForRevenue();
        String fieldName = 'Opportunity__r.' + opptyField;
        if (Schema.sObjectType.Gold_Sheet_Single_Sales_Objective__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String query =
                'SELECT Id,Name,Opportunity__c,Opportunity__r.Name,Opportunity__r.StageName,Opportunity__r.CloseDate,' +
                'Opportunity__r.Account.Name,Opportunity__r.AccountId,' +
                fieldName +
                ' FROM Gold_Sheet_Single_Sales_Objective__c WHERE Gold_Sheet__c =:goldsheetId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listGoldSheetSSo = DataFactory.read(query, paramters);

            if (!listGoldSheetSSo.isEmpty()) {
                for (Gold_Sheet_Single_Sales_Objective__c sso : listGoldSheetSSo) {
                    GoldSheetSSOWrapper wrapper = new GoldSheetSSOWrapper(sso, isDeletable, opptyField);
                    goldSheetSSoWrapperListToReturn.add(wrapper);
                }
            }
        } catch (Exception ex) {
            System.debug('exception ----' + ex);
            System.debug('exception line----' + ex.getLineNumber());
            throw new GoldSheetSSOException('Error occured while getting data from Gold Sheet SSO');
        }
        return goldSheetSSoWrapperListToReturn;
    }

    @AuraEnabled
    public static void removeGoldSheetSSO(String goldSheetSSOId) {
        try {
            String objName = 'Gold_Sheet_Single_Sales_Objective__c';
            ApexCommonUtil.deleteRecord(goldSheetSSOId, objName);
        } catch (Exception ex) {
            throw new GoldSheetSSOException('Error occured while deleting data from Gold Sheet SSO');
        }
    }
    @AuraEnabled
    public static Map<String, Boolean> getObjectPermission() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Gold_Sheet_Single_Sales_Objective__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    @AuraEnabled
    public static void saveSelectedRecords(String inputList, String goldSheetId) {
        List<Gold_Sheet_Single_Sales_Objective__c> listGoldsheetSSOToInsert = new List<Gold_Sheet_Single_Sales_Objective__c>();
        List<GoldSheetSSOWrapper> listGoldSheetSSOWrapper = (List<GoldSheetSSOWrapper>) system.JSON.deserialize(
            inputList,
            List<GoldSheetSSOWrapper>.class
        );
        List<GoldSheetSSOWrapper> existinggoldSheetSSORecords = getGoldSheetSSOData(goldSheetId);
        List<String> exitsingOpptyIds = new List<String>();
        for (GoldSheetSSOWrapper gSSOExistingWrapper : existinggoldSheetSSORecords) {
            exitsingOpptyIds.add(gSSOExistingWrapper.oppId);
        }
        for (GoldSheetSSOWrapper gSSOWrapper : listGoldSheetSSOWrapper) {
            if (!exitsingOpptyIds.contains(gSSOWrapper.oppId)) {
                Gold_Sheet_Single_Sales_Objective__c goldSheetSSO = new Gold_Sheet_Single_Sales_Objective__c();
                goldSheetSSO.Opportunity__c = gSSOWrapper.oppId;
                goldSheetSSO.Gold_Sheet__c = goldSheetId;
                listGoldsheetSSOToInsert.add(goldSheetSSO);
            }
        }

        if (!listGoldsheetSSOToInsert.isEmpty()) {
            DataFactory.create(listGoldsheetSSOToInsert);
        }
    }
    private class GoldSheetSSOException extends Exception {
    }
}