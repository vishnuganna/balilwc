public with sharing class ClosedWonOpportunityOnGoldSheet {
    public static Boolean ClosedWonOpportunityOnGoldSheetInsertFlag = true;
    public static Boolean ClosedWonOpportunityOnGoldSheetUpdateFlag = true;
    public static Boolean ClosedWonOpportunityOnGoldSheetDeleteFlag = true;

    final private static String STAGE = 'Closed Won';

    @AuraEnabled
    public static void checkIfClosedWon(List<Opportunity> lstOpportunity) {
        Set<Id> accIds = new Set<Id>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        try {
            for (Opportunity opty : lstOpportunity) {
                if (opty.StageName == STAGE && opty.AccountId != null) {
                    accIds.add(opty.AccountId);
                }
            }
            String goldQuery = 'Select Id, Account__c FROM Gold_Sheet__c WHERE Account__c IN :accIds';
            Map<String, Object> param = new Map<String, Object>();
            param.put('accIds', accIds);
            List<Gold_Sheet__c> listGolds = DataFactory.read(goldQuery, param);
            map<Id, List<Gold_Sheet__c>> goldSheetWithAccoutnId = new Map<Id, List<Gold_Sheet__c>>();

            for (Gold_Sheet__c gs : listGolds) {
                if (!goldSheetWithAccoutnId.containsKey(gs.Account__c)) {
                    goldSheetWithAccoutnId.put(gs.Account__c, new List<Gold_Sheet__c>{ gs });
                } else {
                    goldSheetWithAccoutnId.get(gs.Account__c).add(gs);
                }
            }
            for (Opportunity oppo : lstOpportunity) {
                if (
                    !goldSheetWithAccoutnId.isEmpty() &&
                    !goldSheetWithAccoutnId.get(oppo.AccountId).isEmpty() &&
                    oppo.StageName == STAGE
                ) {
                    oppo.Has_an_Associated_GoldSheet__c = true;
                } else {
                    oppo.Has_an_Associated_GoldSheet__c = false;
                }
            }
        } catch (Exception e) {
            throw new ClosedWonOpportunityOnGoldSheetException(
                'Error while checking if Opportunity has an Associated GoldSheet ' + e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static void checkIfClosedWon(List<Gold_Sheet__c> lstGoldsheet) {
        Set<Id> accIds = new Set<Id>();
        for (Gold_Sheet__c goldsheet : lstGoldsheet) {
            accIds.add(goldsheet.Account__c);
        }
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        try {
            String query = 'Select Id, StageName, AccountId FROM Opportunity WHERE StageName =:STAGE AND AccountId IN: accIds';
            Map<String, Object> params = new Map<String, Object>();
            params.put('stage', STAGE);
            params.put('accIds', accIds);
            List<Opportunity> listOpps = DataFactory.read(query, params);

            String goldQuery = 'Select Id, Account__c FROM Gold_Sheet__c WHERE Account__c IN :accIds';
            Map<String, Object> param = new Map<String, Object>();
            param.put('accIds', accIds);
            List<Gold_Sheet__c> listGolds = DataFactory.read(goldQuery, param);

            for (Opportunity oppo : listOpps) {
                if (!listGolds.isEmpty()) {
                    oppo.Has_an_Associated_GoldSheet__c = true;
                } else {
                    oppo.Has_an_Associated_GoldSheet__c = false;
                }
                oppToUpdate.add(oppo);
            }
            if (!oppToUpdate.isEmpty()) {
                DataFactory.upsurt(oppToUpdate);
            }
        } catch (Exception e) {
            throw new ClosedWonOpportunityOnGoldSheetException(
                'Error while checking if Opportunity has an Associated GoldSheet ' + e.getMessage()
            );
        }
    }
    private class ClosedWonOpportunityOnGoldSheetException extends Exception {
    }
}