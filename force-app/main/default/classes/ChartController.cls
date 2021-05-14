@SuppressWarnings('PMD.NcssMethodCount')
public with sharing class ChartController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<OpportunityWithScorecardWrapper>> getAllOpportunitiesWithScorecard() {
        List<OpportunityWithScorecardWrapper> scorecardOptyWrapperList = new List<OpportunityWithScorecardWrapper>();
        List<Score_Card__c> scorecardList = new List<Score_Card__c>();
        List<Opportunity> optyList = new List<Opportunity>();
        Map<String, List<OpportunityWithScorecardWrapper>> opportuntiesPerStage = new Map<String, List<OpportunityWithScorecardWrapper>>();
        Map<String, OpportunityWithScorecardWrapper.ScorecardWrapper> bluesheetScorecardMap = new Map<String, OpportunityWithScorecardWrapper.ScorecardWrapper>();
        Decimal radiusFactor = 1.0;
        Decimal optyRadius = 20;
        Decimal reducingFactor = optyRadius - 3;
        Decimal lastOptyAmount = 0.0;
        Decimal currentOptyAmount = 0.0;
        Map<String, Integer> countOptyPerStage = new Map<String, Integer>();
        Map<String, Decimal> optyRevenuePerStage = new Map<String, Decimal>();
        String userId = UserInfo.getUserId();
        try {
            String query = 'SELECT Id, Name, Blue_Sheet__c,Blue_Sheet__r.Opportunity__c,BusinessCriteria_Score__c,OpportunityCriteria_Score__c,Potential_Score__c,Total_Score__c FROM Score_Card__c';
            Map<String, Object> params = new Map<String, Object>();
            scorecardList = DataFactory.read(query, params);
            if (scorecardList != null && !scorecardList.isEmpty()) {
                for (Score_Card__c scoreCard : scorecardList) {
                    OpportunityWithScorecardWrapper.ScorecardWrapper wrapper = new OpportunityWithScorecardWrapper.ScorecardWrapper(
                        scoreCard
                    );
                    bluesheetScorecardMap.put(scoreCard.Blue_Sheet__r.Opportunity__c, wrapper);
                }
            }

            List<OpportunityStage> stages = new List<OpportunityStage>();
            String queryStage = 'SELECT MasterLabel FROM OpportunityStage WHERE IsClosed = FALSE';
            Map<String, Object> stageParams = new Map<String, Object>();
            stages = DataFactory.read(queryStage, stageParams);
            List<String> optyStageValues = new List<String>();
            for (OpportunityStage st : stages) {
                optyStageValues.add(st.MasterLabel);
            }

            String optyQuery = 'SELECT Id, Name, Amount, Probability, StageName, Stage_Last_ModifiedOn__c,Blue_Sheet__c,owner.ManagerId FROM Opportunity WHERE StageName IN: optyStageValues AND (owner.ManagerId =: userId OR ownerId =: userId) ORDER BY Amount DESC';
            Map<String, Object> paramsOpty = new Map<String, Object>();
            paramsOpty.put('optyStageValues', (object) optyStageValues);
            paramsOpty.put('userId', userId);
            optyList = DataFactory.read(optyQuery, paramsOpty);
            if (!optyList.isEmpty()) {
                Integer totalNumberOfOpty = optyList.size();
                if (totalNumberOfOpty < reducingFactor) {
                    radiusFactor = reducingFactor / totalNumberOfOpty;
                } else {
                    radiusFactor = totalNumberOfOpty / reducingFactor;
                }
                for (Opportunity opty : optyList) {
                    if (!countOptyPerStage.containsKey(opty.StageName)) {
                        Integer count = 1;
                        countOptyPerStage.put(opty.StageName, count);
                    } else {
                        Integer count = countOptyPerStage.get(opty.StageName) + 1;
                        countOptyPerStage.put(opty.StageName, count);
                    }
                    if (!optyRevenuePerStage.containsKey(opty.StageName)) {
                        Decimal revenue = opty.Amount != null &&
                            opty.Probability != null
                            ? (opty.Amount * opty.Probability) / 100
                            : 0.0;
                        optyRevenuePerStage.put(opty.StageName, revenue);
                    } else {
                        Decimal currentAmount = opty.Amount != null &&
                            opty.Probability != null
                            ? (opty.Amount * opty.Probability) / 100
                            : 0.0;
                        Decimal revenue = optyRevenuePerStage.get(opty.StageName) + currentAmount;
                        optyRevenuePerStage.put(opty.StageName, revenue);
                    }
                }
            }
            if (optyList != null && !optyList.isEmpty()) {
                lastOptyAmount = optyList[0].Amount;
                for (Opportunity opty : optyList) {
                    OpportunityWithScorecardWrapper optyWrap = new OpportunityWithScorecardWrapper(opty);
                    if (bluesheetScorecardMap != null && !bluesheetScorecardMap.isEmpty()) {
                        optyWrap.scorecard = bluesheetScorecardMap.get(optyWrap.Id) != null
                            ? bluesheetScorecardMap.get(optyWrap.Id)
                            : null;
                        optyWrap.scorecardTotalScore = optyWrap.scorecard != null ? optyWrap.scorecard.totalScore : 0.0;
                    } else {
                        optyWrap.scorecardTotalScore = 0.0;
                    }
                    if (optyWrap.opportunityAmount != null && optyWrap.opportunityAmount != 0.0) {
                        currentOptyAmount = optyWrap.opportunityAmount;
                        if (lastOptyAmount != currentOptyAmount) {
                            optyRadius = optyRadius - radiusFactor;
                            lastOptyAmount = currentOptyAmount;
                        }
                        optyWrap.opportunityRadius = optyRadius;
                    }

                    Integer optyCount = countOptyPerStage.get(opty.StageName);
                    Decimal optyRevenue = optyRevenuePerStage.get(opty.StageName);

                    optyWrap.countOptyPerStage = optyCount;
                    optyWrap.optyRevenuePerStage = optyRevenue;
                    //optyWrap.optyStages = optyStageValues;
                    if (opty.Stage_Last_ModifiedOn__c == null) {
                        optyWrap.daysInStage = '';
                    } else {
                        Date stageUpdatedDate = Date.valueOf(opty.Stage_Last_ModifiedOn__c);
                        Date dateToday = Date.today();
                        optyWrap.daysInStage = String.valueOf(stageUpdatedDate.daysBetween(dateToday));
                    }
                    if (opty.Blue_Sheet__c != null) {
                        optyWrap.isConnectedToBluesheet = true;
                    } else {
                        optyWrap.isConnectedToBluesheet = false;
                    }
                    //scorecardOptyWrapperList.add(optyWrap);

                    if (!opportuntiesPerStage.containsKey(optyWrap.opportunityStage)) {
                        opportuntiesPerStage.put(
                            optyWrap.opportunityStage,
                            new List<OpportunityWithScorecardWrapper>{ optyWrap }
                        );
                    } else {
                        opportuntiesPerStage.get(optyWrap.opportunityStage).add(optyWrap);
                    }
                }
            }
        } catch (Exception e) {
            system.System.debug('exception line----' + e.getLineNumber());
            throw new ChartException(e.getMessage());
        }
        return opportuntiesPerStage;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> opportunityOpenStatus() {
        try {
            List<OpportunityStage> stages = new List<OpportunityStage>();
            String queryStage = 'SELECT MasterLabel FROM OpportunityStage WHERE IsClosed = FALSE';
            Map<String, Object> stageParams = new Map<String, Object>();
            stages = DataFactory.read(queryStage, stageParams);
            List<String> optyStageValues = new List<String>();
            for (OpportunityStage st : stages) {
                optyStageValues.add(st.MasterLabel);
            }
            return optyStageValues;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private class ChartException extends Exception {
    }
}