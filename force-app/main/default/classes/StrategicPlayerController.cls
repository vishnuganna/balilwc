/*******************************************************************************************
 * @Name         StrategicPlayerController
 * @Author       Keerthana Mohanasundaram
 * @Date         2020-07-21
 * @Group
 * @Description  KFS-337 - This class contains all methods related to create,get and update Strategic Player record
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Keerthana Mohanasundaram     2021-07-20          Initial Creation
 *********************************************************************
 */

public with sharing class StrategicPlayerController {
    /* get required objects fro lookup component */
    @AuraEnabled
    public static WrapperLookupObject getLookupObjects() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        String apiName = 'Strategic_Player__c';
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace(apiName);
        apiName = 'Team_Member__c';
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace(apiName);
        return wrapper;
    }

    /*Method to get picklist values for the buy sell poisition*/
    @AuraEnabled(cacheable=true)
    public static string getBuySellPicklistValues() {
        String objName = 'Strategic_Player__c';
        String fieldAPIName = 'Buy_Sell_Position__c';
        String pickListvalues = ApexCommonUtil.getPicklistValues(objName, fieldAPIName);
        return pickListvalues;
    }

    /*Method to get picklist values for the role*/
    @AuraEnabled(cacheable=true)
    public static string getRolePicklistValues() {
        String objName = 'Strategic_Player__c';
        String fieldAPIName = 'Strategic_Player_Role__c';
        String pickListvalues = ApexCommonUtil.getPicklistValues(objName, fieldAPIName);
        return pickListvalues;
    }

    @AuraEnabled
    public static Map<String, Boolean> getObjectPermission() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Strategic_Player__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    @AuraEnabled
    public static List<String> getAccountOwnerTitle(String goldsheetId) {
        try {
            String query = 'SELECT Id,Name,Account__r.Id,Account__r.OwnerId,Account__r.Owner.Title FROM Gold_Sheet__c WHERE Id =:goldsheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            List<Gold_Sheet__c> listGoldSheet = DataFactory.read(query, paramters);
            List<String> accountOwnerTitle = new List<String>();
            String accountOwner = listGoldSheet[0].Account__r.OwnerId;
            accountOwnerTitle.add(accountOwner);
            accountOwnerTitle.add(listGoldSheet[0].Account__r.Id);
            accountOwnerTitle.add(listGoldSheet[0].Account__r.Owner.Title);
            return accountOwnerTitle;
        } catch (Exception ex) {
            throw new StrategicPlayerException('Error occured while getting Owner Details from Account');
        }
    }

    /*Snippet to get List of Strategic Player data records */
    @AuraEnabled
    public static StrategicPlayersInfo getPlayersList(String goldSheetId, Integer queryLimit, Integer queryOffset) {
        return new StrategicPlayersInfo(
            countStrategicPlayerRecords(goldSheetId),
            getStrategicPlayerData(goldSheetId, queryLimit, queryOffset)
        );
    }

    public class StrategicPlayersInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<StrategicPlayerWrapper> strategicPlayersRecords { get; set; }

        public StrategicPlayersInfo(Integer totalRecordCount, List<StrategicPlayerWrapper> strategicPlayersRecords) {
            this.totalRecordCount = totalRecordCount;
            this.strategicPlayersRecords = strategicPlayersRecords;
        }
    }

    //Method to count StrategicPlayer records
    @AuraEnabled
    public static Integer countStrategicPlayerRecords(String goldSheetId) {
        String objName = 'Strategic_Player__c';
        String fieldName = 'Gold_Sheet__c';
        return ApexCommonUtil.countOfObjectRecords(goldSheetId, objName, fieldName);
    }

    /* @Description this method is used to get the Strategic Player data
     * @Return - it retuns data from wrapper*/
    @AuraEnabled
    public static List<StrategicPlayerWrapper> getStrategicPlayerData(
        String goldsheetId,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<StrategicPlayerWrapper> wrapperToReturn = new List<StrategicPlayerWrapper>();
        List<Strategic_Player__c> listStrategicPlayers = new List<Strategic_Player__c>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Strategic_Player__c.isDeletable()) {
            isUpdatable = true;
        }
        try {
            String query =
                'SELECT Id,Name,Buy_Sell_Position__c,Gold_Sheet__c,Team_Member__c,Team_Member__r.Name,Team_Member__r.title,Strategic_Player_Role__c,Strategic_Player__c,' +
                'Strategic_Player__r.Name,Strategic_Player__r.FirstName,Strategic_Player__r.LastName,Strategic_Player__r.title FROM Strategic_Player__c WHERE Gold_Sheet__c =:goldsheetId ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            paramters.put('queryLimit', queryLimit);
            paramters.put('queryOffset', queryOffset);
            listStrategicPlayers = DataFactory.read(query, paramters);
            for (Strategic_Player__c player : listStrategicPlayers) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = player.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                StrategicPlayerWrapper wrapper = new StrategicPlayerWrapper(player, isUpdatable, false);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                wrapperToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            throw new StrategicPlayerException('Error occured while getting data from Strategic Players');
        }
        return wrapperToReturn;
    }
    /* @Description this method is used to save the Strategic Player data
     * @Return -  return wrapper to show data */
    @AuraEnabled
    public static List<StrategicPlayerWrapper> saveStrategicPlayerData(
        String inputString,
        Map<String, Map<String, Boolean>> rfsMap
    ) {
        List<Strategic_Player__c> listStrategicPlayerToInsert = new List<Strategic_Player__c>();
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        StrategicPlayerWrapper wrapper = (StrategicPlayerWrapper) System.JSON.deserialize(
            inputString,
            StrategicPlayerWrapper.class
        );
        String goldSheetId = wrapper.goldsheetId;
        String objectApiName = util.getNamespaceWithUnderScores() == ''
            ? 'Strategic_Player__c'
            : util.getNamespaceWithUnderScores() + 'Strategic_Player__c';
        String query =
            'SELECT Id,Name,Buy_Sell_Position__c,Gold_Sheet__c,Team_Member__c,Team_Member__r.Name,Team_Member__r.title,Strategic_Player_Role__c,Strategic_Player__c,' +
            'Strategic_Player__r.Name,Strategic_Player__r.FirstName,Strategic_Player__r.LastName,Strategic_Player__r.title FROM Strategic_Player__c WHERE Gold_Sheet__c =:goldsheetId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('goldsheetId', goldsheetId);
        List<Strategic_Player__c> existingListStrategicPlayers = DataFactory.read(query, paramters);
        set<Id> contactId = new Set<Id>();
        for (Strategic_Player__c player : existingListStrategicPlayers) {
            contactId.add(player.Strategic_Player__c);
        }
        if (goldsheetId != null && (wrapper.id != null || !contactId.contains(wrapper.strategicPlayer))) {
            Strategic_Player__c player = new Strategic_Player__c();
            if (wrapper.id != null) {
                player.Id = wrapper.id;
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    player.Id,
                    goldSheetId,
                    rfsMap
                );
            } else {
                markerList = RedFlagStrengthData.createRFSrecords(goldsheetId, objectApiName, rfsMap);
            }
            player.Buy_Sell_Position__c = wrapper.buySellPosition;
            player.Gold_Sheet__c = wrapper.goldsheetId;
            player.Team_Member__c = wrapper.ourTeamMember;
            player.Strategic_Player_Role__c = wrapper.role;
            player.Strategic_Player__c = wrapper.strategicPlayer;
            listStrategicPlayerToInsert.add(player);
        } else {
            throw new StrategicPlayerException('You cannot save this Strategic Player again');
        }
        List<Database.UpsertResult> srList = DataFactory.upsurt(listStrategicPlayerToInsert);
        List<StrategicPlayerWrapper> wrapperToReturn = getStrategicPlayerData(
            listStrategicPlayerToInsert[0].Gold_Sheet__c,
            10,
            0
        );
        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess() && !markerList.isEmpty()) {
                DataFactory.create(markerList);
            }
        }
        List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c marker : markerList) {
            marker.Source_ID__c = srList[0].getId();
            markerListUpdated.add(marker);
        }
        DataFactory.modify(markerListUpdated);

        return wrapperToReturn;
    }
    @AuraEnabled
    public static void removeStrategicPlayer(string recordId) {
        try {
            String objName = 'Strategic_Player__c';
            ApexCommonUtil.deleteRecord(recordId, objName);
        } catch (Exception ex) {
            throw new StrategicPlayerException('Error occured while deleting data from Strategic Player');
        }
    }
    private class StrategicPlayerException extends Exception {
    }

    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }
}