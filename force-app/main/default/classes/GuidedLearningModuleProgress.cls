public with sharing class GuidedLearningModuleProgress {
    @AuraEnabled
    public static List<MyPositionController.PositionSummaryWrapper> getSummaryOfMPData() {
        String userId = UserInfo.getUserId();
        List<Summary_of_My_Position_Today__c> sompData = new List<Summary_of_My_Position_Today__c>();
        List<MyPositionController.PositionSummaryWrapper> sompWrapDataToReturn = new List<MyPositionController.PositionSummaryWrapper>();
        try {
            string sompQuery = 'select id,Summary__c,Description__c,Is_a_Strength__c,Is_a_Red_Flag__c  from Summary_of_My_Position_Today__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from SOMP section
            sompData = DataFactory.read(sompQuery, paramters);
            for (Summary_of_My_Position_Today__c somp : sompData) {
                MyPositionController.PositionSummaryWrapper wrap = new MyPositionController.PositionSummaryWrapper(
                    somp,
                    null
                );
                sompWrapDataToReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }

        return sompWrapDataToReturn;
    }

    @AuraEnabled
    public static SingleSalesObjectiveController.SingleSalesObjectiveWrapper getSingleSalesObjectData() {
        String userId = UserInfo.getUserId();
        SingleSalesObjectiveController.SingleSalesObjectiveWrapper wrap;
        try {
            string ssoQuery =
                'select id,Customer_Timing_for_Priorities__c, Customers_Stated_Objectives__c,Evaluation_of_Objectives__c' +
                ' from Single_Sales_Objective__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from cometition section
            List<Single_Sales_Objective__c> ssoData = DataFactory.read(ssoQuery, paramters);
            for (Single_Sales_Objective__c somp : ssoData) {
                wrap = new SingleSalesObjectiveController.SingleSalesObjectiveWrapper(somp, null);
                //sompWrapDataToReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }
        return wrap;
    }
    @AuraEnabled
    public static List<BuyingInfluenceWrapperClass> getBuyingInfluenceData() {
        String userId = UserInfo.getUserId();
        List<Buying_Influence__c> biData = new List<Buying_Influence__c>();
        List<BuyingInfluenceWrapperClass> biWrapDataToReturn = new List<BuyingInfluenceWrapperClass>();
        try {
            String biQuery = 'Select Id,Name,Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingState,Contact__r.MailingCountry,Blue_Sheet__c,Business_Results__c,Buying_From_Us__c,Buying_from_Someone_Else__c,Coach__c,Doing_Nothing__c,Economic__c,Even_Keel__c,Growth__c,High__c,Location__c,Low__c,Medium__c,Over_Confident__c,Personal_Wins__c,Rating__c,Rating_Evidence__c,Rating_Text__c,Search_Competitor__r.Name,Technical__c,Title__c,Trouble__c,User__c,Using_Budget_for_Something_Else__c,Using_Internal_Resources__c,Blue_Sheet__r.Opportunity__r.OwnerId  from Buying_Influence__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from Buying Influence section
            biData = DataFactory.read(biQuery, paramters);
            for (Buying_Influence__c bi : biData) {
                BuyingInfluenceWrapperClass wrap = new BuyingInfluenceWrapperClass(bi);
                biWrapDataToReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }

        return biWrapDataToReturn;
    }
    @AuraEnabled
    public static Boolean checkBIforCoach() {
        Boolean coachPresent = false;
        List<BuyingInfluenceWrapperClass> biData = new List<BuyingInfluenceWrapperClass>();
        try {
            biData = GuidedLearningModuleProgress.getBuyingInfluenceData();
            for (BuyingInfluenceWrapperClass biWrap : biData) {
                if (biWrap.coach == true) {
                    coachPresent = true;
                    break;
                }
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }
        return coachPresent;
    }
    @AuraEnabled
    public static Boolean checkBIforDegrees() {
        Boolean degreePresent = false;
        List<BuyingInfluenceWrapperClass> biData = new List<BuyingInfluenceWrapperClass>();
        try {
            biData = GuidedLearningModuleProgress.getBuyingInfluenceData();
            for (BuyingInfluenceWrapperClass biWrap : biData) {
                if (biWrap.high == true || biWrap.medium == true || biWrap.low == true) {
                    degreePresent = true;
                    break;
                }
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }
        return degreePresent;
    }
    @AuraEnabled
    public static Boolean checkBIforModes() {
        Boolean modePresent = false;
        List<BuyingInfluenceWrapperClass> biData = new List<BuyingInfluenceWrapperClass>();
        try {
            biData = GuidedLearningModuleProgress.getBuyingInfluenceData();
            for (BuyingInfluenceWrapperClass biWrap : biData) {
                if (
                    biWrap.growth == true ||
                    biWrap.evenKeel == true ||
                    biWrap.trouble == true ||
                    biWrap.overConfident == true
                ) {
                    modePresent = true;
                    break;
                }
            }
        } catch (Exception e) {
            throw new SGJException('Error occured while getting data');
        }
        return modePresent;
    }
    @AuraEnabled
    public static Boolean checkBIforRatings() {
        Boolean ratingPresent = false;
        List<BuyingInfluenceWrapperClass> biData = new List<BuyingInfluenceWrapperClass>();
        try {
            biData = GuidedLearningModuleProgress.getBuyingInfluenceData();
            for (BuyingInfluenceWrapperClass biWrap : biData) {
                if (biWrap.rating != null && biWrap.rating != '') {
                    ratingPresent = true;
                    break;
                }
            }
        } catch (Exception e) {
            throw new SGJException('Error occured while getting data');
        }
        return ratingPresent;
    }
    @AuraEnabled
    public static Boolean checkScoreCardForDecision() {
        String userId = UserInfo.getUserId();
        Boolean decisionPresent = false;
        List<Score_Card__c> scorecardData = new List<Score_Card__c>();
        List<Score_Card_Detail__c> listScorecardCriteria = new List<Score_Card_Detail__c>();
        try {
            String scoreQuery =
                'Select Id,Name,Blue_Sheet__c,BusinessCriteria_Score__c,OpportunityCriteria_Score__c,Potential_Score__c,Total_Score__c,' +
                ' (Select Id,Point_Value__c,Is_Opportunity_Section__c,Name,Current_Score__c,Score_Value__c,Section__c,Title__c,Criteria_Definition__c FROM Score_Card_Details__r) ' +
                ' FROM Score_Card__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId Order By CreatedDate ASC';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from Scorecard section
            scorecardData = DataFactory.read(scoreQuery, paramters);
            if (!scorecardData.isEmpty()) {
                listScorecardCriteria = scorecardData[0].Score_Card_Details__r;
                for (Score_Card_Detail__c detail : listScorecardCriteria) {
                    if (
                        detail.Score_Value__c != null &&
                        (detail.Score_Value__c == 'Yes' ||
                        detail.Score_Value__c == 'No' ||
                        detail.Score_Value__c == 'Unknown')
                    ) {
                        decisionPresent = true;
                    }
                }
            }
        } catch (Exception e) {
            throw new SGJException('Error occured while getting data');
        }
        return decisionPresent;
    }
    @AuraEnabled
    public static Boolean checkBIforWinOrResults() {
        Boolean winOrResultsPresnt = false;
        List<BuyingInfluenceWrapperClass> biData = new List<BuyingInfluenceWrapperClass>();
        try {
            biData = GuidedLearningModuleProgress.getBuyingInfluenceData();
            for (BuyingInfluenceWrapperClass biWrap : biData) {
                if (
                    (biWrap.personalWins != null && biWrap.personalWins != '') ||
                    (biWrap.businessResults != null &&
                    biWrap.businessResults != '')
                ) {
                    winOrResultsPresnt = true;
                    break;
                }
            }
        } catch (Exception e) {
            throw new SGJException('Error occured while getting data');
        }
        return winOrResultsPresnt;
    }
    @AuraEnabled
    public static Boolean checkCompetitivePreference() {
        String userId = UserInfo.getUserId();
        Boolean competitivePreferencePresent = false;
        List<Competition__c> competitionData = new List<Competition__c>();
        try {
            String competitonQuery =
                'Select Id,Name,Competitior_Name__c,Competitive_Detail__c,Account__c,Account__r.Name,Blue_Sheet__c,Competitor_Type__c,My_Position_Vs_Competitor__c' +
                ' FROM Competition__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from Competition section
            competitionData = DataFactory.read(competitonQuery, paramters);
            for (Competition__c comp : competitionData) {
                if (comp.Competitor_Type__c != null && comp.Competitor_Type__c != '') {
                    competitivePreferencePresent = true;
                }
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }
        return competitivePreferencePresent;
    }
    @AuraEnabled
    public static Boolean checkMyPositionVsCompetitor() {
        String userId = UserInfo.getUserId();
        Boolean myPositionPresent = false;
        List<Competition__c> competitionData = new List<Competition__c>();
        try {
            String competitonQuery =
                'Select Id,Name,Competitior_Name__c,Competitive_Detail__c,Account__c,Account__r.Name,Blue_Sheet__c,Competitor_Type__c,My_Position_Vs_Competitor__c' +
                ' FROM Competition__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from Competition section
            competitionData = DataFactory.read(competitonQuery, paramters);
            for (Competition__c comp : competitionData) {
                if (comp.My_Position_Vs_Competitor__c != null && comp.My_Position_Vs_Competitor__c != '') {
                    myPositionPresent = true;
                }
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }
        return myPositionPresent;
    }
    @AuraEnabled
    public static List<ActionPlanWrapperClass> getActionPlan() {
        String userId = UserInfo.getUserId();
        List<Action_Plan__c> listActionPlan = new List<Action_Plan__c>();
        List<ActionPlanWrapperClass> actionPlanWrapperList = new List<ActionPlanWrapperClass>();
        try {
            String actionPlanQuery =
                ' Select Id,Name,Action_Type__c,AssignedTo__c,AssignedTo__r.Name,Blue_Sheet__c,Contact__c,Contact__r.Name,Description__c,Due_Date__c,Is_a_Best_Action__c' +
                ' ,Priority__c, Start_Date__c,IsProvidingPerspective__c,ProvidingPerspectiveDescription__c,Status__c,Summary__c,User__c,User__r.Name' +
                ' FROM Action_Plan__c WHERE Blue_Sheet__r.Opportunity__r.OwnerId=:userId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('userId', userId);
            //get data from Action Plan section
            listActionPlan = DataFactory.read(actionPlanQuery, paramters);
            for (Action_Plan__c actionPlan : listActionPlan) {
                ActionPlanWrapperClass wrapper = new ActionPlanWrapperClass(actionPlan, null);
                actionPlanWrapperList.add(wrapper);
            }
        } catch (Exception e) {
            throw new SGJException(System.Label.ErrorGettingData);
        }
        return actionPlanWrapperList;
    }
    private class SGJException extends Exception {
    }
}