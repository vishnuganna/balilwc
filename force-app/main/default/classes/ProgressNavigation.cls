public with sharing class ProgressNavigation {
    public static boolean myPositionUpdate = true;
    public static boolean bIAvoidRecursion = true;
    public static boolean competetitionAvoidRecursion = true;
    public static boolean actionPlanInsert = true;
    public static boolean actionPlanUpdate = true;
    public static boolean LastUpdatedDateInsert = true;
    public static boolean LastUpdatedDateUpdate = true;

    public static void updateProgressCompetition(List<Competition__c> compRecords) {
        Set<String> compBlueSheetIds = new Set<String>();
        //check for Completion of Competition Records
        for (Competition__c cp : compRecords) {
            compBlueSheetIds.add(cp.Blue_Sheet__c);
        }

        String competitionQuery = 'Select Id,Name,Blue_Sheet__c,Competitior_Name__c,Competitive_Detail__c,Competitor_Type__c,My_Position_Vs_Competitor__c FROM Competition__c WHERE Blue_Sheet__c IN:compBlueSheetIds';
        Map<String, Object> competitionParameters = new Map<String, Object>();
        competitionParameters.put('compBlueSheetIds', compBlueSheetIds);
        List<Competition__c> CompetitionList = DataFactory.read(competitionQuery, competitionParameters);
        Map<String, String> mapTrackProgress = new Map<String, String>();
        Map<String, List<Competition__c>> mapBlueSheetWithComp = new Map<String, List<Competition__c>>();

        if (CompetitionList.size() > 0) {
            for (Competition__c cp : CompetitionList) {
                if (mapBlueSheetWithComp.containskey(cp.Blue_Sheet__c)) {
                    mapBlueSheetWithComp.get(cp.Blue_Sheet__c).add(cp);
                } else {
                    mapBlueSheetWithComp.put(cp.Blue_Sheet__c, new List<Competition__c>{ cp });
                }
            }
        }

        for (String blueSheetId : mapBlueSheetWithComp.keyset()) {
            for (Competition__c competition : mapBlueSheetWithComp.get(blueSheetId)) {
                if (
                    competition.Competitor_Type__c != null &&
                    competition.My_Position_Vs_Competitor__c != null &&
                    competition.Competitive_Detail__c != null
                ) {
                    mapTrackProgress.put(competition.Blue_Sheet__c, 'Complete');
                    break;
                } else {
                    mapTrackProgress.put(competition.Blue_Sheet__c, 'In Progress');
                }
            }
        }

        //Query the Blue Sheet records
        String blueSheetNewQuery = 'Select Id,Name,Competition_Progress__c FROM Blue_Sheet__c WHERE Id IN:compBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('compBlueSheetIds', compBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();

        //Update blue sheet Competition Progress field
        for (Blue_Sheet__c blue : bluesheetList) {
            if (
                mapTrackProgress.containsKey(blue.Id) && (blue.Competition_Progress__c != mapTrackProgress.get(blue.Id))
            ) {
                blue.Competition_Progress__c = mapTrackProgress.get(blue.Id);
                updateBlueStatus.add(blue);
            }
            if (
                mapBlueSheetWithComp.isEmpty() ||
                mapBlueSheetWithComp.get(blue.Id).isEmpty() && (blue.Competition_Progress__c != 'Not Started')
            ) {
                blue.Competition_Progress__c = 'Not Started';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    public static void updateProgressCurrentPosition(List<Current_Position__c> currentRecords) {
        Set<String> cpBlueSheetIds = new Set<String>();
        Map<String, String> mapTrackProgress = new Map<String, String>();
        for (Current_Position__c cp : currentRecords) {
            cpBlueSheetIds.add(cp.Blue_Sheet__c);
            if (cp.Current_Position__c != null) {
                mapTrackProgress.put(cp.Blue_Sheet__c, 'Complete');
            } else {
                mapTrackProgress.put(cp.Blue_Sheet__c, 'Not Started');
            }
        }

        //Query the Blue Sheet records
        String blueSheetNewQuery = 'Select Id,Name,Current_Position_Progress__c FROM Blue_Sheet__c WHERE Id IN:cpBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('cpBlueSheetIds', cpBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();

        //Update blue sheet CurrentPosition Progress field
        for (Blue_Sheet__c blue : bluesheetList) {
            if (
                mapTrackProgress.containsKey(blue.Id) &&
                (blue.Current_Position_Progress__c != mapTrackProgress.get(blue.Id))
            ) {
                blue.Current_Position_Progress__c = mapTrackProgress.get(blue.Id);
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    //KFS-225 Scorecard navigation status update functionality
    //Method to update the status when scorecard is created or updated.
    public static void updateNavigationProgress(List<Score_Card__c> lstScorecards) {
        map<Id, Id> mapScorecardToBluesheet = new Map<Id, Id>();
        set<Id> bluesheetIds = new Set<Id>();
        set<Id> scorecardIds = new Set<Id>();
        map<Id, List<Score_Card_Detail__c>> mapScorecardWithDetails = new Map<Id, List<Score_Card_Detail__c>>();
        map<Id, boolean> mapScWithfilledData = new Map<Id, boolean>();
        for (Score_Card__c scorecard : lstScorecards) {
            bluesheetIds.add(scorecard.Blue_Sheet__c);
            scorecardIds.add(scorecard.Id);
        }

        List<Score_Card_Detail__c> scorecardDetails = new List<Score_Card_Detail__c>();
        String queryScorecard = 'SELECT Id,Name,Score_Value__c,Score_Card__c from Score_Card_Detail__c WHERE Score_Card__c IN:scorecardIds ';

        map<String, Object> detailsParams = new Map<String, Object>();
        detailsParams.put('scorecardIds', scorecardIds);

        scorecardDetails = DataFactory.read(queryScorecard, detailsParams);

        for (Score_Card_Detail__c scd : scorecardDetails) {
            if (mapScorecardWithDetails.containskey(scd.Score_Card__c)) {
                mapScorecardWithDetails.get(scd.Score_Card__c).add(scd);
            } else {
                mapScorecardWithDetails.put(scd.Score_Card__c, new List<Score_Card_Detail__c>{ scd });
            }
        }

        for (Id scId : mapScorecardWithDetails.keyset()) {
            for (Score_Card_Detail__c scorecardDetail : mapScorecardWithDetails.get(scId)) {
                if (scorecardDetail.Score_Value__c == null || scorecardDetail.Score_Value__c == '') {
                    mapScWithfilledData.put(scorecardDetail.Score_Card__c, false);
                    break;
                } else {
                    mapScWithfilledData.put(scorecardDetail.Score_Card__c, true);
                }
            }
        }

        String query = 'SELECT Id,Name,Scorecard_Progress__c FROM Blue_Sheet__c WHERE Id IN:bluesheetIds';
        map<String, Object> params = new Map<String, Object>();
        params.put('bluesheetIds', bluesheetIds);
        List<Blue_Sheet__c> lstBlueSheets = DataFactory.read(query, params);
        List<Blue_Sheet__c> lstBlueSheetsToUpdate = new List<Blue_Sheet__c>();
        map<Id, Blue_Sheet__c> mapBluesheetWithIds = new Map<Id, Blue_Sheet__c>();
        for (Blue_Sheet__c bluesheet : lstBlueSheets) {
            mapBluesheetWithIds.put(bluesheet.Id, bluesheet);
        }
        for (Score_Card__c scorecard : lstScorecards) {
            if (
                (scorecard.Total_Score__c <= 60 ||
                (scorecard.Total_Score__c > 60 && !mapScWithfilledData.isEmpty() &&
                !mapScWithfilledData.get(scorecard.Id))) &&
                mapBluesheetWithIds.get(scorecard.Blue_Sheet__c).Scorecard_Progress__c != 'In Progress'
            ) {
                mapBluesheetWithIds.get(scorecard.Blue_Sheet__c).Scorecard_Progress__c = 'IN Progress';
                lstBlueSheetsToUpdate.add(mapBluesheetWithIds.get(scorecard.Blue_Sheet__c));
            }
            if (
                (scorecard.Total_Score__c > 60 && !mapScWithfilledData.isEmpty() &&
                mapScWithfilledData.get(scorecard.Id)) &&
                mapBluesheetWithIds.get(scorecard.Blue_Sheet__c).Scorecard_Progress__c != 'Complete'
            ) {
                mapBluesheetWithIds.get(scorecard.Blue_Sheet__c).Scorecard_Progress__c = 'Complete';
                lstBlueSheetsToUpdate.add(mapBluesheetWithIds.get(scorecard.Blue_Sheet__c));
            }
        }

        if (!lstBlueSheetsToUpdate.isEmpty()) {
            DataFactory.Modify(lstBlueSheetsToUpdate);
        }
    }
    //Method to update the status when scorecard is deleted
    public static void updateNavigationAfterDelete(map<Id, Score_Card__c> oldmap) {
        set<Id> bluesheetIds = new Set<Id>();
        set<Id> scorecardIds = new Set<Id>();
        for (Score_Card__c scorecard : oldmap.values()) {
            scorecardIds.add(scorecard.Id);
            bluesheetIds.add(scorecard.Blue_Sheet__c);
        }
        String query = 'SELECT Id,Name,Scorecard_Progress__c FROM Blue_Sheet__c WHERE Id IN:bluesheetIds';
        map<String, Object> params = new Map<String, Object>();
        params.put('bluesheetIds', bluesheetIds);
        List<Blue_Sheet__c> lstBlueSheets = DataFactory.read(query, params);

        map<Id, Blue_Sheet__c> mapBluesheetWithIds = new Map<Id, Blue_Sheet__c>();
        for (Blue_Sheet__c bluesheet : lstBlueSheets) {
            mapBluesheetWithIds.put(bluesheet.Id, bluesheet);
        }
        for (Score_Card__c scorecard : oldmap.values()) {
            mapBluesheetWithIds.get(scorecard.Blue_Sheet__c).Scorecard_Progress__c = 'Not Started';
        }
        DataFactory.Modify(mapBluesheetWithIds.values());
    }
    //KFS-225 end of code

    public static void updateProgressSummaryOfMyPosition(List<Summary_of_My_Position_Today__c> sumOfMyPositionRecords) {
        Set<String> blueSheetIds = new Set<String>();

        //check for Completion of Summary of my position Records
        for (Summary_of_My_Position_Today__c somp : sumOfMyPositionRecords) {
            blueSheetIds.add(somp.Blue_Sheet__c);
        }

        String summaryOfMyPositionQuery = 'Select Id,Description__c,Blue_Sheet__c,Is_a_Red_Flag__c,Is_a_Strength__c,Summary__c,Name FROM Summary_of_My_Position_Today__c WHERE Blue_Sheet__c IN:blueSheetIds';
        Map<String, Object> sumOfMyPosParameters = new Map<String, Object>();
        sumOfMyPosParameters.put('blueSheetIds', blueSheetIds);
        List<Summary_of_My_Position_Today__c> myPositionList = DataFactory.read(
            summaryOfMyPositionQuery,
            sumOfMyPosParameters
        );
        Map<String, String> mapTrackProgress = new Map<String, String>();
        Map<String, List<Summary_of_My_Position_Today__c>> mapBlueSheetWithMyPosition = new Map<String, List<Summary_of_My_Position_Today__c>>();

        if (myPositionList.size() > 0) {
            for (Summary_of_My_Position_Today__c somp : myPositionList) {
                if (mapBlueSheetWithMyPosition.containskey(somp.Blue_Sheet__c)) {
                    mapBlueSheetWithMyPosition.get(somp.Blue_Sheet__c).add(somp);
                } else {
                    mapBlueSheetWithMyPosition.put(
                        somp.Blue_Sheet__c,
                        new List<Summary_of_My_Position_Today__c>{ somp }
                    );
                }
            }
        }

        for (String blueSheetId : mapBlueSheetWithMyPosition.keyset()) {
            Boolean isRedFlagPositionCompleted = false;
            Boolean isStrengthPositionCompleted = false;
            for (Summary_of_My_Position_Today__c sumOfMyPosition : mapBlueSheetWithMyPosition.get(blueSheetId)) {
                if (sumOfMyPosition.Is_a_Strength__c) {
                    isStrengthPositionCompleted = true;
                } else if (sumOfMyPosition.Is_a_Red_Flag__c) {
                    isRedFlagPositionCompleted = true;
                }

                if (isStrengthPositionCompleted && isRedFlagPositionCompleted) {
                    mapTrackProgress.put(sumOfMyPosition.Blue_Sheet__c, 'Complete');
                    break;
                } else if (isStrengthPositionCompleted || isRedFlagPositionCompleted) {
                    mapTrackProgress.put(sumOfMyPosition.Blue_Sheet__c, 'In Progress');
                }
            }
        }

        //Query the Blue Sheet records
        String blueSheetNewQuery = 'Select Id,Name,Summary_Position_Progress__c FROM Blue_Sheet__c WHERE Id IN:blueSheetIds';
        Map<String, Object> blueSheetNewParameters = new Map<String, Object>();
        blueSheetNewParameters.put('blueSheetIds', blueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewParameters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();

        //Update blue sheet summary of my position Progress field
        for (Blue_Sheet__c blue : bluesheetList) {
            if (mapTrackProgress.containsKey(blue.Id)) {
                blue.Summary_Position_Progress__c = mapTrackProgress.get(blue.Id);
                updateBlueStatus.add(blue);
            }
            if (mapBlueSheetWithMyPosition.isEmpty() || mapBlueSheetWithMyPosition.get(blue.Id).isEmpty()) {
                blue.Summary_Position_Progress__c = 'Not Started';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    public static void updateProgressBI(List<Buying_Influence__c> bIRecords) {
        Set<String> setBIBlueSheetIds = new Set<String>();
        //check for Completion of Buying Influence Records
        for (Buying_Influence__c cp : bIRecords) {
            setBIBlueSheetIds.add(cp.Blue_Sheet__c);
        }

        String bIQuery =
            'Select Id,Name,Blue_Sheet__c,Business_Results__c,Buying_From_Us__c,Buying_from_Someone_Else__c,Coach__c,' +
            'Doing_Nothing__c,Economic__c,Even_Keel__c,Growth__c,High__c,Location__c,Low__c,Medium__c,Contact__c,Over_Confident__c,' +
            'Personal_Wins__c,Rating__c,Rating_Evidence__c,Rating_Text__c,Search_Competitor__c,Technical__c,Title__c,Trouble__c,' +
            'User__c,Using_Budget_for_Something_Else__c,Using_Internal_Resources__c' +
            ' FROM Buying_Influence__c WHERE Blue_Sheet__c IN:setBIBlueSheetIds';

        Map<String, Object> bIParameters = new Map<String, Object>();
        bIParameters.put('setBIBlueSheetIds', setBIBlueSheetIds);
        List<Buying_Influence__c> bIList = DataFactory.read(bIQuery, bIParameters);
        Map<String, String> mapTrackProgress = new Map<String, String>();
        Map<String, List<Buying_Influence__c>> mapBlueSheetWithBI = new Map<String, List<Buying_Influence__c>>();

        if (bIList.size() > 0) {
            for (Buying_Influence__c cp : bIList) {
                if (mapBlueSheetWithBI.containskey(cp.Blue_Sheet__c)) {
                    mapBlueSheetWithBI.get(cp.Blue_Sheet__c).add(cp);
                } else {
                    mapBlueSheetWithBI.put(cp.Blue_Sheet__c, new List<Buying_Influence__c>{ cp });
                }
            }
        }

        for (String blueSheetId : mapBlueSheetWithBI.keyset()) {
            for (Buying_Influence__c buy : mapBlueSheetWithBI.get(blueSheetId)) {
                if (
                    (buy.Economic__c ||
                    buy.Technical__c ||
                    buy.User__c ||
                    buy.Coach__c) &&
                    (buy.High__c ||
                    buy.Medium__c ||
                    buy.Low__c) &&
                    (buy.Over_Confident__c ||
                    buy.Growth__c ||
                    buy.Trouble__c ||
                    buy.Even_Keel__c) &&
                    (buy.Using_Budget_for_Something_Else__c ||
                    buy.Using_Internal_Resources__c ||
                    buy.Buying_from_Someone_Else__c ||
                    buy.Doing_Nothing__c ||
                    buy.Buying_From_Us__c) &&
                    buy.Personal_Wins__c != null &&
                    buy.Business_Results__c != null &&
                    buy.Rating_Evidence__c != null &&
                    buy.Rating__c != null &&
                    buy.Contact__c != null
                ) {
                    mapTrackProgress.put(buy.Blue_Sheet__c, 'Complete');
                    break;
                } else {
                    mapTrackProgress.put(buy.Blue_Sheet__c, 'In Progress');
                }
            }
        }

        //Query the Blue Sheet records
        String blueSheetNewQuery = 'Select Id,Name,Buying_Influence_Progress__c FROM Blue_Sheet__c WHERE Id IN:setBIBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('setBIBlueSheetIds', setBIBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();

        //Update blue sheet Buying Influence Progress field
        for (Blue_Sheet__c blue : bluesheetList) {
            if (
                mapTrackProgress.containsKey(blue.Id) &&
                (blue.Buying_Influence_Progress__c != mapTrackProgress.get(blue.Id))
            ) {
                blue.Buying_Influence_Progress__c = mapTrackProgress.get(blue.Id);
                updateBlueStatus.add(blue);
            }
            if (
                (mapBlueSheetWithBI.isEmpty() || mapBlueSheetWithBI.get(blue.Id).isEmpty()) &&
                (blue.Buying_Influence_Progress__c != 'Not Started')
            ) {
                blue.Buying_Influence_Progress__c = 'Not Started';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }

    // Start SSO Progress Updation - Bhagyashree Mandlik - 22/06/2020 :KFS-138

    public static void updateProgressSingleSalesObjective(List<Single_Sales_Objective__c> ssoRecords) {
        Set<String> ssoBlueSheetIds = new Set<String>();
        Map<String, String> mapTrackProgress = new Map<String, String>();
        for (Single_Sales_Objective__c sso : ssoRecords) {
            ssoBlueSheetIds.add(sso.Blue_Sheet__c);
            if (
                sso.Customer_Timing_for_Priorities__c != null &&
                sso.Customers_Stated_Objectives__c != null &&
                sso.Evaluation_of_Objectives__c != null
            ) {
                mapTrackProgress.put(sso.Blue_Sheet__c, 'Complete');
            } else if (
                sso.Customer_Timing_for_Priorities__c != null ||
                sso.Customers_Stated_Objectives__c != null ||
                sso.Evaluation_of_Objectives__c != null
            ) {
                mapTrackProgress.put(sso.Blue_Sheet__c, 'In Progress');
            } else {
                mapTrackProgress.put(sso.Blue_Sheet__c, 'Not Started');
            }
        }

        //Query the Blue Sheet records
        String blueSheetNewQuery = 'Select Id, Name, SSO_Progress__c FROM Blue_Sheet__c WHERE Id IN:ssoBlueSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('ssoBlueSheetIds', ssoBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();

        //Update the Blue Sheet Progress Field
        for (Blue_Sheet__c blue : bluesheetList) {
            if (mapTrackProgress.containsKey(blue.Id) && (blue.SSO_Progress__c != mapTrackProgress.get(blue.Id))) {
                blue.SSO_Progress__c = mapTrackProgress.get(blue.Id);
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }
    // End SSO Progress Updation - Bhagyashree Mandlik - 22/06/2020
    //KFS-230 Action Plan navigation status update functionality
    //Method to update the status when Action Plan is created or updated or deleted.
    public static void updateActionPlanProgressNavigation(List<Action_Plan__c> actionPlans) {
        Set<String> actBuleSheetIds = new Set<String>();
        //check for ActionPlan of actPlan Records
        for (Action_Plan__c actPlan : actionPlans) {
            actBuleSheetIds.add(actPlan.Blue_Sheet__c);
        }

        String actBlueSheet = 'Select Id,Name,Blue_Sheet__c,Is_a_Best_Action__c,Status__c FROM Action_Plan__c WHERE Blue_Sheet__c IN:actBuleSheetIds';
        Map<String, Object> actPlanParameters = new Map<String, Object>();
        actPlanParameters.put('actBuleSheetIds', actBuleSheetIds);
        List<Action_Plan__c> ActionPlanList = DataFactory.read(actBlueSheet, actPlanParameters);
        Map<String, String> mapTrackProgress = new Map<String, String>();
        Map<String, List<Action_Plan__c>> mapBlueSheetWithComp = new Map<String, List<Action_Plan__c>>();

        if (ActionPlanList.size() > 0) {
            for (Action_Plan__c actPlan : ActionPlanList) {
                if (mapBlueSheetWithComp.containskey(actPlan.Blue_Sheet__c)) {
                    mapBlueSheetWithComp.get(actPlan.Blue_Sheet__c).add(actPlan);
                } else {
                    mapBlueSheetWithComp.put(actPlan.Blue_Sheet__c, new List<Action_Plan__c>{ actPlan });
                }
            }
        }

        for (String blueSheetId : mapBlueSheetWithComp.keyset()) {
            for (Action_Plan__c actPlan : mapBlueSheetWithComp.get(blueSheetId)) {
                if (actPlan.Is_a_Best_Action__c && actPlan.Status__c == 'Completed') {
                    mapTrackProgress.put(actPlan.Blue_Sheet__c, 'Complete');
                    break;
                } else {
                    mapTrackProgress.put(actPlan.Blue_Sheet__c, 'In Progress');
                }
            }
        }
        //Query the Blue Sheet records
        String blueSheetNewQuery = 'Select Id,Name,Action_Plan_Progress__c FROM Blue_Sheet__c WHERE Id IN:actBuleSheetIds';
        Map<String, Object> blueSheetNewparamters = new Map<String, Object>();
        blueSheetNewparamters.put('actBuleSheetIds', actBuleSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(blueSheetNewQuery, blueSheetNewparamters);
        List<Blue_Sheet__c> updateBlueStatus = new List<Blue_Sheet__c>();

        //Update blue sheet actPlan Progress field
        for (Blue_Sheet__c blue : bluesheetList) {
            if (
                mapTrackProgress.containsKey(blue.Id) && (blue.Action_Plan_Progress__c != mapTrackProgress.get(blue.Id))
            ) {
                blue.Action_Plan_Progress__c = mapTrackProgress.get(blue.Id);
                updateBlueStatus.add(blue);
            }
            if (
                mapBlueSheetWithComp.isEmpty() ||
                mapBlueSheetWithComp.get(blue.Id).isEmpty() && (blue.Action_Plan_Progress__c != 'Not Started')
            ) {
                blue.Action_Plan_Progress__c = 'Not Started';
                updateBlueStatus.add(blue);
            }
        }
        if (updateBlueStatus.size() > 0) {
            DataFactory.modify(updateBlueStatus);
        }
    }
    //KFS-230 END
    //KFS-1770 Start// Updating Blue Sheet Last Updated Date
    public static void blueSheetLastUpdatedDateAndTime(List<sObject> ls) {
        List<sObject> objList = new List<sObject>();
        Set<sObject> setObj = new Set<sObject>();
        for (sObject s : ls) {
            Blue_Sheet__c blueSheet = new Blue_Sheet__c();
            blueSheet.Id = (Id) s.get('Blue_Sheet__c');
            //blueSheet.Last_Updated__c = (DateTime) s.get('LastModifiedDate');
            setObj.add(blueSheet);
        }
        objList.addAll(setObj);
        if (objList.size() > 0) {
            DataFactory.modify(objList);
        }
    } //KFS-1770 End
}