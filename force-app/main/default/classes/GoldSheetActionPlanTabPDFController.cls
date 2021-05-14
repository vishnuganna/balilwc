public with sharing class GoldSheetActionPlanTabPDFController {
    public String goldSheetActionPlanPDFData { get; set; }
    public static GoldSheetPDFWrapper goldSheetActionPlanPDFWrapper { get; set; }
    public static String actionStatusInData;
    public static String informationNeeded;
    public static String investmentPrograms;
    public GoldSheetActionPlanTabPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        actionStatusInData = System.currentPageReference().getParameters().get('actionStatus');
        informationNeeded = System.currentPageReference().getParameters().get('informationNeeded');
        investmentPrograms = System.currentPageReference().getParameters().get('investmentPrograms');
        goldSheetActionPlanPDFWrapper = new GoldSheetPDFWrapper();
        if (recordId != null) {
            goldSheetActionPlanPDFWrapper.actionsList = getActionRecords(recordId);
            goldSheetActionPlanPDFWrapper.informationNeededList = getInformationNeededRecords(recordId);
            goldSheetActionPlanPDFWrapper.investmentProgramList = getInvProgramRecords(recordId);
            goldSheetActionPlanPDFWrapper.milestoneWrapperList = getMilestoneRecords(recordId);
            goldSheetActionPlanPDFData = JSON.serialize(goldSheetActionPlanPDFWrapper);
        }
    }

    //Method to GET Records from Action Plan Activities-Actions Tab in Gold Sheet
    @AuraEnabled
    public static List<ActionPlanActivitiesActionsWrapper> getActionRecords(String goldSheetId) {
        Boolean isDeletable = false;
        List<Action__c> actionsList = new List<Action__c>();
        List<ActionPlanActivitiesActionsWrapper> actionsWrapperList = new List<ActionPlanActivitiesActionsWrapper>();
        if (Schema.sObjectType.Action__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String actionsQuery;

            if (actionStatusInData != null && actionStatusInData.equalsIgnoreCase('Complete')) {
                actionsQuery = 'Select Id, Name, Action_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC';
            } else if (actionStatusInData != null && actionStatusInData.equalsIgnoreCase('Incomplete')) {
                actionsQuery = 'Select Id, Name, Action_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC';
            } else {
                actionsQuery = 'Select Id, Name, Action_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';
            }

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            //get data from ActionPlan Activities - Actions section
            actionsList = DataFactory.read(actionsQuery, paramters);
            //Iterate through list to get list of wrapper to return to UI
            for (Action__c gsActions : actionsList) {
                String sourceId = gsActions.Id;
                ActionPlanActivitiesActionsWrapper wrapper = new ActionPlanActivitiesActionsWrapper(
                    gsActions,
                    isDeletable
                );
                actionsWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new ActionPlanActivitiesActionsException(
                'Error occured while getting data from ActionPlan Activities - Actions'
            );
        }
        //Return list of wrapper containing all ActionPlan Activities - Actions data
        return actionsWrapperList;
    }

    //Method to GET Records from Information Needed Tab in Gold Sheet
    @AuraEnabled
    public static List<InformationNeededWrapper> getInformationNeededRecords(String goldSheetId) {
        Boolean isDeletable = false;
        List<Information_Needed__c> informationNeededList = new List<Information_Needed__c>();
        List<InformationNeededWrapper> informationNeededWrapperList = new List<InformationNeededWrapper>();
        if (Schema.sObjectType.Information_Needed__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String informationNeededQuery;
            if (informationNeeded != null && informationNeeded.equalsIgnoreCase('Complete')) {
                informationNeededQuery = 'Select Id, Name, Information_Needed_Title__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC';
            } else if (informationNeeded != null && informationNeeded.equalsIgnoreCase('Incomplete')) {
                informationNeededQuery = 'Select Id, Name, Information_Needed_Title__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC';
            } else {
                informationNeededQuery = 'Select Id, Name, Information_Needed_Title__c, Source__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';
            }

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            //get data from Information Needed section
            informationNeededList = DataFactory.read(informationNeededQuery, paramters);
            //Iterate through list to get list of wrapper to return to UI
            for (Information_Needed__c gsInformationNeeds : informationNeededList) {
                String sourceId = gsInformationNeeds.Id;
                InformationNeededWrapper wrapper = new InformationNeededWrapper(gsInformationNeeds, isDeletable);
                informationNeededWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new InformationNeededException('Error occured while getting data from InInformation Needed');
        }
        //Return list of wrapper containing all Information Needed data
        return informationNeededWrapperList;
    }

    //Method to GET Records from Investment Program Activities-Actions Tab in Gold Sheet
    @AuraEnabled
    public static List<InvestmentProgramControllerWrapper> getInvProgramRecords(String goldSheetId) {
        Boolean isDeletable = false;
        List<Investment_Program__c> investmentProgramList = new List<Investment_Program__c>();
        List<InvestmentProgramControllerWrapper> invProgramWrapperList = new List<InvestmentProgramControllerWrapper>();
        if (Schema.sObjectType.Investment_Program__c.isDeletable()) {
            isDeletable = true;
        }
        try {
            String invProgQuery;
            if (investmentPrograms != null && investmentPrograms.equalsIgnoreCase('Complete')) {
                invProgQuery = 'Select Id, Name, Investment_Program_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c DESC';
            } else if (investmentPrograms != null && investmentPrograms.equalsIgnoreCase('Incomplete')) {
                invProgQuery = 'Select Id, Name, Investment_Program_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY Status__c ASC';
            } else {
                invProgQuery = 'Select Id, Name, Investment_Program_Title__c, Due_Date__c, Assigned_To__c, Assigned_To__r.Name, Status__c, Description__c, Fields_of_Play_Gold_Sheet__c FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:goldSheetId ORDER BY createdDate DESC';
            }

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldSheetId', goldSheetId);
            //get data from ActionPlan Activities - Actions section
            investmentProgramList = DataFactory.read(invProgQuery, paramters);
            //Iterate through list to get list of wrapper to return to UI
            for (Investment_Program__c inv : investmentProgramList) {
                String sourceId = inv.Id;
                InvestmentProgramControllerWrapper wrapper = new InvestmentProgramControllerWrapper(inv, isDeletable);
                invProgramWrapperList.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new InvestmentProgramControllerException(
                'Error occured while getting data from ActionPlan Activities - Actions'
            );
        }
        //Return list of wrapper containing all ActionPlan Activities - Actions data
        return invProgramWrapperList;
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

            milestonesQuery = 'Select Id, Name, Milestone_Number_Index__c,Milestone_Number__c, Meeting_Notes__c, Meeting_Date__c, Gold_Sheet__c FROM Milestone__c WHERE Gold_Sheet__c=:goldSheetId ORDER BY Meeting_Date__c ASC';

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

    private class ActionPlanActivitiesActionsException extends Exception {
    }

    private class InformationNeededException extends Exception {
    }

    private class InvestmentProgramControllerException extends Exception {
    }

    private class MilestonesException extends Exception {
    }
}