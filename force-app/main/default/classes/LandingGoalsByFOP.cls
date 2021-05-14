public with sharing class LandingGoalsByFOP {
    @AuraEnabled
    public static void getGoalCountForFOP(List<Relationship_Goal__c> goals) {
        Map<String, Integer> mapGoalsToGoldToReturn = new Map<String, Integer>();
        List<String> goldIdSet = new List<String>();
        for (Relationship_Goal__c goal : goals) {
            goldIdSet.add(goal.Fields_of_Play_Gold_Sheet__c);
        }
        String goalQuery = 'SELECT COUNT(Id) numberOfRecords, Fields_of_Play_Gold_Sheet__c goldSheetId FROM Relationship_Goal__c WHERE Fields_of_Play_Gold_Sheet__c IN :goldIdSet GROUP BY Fields_of_Play_Gold_Sheet__c ';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('goldIdSet', goldIdSet);
        List<AggregateResult> listRelationshipGoal = DataFactory.read(goalQuery, parameters);
        if (!listRelationshipGoal.isEmpty()) {
            for (AggregateResult rs : listRelationshipGoal) {
                if (mapGoalsToGoldToReturn.containskey(String.valueOf(rs.get('goldSheetId')))) {
                    mapGoalsToGoldToReturn.put(
                        String.valueOf(rs.get('goldSheetId')),
                        Integer.valueOf(rs.get('numberOfRecords'))
                    );
                } else {
                    mapGoalsToGoldToReturn.put(
                        String.valueOf(rs.get('goldSheetId')),
                        Integer.valueOf(rs.get('numberOfRecords'))
                    );
                }
            }
            updateGoalCountforFOP(mapGoalsToGoldToReturn, goldIdSet);
        }
    }

    @AuraEnabled
    public static void updateGoalCountforFOP(Map<String, Integer> mapGoalsToGoldToReturn, List<String> goldIdSet) {
        List<Gold_Sheet__c> goldPresent = new List<Gold_Sheet__c>();
        List<Gold_Sheet__c> goldSheetList = new List<Gold_Sheet__c>();
        String query =
            'SELECT Id, FOP_Name__c, Owner.Name, OwnerId, Goals_Completed__c, Goals_Present__c, Account__r.Name, Account__c' +
            ' FROM Gold_Sheet__c WHERE Id IN :goldIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('goldIdSet', goldIdSet);
        goldSheetList = DataFactory.read(query, paramters);
        if (!goldSheetList.isEmpty()) {
            for (Gold_Sheet__c gs : goldSheetList) {
                if (mapGoalsToGoldToReturn.get(gs.Id) < 1) {
                    gs.Goals_Present__c = 0;
                } else {
                    gs.Goals_Present__c = mapGoalsToGoldToReturn.get(gs.Id);
                }
                goldPresent.add(gs);
            }
        }
        if (goldPresent.size() > 0) {
            DataFactory.modify(goldPresent);
        }
    }

    private class LandingGoalsByFOPException extends Exception {
    }
}