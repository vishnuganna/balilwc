public with sharing class DeleteBusinessRuleAlerts {
    public static void deleteBusinessRuleAlertForActionPlans(List<Action_Plan__c> actionPlans) {
        set<Id> recordIds = new Set<Id>();
        for (Action_Plan__c action : actionPlans) {
            recordIds.add(action.Id);
        }

        String soql = 'SELECT Id,Name,Action_Plan__c from KF_sell_best__c WHERE Action_Plan__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }
    public static void deleteBusinessRuleAlertForOpportunities(List<Opportunity> opportunities) {
        set<Id> recordIds = new Set<Id>();
        for (Opportunity opty : opportunities) {
            recordIds.add(opty.Id);
        }

        String soql = 'SELECT Id,Name,Opportunity__c from KF_sell_best__c WHERE Opportunity__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }
    public static void deleteBusinessRuleAlertForBuyingInfluence(List<Buying_Influence__c> buyingInfluences) {
        set<Id> recordIds = new Set<Id>();
        for (Buying_Influence__c bi : buyingInfluences) {
            recordIds.add(bi.Id);
        }

        String soql = 'SELECT Id,Name,Buying_Influence__c from KF_sell_best__c WHERE Buying_Influence__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }
    // public static void deleteBusinessRuleAlertForSSO(List<Single_Sales_Objective__c> ssoList) {
    //     set<Id> recordIds = new Set<Id>();
    //     for (Single_Sales_Objective__c sso : ssoList) {
    //         recordIds.add(sso.Id);
    //     }

    //     String soql = 'SELECT Id,Name,Single_Sales_Objective__c from KF_sell_best__c WHERE Single_Sales_Objective__c IN: recordIds';
    //     Map<String, Object> soqlParamMap = new Map<String, Object>();
    //     soqlParamMap.put('recordIds', recordIds);
    //     List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

    //     if (!bestActionList.isEmpty()) {
    //         DataFactory.remove(bestActionList);
    //     }
    // }
    // public static void deleteBusinessRuleAlertForCurrentPosition(List<Current_Position__c> currentPositions) {
    //     set<Id> recordIds = new Set<Id>();
    //     for (Current_Position__c currentPos : currentPositions) {
    //         recordIds.add(currentPos.Id);
    //     }

    //     String soql = 'SELECT Id,Name,Current_Position__c from KF_sell_best__c WHERE Current_Position__c IN: recordIds';
    //     Map<String, Object> soqlParamMap = new Map<String, Object>();
    //     soqlParamMap.put('recordIds', recordIds);
    //     List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

    //     if (!bestActionList.isEmpty()) {
    //         DataFactory.remove(bestActionList);
    //     }
    // }
    public static void deleteBusinessRuleAlertForCompetition(List<Competition__c> competitions) {
        set<Id> recordIds = new Set<Id>();
        for (Competition__c comp : competitions) {
            recordIds.add(comp.Id);
        }

        String soql = 'SELECT Id,Name,Competition__c from KF_sell_best__c WHERE Competition__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }

    public static void deleteBusinessRuleAlertForBluesheet(List<Blue_Sheet__c> bluesheets) {
        set<Id> recordIds = new Set<Id>();
        for (Blue_Sheet__c bs : bluesheets) {
            recordIds.add(bs.Id);
        }

        String soql = 'SELECT Id,Name,Blue_Sheet__c from KF_sell_best__c WHERE Blue_Sheet__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }

    public static void deleteBusinessRuleAlertForGreenSheetBI(List<Green_Sheet_Buying_Influence__c> greensheetBI) {
        set<Id> recordIds = new Set<Id>();
        for (Green_Sheet_Buying_Influence__c bi : greensheetBI) {
            recordIds.add(bi.Id);
        }

        String soql = 'SELECT Id,Name,Green_Sheet_Buying_Influence__c from KF_sell_best__c WHERE Green_Sheet_Buying_Influence__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }

    public static void deleteBusinessRuleAlertForGreenSheet(List<Green_Sheet__c> greensheet) {
        set<Id> recordIds = new Set<Id>();
        for (Green_Sheet__c gs : greensheet) {
            recordIds.add(gs.Id);
        }

        String soql = 'SELECT Id,Name,Green_Sheet__c from KF_sell_best__c WHERE Green_Sheet__c IN: recordIds';
        Map<String, Object> soqlParamMap = new Map<String, Object>();
        soqlParamMap.put('recordIds', recordIds);
        List<KF_sell_best__c> bestActionList = DataFactory.read(soql, soqlParamMap);

        if (!bestActionList.isEmpty()) {
            DataFactory.remove(bestActionList);
        }
    }
}