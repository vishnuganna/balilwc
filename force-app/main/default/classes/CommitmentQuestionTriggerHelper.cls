public with sharing class CommitmentQuestionTriggerHelper {
    public static void updateQuestionCountonGreenSheet(List<Commitment_Question__c> commitmentQuestions) {
        integer countComQuestions = 0;
        set<Id> commitmentIds = new Set<Id>();
        map<String, Integer> greenSheetIdsWithCount = new Map<String, Integer>();

        for (Commitment_Question__c qustn : commitmentQuestions) {
            commitmentIds.add(qustn.Getting_Commitment__c);
        }

        String query = 'SELECT COUNT(Id) numberOfRecords, Getting_Commitment__r.Green_Sheet__c greensheetId FROM Commitment_Question__c WHERE Getting_Commitment__c IN : commitmentIds GROUP BY Getting_Commitment__r.Green_Sheet__c ';
        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('commitmentIds', commitmentIds);
        List<AggregateResult> listCommitmentQuestions = DataFactory.read(query, parameters);
        if (!listCommitmentQuestions.isEmpty()) {
            for (AggregateResult rs : listCommitmentQuestions) {
                if (greenSheetIdsWithCount.containskey(String.valueOf(rs.get('greensheetId')))) {
                    greenSheetIdsWithCount.put(
                        String.valueOf(rs.get('greensheetId')),
                        Integer.valueOf(rs.get('numberOfRecords'))
                    );
                } else {
                    greenSheetIdsWithCount.put(
                        String.valueOf(rs.get('greensheetId')),
                        Integer.valueOf(rs.get('numberOfRecords'))
                    );
                }
            }
            set<String> greensheetIds = greenSheetIdsWithCount.keySet();
            updateQuestionCountonGreenSheet(greenSheetIdsWithCount, greensheetIds);
        }
    }
    public static void updateQuestionCountonGreenSheet(
        Map<String, Integer> greenSheetIdsWithCount,
        set<String> greensheetId
    ) {
        List<Green_Sheet__c> greenSheetToUpdate = new List<Green_Sheet__c>();
        List<Green_Sheet__c> greenSheetList = new List<Green_Sheet__c>();
        String query =
            'SELECT Id, Name,Count_Commitment_Question__c' + ' FROM Green_Sheet__c WHERE Id IN :greensheetId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('greensheetId', greensheetId);
        greenSheetList = DataFactory.read(query, paramters);
        if (!greenSheetList.isEmpty()) {
            for (Green_Sheet__c gs : greenSheetList) {
                if (greenSheetIdsWithCount.get(gs.Id) < 1) {
                    gs.Count_Commitment_Question__c = 0;
                } else {
                    gs.Count_Commitment_Question__c = greenSheetIdsWithCount.get(gs.Id);
                }
                greenSheetToUpdate.add(gs);
            }
        }
        if (greenSheetToUpdate.size() > 0) {
            DataFactory.modify(greenSheetToUpdate);
        }
    }
}