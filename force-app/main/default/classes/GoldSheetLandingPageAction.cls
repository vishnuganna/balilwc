public with sharing class GoldSheetLandingPageAction {
    public static List<KF_Sell_Best__c> bestActionLstDelete = new List<KF_Sell_Best__c>();
    public void processGoldSheetLastUpdate() {
        String queryMDT = 'SELECT Name__c, Value__c FROM KF_Config__mdt WHERE Name__c =: daysToUpdate ';
        Map<String, Object> paramets = new Map<String, Object>();
        paramets.put('daysToUpdate', 'Gold_Sheet_Last_Updated_Days');
        List<KF_Config__mdt> daysToUpdate = DataFactory.read(queryMDT, paramets);
        String daysTo = daysToUpdate[0].Value__c;
        Integer lastUpdatedThreshold = integer.valueof(daysTo);
        Date filteredDate = system.today().addDays(lastUpdatedThreshold * -1);
        String query = 'SELECT Id, Name, FOP_Name__c, Account__r.Name, Account__r.Id, Last_Updated__c, Account__r.Owner.FirstName, Account__r.Owner.LastName FROM Gold_Sheet__c USING SCOPE team WHERE Last_Updated__c < :filteredDate ';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('filteredDate', filteredDate);
        Set<String> gsIdSet = new Set<String>();
        List<Gold_Sheet__c> gsLst = DataFactory.read(query, paramters);
        for (Gold_Sheet__c gs : gsLst) {
            gsIdSet.add(gs.Id);
        }
        Map<String, KF_Sell_Best__c> mapGSIdnBArec = getBestAction(gsIdSet);
        List<KF_Sell_Best__c> bestActionToInsert = new List<KF_Sell_Best__c>();
        for (Gold_Sheet__c gs : gsLst) {
            KF_Sell_Best__c bestActionRec = mapGSIdnBArec.get(gs.Id);
            if (bestActionRec == null) {
                // Alert not exists, create it
                KF_Sell_Best__c bestAction = new KF_Sell_Best__c();
                bestAction.Fields_of_Play_Gold_Sheet__c = gs.Id;
                bestAction.Action_Title__c = System.Label.UpdatePastDue;
                bestActionToInsert.add(bestAction);
            }
        }
        if (!bestActionToInsert.isEmpty()) {
            DataFactory.create(bestActionToInsert);
        }
    }

    private static Map<String, KF_Sell_Best__c> getBestAction(Set<String> gsIdSet) {
        Map<String, KF_Sell_Best__c> mapGSIdnBArec = new Map<String, KF_Sell_Best__c>();
        Map<String, Object> paramters = new Map<String, Object>();
        String actionTitleType = System.Label.UpdatePastDue;
        String query = 'Select Id,Fields_of_Play_Gold_Sheet__c,Action_Title__c from KF_Sell_Best__c where Fields_of_Play_Gold_Sheet__c =: gsIdSet';
        paramters.put('gsIdSet', gsIdSet);
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c bestactionObj : bestActionLst) {
            if (bestactionObj.Action_Title__c == actionTitleType) {
                mapGSIdnBArec.put(bestactionObj.Fields_of_Play_Gold_Sheet__c, bestactionObj);
            }
        }
        return mapGSIdnBArec;
    }

    public static void deleteBestAction(Map<Id, Gold_Sheet__c> gsMap) {
        // delete all the Best Action record for 'Update Past Due'
        Set<Id> gsIdSet = gsMap.keySet();
        String actionTitleType = System.Label.UpdatePastDue;
        String query = 'Select Id,Action_Title__c from KF_Sell_Best__c where Fields_of_Play_Gold_Sheet__c =: gsIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('gsIdSet', gsIdSet);

        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        List<KF_Sell_Best__c> bestActionLstDelete = new List<KF_Sell_Best__c>();
        for (KF_Sell_Best__c baObj : bestActionLst) {
            if (baObj.Action_Title__c == actionTitleType) {
                bestActionLstDelete.add(baObj);
            }
        }
        if (!bestActionLstDelete.isEmpty()) {
            DataFactory.remove(bestActionLstDelete);
        }
    }

    //Main code for creating Best Actions for ActionPlan Activities in GoldSheet
    public void processGoldSheetActivityDueDate() {
        String query = 'SELECT Id, Name, FOP_Name__c, Account__r.Name, Account__r.Id, Account__r.Owner.FirstName, Account__r.Owner.LastName FROM Gold_Sheet__c USING SCOPE team';
        Map<String, Object> paramters = new Map<String, Object>();
        Set<String> gsIdSet = new Set<String>();
        List<Gold_Sheet__c> gsLst = DataFactory.read(query, paramters);
        for (Gold_Sheet__c gs : gsLst) {
            gsIdSet.add(gs.Id);
        }

        Set<String> infoIdSet = new Set<String>();
        String infoNeededQuery = 'Select Id, Name, Due_Date__c, Information_Needed_Title__c, Fields_of_Play_Gold_Sheet__c, Fields_of_Play_Gold_Sheet__r.FOP_Name__c, Fields_of_Play_Gold_Sheet__r.Account__r.Name, Fields_of_Play_Gold_Sheet__r.Account__r.Owner.FirstName, Fields_of_Play_Gold_Sheet__r.Account__r.Owner.LastName FROM Information_Needed__c WHERE Fields_of_Play_Gold_Sheet__c=:gsIdSet  AND Due_Date__c < TODAY ';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('gsIdSet', gsIdSet);
        List<Information_Needed__c> informationNeededList = DataFactory.read(infoNeededQuery, parameters);
        for (Information_Needed__c informationNeeded : informationNeededList) {
            infoIdSet.add(informationNeeded.Id);
        }
        Set<String> actionIdSet = new Set<String>();
        String actionsQuery = 'Select Id, Name, Due_Date__c, Action_Title__c, Fields_of_Play_Gold_Sheet__c, Fields_of_Play_Gold_Sheet__r.FOP_Name__c, Fields_of_Play_Gold_Sheet__r.Account__r.Name, Fields_of_Play_Gold_Sheet__r.Account__r.Owner.FirstName, Fields_of_Play_Gold_Sheet__r.Account__r.Owner.LastName FROM Action__c WHERE Fields_of_Play_Gold_Sheet__c=:gsIdSet  AND Due_Date__c < TODAY ';
        Map<String, Object> params = new Map<String, Object>();
        params.put('gsIdSet', gsIdSet);
        List<Action__c> actionsList = DataFactory.read(actionsQuery, params);
        for (Action__c action : actionsList) {
            actionIdSet.add(action.Id);
        }
        Set<String> invtIdSet = new Set<String>();
        String invProgQuery = 'Select Id, Name, Due_Date__c, Investment_Program_Title__c, Fields_of_Play_Gold_Sheet__c, Fields_of_Play_Gold_Sheet__r.FOP_Name__c, Fields_of_Play_Gold_Sheet__r.Account__r.Name, Fields_of_Play_Gold_Sheet__r.Account__r.Owner.FirstName, Fields_of_Play_Gold_Sheet__r.Account__r.Owner.LastName FROM Investment_Program__c WHERE Fields_of_Play_Gold_Sheet__c=:gsIdSet AND Due_Date__c < TODAY ';
        Map<String, Object> paramter = new Map<String, Object>();
        paramter.put('gsIdSet', gsIdSet);
        List<Investment_Program__c> invProgList = DataFactory.read(invProgQuery, paramter);
        for (Investment_Program__c invProg : invProgList) {
            invtIdSet.add(invProg.Id);
        }

        Map<String, KF_Sell_Best__c> mapActIdnBArec = getActivityAction(actionIdSet);
        Map<String, KF_Sell_Best__c> mapInfoIdnBArec = getActivityInfoNeeded(infoIdSet);
        Map<String, KF_Sell_Best__c> mapInvstIdnBArec = getActivityInvProg(invtIdSet);
        List<KF_Sell_Best__c> bestActionToInsert = new List<KF_Sell_Best__c>();
        for (Information_Needed__c info : informationNeededList) {
            KF_Sell_Best__c bestActionRec = mapInfoIdnBArec.get(info.Id);
            if (bestActionRec == null) {
                // Alert not exists, create it
                KF_Sell_Best__c bestAction = new KF_Sell_Best__c();
                bestAction.Gold_Sheet_InfoNeeded__c = info.Id;
                bestAction.Action_Title__c = System.Label.UpdateRequired;
                bestAction.Alert_Type__c = 'Gold_Sheet_Activities_Past_Due';
                bestAction.Activity_Due_Date__c = info.Due_Date__c;
                bestAction.Activity_Title__c = info.Information_Needed_Title__c;
                bestAction.Fields_of_Play_Gold_Sheet__c = info.Fields_of_Play_Gold_Sheet__c;
                bestAction.Associated_Object__c = System.Label.InformationNeededDisplay;
                bestActionToInsert.add(bestAction);
            }
        }
        for (Action__c act : actionsList) {
            KF_Sell_Best__c bestActionRec = mapActIdnBArec.get(act.Id);
            if (bestActionRec == null) {
                // Alert not exists, create it
                KF_Sell_Best__c bestAction = new KF_Sell_Best__c();
                bestAction.Gold_Sheet_Action__c = act.Id;
                bestAction.Action_Title__c = System.Label.UpdateRequired;
                bestAction.Alert_Type__c = 'Gold_Sheet_Activities_Past_Due';
                bestAction.Activity_Due_Date__c = act.Due_Date__c;
                bestAction.Activity_Title__c = act.Action_Title__c;
                bestAction.Fields_of_Play_Gold_Sheet__c = act.Fields_of_Play_Gold_Sheet__c;
                bestAction.Associated_Object__c = System.Label.ActionHeaderPDF;
                bestActionToInsert.add(bestAction);
            }
        }
        for (Investment_Program__c inv : invProgList) {
            KF_Sell_Best__c bestActionRec = mapInvstIdnBArec.get(inv.Id);
            if (bestActionRec == null) {
                // Alert not exists, create it
                KF_Sell_Best__c bestAction = new KF_Sell_Best__c();
                bestAction.Gold_Sheet_Investment_Program__c = inv.Id;
                bestAction.Action_Title__c = System.Label.UpdateRequired;
                bestAction.Alert_Type__c = 'Gold_Sheet_Activities_Past_Due';
                bestAction.Activity_Due_Date__c = inv.Due_Date__c;
                bestAction.Activity_Title__c = inv.Investment_Program_Title__c;
                bestAction.Fields_of_Play_Gold_Sheet__c = inv.Fields_of_Play_Gold_Sheet__c;
                bestAction.Associated_Object__c = System.Label.InvestmentProgram;
                bestActionToInsert.add(bestAction);
            }
        }
        if (!bestActionToInsert.isEmpty()) {
            DataFactory.create(bestActionToInsert);
        }
    }

    //To get Action Object KF_Sell_Best record
    private static Map<String, KF_Sell_Best__c> getActivityAction(Set<String> actionIdSet) {
        Map<String, KF_Sell_Best__c> mapActIdnBArec = new Map<String, KF_Sell_Best__c>();
        Map<String, Object> paramters = new Map<String, Object>();
        String actionTitleType = System.Label.UpdateRequired;
        String query = 'Select Id,Gold_Sheet_Action__c, Associated_Object__c, Action_Title__c  from KF_Sell_Best__c where Gold_Sheet_Action__c =: actionIdSet AND Alert_Type__c = \'Gold_Sheet_Activities_Past_Due\'';
        paramters.put('actionIdSet', actionIdSet);
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c bestactionObj : bestActionLst) {
            mapActIdnBArec.put(bestactionObj.Gold_Sheet_Action__c, bestactionObj);
        }
        return mapActIdnBArec;
    }

    public static void updateBestActivityAction(Map<Id, Action__c> actMap) {
        // delete all the Best Action Record for 'Update Past Due'
        Set<Id> actIdSet = actMap.keySet();
        String query = 'Select Id, Activity_Due_Date__c, Gold_Sheet_Action__r.Due_Date__c , Gold_Sheet_Action__c, Action_Title__c,Gold_Sheet_Action__r.Action_Title__c,Date_Completed__c from KF_Sell_Best__c where Gold_Sheet_Action__c =: actIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('actIdSet', actIdSet);
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        List<KF_Sell_Best__c> bestActionLstDelete = new List<KF_Sell_Best__c>();
        List<KF_Sell_Best__c> listToUpdate = new List<KF_Sell_Best__c>();
        for (KF_Sell_Best__c baObj : bestActionLst) {
            if (baObj.Gold_Sheet_Action__r.Due_Date__c >= system.TODAY()) {
                bestActionLstDelete.add(baObj);
            } else {
                baObj.Date_Completed__c = baObj.Gold_Sheet_Action__r.Due_Date__c;
                baObj.Activity_Due_Date__c = baObj.Gold_Sheet_Action__r.Due_Date__c;
                baObj.Activity_Title__c = baObj.Gold_Sheet_Action__r.Action_Title__c;
                listToUpdate.add(baObj);
                DataFactory.upsurt(listToUpdate);
            }
        }
        if (!bestActionLstDelete.isEmpty()) {
            DataFactory.remove(bestActionLstDelete);
        }
    }

    //To delete Action Object KF_Sell_Best record
    public static List<KF_Sell_Best__c> deleteBestActivityAction(Map<Id, Action__c> actMap) {
        // delete all the Best Action record for 'Update Past Due'
        Set<Id> actIdSet = actMap.keySet();
        String query = 'Select Id, Activity_Due_Date__c, Gold_Sheet_Action__r.Due_Date__c , Gold_Sheet_Action__c, Action_Title__c from KF_Sell_Best__c where Gold_Sheet_Action__c =: actIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('actIdSet', actIdSet);

        List<KF_Sell_Best__c> listToDelete = new List<KF_Sell_Best__c>();
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c baObj : bestActionLst) {
            listToDelete.add(baObj);
        }
        GoldSheetLandingPageAction.bestActionLstDelete = listToDelete;
        return listToDelete;
    }

    //To get Information_Needed Object KF_Sell_Best record
    private static Map<String, KF_Sell_Best__c> getActivityInfoNeeded(Set<String> infoIdSet) {
        Map<String, KF_Sell_Best__c> mapInfoIdnBArec = new Map<String, KF_Sell_Best__c>();
        Map<String, Object> paramters = new Map<String, Object>();
        String actionTitleType = System.Label.UpdateRequired;
        String query = 'Select Id, Gold_Sheet_InfoNeeded__c, Associated_Object__c, Action_Title__c from KF_Sell_Best__c where Gold_Sheet_InfoNeeded__c =: infoIdSet  AND Alert_Type__c = \'Gold_Sheet_Activities_Past_Due\'';
        paramters.put('infoIdSet', infoIdSet);
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c bestactionObj : bestActionLst) {
            mapInfoIdnBArec.put(bestactionObj.Gold_Sheet_InfoNeeded__c, bestactionObj);
        }
        return mapInfoIdnBArec;
    }

    public static void updateBestActivityInfoNeeded(Map<Id, Information_Needed__c> infoMap) {
        // delete all the Best Action record for 'Update Past Due'
        Set<Id> infoIdSet = infoMap.keySet();
        String query = 'Select Id, Action_Title__c, Gold_Sheet_InfoNeeded__c, Activity_Due_Date__c, Gold_Sheet_InfoNeeded__r.Due_Date__c,Gold_Sheet_InfoNeeded__r.Information_Needed_Title__c,Date_Completed__c from KF_Sell_Best__c where Gold_Sheet_InfoNeeded__c =: infoIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('infoIdSet', infoIdSet);

        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        List<KF_Sell_Best__c> listToUpdate = new List<KF_Sell_Best__c>();
        List<KF_Sell_Best__c> bestActionLstDelete = new List<KF_Sell_Best__c>();
        for (KF_Sell_Best__c baObj : bestActionLst) {
            if (baObj.Gold_Sheet_InfoNeeded__r.Due_Date__c >= system.TODAY()) {
                bestActionLstDelete.add(baObj);
            } else {
                baObj.Date_Completed__c = baObj.Gold_Sheet_InfoNeeded__r.Due_Date__c;
                baObj.Activity_Due_Date__c = baObj.Gold_Sheet_InfoNeeded__r.Due_Date__c;
                baObj.Activity_Title__c = baObj.Gold_Sheet_InfoNeeded__r.Information_Needed_Title__c;
                listToUpdate.add(baObj);
                DataFactory.upsurt(listToUpdate);
            }
        }
        if (!bestActionLstDelete.isEmpty()) {
            DataFactory.remove(bestActionLstDelete);
        }
    }

    //To delete Information_Needed Object KF_Sell_Best record
    public static List<KF_Sell_Best__c> deleteBestActivityInfoNeeded(Map<Id, Information_Needed__c> infoMap) {
        // delete all the Best Action record for 'Update Past Due'
        Set<Id> infoIdSet = infoMap.keySet();
        String query = 'Select Id, Action_Title__c, Gold_Sheet_InfoNeeded__c, Activity_Due_Date__c, Gold_Sheet_InfoNeeded__r.Due_Date__c from KF_Sell_Best__c where Gold_Sheet_InfoNeeded__c =: infoIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('infoIdSet', infoIdSet);

        List<KF_Sell_Best__c> listToDelete = new List<KF_Sell_Best__c>();
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c baObj : bestActionLst) {
            listToDelete.add(baObj);
        }
        GoldSheetLandingPageAction.bestActionLstDelete = listToDelete;
        return listToDelete;
    }

    //To get Investment_Program Object KF_Sell_Best record
    private static Map<String, KF_Sell_Best__c> getActivityInvProg(Set<String> invtIdSet) {
        Map<String, KF_Sell_Best__c> mapInvstIdnBArec = new Map<String, KF_Sell_Best__c>();
        Map<String, Object> paramters = new Map<String, Object>();
        String actionTitleType = System.Label.UpdateRequired;
        String query = 'Select Id, Associated_Object__c, Gold_Sheet_Investment_Program__c, Action_Title__c from KF_Sell_Best__c where Gold_Sheet_Investment_Program__c =: invtIdSet  AND Alert_Type__c = \'Gold_Sheet_Activities_Past_Due\'';
        paramters.put('invtIdSet', invtIdSet);
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c bestactionObj : bestActionLst) {
            mapInvstIdnBArec.put(bestactionObj.Gold_Sheet_Investment_Program__c, bestactionObj);
        }
        return mapInvstIdnBArec;
    }

    public static void updateBestActivityInvProg(Map<Id, Investment_Program__c> invstMap) {
        // delete all the Best Action record for 'Update Past Due'
        Set<Id> invstIdSet = invstMap.keySet();
        String query = 'Select Id, Action_Title__c, Gold_Sheet_Investment_Program__c, Activity_Due_Date__c, Gold_Sheet_Investment_Program__r.Due_Date__c,Gold_Sheet_Investment_Program__r.Investment_Program_Title__c,Date_Completed__c from KF_Sell_Best__c where Gold_Sheet_Investment_Program__c =: invstIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('invstIdSet', invstIdSet);

        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        List<KF_Sell_Best__c> listToUpdate = new List<KF_Sell_Best__c>();
        List<KF_Sell_Best__c> bestActionLstDelete = new List<KF_Sell_Best__c>();
        for (KF_Sell_Best__c baObj : bestActionLst) {
            if (baObj.Gold_Sheet_Investment_Program__r.Due_Date__c >= system.TODAY()) {
                bestActionLstDelete.add(baObj);
            } else {
                baObj.Date_Completed__c = baObj.Gold_Sheet_Investment_Program__r.Due_Date__c;
                baObj.Activity_Due_Date__c = baObj.Gold_Sheet_Investment_Program__r.Due_Date__c;
                baObj.Activity_Title__c = baObj.Gold_Sheet_Investment_Program__r.Investment_Program_Title__c;
                listToUpdate.add(baObj);
                DataFactory.upsurt(listToUpdate);
            }
        }
        if (!bestActionLstDelete.isEmpty()) {
            DataFactory.remove(bestActionLstDelete);
        }
    }

    //To delete Investment_Program Object KF_Sell_Best record
    public static List<KF_Sell_Best__c> deleteBestActivityInvProg(Map<Id, Investment_Program__c> invstMap) {
        // delete all the Best Action record for 'Update Past Due'
        Set<Id> invstIdSet = invstMap.keySet();
        String query = 'Select Id, Action_Title__c, Gold_Sheet_Investment_Program__c, Activity_Due_Date__c, Gold_Sheet_Investment_Program__r.Due_Date__c from KF_Sell_Best__c where Gold_Sheet_Investment_Program__c =: invstIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('invstIdSet', invstIdSet);

        List<KF_Sell_Best__c> listToDelete = new List<KF_Sell_Best__c>();
        List<KF_Sell_Best__c> bestActionLst = DataFactory.read(query, paramters);
        for (KF_Sell_Best__c baObj : bestActionLst) {
            listToDelete.add(baObj);
        }
        GoldSheetLandingPageAction.bestActionLstDelete = listToDelete;
        return listToDelete;
    }

    // delete method which will delete the KF_Sell_Best__c record
    public static void deleteBestActionRecord() {
        if (!GoldSheetLandingPageAction.bestActionLstDelete.isEmpty()) {
            DataFactory.remove(GoldSheetLandingPageAction.bestActionLstDelete);
        }
    }
}