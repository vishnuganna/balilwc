@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ExcessiveClassLength,PMD.CognitiveComplexity')
public with sharing class FOPSpotLightReportFields {
    public static void updateRevenueTargetFields(List<Revenue_Target__c> rtRecords) {
        Map<String, List<Decimal>> mapRtTargetValues = new Map<String, List<Decimal>>();
        List<String> rtIds = new List<String>();
        for (Revenue_Target__c rt : rtRecords) {
            rtIds.add(rt.Id);
        }
        //Query The revenue Target records as the trigger.new will not have relationship fields
        String revenueQuery = 'Select Id,Gold_Sheet__c,Current_Year__r.High_Target__c,Current_Year__r.Low_Target__c,Current_Year__r.Realistic_Target__c FROM Revenue_Target__c WHERE Id IN:rtIds';
        Map<String, Object> revenueParamters = new Map<String, Object>();
        revenueParamters.put('rtIds', rtIds);
        List<Revenue_Target__c> listRevenueTargetDetail = DataFactory.read(revenueQuery, revenueParamters);
        for (Revenue_Target__c rt : listRevenueTargetDetail) {
            mapRtTargetValues.put(
                rt.Gold_Sheet__c,
                new List<Decimal>{
                    rt.Current_Year__r.High_Target__c,
                    rt.Current_Year__r.Low_Target__c,
                    rt.Current_Year__r.Realistic_Target__c
                }
            );
        }

        //Query the Gold Sheet records and update the corresposnding fields
        Set<String> setRtGoldSheetIds = new Set<String>();
        setRtGoldSheetIds = mapRtTargetValues.keySet();
        String goldsheetQuery = 'SELECT Id,High_Target_Current_Year__c,Low_Target_Current_Year__c,Realistic_Target_Current_Year__c FROM Gold_Sheet__c WHERE Id IN :setRtGoldSheetIds';
        Map<String, Object> goldSheetParamters = new Map<String, Object>();
        goldSheetParamters.put('setRtGoldSheetIds', setRtGoldSheetIds);
        List<Gold_Sheet__c> listGoldSheet = DataFactory.read(goldsheetQuery, goldSheetParamters);
        List<Gold_Sheet__c> listUpdateGoldSheet = new List<Gold_Sheet__c>();
        if (listGoldSheet.size() > 0) {
            for (Gold_Sheet__c gs : listGoldSheet) {
                if (mapRtTargetValues.containsKey(gs.Id)) {
                    List<Decimal> dRtValues = mapRtTargetValues.get(gs.Id);
                    gs.High_Target_Current_Year__c = dRtValues[0];
                    gs.Low_Target_Current_Year__c = dRtValues[1];
                    gs.Realistic_Target_Current_Year__c = dRtValues[2];
                    listUpdateGoldSheet.add(gs);
                }
            }
            if (listUpdateGoldSheet.size() > 0) {
                DataFactory.modify(listUpdateGoldSheet);
            }
        }
    }
    public static void updateRoleFieldStrategicPlayer(List<Strategic_Player__c> spRecords) {
        Map<String, Map<String, Decimal>> mapSPRoleValues = new Map<String, Map<String, Decimal>>();
        List<String> goldSheetsIds = new List<String>();
        for (Strategic_Player__c sp : spRecords) {
            goldSheetsIds.add(sp.Gold_Sheet__c);
        }
        //Query all the Strategic Player records with goldsheetId to get the count of each role value
        String strategicPlayerQuery = 'SELECT COUNT(Id) numberOfRecords,Gold_Sheet__c goldSheetId,Strategic_Player_Role__c role FROM Strategic_Player__c WHERE Gold_Sheet__c IN :goldSheetsIds GROUP BY Gold_Sheet__c,Strategic_Player_Role__c ';
        Map<String, Object> strategicPlayerParameters = new Map<String, Object>();
        strategicPlayerParameters.put('goldSheetsIds', goldSheetsIds);
        List<AggregateResult> listStrategicPlayer = DataFactory.read(strategicPlayerQuery, strategicPlayerParameters);
        if (!listStrategicPlayer.isEmpty()) {
            for (AggregateResult rs : listStrategicPlayer) {
                if (mapSPRoleValues.containskey(String.valueOf(rs.get('goldSheetId')))) {
                    mapSPRoleValues.get(String.valueOf(rs.get('goldSheetId')))
                        .put(String.valueOf(rs.get('role')), Integer.valueOf(rs.get('numberOfRecords')));
                } else {
                    Map<String, Decimal> mapRoleValueNew = new Map<String, Decimal>();
                    mapRoleValueNew.put(String.valueOf(rs.get('role')), Integer.valueOf(rs.get('numberOfRecords')));
                    mapSPRoleValues.put(String.valueOf(rs.get('goldSheetId')), mapRoleValueNew);
                }
            }
        }
        //Query the Gold Sheet records and update the corresposnding fields
        String goldsheetQuery = 'SELECT Id,Strategic_Player_Antisponsor__c,Strategic_Player_Coach__c,Strategic_Player_Key_Player__c,Strategic_Player_Sponsor__c FROM Gold_Sheet__c WHERE Id IN :goldSheetsIds';
        Map<String, Object> goldSheetParamters = new Map<String, Object>();
        goldSheetParamters.put('goldSheetsIds', goldSheetsIds);
        List<Gold_Sheet__c> listGoldSheet = DataFactory.read(goldsheetQuery, goldSheetParamters);
        List<Gold_Sheet__c> listUpdateGoldSheet = new List<Gold_Sheet__c>();

        if (listGoldSheet.size() > 0) {
            for (Gold_Sheet__c gs : listGoldSheet) {
                if (mapSPRoleValues.containsKey(gs.Id)) {
                    Map<String, Decimal> dRtValues = mapSPRoleValues.get(gs.Id);
                    gs.Strategic_Player_Sponsor__c = dRtValues.get('Sponsor');
                    if (dRtValues.get('Sponsor') == null) {
                        gs.Strategic_Player_Sponsor__c = 0;
                    }
                    gs.Strategic_Player_Coach__c = dRtValues.get('Strategic Coach');
                    if (dRtValues.get('Strategic Coach') == null) {
                        gs.Strategic_Player_Coach__c = 0;
                    }
                    gs.Strategic_Player_Antisponsor__c = dRtValues.get('Anti Sponsor');
                    if (dRtValues.get('Anti Sponsor') == null) {
                        gs.Strategic_Player_Antisponsor__c = 0;
                    }
                    gs.Strategic_Player_Key_Player__c = dRtValues.get('Additional Key Player');
                    if (dRtValues.get('Additional Key Player') == null) {
                        gs.Strategic_Player_Key_Player__c = 0;
                    }
                } else {
                    gs.Strategic_Player_Sponsor__c = 0;
                    gs.Strategic_Player_Coach__c = 0;
                    gs.Strategic_Player_Antisponsor__c = 0;
                    gs.Strategic_Player_Key_Player__c = 0;
                }
                listUpdateGoldSheet.add(gs);
            }
            if (listUpdateGoldSheet.size() > 0) {
                DataFactory.modify(listUpdateGoldSheet);
            }
        }
    }

    public static void updateRelationshopGoals(List<Relationship_Goal__c> rgRecords) {
        Map<String, Map<String, Decimal>> mapRGStatusValues = new Map<String, Map<String, Decimal>>();
        List<String> goldSheetsIds = new List<String>();
        for (Relationship_Goal__c sp : rgRecords) {
            goldSheetsIds.add(sp.Fields_of_Play_Gold_Sheet__c);
        }
        //Query all the Relationship Goal records with goldsheetId to get the count of each status value

        String relationshipGoalQuery = 'SELECT COUNT(Id) numberOfRecords,Fields_of_Play_Gold_Sheet__c  goldSheetId,Goal_Status__c status FROM Relationship_Goal__c WHERE Fields_of_Play_Gold_Sheet__c  IN :goldSheetsIds GROUP BY Fields_of_Play_Gold_Sheet__c ,Goal_Status__c ';
        Map<String, Object> relationshipGoalParameters = new Map<String, Object>();
        relationshipGoalParameters.put('goldSheetsIds', goldSheetsIds);
        List<AggregateResult> listRelationshipGoal = DataFactory.read(
            relationshipGoalQuery,
            relationshipGoalParameters
        );
        if (!listRelationshipGoal.isEmpty()) {
            for (AggregateResult rs : listRelationshipGoal) {
                if (mapRGStatusValues.containskey(String.valueOf(rs.get('goldSheetId')))) {
                    mapRGStatusValues.get(String.valueOf(rs.get('goldSheetId')))
                        .put(String.valueOf(rs.get('status')), Integer.valueOf(rs.get('numberOfRecords')));
                } else {
                    Map<String, Decimal> mapRoleValueNew = new Map<String, Decimal>();
                    mapRoleValueNew.put(String.valueOf(rs.get('status')), Integer.valueOf(rs.get('numberOfRecords')));
                    mapRGStatusValues.put(String.valueOf(rs.get('goldSheetId')), mapRoleValueNew);
                }
            }
        }
        //Query the Gold Sheet records and update the corresposnding fields

        String goldsheetQuery = 'SELECT Id,Goals_Completed__c,Goals_Incomplete__c FROM Gold_Sheet__c  WHERE Id IN :goldSheetsIds';
        Map<String, Object> goldSheetParamters = new Map<String, Object>();
        goldSheetParamters.put('goldSheetsIds', goldSheetsIds);
        List<Gold_Sheet__c> listGoldSheet = DataFactory.read(goldsheetQuery, goldSheetParamters);
        List<Gold_Sheet__c> listUpdateGoldSheet = new List<Gold_Sheet__c>();
        if (listGoldSheet.size() > 0) {
            for (Gold_Sheet__c gs : listGoldSheet) {
                if (mapRGStatusValues.containsKey(gs.Id)) {
                    Map<String, Decimal> dRtValues = mapRGStatusValues.get(gs.Id);
                    gs.Goals_Completed__c = dRtValues.get('Complete');
                    if (dRtValues.get('Complete') == null) {
                        gs.Goals_Completed__c = 0;
                    }
                    gs.Goals_Incomplete__c = dRtValues.get('Incomplete');
                    if (dRtValues.get('Incomplete') == null) {
                        gs.Goals_Incomplete__c = 0;
                    }
                } else {
                    gs.Goals_Completed__c = 0;
                    gs.Goals_Incomplete__c = 0;
                }
                listUpdateGoldSheet.add(gs);
            }
            if (listUpdateGoldSheet.size() > 0) {
                DataFactory.modify(listUpdateGoldSheet);
            }
        }
    }
    public static void getOpportunityGoldSheetSSoCount(List<Gold_Sheet_Single_Sales_Objective__c> gSSoRecords) {
        Map<String, Decimal> mapgSSOValues = new Map<String, Decimal>();
        List<String> goldSheetsIds = new List<String>();
        for (Gold_Sheet_Single_Sales_Objective__c sso : gSSoRecords) {
            goldSheetsIds.add(sso.Gold_Sheet__c);
        }

        String gSSOQuery = 'SELECT COUNT(Id) numberOfRecords,Gold_Sheet__c goldSheetId FROM Gold_Sheet_Single_Sales_Objective__c where Opportunity__r.IsClosed = false AND Gold_Sheet__c IN :goldSheetsIds GROUP BY Gold_Sheet__c ';
        Map<String, Object> gSSOQueryParameters = new Map<String, Object>();
        gSSOQueryParameters.put('goldSheetsIds', goldSheetsIds);
        List<AggregateResult> listgSSO = DataFactory.read(gSSOQuery, gSSOQueryParameters);
        if (!listgSSO.isEmpty()) {
            for (AggregateResult rs : listgSSO) {
                mapgSSOValues.put(String.valueOf(rs.get('goldSheetId')), Integer.valueOf(rs.get('numberOfRecords')));
            }
        }
        String goldsheetQuery = 'SELECT Id,Count_FOP_Opportunity__c FROM Gold_Sheet__c WHERE Id IN :goldSheetsIds';
        Map<String, Object> goldSheetParamters = new Map<String, Object>();
        goldSheetParamters.put('goldSheetsIds', goldSheetsIds);
        List<Gold_Sheet__c> listGoldSheet = DataFactory.read(goldsheetQuery, goldSheetParamters);
        List<Gold_Sheet__c> listUpdateGoldSheet = new List<Gold_Sheet__c>();

        if (listGoldSheet.size() > 0) {
            for (Gold_Sheet__c gs : listGoldSheet) {
                if (mapgSSOValues.containsKey(gs.Id)) {
                    gs.Count_FOP_Opportunity__c = mapgSSOValues.get(gs.Id);
                } else {
                    gs.Count_FOP_Opportunity__c = 0;
                }
                listUpdateGoldSheet.add(gs);
            }
        }
        if (listUpdateGoldSheet.size() > 0) {
            DataFactory.modify(listUpdateGoldSheet);
        }
    }
    public static void updateRoleFieldStrategicBuySell(List<Strategic_Player__c> spRecords) {
        Map<String, Map<String, Decimal>> mapSPRoleValues = new Map<String, Map<String, Decimal>>();
        List<String> goldSheetsIds = new List<String>();
        for (Strategic_Player__c sp : spRecords) {
            goldSheetsIds.add(sp.Gold_Sheet__c);
        }
        //Query all the Strategic Player records with goldsheetId to get the count of each role value
        String strategicPlayerQuery = 'SELECT COUNT(Id) numberOfRecords,Gold_Sheet__c goldSheetId,Buy_Sell_Position__c buy FROM Strategic_Player__c WHERE Gold_Sheet__c IN :goldSheetsIds GROUP BY Gold_Sheet__c,Buy_Sell_Position__c ';
        Map<String, Object> strategicPlayerParameters = new Map<String, Object>();
        strategicPlayerParameters.put('goldSheetsIds', goldSheetsIds);
        List<AggregateResult> listStrategicPlayer = DataFactory.read(strategicPlayerQuery, strategicPlayerParameters);
        if (!listStrategicPlayer.isEmpty()) {
            for (AggregateResult rs : listStrategicPlayer) {
                if (mapSPRoleValues.containskey(String.valueOf(rs.get('goldSheetId')))) {
                    mapSPRoleValues.get(String.valueOf(rs.get('goldSheetId')))
                        .put(String.valueOf(rs.get('buy')), Integer.valueOf(rs.get('numberOfRecords')));
                } else {
                    Map<String, Decimal> mapRoleValueNew = new Map<String, Decimal>();
                    mapRoleValueNew.put(String.valueOf(rs.get('buy')), Integer.valueOf(rs.get('numberOfRecords')));
                    mapSPRoleValues.put(String.valueOf(rs.get('goldSheetId')), mapRoleValueNew);
                }
            }
        }
        //Query the Gold Sheet records and update the corresposnding fields
        String goldsheetQuery = 'SELECT Id,Strategic_Player_Count__c,Strategic_Player_Level1_Count__c,Strategic_Player_Level2_Count__c,Strategic_Player_Level3_Count__c,Strategic_Player_Level4_Count__c FROM Gold_Sheet__c WHERE Id IN :goldSheetsIds';
        Map<String, Object> goldSheetParamters = new Map<String, Object>();
        goldSheetParamters.put('goldSheetsIds', goldSheetsIds);
        List<Gold_Sheet__c> listGoldSheet = DataFactory.read(goldsheetQuery, goldSheetParamters);
        List<Gold_Sheet__c> listUpdateGoldSheet = new List<Gold_Sheet__c>();

        if (listGoldSheet.size() > 0) {
            for (Gold_Sheet__c gs : listGoldSheet) {
                if (mapSPRoleValues.containsKey(gs.Id)) {
                    Map<String, Decimal> dRtValues = mapSPRoleValues.get(gs.Id);
                    gs.Strategic_Player_Level1_Count__c = dRtValues.get('Level 1: Commodities');
                    if (dRtValues.get('Level 1: Commodities') == null) {
                        gs.Strategic_Player_Level1_Count__c = 0;
                    }
                    gs.Strategic_Player_Level2_Count__c = dRtValues.get(
                        'Level 2: Differentiated Quality Products/Services'
                    );
                    if (dRtValues.get('Level 2: Differentiated Quality Products/Services') == null) {
                        gs.Strategic_Player_Level2_Count__c = 0;
                    }
                    gs.Strategic_Player_Level3_Count__c = dRtValues.get('Level 3: Personalized Services and Support');
                    if (dRtValues.get('Level 3: Personalized Services and Support') == null) {
                        gs.Strategic_Player_Level3_Count__c = 0;
                    }
                    gs.Strategic_Player_Level4_Count__c = dRtValues.get('Level 4: Business Issues');
                    if (dRtValues.get('Level 4: Business Issues') == null) {
                        gs.Strategic_Player_Level4_Count__c = 0;
                    }
                    gs.Strategic_Player_Level5_Count__c = dRtValues.get('Level 5: Organizational Issues');
                    if (dRtValues.get('Level 5: Organizational Issues') == null) {
                        gs.Strategic_Player_Level5_Count__c = 0;
                    }
                    gs.Strategic_Player_Count__c =
                        gs.Strategic_Player_Level1_Count__c +
                        gs.Strategic_Player_Level2_Count__c +
                        gs.Strategic_Player_Level3_Count__c +
                        gs.Strategic_Player_Level4_Count__c +
                        gs.Strategic_Player_Level5_Count__c;
                } else {
                    gs.Strategic_Player_Level1_Count__c = 0;
                    gs.Strategic_Player_Level2_Count__c = 0;
                    gs.Strategic_Player_Level3_Count__c = 0;
                    gs.Strategic_Player_Level4_Count__c = 0;
                    gs.Strategic_Player_Level5_Count__c = 0;
                    gs.Strategic_Player_Count__c = 0;
                }
                listUpdateGoldSheet.add(gs);
            }
            if (listUpdateGoldSheet.size() > 0) {
                DataFactory.modify(listUpdateGoldSheet);
            }
        }
    }
}