public with sharing class ScoreCard {
    @AuraEnabled
    public static List<scoreCardOpptyWrapper> getAllScoreCard() {
        List<Admin_Score_Card__c> scoreCardAdmin = new List<Admin_Score_Card__c>();
        List<scoreCardOpptyWrapper> scoreCardOpptyWrapper = new List<scoreCardOpptyWrapper>();
        List<scoreCardOpptyWrapper> scoreCardWrapperLanguage = new List<scoreCardOpptyWrapper>();
        Boolean isUpdatable;
        String currentLanguage = UserInfo.getLanguage();
        if (Schema.sObjectType.Admin_Score_Card__c.isUpdateable()) {
            isUpdatable = true;
        }

        String adminScoreQuery =
            'Select Id,Name,Is_Active__c,Is_Default__c,Total_Points__c,Language__c,Admin_Scorecard_Name__c' +
            ' FROM Admin_Score_Card__c WHERE Is_Active__c =True ORDER BY Is_Default__c';

        Map<String, Object> parameters = new Map<String, Object>();
        scoreCardAdmin = DataFactory.read(adminScoreQuery, parameters);
        if (scoreCardAdmin.size() > 0) {
            for (Admin_Score_Card__c admin : scoreCardAdmin) {
                if ((admin.Language__c == currentLanguage) && admin.Is_Default__c == true) {
                    if (!scoreCardOpptyWrapper.isEmpty()) {
                        scoreCardOpptyWrapper.clear();
                    }
                    scoreCardOpptyWrapper wrapper = new scoreCardOpptyWrapper(admin, isUpdatable);
                    scoreCardOpptyWrapper.add(wrapper);
                } else if (
                    (admin.Language__c == 'en_US') &&
                    admin.Is_Default__c == true &&
                    scoreCardOpptyWrapper.isEmpty()
                ) {
                    scoreCardOpptyWrapper wrapperDefault = new scoreCardOpptyWrapper(admin, isUpdatable);
                    scoreCardOpptyWrapper.add(wrapperDefault);
                } else {
                    scoreCardOpptyWrapper wrapperLanguage = new scoreCardOpptyWrapper(admin, isUpdatable);
                    scoreCardWrapperLanguage.add(wrapperLanguage);
                }
            }
            scoreCardOpptyWrapper.addAll(scoreCardWrapperLanguage);
            return scoreCardOpptyWrapper;
        } else {
            throw new AuraHandledException('Unable to find scoreCard record');
        }
    }

    @AuraEnabled
    public static ScoreCardOpptyWrapper getScoreCardTemplateCriteria(String scoreCardId) {
        List<Admin_Scorecard_Criteria__c> listScorecardCriteria = new List<Admin_Scorecard_Criteria__c>();
        scoreCardOpptyWrapper scoreCardOpptyWrapper = new scoreCardOpptyWrapper();

        String criteriaQuery =
            'Select Id,Name,Criteria_Definition__c,Admin_Score_Card__c,Is_Active__c,Section__c,Title__c,Point_Value__c,Order_Number__c' +
            ' FROM Admin_Scorecard_Criteria__c WHERE Is_Active__c =True AND Admin_Score_Card__c =:scoreCardId Order by Order_Number__c asc';

        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('scoreCardId', scoreCardId);
        listScorecardCriteria = DataFactory.read(criteriaQuery, parameters);
        if (listScorecardCriteria.size() > 0) {
            List<scoreCardOpptyWrapper.TemplateCriteria> lstCriteria = new List<scoreCardOpptyWrapper.TemplateCriteria>();
            for (Admin_Scorecard_Criteria__c criteria : listScorecardCriteria) {
                scoreCardOpptyWrapper.TemplateCriteria wrapper = new scoreCardOpptyWrapper.TemplateCriteria();
                wrapper.section = criteria.Section__c;
                wrapper.title = criteria.Title__c;
                wrapper.criteriaDef = criteria.Criteria_Definition__c;
                wrapper.pointValue = criteria.Point_Value__c;
                wrapper.templateCriteriaId = criteria.id;
                lstCriteria.add(wrapper);
            }
            scoreCardOpptyWrapper.templateCriteria = lstCriteria;
            return scoreCardOpptyWrapper;
        } else {
            throw new AuraHandledException('Unable to find scoreCard record');
        }
    }

    @AuraEnabled
    public static void saveScoreCardData(String inputString, String oppId, Integer potentialScore) {
        ScoreCardOpptyWrapper wrapper = (ScoreCardOpptyWrapper) System.JSON.deserialize(
            inputString,
            ScoreCardOpptyWrapper.class
        );
        List<Score_Card__c> listScoreCardToInsert = new List<Score_Card__c>();
        List<Score_Card_Detail__c> listScoreCardDetailsToInsert = new List<Score_Card_Detail__c>();

        String bluesheetQuery = 'SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c =:oppId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('oppId', oppId);
        List<Blue_Sheet__c> bluesheet = DataFactory.read(bluesheetQuery, paramters);

        if (!bluesheet.isEmpty()) {
            if (wrapper.id == null) {
                Score_Card__c scoreCard = new Score_Card__c();
                scoreCard.Blue_Sheet__c = bluesheet[0].Id;
                scoreCard.Potential_Score__c = potentialScore;
                listScoreCardToInsert.add(scoreCard);
                DataFactory.create(listScoreCardToInsert);
            }
            String bluesheetId = bluesheet[0].Id;
            List<Score_Card__c> listScorecard = new List<Score_Card__c>();
            String scorecardQuery = 'SELECT Id from Score_Card__c WHERE Blue_Sheet__c =: bluesheetId';
            listScorecard = DataFactory.read(scorecardQuery, new Map<String, Object>{ 'bluesheetId' => bluesheetId });

            if (!listScorecard.isEmpty()) {
                listScorecard[0].Potential_Score__c = potentialScore;
                for (scoreCardOpptyWrapper.templateCriteria criteria : wrapper.templateCriteria) {
                    Score_Card_Detail__c childScorecardDetail = new Score_Card_Detail__c();
                    if (criteria.id != null) {
                        childScorecardDetail.id = criteria.id;
                    } else {
                        childScorecardDetail.Score_Card__c = listScorecard[0].Id;
                    }
                    childScorecardDetail.Criteria_Definition__c = criteria.criteriaDef;
                    childScorecardDetail.Current_Score__c = criteria.currentScore;
                    childScorecardDetail.Point_Value__c = criteria.pointValue;
                    childScorecardDetail.Score_Value__c = criteria.scoreValue;
                    childScorecardDetail.Title__c = criteria.title;

                    childScorecardDetail.Section__c = criteria.section;
                    listScoreCardDetailsToInsert.add(childScorecardDetail);
                }

                DataFactory.upsurt(listScoreCardDetailsToInsert);
                DataFactory.upsurt(listScorecard);
            }
        }
    }

    /*@AuraEnabled
    public static List < scoreCardOpptyWrapper > getScorecardDetails(String scorecardId) {
        List < Score_Card_Detail__c > listScorecardCriteria = new List < Score_Card_Detail__c > ();
        List < scoreCardOpptyWrapper > scoreCardOpptyWrapper = new List < scoreCardOpptyWrapper > ();
        
        String scorecardQuery = 'Select Id,Name,Criteria_Definition__c,Point_Value__c,Score_Value__c,Title__c,' +
           ' Score_Card__c,Section__c,Score_Card__r.BusinessCriteria_Score__c,Score_Card__r.OpportunityCriteria_Score__c,Score_Card__r.Total_Score__c'+
           ' Score_Card__r.Name,Score_Card__r.Id'
           ' FROM Score_Card_Detail__c WHERE Score_Card__r.Id =:scorecardId';
        
        Map < String, Object > parameters = new Map < String, Object > ();
        parameters.put('scorecardId',scorecardId);
        listScorecardCriteria = DataFactory.read(scorecardQuery, parameters);

        if (listScorecardCriteria.size() > 0) {
            for (Score_Card_Detail__c scorecard: listScorecardCriteria) {
                scoreCardOpptyWrapper wrapper = new scoreCardOpptyWrapper();
                scoreCardOpptyWrapper.add(wrapper);

            }
            return scoreCardOpptyWrapper;
        } else {
         	throw new AuraHandledException('Unable to find scoreCard record');
        }

 	}*/

    @AuraEnabled
    public static scoreCardOpptyWrapper getScoreCardForOppty(String opptyId) {
        Boolean isUpdatable;
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }
        //List < scoreCardOpptyWrapper > scoreCardOpptyWrapper = new List < scoreCardOpptyWrapper > ();
        List<Score_Card__c> scoreCard = new List<Score_Card__c>();
        List<scoreCardOpptyWrapper.templateCriteria> listScorecardDetails = new List<scoreCardOpptyWrapper.templateCriteria>();
        List<Score_Card_Detail__c> listScorecardCriteria = new List<Score_Card_Detail__c>();
        String scoreQuery =
            'Select Id,Name,Blue_Sheet__c,BusinessCriteria_Score__c,OpportunityCriteria_Score__c,Potential_Score__c,Total_Score__c,' +
            ' (Select Id,Point_Value__c,Is_Opportunity_Section__c,Name,Current_Score__c,Score_Value__c,Section__c,Title__c,Criteria_Definition__c FROM Score_Card_Details__r) ' +
            ' FROM Score_Card__c WHERE Blue_Sheet__r.Opportunity__c =:opptyId';

        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('opptyId', opptyId);
        scoreCard = DataFactory.read(scoreQuery, parameters);

        if (!scoreCard.isEmpty()) {
            listScorecardCriteria = scoreCard[0].Score_Card_Details__r;
            scoreCardOpptyWrapper wrapper = new scoreCardOpptyWrapper(scoreCard[0], isUpdatable);
            for (Score_Card_Detail__c detail : listScorecardCriteria) {
                scoreCardOpptyWrapper.templateCriteria criteria = new scoreCardOpptyWrapper.templateCriteria();
                criteria.criteriaDef = detail.Criteria_Definition__c;
                criteria.currentScore = detail.Current_Score__c;
                criteria.pointValue = detail.Point_Value__c;
                criteria.scoreValue = detail.Score_Value__c;
                criteria.title = detail.Title__c;
                criteria.section = detail.Section__c;
                criteria.isOpptySection = detail.Is_Opportunity_Section__c;
                criteria.id = detail.Id;
                listScorecardDetails.add(criteria);
            }
            wrapper.templateCriteria = listScorecardDetails;
            return wrapper;
        } else {
            throw new AuraHandledException('Unable to find scoreCard record');
        }
    }
    @AuraEnabled
    public static void deleteScoreCard(String scoreCardId) {
        List<Score_Card__c> scoreCard = new List<Score_Card__c>();
        String scoreQuery = 'Select Id,Name FROM Score_Card__c WHERE Id =:scoreCardId';

        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('scoreCardId', scoreCardId);
        scoreCard = DataFactory.read(scoreQuery, parameters);
        if (!scoreCard.isEmpty()) {
            DataFactory.remove(scoreCard, true, true, true);
        } else {
            throw new AuraHandledException('Unable to find scoreCard record');
        }
    }
    @AuraEnabled
    public static String getOpptyName(String opptyId) {
        String opptyQuery = 'Select Id,Name FROM Opportunity WHERE Id =:opptyId';

        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('opptyId', opptyId);
        List<Opportunity> opptyData = DataFactory.read(opptyQuery, parameters);
        if (opptyData.size() > 0) {
            String OpptyName = opptyData[0].Name;
            return OpptyName;
        } else {
            throw new AuraHandledException('Unable to find scoreCard record');
        }
    }
}