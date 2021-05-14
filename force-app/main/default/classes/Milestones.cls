//Apex class for logic on Milestones
public with sharing class Milestones {
    //Method to get access of Milestone oject
    @AuraEnabled
    public static Map<String, Boolean> getMilestonesAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Milestone__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    //Method to upsert Milestone record
    @AuraEnabled
    public static void upsertMilestone(String jsonString) {
        MilestoneWrapper msWrapper = (MilestoneWrapper) JSON.deserialize(jsonString, MilestoneWrapper.class);
        List<Database.UpsertResult> srList;
        Set<String> playerIdList = msWrapper.msPlayer;
        List<Milestone_Strategic_Player_Map__c> playerMilestoneMap = new List<Milestone_Strategic_Player_Map__c>();
        List<Milestone_Strategic_Player_Map__c> existingPlayers = new List<Milestone_Strategic_Player_Map__c>();
        List<String> existingPlayersId = new List<String>();

        String goldSheetId = msWrapper.goldSheet;
        List<Milestone__c> milestonesList = new List<Milestone__c>();
        if (goldSheetId != null) {
            Milestone__c stone = new Milestone__c();
            if (msWrapper.id != '') {
                stone.Id = msWrapper.id;

                String mileId = msWrapper.id;
                String milestonesPlayersQuery;
                milestonesPlayersQuery = 'Select Id, Name, Milestone_ID__c, Strategic_Player_ID__c  FROM Milestone_Strategic_Player_Map__c WHERE Milestone_ID__c=:mileId';
                Map<String, Object> params = new Map<String, Object>();
                params.put('mileId', mileId);
                //get data from Milestone Strategic Player Map object
                existingPlayers = DataFactory.read(milestonesPlayersQuery, params);
                for (Milestone_Strategic_Player_Map__c play : existingPlayers) {
                    existingPlayersId.add(play.Strategic_Player_ID__c);
                }
            }
            stone.Gold_Sheet__c = msWrapper.goldSheet;
            stone.Meeting_Date__c = Date.valueOf(msWrapper.msDate);
            stone.Milestone_Number__c = msWrapper.msNumber;

            List<String> milestoneNumbers = new List<String>();
            milestoneNumbers = msWrapper.msNumber.split(' ');
            String milestoneNumberIndex = milestoneNumbers[1];
            stone.Milestone_Number_Index__c = milestoneNumberIndex;

            stone.Meeting_Notes__c = msWrapper.msNotes;
            stone.Notes_Completed__c = (msWrapper.msNotes != '') ? System.Label.yes : System.Label.no;
            milestonesList.add(stone);

            srList = DataFactory.upsurt(milestonesList);
        }

        if (srList[0].isSuccess() && playerIdList != null && !playerIdList.isEmpty()) {
            // if (playerIdList != null && !playerIdList.isEmpty()) {
            for (String player : playerIdList) {
                if (!existingPlayersId.contains(player)) {
                    Milestone_Strategic_Player_Map__c milestonePlayer = new Milestone_Strategic_Player_Map__c();
                    milestonePlayer.Milestone_ID__c = srList[0].getId();
                    milestonePlayer.Strategic_Player_ID__c = player;
                    milestonePlayer.Gold_Sheet__c = goldSheetId;
                    playerMilestoneMap.add(milestonePlayer);
                }
            }
            // }
        }
        DataFactory.upsurt(playerMilestoneMap);
    }

    //Method to read Milestone records
    @AuraEnabled
    public static Map<String, List<MilestoneWrapper>> getMilestoneRecords(String goldSheetId) {
        List<Milestone__c> milestonesList = new List<Milestone__c>();
        List<Milestone_Strategic_Player_Map__c> milestonePlayerMapList = new List<Milestone_Strategic_Player_Map__c>();
        List<Strategic_Player__c> playersData = new List<Strategic_Player__c>();
        Map<String, MilestoneWrapper.PlayerWrapper> playersWrapperDataMap = new Map<String, MilestoneWrapper.PlayerWrapper>();

        List<MilestoneWrapper> milestone1WrapperList = new List<MilestoneWrapper>();
        List<MilestoneWrapper> milestone2WrapperList = new List<MilestoneWrapper>();
        List<MilestoneWrapper> milestone3WrapperList = new List<MilestoneWrapper>();
        List<MilestoneWrapper> milestone4WrapperList = new List<MilestoneWrapper>();
        List<MilestoneWrapper> milestone5WrapperList = new List<MilestoneWrapper>();
        Map<String, List<MilestoneWrapper>> milestonesWrapperMap = new Map<String, List<MilestoneWrapper>>();

        try {
            String milestonesQuery;

            milestonesQuery = 'Select Id, Name,Milestone_Number_Index__c, Milestone_Number__c, Meeting_Notes__c, Meeting_Date__c, Gold_Sheet__c FROM Milestone__c WHERE Gold_Sheet__c=:goldSheetId ORDER BY Meeting_Date__c ASC';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);

            //get data from Milestone object
            milestonesList = DataFactory.read(milestonesQuery, paramters);

            String milestonesPlayersQuery;

            milestonesPlayersQuery = 'Select Id, Name, Milestone_ID__c, Strategic_Player_ID__c  FROM Milestone_Strategic_Player_Map__c WHERE Gold_Sheet__c=:goldSheetId';

            Map<String, Object> params = new Map<String, Object>();
            params.put('goldSheetId', goldSheetId);

            //get data from Milestone Strategic Player Map object
            milestonePlayerMapList = DataFactory.read(milestonesPlayersQuery, params);

            Map<String, Set<String>> milestonePlayerIDMap = new Map<String, Set<String>>();
            Set<String> playersIDSet = new Set<String>();
            if (milestonePlayerMapList != null && !milestonePlayerMapList.isEmpty()) {
                for (Milestone_Strategic_Player_Map__c msp : milestonePlayerMapList) {
                    Set<String> playersIDs = new Set<String>();
                    for (Milestone_Strategic_Player_Map__c obj : milestonePlayerMapList) {
                        if (msp.Milestone_ID__c == obj.Milestone_ID__c) {
                            playersIDs.add(obj.Strategic_Player_ID__c);
                        }
                    }
                    milestonePlayerIDMap.put(msp.Milestone_ID__c, playersIDs);
                    playersIDSet.add(msp.Strategic_Player_ID__c);
                }
            }

            String playersQuery;

            playersQuery = 'Select Id, Name, Strategic_Player_Role__c, Strategic_Player__c, Strategic_Player__r.Name, Strategic_Player__r.FirstName, Strategic_Player__r.LastName,Strategic_Player__r.title FROM Strategic_Player__c WHERE Id=:playersIDSet';

            Map<String, Object> param = new Map<String, Object>();
            param.put('playersIDSet', playersIDSet);

            //get data from Strategic Player object
            playersData = DataFactory.read(playersQuery, param);

            for (Strategic_Player__c sp : playersData) {
                MilestoneWrapper.PlayerWrapper spWrapper = new MilestoneWrapper.PlayerWrapper(sp);
                playersWrapperDataMap.put(sp.Id, spWrapper);
            }

            //iterate through list to get list of wrapper to return to UI
            for (Milestone__c milestone : milestonesList) {
                MilestoneWrapper wrapper = new MilestoneWrapper(milestone);
                String milestoneNumber = wrapper.msNumber;
                switch on milestoneNumber {
                    when 'Milestone 1' {
                        milestone1WrapperList.add(wrapper);
                    }
                    when 'Milestone 2' {
                        milestone2WrapperList.add(wrapper);
                    }
                    when 'Milestone 3' {
                        milestone3WrapperList.add(wrapper);
                    }
                    when 'Milestone 4' {
                        milestone4WrapperList.add(wrapper);
                    }
                    when else {
                        List<MilestoneWrapper.PlayerWrapper> playerWrapperList = new List<MilestoneWrapper.PlayerWrapper>();
                        if (milestonePlayerIDMap != null && !milestonePlayerIDMap.isEmpty()) {
                            Set<String> playerSet = new Set<String>();
                            playerSet = milestonePlayerIDMap.get(milestone.Id);
                            if (playerSet != null && !playerSet.isEmpty()) {
                                wrapper.msPlayer = milestonePlayerIDMap.get(milestone.Id);
                                for (String sp : wrapper.msPlayer) {
                                    playerWrapperList.add(playersWrapperDataMap.get(sp));
                                }
                                wrapper.playerWrapperList = playerWrapperList;
                            }
                        }
                        milestone5WrapperList.add(wrapper);
                    }
                }
            }
            milestonesWrapperMap.put('Milestone1', milestone1WrapperList);
            milestonesWrapperMap.put('Milestone2', milestone2WrapperList);
            milestonesWrapperMap.put('Milestone3', milestone3WrapperList);
            milestonesWrapperMap.put('Milestone4', milestone4WrapperList);
            milestonesWrapperMap.put('Milestone5', milestone5WrapperList);
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new MilestonesException('Error occured while getting data from Milestone');
        }
        //return list of wrapper containing all Milestone data
        return milestonesWrapperMap;
    }

    // Method to Delete Milestone Record
    @AuraEnabled
    public static void deleteMilestone(String recordId) {
        ApexCommonUtil.deleteRecord(recordId, 'Milestone__c');
    }

    @AuraEnabled
    public static void removePlayer(List<String> deletePlayerId, String milestoneId) {
        List<Milestone_Strategic_Player_Map__c> milestonePlayerMapList = new List<Milestone_Strategic_Player_Map__c>();
        String milestonesPlayersQuery;

        milestonesPlayersQuery = 'Select Id, Name, Milestone_ID__c, Strategic_Player_ID__c  FROM Milestone_Strategic_Player_Map__c WHERE Milestone_ID__c=:milestoneId AND Strategic_Player_ID__c=:deletePlayerId';

        Map<String, Object> params = new Map<String, Object>();
        params.put('milestoneId', milestoneId);
        params.put('deletePlayerId', deletePlayerId);

        //get data from Milestone Strategic Player Map object
        milestonePlayerMapList = DataFactory.read(milestonesPlayersQuery, params);

        DataFactory.remove(milestonePlayerMapList);
    }

    public class WrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    @AuraEnabled
    public static WrapperLookupObject getStrategicPlayerName() {
        WrapperLookupObject wrapper = new WrapperLookupObject();
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace('Milestone__c');
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace('Strategic_Player__c');
        return wrapper;
    }

    private class MilestonesException extends Exception {
    }
}