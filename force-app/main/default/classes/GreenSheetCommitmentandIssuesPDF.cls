public with sharing class GreenSheetCommitmentandIssuesPDF {
    public String greenSheetComponentsPDFData { get; set; }
    public static GreenSheetPDFWrapper greenSheetPDFWrapper { get; set; }

    public GreenSheetCommitmentandIssuesPDF() {
        String recordId = System.currentPageReference().getParameters().get('id');
        greenSheetPDFWrapper = new GreenSheetPDFWrapper();
        if (recordId != null) {
            greenSheetPDFWrapper.gettingCommitment = getGettingCommitmentData(recordId);
            greenSheetPDFWrapper.basicIssues = getBasicIssueRecords(recordId);
            //System.debug('greenSheetPDFWrapper>>>' + greenSheetPDFWrapper);
            greenSheetComponentsPDFData = JSON.serialize(greenSheetPDFWrapper);
        }
    }

    /* Method to fetch Get Commitment data */
    @AuraEnabled
    public static List<GettingCommitmentWrapper> getGettingCommitmentData(String greenSheetId) {
        List<Getting_Commitment__c> gettingCommitmentData = new List<Getting_Commitment__c>();
        List<GettingCommitmentWrapper> commitmentWrapperList = new List<GettingCommitmentWrapper>();

        List<Commitment_Question__c> commitmentQuestionData = new List<Commitment_Question__c>();
        List<CommitmentQuestionWrapper> questionWrapperList = new List<CommitmentQuestionWrapper>();

        try {
            String gettingCommitmentQuery = 'SELECT Id,Name,Green_Sheet__c,Best_Action_Commitment__c,Minimum_Acceptable_Action_Commit__c FROM Getting_Commitment__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            gettingCommitmentData = DataFactory.read(gettingCommitmentQuery, gsParams);

            if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                String commitmentId = gettingCommitmentData[0].id;
                String commitmentQuestionQuery = 'SELECT Id,Name,Getting_Commitment__c,Question__c FROM Commitment_Question__c WHERE Getting_Commitment__c =:commitmentId';
                Map<String, Object> gsParameters = new Map<String, Object>();
                gsParameters.put('commitmentId', commitmentId);
                commitmentQuestionData = DataFactory.read(commitmentQuestionQuery, gsParameters);

                if (commitmentQuestionData != null && !commitmentQuestionData.isEmpty()) {
                    for (Commitment_Question__c cq : commitmentQuestionData) {
                        CommitmentQuestionWrapper quesWrap = new CommitmentQuestionWrapper(cq);
                        List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                        String sourceId = cq.Id;
                        rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                        quesWrap.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                        questionWrapperList.add(quesWrap);
                    }
                }

                for (Getting_Commitment__c gc : gettingCommitmentData) {
                    GettingCommitmentWrapper gcWrap = new GettingCommitmentWrapper(gc);
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                    String sourceId = gc.Id;
                    rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                    gcWrap.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                    gcWrap.questionWrapperList = questionWrapperList;
                    commitmentWrapperList.add(gcWrap);
                }
            }
            //System.debug('commitmentWrapperList>>>' + commitmentWrapperList);
        } catch (Exception ex) {
            throw new GettingCommitmentException('Error occured while getting data from Getting Commitment');
        }
        return commitmentWrapperList;
    }

    /*Method to get Basic Issues Question records*/
    @AuraEnabled
    public static List<BasicIssuesWrapper> getBasicIssueRecords(String greenSheetId) {
        List<Basic_Issues__c> basicIssuesQuestions = new List<Basic_Issues__c>();
        List<BasicIssuesWrapper> basicIssuesQuestionsWrapperListToReturn = new List<BasicIssuesWrapper>();
        try {
            String getIssueQuery = 'SELECT Id, Question_Type__c, Question__c, Green_Sheet__c FROM Basic_Issues__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greenSheetId', greenSheetId);
            //get data from Basic_Issues__c section
            basicIssuesQuestions = DataFactory.read(getIssueQuery, paramters);
            for (Basic_Issues__c basic : basicIssuesQuestions) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = basic.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                BasicIssuesWrapper wrapper = new BasicIssuesWrapper(basic);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                basicIssuesQuestionsWrapperListToReturn.add(wrapper);
            }
            //System.debug('basicIssuesQuestionsWrapperListToReturn>>>' + basicIssuesQuestionsWrapperListToReturn);
        } catch (Exception ex) {
            //system.System.debug('exception ----' + ex);
            throw new GreenSheetBasicIssuesException('Error occured while fetching Basic Issues Questions');
        }
        return basicIssuesQuestionsWrapperListToReturn;
    }

    public static Map<String, RedFlagStrengthMarkerWrapper> convertRfsMarkerToPdfWrapper(
        List<RedFlagStrengthMarkerWrapper> rfsWrapperList
    ) {
        Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerMap = new Map<String, RedFlagStrengthMarkerWrapper>();
        for (RedFlagStrengthMarkerWrapper redFlagMarker : rfsWrapperList) {
            rfsMarkerMap.put(redFlagMarker.fieldApiName, redFlagMarker);
        }
        return rfsMarkerMap;
    }

    private class GettingCommitmentException extends Exception {
    }

    private class GreenSheetBasicIssuesException extends Exception {
    }
}