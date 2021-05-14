/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────
 * KFS-286 (part of main US KFS-122) : Apex class to change the Progress field on the Blue Sheet Object
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Keerthana Mohanasundaram
 * @created        05/27/20202
 *
 * Most of the methods in this class are called from the triggers of the different Blue Sheet Objects.
 */

public with sharing class BlueSheetStatus {
    public static void updateBlueFromSSO(List<Single_Sales_Objective__c> ssoRecords) {
        List<String> ssoBlueSheetIds = new List<String>();
        for (Single_Sales_Objective__c sso : ssoRecords) {
            ssoBlueSheetIds.add(sso.Blue_Sheet__c);
        }
        //Changing Progress Field of bluesheet
        String blueSheetNewQuery = 'Select Id,Name,Progress__c FROM Blue_Sheet__c WHERE Id IN:ssoBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('ssoBlueSheetIds', ssoBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            if (blue.Progress__c == 'Not Started') {
                blue.Progress__c = 'Initialized';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    public static void updateBlueFromCurrentPosition(List<Current_Position__c> cpRecords) {
        List<String> cpBlueSheetIds = new List<String>();
        for (Current_Position__c cp : cpRecords) {
            cpBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        //Changing Progress Field of bluesheet
        String blueSheetNewQuery = 'Select Id,Name,Progress__c FROM Blue_Sheet__c WHERE Id IN:cpBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('cpBlueSheetIds', cpBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            if (blue.Progress__c == 'Not Started') {
                blue.Progress__c = 'Initialized';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }
    public static void updateBlueFromScoreCard(List<Score_Card__c> scoreRecords) {
        List<String> scoreBlueSheetIds = new List<String>();
        for (Score_Card__c cp : scoreRecords) {
            scoreBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        //Changing Progress Field of bluesheet
        String blueSheetNewQuery = 'Select Id,Name,Progress__c FROM Blue_Sheet__c WHERE Id IN:scoreBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('scoreBlueSheetIds', scoreBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            if (blue.Progress__c == 'Not Started') {
                blue.Progress__c = 'Initialized';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    public static void updateBlueFromCompetition(List<Competition__c> compRecords) {
        Set<String> compBlueSheetIds = new Set<String>();
        for (Competition__c cp : compRecords) {
            compBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        //Changing Progress Field of bluesheet
        String blueSheetNewQuery = 'Select Id,Name,Progress__c FROM Blue_Sheet__c WHERE Id IN:compBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('compBlueSheetIds', compBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            if (blue.Progress__c == 'Not Started') {
                blue.Progress__c = 'Initialized';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }
    public static void updateBlueFromBuyingInfluence(List<Buying_Influence__c> buyRecords) {
        Set<String> buyBlueSheetIds = new Set<String>();
        for (Buying_Influence__c cp : buyRecords) {
            buyBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        //Check for Action Plan Records

        String actionPlanQuery = 'Select Id,Name,Blue_Sheet__c FROM Action_Plan__c WHERE Blue_Sheet__c IN:buyBlueSheetIds';
        Map<String, Object> actionPlanparamters = new Map<String, Object>();
        actionPlanparamters.put('buyBlueSheetIds', buyBlueSheetIds);
        List<Action_Plan__c> actionPlanList = DataFactory.read(actionPlanQuery, actionPlanparamters);
        Set<String> actionBlueSheetIds = new Set<String>();
        for (Action_Plan__c ap : actionPlanList) {
            actionBlueSheetIds.add(ap.Blue_Sheet__c);
        }
        //Changing Progress Field of bluesheet
        String blueSheetNewQuery = 'Select Id,Name,Progress__c FROM Blue_Sheet__c WHERE Id IN:buyBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('buyBlueSheetIds', buyBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            if (blue.Progress__c == 'Not Started') {
                blue.Progress__c = 'Initialized';
                updateBlueStatus.add(blue);
            }
            if (actionBlueSheetIds.contains(blue.Id) && blue.Progress__c != 'In Progress') {
                blue.Progress__c = 'In Progress';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    public static void updateBlueFromActionPlan(List<Action_Plan__c> actionRecords) {
        Set<String> actionBlueSheetIds = new Set<String>();
        for (Action_Plan__c cp : actionRecords) {
            actionBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        //Checking Buying Influence Records

        String buyingInfluenceQuery = 'Select Id,Name,Blue_Sheet__c FROM Buying_Influence__c WHERE Blue_Sheet__c IN:actionBlueSheetIds';
        Map<String, Object> buyingparamters = new Map<String, Object>();
        buyingparamters.put('actionBlueSheetIds', actionBlueSheetIds);
        List<Buying_Influence__c> buyingList = DataFactory.read(buyingInfluenceQuery, buyingparamters);
        Set<String> buyingBlueSheetIds = new Set<String>();
        for (Buying_Influence__c ap : buyingList) {
            buyingBlueSheetIds.add(ap.Blue_Sheet__c);
        }

        //Changing Progress Field of bluesheet
        String blueSheetNewQuery = 'Select Id,Name,Progress__c FROM Blue_Sheet__c WHERE Id IN:actionBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('actionBlueSheetIds', actionBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            if (blue.Progress__c == 'Not Started') {
                blue.Progress__c = 'Initialized';
                updateBlueStatus.add(blue);
            }
            if (buyingBlueSheetIds.contains(blue.Id) && blue.Progress__c != 'In Progress') {
                blue.Progress__c = 'In Progress';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    @AuraEnabled
    public static List<BlueSheetProgressWrapper> getBlueSheetActionInprogress(String opptId) {
        if (
            (Schema.sObjectType.Blue_Sheet__c.isCreateable() ||
            Schema.sObjectType.Blue_Sheet__c.isUpdateable() ||
            Schema.sObjectType.Blue_Sheet__c.isAccessible()) &&
            Schema.sObjectType.Blue_Sheet__c.fields.Action_Plan_Progress__c.isAccessible()
        ) {
            List<Blue_Sheet__c> bluesheetProgressList = new List<Blue_Sheet__c>();
            List<BlueSheetProgressWrapper> blueSheetProgressWrapperList = new List<BlueSheetProgressWrapper>();
            String blueSheetProgressQuery = 'SELECT Id, Name,Action_Plan_Progress__c,Buying_Influence_Progress__c,Competition_Progress__c, Current_Position_Progress__c,Scorecard_Progress__c,SSO_Progress__c,Summary_Position_Progress__c FROM Blue_Sheet__c where Opportunity__c =: opptId limit 1';
            Map<String, Object> blueSheetProgressQueryParams = new Map<String, Object>();
            blueSheetProgressQueryParams.put('opptId', opptId);
            bluesheetProgressList = DataFactory.read(blueSheetProgressQuery, blueSheetProgressQueryParams);

            for (Blue_Sheet__c blueSheet : bluesheetProgressList) {
                BlueSheetProgressWrapper wrapper = new BlueSheetProgressWrapper(blueSheet);
                blueSheetProgressWrapperList.add(wrapper);
            }
            return blueSheetProgressWrapperList;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static Boolean getBlueSheetAndSelfGuidedJourneyAcess() {
        Map<String, Boolean> sGJAcess = ApexCommonUtil.getObjectAccessByObjectName('Self_Guided_Journey__c');
        Map<String, Boolean> bsAcess = ApexCommonUtil.getObjectAccessByObjectName('Blue_Sheet__c');
        return bsAcess.get('isCreateable') &&
            sGJAcess.get('isCreateable') &&
            !SelfGuidedLearning.checkIfSelfGuidedLearningDisabled()
            ? true
            : false;
    }
}