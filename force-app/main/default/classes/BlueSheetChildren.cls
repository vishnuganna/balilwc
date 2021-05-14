public with sharing class BlueSheetChildren {
    public static boolean cpInsert = true;
    public static boolean cpUpdate = true;
    public static boolean ssoInsert = true;
    public static boolean ssoUpdate = true;
    public static boolean scInsert = true;
    public static boolean scUpdate = true;

    public static void updateCurrentPosition(List<Current_Position__c> cpRecords) {
        List<String> cpBlueSheetIds = new List<String>();
        for (Current_Position__c cp : cpRecords) {
            cpBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        // Update the Current Position field on the Blue Sheet
        String query = 'Select Id,Name,Current_Position__c FROM Blue_Sheet__c WHERE Id IN:cpBlueSheetIds';
        Map<String, Object> params = new Map<String, Object>();
        params.put('cpBlueSheetIds', cpBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(query, params);
        List<Blue_Sheet__c> updateBS = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            blue.Current_Position__c = cpRecords[0].Current_Position__c;
            updateBS.add(blue);
        }
        if (updateBS.size() > 0) {
            DataFactory.modify(updateBS);
        }
    }

    public static void updateSingleSalesObjective(List<Single_Sales_Objective__c> cpRecords) {
        List<String> cpBlueSheetIds = new List<String>();
        for (Single_Sales_Objective__c cp : cpRecords) {
            cpBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        // Update the Customer Timing for Priorities field on the Blue Sheet
        String query = 'Select Id,Name,Customer_Timing_for_Priorities__c FROM Blue_Sheet__c WHERE Id IN:cpBlueSheetIds';
        Map<String, Object> params = new Map<String, Object>();
        params.put('cpBlueSheetIds', cpBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(query, params);
        List<Blue_Sheet__c> updateBS = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            blue.Customer_Timing_for_Priorities__c = cpRecords[0].Customer_Timing_for_Priorities__c;
            updateBS.add(blue);
        }
        if (updateBS.size() > 0) {
            DataFactory.modify(updateBS);
        }
    }

    public static void updateScores(List<Score_Card__c> cpRecords) {
        List<String> cpBlueSheetIds = new List<String>();
        for (Score_Card__c cp : cpRecords) {
            cpBlueSheetIds.add(cp.Blue_Sheet__c);
        }
        // Update the Scorecard fields on the Blue Sheet
        String query = 'Select Id,Name,Business_Score__c,Opportunity_Score__c,Scorecard_Total__c FROM Blue_Sheet__c WHERE Id IN:cpBlueSheetIds';
        Map<String, Object> params = new Map<String, Object>();
        params.put('cpBlueSheetIds', cpBlueSheetIds);
        List<Blue_Sheet__c> bluesheetList = DataFactory.read(query, params);
        List<Blue_Sheet__c> updateBS = new List<Blue_Sheet__c>();
        for (Blue_Sheet__c blue : bluesheetList) {
            blue.Business_Score__c = cpRecords[0].BusinessCriteria_Score__c;
            blue.Opportunity_Score__c = cpRecords[0].OpportunityCriteria_Score__c;
            blue.Scorecard_Total__c = cpRecords[0].Total_Score__c;
            updateBS.add(blue);
        }
        if (updateBS.size() > 0) {
            DataFactory.modify(updateBS);
        }
    }
}