public with sharing class OpportunityCountOnGoldSheet {
    @AuraEnabled
    public static void countSSOonGoldSheet(List<Gold_Sheet_Single_Sales_Objective__c> ssoList) {
        Map<String, Integer> ssoCountList = new Map<String, Integer>();
        Map<String, Gold_Sheet__c> gsToUpdate = new Map<String, Gold_Sheet__c>();
        try {
            Set<Id> goldIds = new Set<Id>();
            for (Gold_Sheet_Single_Sales_Objective__c goldSSO : ssoList) {
                goldIds.add(goldSSO.Gold_Sheet__c);
            }
            String ssoQuery = 'SELECT Count(Id) sso, Gold_Sheet__c goldSheet FROM Gold_Sheet_Single_Sales_Objective__c WHERE Gold_Sheet__c =:goldIds GROUP BY Gold_Sheet__c';
            Map<String, Object> parameters = new Map<String, Object>();
            parameters.put('goldIds', goldIds);
            List<AggregateResult> listGoldSSO = DataFactory.read(ssoQuery, parameters);
            if (!listGoldSSO.isEmpty()) {
                for (AggregateResult rs : listGoldSSO) {
                    ssoCountList.put(String.valueOf(rs.get('goldSheet')), Integer.valueOf(rs.get('sso')));
                }
                updateGoldSheetSSOCount(ssoCountList);
            }
        } catch (Exception e) {
            throw new OpportunityCountOnGoldSheetException(
                'Error while getting data for Gold Sheet SSO Count on Gold Sheet' + e.getMessage()
            );
        }
    }

    @AuraEnabled
    public static void updateGoldSheetSSOCount(Map<String, Integer> ssoCountList) {
        List<String> goldIdToUpdate = new List<String>();
        List<Gold_Sheet__c> sheetsToUpdate = new List<Gold_Sheet__c>();
        try {
            for (Id ssoCount : ssoCountList.keySet()) {
                goldIdToUpdate.add(ssoCount);
            }
            String ssoGoldQuery = 'Select Id, New_Opportunity_Count__c FROM Gold_Sheet__c WHERE Id IN :goldIdToUpdate';
            Map<String, Object> param = new Map<String, Object>();
            param.put('goldIdToUpdate', goldIdToUpdate);
            List<Gold_Sheet__c> listGolds = DataFactory.read(ssoGoldQuery, param);
            if (!listGolds.isEmpty()) {
                for (Gold_Sheet__c goldOpp : listGolds) {
                    goldOpp.New_Opportunity_Count__c = ssoCountList.get(goldOpp.Id);
                    sheetsToUpdate.add(goldOpp);
                }
            }
            if (!sheetsToUpdate.isEmpty()) {
                DataFactory.upsurt(sheetsToUpdate);
            }
        } catch (Exception e) {
            throw new OpportunityCountOnGoldSheetException(
                'Error while updating Gold Sheet SSO Count on Gold Sheet' + e.getMessage()
            );
        }
    }

    private class OpportunityCountOnGoldSheetException extends Exception {
    }
}