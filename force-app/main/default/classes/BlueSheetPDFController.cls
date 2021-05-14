public with sharing class BlueSheetPDFController {
    public static String PDFData { get; set; }
    public Blue_Sheet__c bluesheet { get; set; }
    public static BlueSheetPDFWrapper blueSheetPDFWrapper { get; set; }

    public BlueSheetPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        blueSheetPDFWrapper = new BlueSheetPDFWrapper();
        String urlVal = Apexpages.currentPage().getUrl();
        Boolean isSocreCardAPI = urlVal.contains('ScorecardA4');
        if (recordId != null) {
            getPDFData(isSocreCardAPI, recordId);
        }
    }

    private static void getPDFData(Boolean isSocreCardAPI, String recordId) {
        if (!isSocreCardAPI) {
            blueSheetPDFWrapper.singleSalesObjectives = getSSORecordsForPDF(recordId);
            blueSheetPDFWrapper.currentPostion = getCurrentPostionPDF(recordId);
            blueSheetPDFWrapper.scoreCard = getScoreCardForBlueSheetPDF(recordId);
            blueSheetPDFWrapper.competitions = getCompetitionForPDF(recordId);
            blueSheetPDFWrapper.buyingInfluences = getBuyingInfluenceForPDF(recordId);
            blueSheetPDFWrapper.positionSummarys = getSOMPRecordsForPDF(recordId);
            blueSheetPDFWrapper.actionPlans = getActionPlanForPDF(recordId);
            blueSheetPDFWrapper.blueSheet = getBlueSheetById(recordId);
            blueSheetPDFWrapper.singleSalesObjective = getSingleSalesObjective(recordId);
            PDFData = JSON.serialize(blueSheetPDFWrapper);
            pdfDownload('Blue Sheet', blueSheetPDFWrapper.blueSheet.opportunityName);
        } else if (isSocreCardAPI) {
            blueSheetPDFWrapper.blueSheet = getBlueSheetById(recordId);
            blueSheetPDFWrapper.scoreCard = getScoreCardForBlueSheetPDF(recordId);
            blueSheetPDFWrapper.singleSalesObjectives = getSSORecordsForPDF(recordId);
            pdfDownload('Score Card', blueSheetPDFWrapper.blueSheet.opportunityName);
        }
    }

    private static void pdfDownload(String pdfName, String oppName) {
        //figure out if we are forcing download or not.
        if (
            System.currentPageReference().getParameters().get('download') != null &&
            System.currentPageReference().getParameters().get('download') == 'true'
        ) {
            //setup a default file name

            // Date dToday = Date.today();
            // String dateStr = dToday.year() + '-' + dToday.month() + '-' + dToday.day();

            string fileName = pdfName + '_' + oppName + '_' + System.now() + '.pdf';
            //here is were the magic happens. We have to set the content disposition as attachment.
            System.currentPageReference().getHeaders().put('content-disposition', 'attachemnt; filename=' + fileName);
        }
    }

    @testVisible
    private static BlueSheetAndOpportunityDataWrapperClass getBlueSheetById(String bluesheetId) {
        BlueSheetAndOpportunityDataWrapperClass blueSheetWrapper = new BlueSheetAndOpportunityDataWrapperClass();
        if (
            Schema.sObjectType.Opportunity.isAccessible() &&
            Schema.sObjectType.Blue_Sheet__c.isAccessible() &&
            Schema.sObjectType.User.isAccessible()
        ) {
            Blue_Sheet__c blueSheetData = [
                SELECT Id, Name, Progress__c, Opportunity__c
                FROM Blue_Sheet__c
                WHERE id = :bluesheetId
                LIMIT 1
            ];
            opportunity objOppt = [
                SELECT Name, CloseDate, Account.Name, Amount, OwnerId, Last_Updated__c, ExpectedRevenue, StageName
                FROM Opportunity
                WHERE id = :blueSheetData.Opportunity__c
                LIMIT 1
            ];
            User user = [SELECT Name FROM User WHERE id = :objOppt.OwnerId LIMIT 1];
            blueSheetWrapper.blueSheetName = blueSheetData.Name;
            blueSheetWrapper.amount = objOppt.Amount;
            blueSheetWrapper.closeDate = objOppt.CloseDate;
            blueSheetWrapper.ownerName = user.Name;
            blueSheetWrapper.opportunityName = objOppt.Name;
            blueSheetWrapper.accountName = objOppt.Account.Name;

            //blueSheetWrapper.bluesheetScorecardLastUpdated = String.valueOf(objOppt.Last_Updated__c);
            blueSheetWrapper.bluesheetScorecardLastUpdated = objOppt.Last_Updated__c;
            blueSheetWrapper.expectedRevenue = objOppt.ExpectedRevenue;
            blueSheetWrapper.stageName = objOppt.StageName;
        }
        return blueSheetWrapper;
    }

    @testVisible
    private static SingleSalesObjectiveController.SingleSalesObjectiveWrapper getSSORecordsForPDF(String bluesheetId) {
        Boolean isUpdatable;
        List<Single_Sales_Objective__c> ssoData = new List<Single_Sales_Objective__c>();
        List<SingleSalesObjectiveController.SingleSalesObjectiveWrapper> ssoWrapDataToReturn = new List<SingleSalesObjectiveController.SingleSalesObjectiveWrapper>();
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }

        try {
            string ssoQuery = 'select id,Customer_Timing_for_Priorities__c, Customers_Stated_Objectives__c,Evaluation_of_Objectives__c from Single_Sales_Objective__c WHERE Blue_Sheet__r.id=:bluesheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('bluesheetId', bluesheetId);
            //get data from cometition section
            ssoData = DataFactory.read(ssoQuery, paramters);
            for (Single_Sales_Objective__c sso : ssoData) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = sso.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                SingleSalesObjectiveController.SingleSalesObjectiveWrapper wrap = new SingleSalesObjectiveController.SingleSalesObjectiveWrapper(
                    sso,
                    isUpdatable
                );
                // wrap.rfsMarkerWrapper = rfsWrapperList;
                wrap.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                ssoWrapDataToReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new SSOException('Error occured while getting data from SSO');
        }

        return ssoWrapDataToReturn.isEmpty() ? null : ssoWrapDataToReturn[0];
    }

    private static Map<String, RedFlagStrengthMarkerWrapper> convertRfsMarkerToPdfWrapper(
        List<RedFlagStrengthMarkerWrapper> rfsWrapperList
    ) {
        Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerMap = new Map<String, RedFlagStrengthMarkerWrapper>();
        for (RedFlagStrengthMarkerWrapper redFlagMarker : rfsWrapperList) {
            rfsMarkerMap.put(redFlagMarker.fieldApiName, redFlagMarker);
        }
        return rfsMarkerMap;
    }

    @testVisible
    private static string getCurrentPostionPDF(string blueSheetId) {
        string currentState = '';

        try {
            List<Current_Position__c> currentPositions = new List<Current_Position__c>();
            String cpQuery = 'Select Current_Position__c, Blue_Sheet__c from Current_Position__c where Blue_Sheet__r.id=:blueSheetId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('blueSheetId', blueSheetId);
            currentPositions = DataFactory.read(cpQuery, paramters);

            if (!currentPositions.isEmpty()) {
                for (Current_Position__c cps : currentPositions) {
                    CurrentPositionWrapper wrapper = new CurrentPositionWrapper(cps);
                    currentState = cps.Current_Position__c;
                }
            }
        } catch (Exception exp) {
            system.debug('Error :' + exp);
        }

        return currentState;
    }

    private static PageReference downloadPDF() {
        System.PageReference pageRef = new System.PageReference('/apex/PDFGenerator');

        //ensure pdf downloads and is assigned with defined name
        pageRef.getHeaders().put('content-disposition', 'attachment; filename=TestPDF.pdf');

        return pageRef;
    }

    @testVisible
    private static scoreCardOpptyWrapper getScoreCardForBlueSheetPDF(String blueSheetId) {
        Boolean isUpdatable;
        scoreCardOpptyWrapper wrapper;
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }
        List<Score_Card__c> scoreCard = new List<Score_Card__c>();
        List<scoreCardOpptyWrapper.templateCriteria> listScorecardDetails = new List<scoreCardOpptyWrapper.templateCriteria>();
        List<Score_Card_Detail__c> listScorecardCriteria = new List<Score_Card_Detail__c>();
        String scoreQuery =
            'Select Id,Name,Blue_Sheet__c,BusinessCriteria_Score__c,OpportunityCriteria_Score__c,Potential_Score__c,Total_Score__c,' +
            ' (Select Id,Point_Value__c,Is_Opportunity_Section__c,Name,Current_Score__c,Score_Value__c,Section__c,Title__c,Criteria_Definition__c FROM Score_Card_Details__r) ' +
            ' FROM Score_Card__c WHERE Blue_Sheet__r.id =:blueSheetId';

        Map<String, Object> parameters = new Map<String, Object>();
        parameters.put('blueSheetId', blueSheetId);
        scoreCard = DataFactory.read(scoreQuery, parameters);

        if (!scoreCard.isEmpty()) {
            listScorecardCriteria = scoreCard[0].Score_Card_Details__r;
            wrapper = new scoreCardOpptyWrapper(scoreCard[0], isUpdatable);
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
        }
        return wrapper;
    }

    @testVisible
    private static List<CompetitionWrapperClass> getCompetitionForPDF(string blueSheetId) {
        List<Competition__c> listCompetition = new List<Competition__c>();
        Boolean isUpdatable;
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }
        List<CompetitionWrapperClass> competitonWrapperListToReturn = new List<CompetitionWrapperClass>();
        try {
            //formation of query
            String competitonQuery =
                'Select Id,Name,Competitior_Name__c,Competitive_Detail__c,Account__c,Account__r.Name,Blue_Sheet__c,Competitor_Type__c,My_Position_Vs_Competitor__c' +
                ' FROM Competition__c WHERE Blue_Sheet__r.id=:blueSheetId ORDER BY createdDate';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('blueSheetId', blueSheetId);
            //get data from cometition section
            listCompetition = DataFactory.read(competitonQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Competition__c competition : listCompetition) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                //rfsWrapperList=getRFSWrapperList(competition);
                String sourceId = competition.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                CompetitionWrapperClass wrapper = new CompetitionWrapperClass(competition, isUpdatable);
                //wrapper.rfsMarkerWrapper = rfsWrapperList;
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                competitonWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new CompetitionException('Error occured while getting data from Competition');
        }
        //return list of wrapper containing all competition data
        return competitonWrapperListToReturn;
    }

    @SuppressWarnings('PMD.NcssMethodCount')
    @testVisible
    private static List<BuyingInfluenceWrapperClass> getBuyingInfluenceForPDF(string blueSheetId) {
        List<Buying_Influence__c> listBI = new List<Buying_Influence__c>();
        List<BuyingInfluenceWrapperClass> biWrapperListToReturn = new List<BuyingInfluenceWrapperClass>();

        try {
            String biQuery = 'Select Id,Name,Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingState,Contact__r.MailingCountry,Blue_Sheet__c,Business_Results__c,Buying_From_Us__c,Buying_from_Someone_Else__c,Coach__c,Doing_Nothing__c,Economic__c,Even_Keel__c,Growth__c,High__c,Location__c,Low__c,Medium__c,Over_Confident__c,Personal_Wins__c,Rating__c,Rating_Evidence__c,Rating_Text__c,Search_Competitor__r.Name,Technical__c,Title__c,Trouble__c,User__c,Using_Budget_for_Something_Else__c,Using_Internal_Resources__c FROM Buying_Influence__c WHERE Blue_Sheet__r.id=:blueSheetId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('blueSheetId', blueSheetId);
            listBI = DataFactory.read(biQuery, paramters);
            for (Buying_Influence__c bi : listBI) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = bi.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                BuyingInfluenceWrapperClass wrapper = new BuyingInfluenceWrapperClass(bi);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                List<String> biRole = new List<String>();
                String biRoleListWithSpaces = '';
                String degree = '-';
                String mode = '-';
                String compPref = '-';
                String perWin = '';
                String busResult = '';
                String rating = '-';
                String evidence = '';
                String busResult1 = '-';
                String busResult2 = '';
                Boolean brMoreText = false;
                Boolean brLessText = false;

                if (bi.Economic__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.Economic__c.getDescribe().getLabel());
                }
                if (bi.Technical__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.Technical__c.getDescribe().getLabel());
                }
                if (bi.Coach__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.Coach__c.getDescribe().getLabel());
                }
                if (bi.User__c == true) {
                    biRole.add(Schema.Buying_Influence__c.fields.User__c.getDescribe().getLabel());
                }
                if (
                    bi.User__c == false &&
                    bi.Coach__c == false &&
                    bi.Technical__c == false &&
                    bi.Economic__c == false
                ) {
                    biRole.add('-');
                }
                biRoleListWithSpaces = String.join(biRole, ', ');
                if (bi.High__c == true) {
                    degree = Schema.Buying_Influence__c.fields.High__c.getDescribe().getLabel();
                }
                if (bi.Low__c == true) {
                    degree = Schema.Buying_Influence__c.fields.Low__c.getDescribe().getLabel();
                }
                if (bi.Medium__c == true) {
                    degree = Schema.Buying_Influence__c.fields.Medium__c.getDescribe().getLabel();
                }

                if (bi.Doing_Nothing__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Doing_Nothing__c.getDescribe().getLabel();
                }
                if (bi.Buying_from_Someone_Else__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Buying_from_Someone_Else__c.getDescribe().getLabel();
                }
                if (bi.Buying_From_Us__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Buying_From_Us__c.getDescribe().getLabel();
                }
                if (bi.Using_Budget_for_Something_Else__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Using_Budget_for_Something_Else__c.getDescribe()
                        .getLabel();
                }
                if (bi.Using_Internal_Resources__c == true) {
                    compPref = Schema.Buying_Influence__c.fields.Using_Internal_Resources__c.getDescribe().getLabel();
                }

                if (bi.Trouble__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Trouble__c.getDescribe().getLabel();
                }
                if (bi.Over_Confident__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Over_Confident__c.getDescribe().getLabel();
                }
                if (bi.Even_Keel__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Even_Keel__c.getDescribe().getLabel();
                }
                if (bi.Growth__c == true) {
                    mode = Schema.Buying_Influence__c.fields.Growth__c.getDescribe().getLabel();
                }

                if (bi.Personal_Wins__c != null) {
                    perWin = bi.Personal_Wins__c;
                }
                if (bi.Rating__c != null) {
                    rating = bi.Rating__c;
                }
                if (bi.Rating_Evidence__c != null) {
                    evidence = bi.Rating_Evidence__c;
                }

                if (bi.Business_Results__c != null) {
                    busResult = bi.Business_Results__c;
                }

                wrapper.biRole = biRole;
                wrapper.biRoleListWithSpaces = biRoleListWithSpaces;
                wrapper.degree = degree;
                wrapper.mode = mode;
                wrapper.compPref = compPref;
                wrapper.businessResults = busResult;

                wrapper.personalWins = perWin;
                wrapper.rating = rating;
                wrapper.ratingEvidence = evidence;

                biWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return biWrapperListToReturn;
    }
    @testVisible
    private static SingleSalesObjectiveBSWrapper getSingleSalesObjective(String recordId) {
        SingleSalesObjectiveBSWrapper data = SingleSalesObjectiveBlueSheet.getSingleSalesObjective(recordId);
        if (data.singleSalesObjectiveBS != null) {
            for (RedFlagStrengthMarkerWrapper flag : data.rfsMarkerWrapper) {
                data.strengthSelected = flag.strengthSelected;
                data.redFlagSelected = flag.redFlagSelected;
            }
        }
        return data;
    }
    @testVisible
    private static PositionSummaryPdfWrapper getSOMPRecordsForPDF(String blueSheetId) {
        Boolean isUpdatable;
        List<Summary_of_My_Position_Today__c> sompData = new List<Summary_of_My_Position_Today__c>();
        PositionSummaryPdfWrapper pdfWrapperPosSummary = new PositionSummaryPdfWrapper();
        List<PositionSummaryDetails> redFlagDetails = new List<PositionSummaryDetails>();
        List<PositionSummaryDetails> strengthDetails = new List<PositionSummaryDetails>();

        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }

        try {
            string sompQuery = 'select id,Summary__c,Description__c,Is_a_Strength__c,Is_a_Red_Flag__c  from Summary_of_My_Position_Today__c WHERE Blue_Sheet__r.id=:blueSheetId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('blueSheetId', blueSheetId);
            //get data from cometition section
            sompData = DataFactory.read(sompQuery, paramters);
            for (Summary_of_My_Position_Today__c somp : sompData) {
                PositionSummaryDetails details = new PositionSummaryDetails(somp);
                if (somp.Is_a_Red_Flag__c) {
                    redFlagDetails.add(details);
                } else {
                    strengthDetails.add(details);
                }
            }
            pdfWrapperPosSummary.redFlags = redFlagDetails;
            pdfWrapperPosSummary.strengths = strengthDetails;
        } catch (Exception e) {
            throw new PSException('Error occured while getting data from ActionPlan');
        }

        return pdfWrapperPosSummary;
    }

    @testVisible
    private static List<ActionPlanWrapperClass> getActionPlanForPDF(string blueSheetId) {
        List<Action_Plan__c> listactionPlan = new List<Action_Plan__c>();
        Boolean isUpdatable;
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }
        List<ActionPlanWrapperClass> actionPlanWrapperListToReturn = new List<ActionPlanWrapperClass>();
        try {
            //formation of query
            String actionPlanQuery =
                ' Select Id,Name,Action_Type__c,AssignedTo__c,AssignedTo__r.Name,Blue_Sheet__c,Contact__c,Contact__r.Name,Description__c,Due_Date__c,Is_a_Best_Action__c' +
                ' ,Priority__c, Start_Date__c,IsProvidingPerspective__c,ProvidingPerspectiveDescription__c,Status__c,Summary__c,User__c,User__r.Name' +
                ' FROM Action_Plan__c WHERE Blue_Sheet__r.id=:blueSheetId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('blueSheetId', blueSheetId);
            //get data from cometition section
            listactionPlan = DataFactory.read(actionPlanQuery, paramters);
            if (listactionPlan != null & !listactionPlan.isEmpty()) {
                listactionPlan = doGroupByAndSorting(listactionPlan);
            }
            //iterate through list to get list of wrapper to return to UI
            for (Action_Plan__c actionPlan : listactionPlan) {
                ActionPlanWrapperClass wrapper = new ActionPlanWrapperClass(actionPlan, isUpdatable);
                actionPlanWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new actionPlanException('Error occured while getting data from actionPlan');
        }
        //return list of wrapper containing all actionPlan data
        return actionPlanWrapperListToReturn;
    }

    // do group by and sorting
    private static List<Action_Plan__c> doGroupByAndSorting(List<Action_Plan__c> apRecLst) {
        /* Sorting order
            Best Action - Non Complete
            Best Action - Complete
            Possible Action - Non Complete
            Possible Action - Complete
            */
        List<Action_Plan__c> finalAPLst = new List<Action_Plan__c>();
        List<Action_Plan__c> bestActionCompleteLst = new List<Action_Plan__c>();
        List<Action_Plan__c> bestActionNonCompleteLst = new List<Action_Plan__c>();
        List<Action_Plan__c> possibleActionCompleteLst = new List<Action_Plan__c>();
        List<Action_Plan__c> possibleActionNonCompleteLst = new List<Action_Plan__c>();

        for (Action_Plan__c apObj : apRecLst) {
            if (apObj.Is_a_Best_Action__c == true) {
                // best action
                if (apObj.status__c == System.Label.Completed) {
                    bestActionCompleteLst.add(apObj);
                } else {
                    bestActionNonCompleteLst.add(apObj);
                }
            } else {
                // possible action
                if (apObj.status__c == System.Label.Completed) {
                    possibleActionCompleteLst.add(apObj);
                } else {
                    possibleActionNonCompleteLst.add(apObj);
                }
            }
        }

        finalAPLst.addAll(bestActionNonCompleteLst);
        finalAPLst.addAll(bestActionCompleteLst);
        finalAPLst.addAll(possibleActionNonCompleteLst);
        finalAPLst.addAll(possibleActionCompleteLst);

        return finalAPLst;
    }

    private class SSOException extends Exception {
    }

    private class CompetitionException extends Exception {
    }

    private class actionPlanException extends Exception {
    }

    private class PSException extends Exception {
    }

    public with sharing class PositionSummaryPdfWrapper {
        public List<PositionSummaryDetails> strengths { get; set; }
        public List<PositionSummaryDetails> redFlags { get; set; }
    }

    public with sharing class PositionSummaryDetails {
        public String summary { get; set; }
        public String description { get; set; }
        public String psId { get; set; }

        public PositionSummaryDetails(Summary_of_My_Position_Today__c somp) {
            this.summary = somp.Summary__c;
            this.description = somp.Description__c;
            this.psId = somp.Id;
        }
    }
}