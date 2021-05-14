public with sharing class GettingCommitment {
    //Method to fetch commitment data
    public static boolean lastUpdatedDate = true;
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
                        quesWrap.rfsMarkerWrapper = rfsWrapperList;
                        questionWrapperList.add(quesWrap);
                    }
                }

                for (Getting_Commitment__c gc : gettingCommitmentData) {
                    GettingCommitmentWrapper gcWrap = new GettingCommitmentWrapper(gc);
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                    String sourceId = gc.Id;
                    rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                    gcWrap.rfsMarkerWrapper = rfsWrapperList;
                    gcWrap.questionWrapperList = questionWrapperList;
                    commitmentWrapperList.add(gcWrap);
                }
            }
        } catch (Exception ex) {
            throw new GettingCommitmentException('Error occured while getting data from Getting Commitment');
        }
        return commitmentWrapperList;
    }

    //Method to upsert Commitment Question record
    @SuppressWarnings('PMD.NcssMethodCount')
    @AuraEnabled
    public static void upsertCommitmentQuestion(
        String jsonString,
        String greenSheetId,
        Map<String, Map<String, Object>> rfsMap
    ) {
        CommitmentQuestionWrapper questionWrapper = (CommitmentQuestionWrapper) JSON.deserialize(
            jsonString,
            CommitmentQuestionWrapper.class
        );
        List<Getting_Commitment__c> gettingCommitmentData = new List<Getting_Commitment__c>();
        List<Database.SaveResult> srList;
        List<Database.UpsertResult> srQuesList;
        String questionId = questionWrapper.id;
        // String commitmentId = questionWrapper.gettingCommitment;
        String commitmentId;
        List<Commitment_Question__c> commitmentQuestionList;
        List<Getting_Commitment__c> gettingCommitmentList;

        try {
            String gettingCommitmentQuery = 'SELECT Id,Name,Green_Sheet__c FROM Getting_Commitment__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            gettingCommitmentData = DataFactory.read(gettingCommitmentQuery, gsParams);

            if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                commitmentId = gettingCommitmentData[0].id;
            }

            if (questionId != null && questionId != '' && commitmentId != null && commitmentId != '') {
                // Update CommitmentQuestion
                //System.debug('questionId not null>>' + questionId);
                //System.debug('commitmentId not null>>' + commitmentId);
                commitmentQuestionList = new List<Commitment_Question__c>();
                Commitment_Question__c question = new Commitment_Question__c();
                question.Id = questionWrapper.id;
                // question.Getting_Commitment__c = commitmentId;
                question.Question__c = questionWrapper.commitmentQuestion;
                commitmentQuestionList.add(question);
                srQuesList = DataFactory.upsurt(commitmentQuestionList);
            } else if ((questionId == null || questionId == '') && commitmentId != null && commitmentId != '') {
                // Create CommitmentQuestion to an existing commitment
                //System.debug('questionId null>>' + questionId);
                //System.debug('commitmentId not null>>' + commitmentId);
                commitmentQuestionList = new List<Commitment_Question__c>();
                Commitment_Question__c question = new Commitment_Question__c();
                question.Getting_Commitment__c = commitmentId;
                question.Question__c = questionWrapper.commitmentQuestion;
                commitmentQuestionList.add(question);
                srQuesList = DataFactory.upsurt(commitmentQuestionList);
            } else {
                // Create CommitmentQuestion when there is no existing commitment
                //System.debug('questionId null>>' + questionId);
                //System.debug('commitmentId null>>' + commitmentId);
                gettingCommitmentList = new List<Getting_Commitment__c>();
                Getting_Commitment__c gettingCommitment = new Getting_Commitment__c();
                gettingCommitment.Green_Sheet__c = greenSheetId;
                gettingCommitmentList.add(gettingCommitment);
                srList = DataFactory.create(gettingCommitmentList);

                //System.debug('questionWrapper>>' + questionWrapper);
                //System.debug('commitmentId>>' + commitmentId);
                //System.debug('questionWrapper.commitmentQuestion>>' + questionWrapper.commitmentQuestion);
                commitmentQuestionList = new List<Commitment_Question__c>();
                //   if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                if (srList != null && !srList.isEmpty() && srList[0].success == true) {
                    Commitment_Question__c question = new Commitment_Question__c(
                        Getting_Commitment__c = srList[0].id,
                        Question__c = questionWrapper.commitmentQuestion
                    );
                    // question.Question__c = questionWrapper.commitmentQuestion;
                    commitmentQuestionList.add(question);
                }
            }

            // Red Flag & strength create/update
            if (srList != null && !srList.isEmpty() && srList[0].isSuccess()) {
                srQuesList = DataFactory.upsurt(commitmentQuestionList);
            }

            if (srQuesList != null && !srQuesList.isEmpty() && srQuesList[0].isSuccess()) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                // Flag code
                // Operation was successful, so get the ID of the record that was processed
                String sourceId = srQuesList[0].getId();
                //System.debug('sourceId>>' + sourceId);
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);

                String objectName = util.getNamespaceWithUnderScores() == ''
                    ? 'Commitment_Question__c'
                    : util.getNamespaceWithUnderScores() + 'Commitment_Question__c';

                if (rfsWrapperList != null && !rfsWrapperList.isEmpty()) {
                    ApexCommonUtil.convertMarkerMap(rfsWrapperList, rfsMap);
                    rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectName,
                        sourceId,
                        sourceId,
                        rfsMap
                    );
                } else {
                    List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
                        sourceId,
                        objectName,
                        rfsMap
                    );
                    DataFactory.create(markerList);

                    List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                    for (Red_Flag_Strength_Marker__c marker : markerList) {
                        marker.Source_ID__c = srQuesList[0].getId();
                        markerListUpdated.add(marker);
                    }
                    DataFactory.modify(markerListUpdated);
                }
            }
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GettingCommitmentException('Error occured while upserting Commitment Question record');
        }
    }

    //Method to upsert Best Action Commitment record
    @AuraEnabled
    public static void upsertBestActionCommitment(String jsonString, Map<String, Map<String, Object>> rfsMap) {
        GettingCommitmentWrapper gcWrapper = (GettingCommitmentWrapper) JSON.deserialize(
            jsonString,
            GettingCommitmentWrapper.class
        );
        List<Database.UpsertResult> srList;
        List<Getting_Commitment__c> gettingCommitmentData = new List<Getting_Commitment__c>();
        String greenSheetId = gcWrapper.greenSheet;
        // String gcId = gcWrapper.Id;
        List<Getting_Commitment__c> gettingCommitmentList = new List<Getting_Commitment__c>();

        try {
            String gettingCommitmentQuery = 'SELECT Id,Name,Green_Sheet__c FROM Getting_Commitment__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            gettingCommitmentData = DataFactory.read(gettingCommitmentQuery, gsParams);

            if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                // Update or Create BestActionCommitment on Existing Commitment record
                Getting_Commitment__c gc = new Getting_Commitment__c();
                gc.Id = gettingCommitmentData[0].id;
                // gc.Green_Sheet__c = gcWrapper.greenSheet;
                gc.Best_Action_Commitment__c = gcWrapper.bestActionCommitment;
                gettingCommitmentList.add(gc);
            } else {
                // Create BestActionCommitment and Commitment record
                Getting_Commitment__c gc = new Getting_Commitment__c();
                gc.Green_Sheet__c = gcWrapper.greenSheet;
                gc.Best_Action_Commitment__c = gcWrapper.bestActionCommitment;
                gettingCommitmentList.add(gc);
            }

            if (gettingCommitmentList != null && !gettingCommitmentList.isEmpty()) {
                srList = DataFactory.upsurt(gettingCommitmentList);
            }

            // Red Flag & strength create/update
            if (srList[0].isSuccess()) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                // Operation was successful, so get the ID of the record that was processed
                String sourceId = srList[0].getId();
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);

                String objectName = util.getNamespaceWithUnderScores() == ''
                    ? 'Getting_Commitment__c'
                    : util.getNamespaceWithUnderScores() + 'Getting_Commitment__c';

                if (rfsWrapperList != null && !rfsWrapperList.isEmpty()) {
                    ApexCommonUtil.convertMarkerMap(rfsWrapperList, rfsMap);
                    rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectName,
                        sourceId,
                        greenSheetId,
                        rfsMap
                    );
                } else {
                    List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
                        sourceId,
                        objectName,
                        rfsMap
                    );
                    DataFactory.create(markerList);

                    List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                    for (Red_Flag_Strength_Marker__c marker : markerList) {
                        marker.Source_ID__c = srList[0].getId();
                        markerListUpdated.add(marker);
                    }
                    DataFactory.modify(markerListUpdated);
                }
            }
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GettingCommitmentException('Error occured while upserting Best Action Commitment data');
        }
    }

    //Method to upsert Best Action Commitment record
    @AuraEnabled
    public static void upsertMinimumActionCommitment(String jsonString, Map<String, Map<String, Object>> rfsMap) {
        GettingCommitmentWrapper gcWrapper = (GettingCommitmentWrapper) JSON.deserialize(
            jsonString,
            GettingCommitmentWrapper.class
        );
        List<Getting_Commitment__c> gettingCommitmentData = new List<Getting_Commitment__c>();
        List<Database.UpsertResult> srList;
        // String gcId = gcWrapper.Id;
        String greenSheetId = gcWrapper.greenSheet;
        List<Getting_Commitment__c> gettingCommitmentList = new List<Getting_Commitment__c>();

        try {
            String gettingCommitmentQuery = 'SELECT Id,Name,Green_Sheet__c FROM Getting_Commitment__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            gettingCommitmentData = DataFactory.read(gettingCommitmentQuery, gsParams);

            if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                // Update or Create MinimumActionCommitment on Existing Commitment record
                Getting_Commitment__c gc = new Getting_Commitment__c();
                gc.Id = gettingCommitmentData[0].id;
                // gc.Green_Sheet__c = gcWrapper.greenSheet;
                gc.Minimum_Acceptable_Action_Commit__c = gcWrapper.acceptableActionCommitment;
                gettingCommitmentList.add(gc);
            } else {
                // Create MinimumActionCommitment on New Commitment record
                Getting_Commitment__c gc = new Getting_Commitment__c();
                gc.Green_Sheet__c = gcWrapper.greenSheet;
                gc.Minimum_Acceptable_Action_Commit__c = gcWrapper.acceptableActionCommitment;
                gettingCommitmentList.add(gc);
            }

            if (gettingCommitmentList != null && !gettingCommitmentList.isEmpty()) {
                srList = DataFactory.upsurt(gettingCommitmentList);
            }

            // Red Flag & strength create/update
            if (srList[0].isSuccess()) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                // Operation was successful, so get the ID of the record that was processed
                String sourceId = srList[0].getId();
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);

                String objectName = util.getNamespaceWithUnderScores() == ''
                    ? 'Getting_Commitment__c'
                    : util.getNamespaceWithUnderScores() + 'Getting_Commitment__c';

                if (rfsWrapperList != null && !rfsWrapperList.isEmpty()) {
                    ApexCommonUtil.convertMarkerMap(rfsWrapperList, rfsMap);
                    rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectName,
                        sourceId,
                        greenSheetId,
                        rfsMap
                    );
                } else {
                    List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
                        sourceId,
                        objectName,
                        rfsMap
                    );
                    DataFactory.create(markerList);

                    List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
                    for (Red_Flag_Strength_Marker__c marker : markerList) {
                        marker.Source_ID__c = srList[0].getId();
                        markerListUpdated.add(marker);
                    }
                    DataFactory.modify(markerListUpdated);
                }
            }
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GettingCommitmentException(
                'Error occured while upserting Minimum Acceptable Action Commitment data'
            );
        }
    }

    // Method to Delete CommitmentQuestion Record
    @AuraEnabled
    public static void deleteCommitmentQuestion(String recordId) {
        try {
            //System.debug('recordId>>' + recordId);
            ApexCommonUtil.deleteRecord(recordId, 'Commitment_Question__c');
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GettingCommitmentException('Error occured while deleting data from Commitment Question');
        }
    }

    // Method to Delete Best Action Commitment Record
    @AuraEnabled
    public static void deleteBestActionCommitment(String greenSheetId) {
        List<Getting_Commitment__c> gettingCommitmentData = new List<Getting_Commitment__c>();

        try {
            String gettingCommitmentQuery = 'SELECT Id,Name,Green_Sheet__c,Best_Action_Commitment__c FROM Getting_Commitment__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            gettingCommitmentData = DataFactory.read(gettingCommitmentQuery, gsParams);

            if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                gettingCommitmentData[0].Best_Action_Commitment__c = '';
            }
            List<Database.SaveResult> srList = DataFactory.modify(gettingCommitmentData);

            //Delete red flag/Strength marker record from backend

            List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(
                gettingCommitmentData[0].Id
            );
            List<Red_Flag_Strength_Marker__c> rfsRecordsUpdated = new List<Red_Flag_Strength_Marker__c>();
            for (Red_Flag_Strength_Marker__c rfsRecord : rfsRecords) {
                if (rfsRecord.Field_API_Name__c == 'BestActionCommitment') {
                    rfsRecordsUpdated.add(rfsRecord);
                }
            }
            //This list srList will have only one record at a time
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    DataFactory.remove(rfsRecordsUpdated);
                }
            }
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GettingCommitmentException('Error occured while deleting Best Acceptable Action Commitment data');
        }
    }

    // Method to Delete Minimum Action Commitment Record
    @AuraEnabled
    public static void deleteMinimumActionCommitment(String greenSheetId) {
        List<Getting_Commitment__c> gettingCommitmentData = new List<Getting_Commitment__c>();

        try {
            String gettingCommitmentQuery = 'SELECT Id,Name,Green_Sheet__c,Minimum_Acceptable_Action_Commit__c FROM Getting_Commitment__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            gettingCommitmentData = DataFactory.read(gettingCommitmentQuery, gsParams);

            if (gettingCommitmentData != null && !gettingCommitmentData.isEmpty()) {
                gettingCommitmentData[0].Minimum_Acceptable_Action_Commit__c = '';
            }
            List<Database.SaveResult> srList = DataFactory.modify(gettingCommitmentData);

            //Delete red flag/Strength marker record from backend
            List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(
                gettingCommitmentData[0].Id
            );
            List<Red_Flag_Strength_Marker__c> rfsRecordsUpdated = new List<Red_Flag_Strength_Marker__c>();
            for (Red_Flag_Strength_Marker__c rfsRecord : rfsRecords) {
                if (rfsRecord.Field_API_Name__c == 'MinimumActionCommitment') {
                    rfsRecordsUpdated.add(rfsRecord);
                }
            }
            //This list srList will have only one record at a time
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    DataFactory.remove(rfsRecordsUpdated);
                }
            }
        } catch (Exception ex) {
            throw new GettingCommitmentException(
                'Error occured while deleting Minimum Acceptable Action Commitment data'
            );
        }
    }

    //Method to update  lastModifiedDate of Getting Commitment object
    public static void gettingCommitmentLastUpdatedDateAndTime(List<sObject> ls) {
        List<sObject> objList = new List<sObject>();
        Set<sObject> setObj = new Set<sObject>();
        Set<string> gettingCommitmentIds = new Set<string>();
        for (sObject s : ls) {
            Getting_Commitment__c gettingCommitment = new Getting_Commitment__c();
            gettingCommitmentIds.add((Id) s.get('Getting_Commitment__c'));
        }
        for (string s : gettingCommitmentIds) {
            Getting_Commitment__c gettingCommitment = new Getting_Commitment__c();
            gettingCommitment.Id = s;
            setObj.add(gettingCommitment);
        }
        objList.addAll(setObj);
        if (objList.size() > 0) {
            DataFactory.modify(objList);
        }
    }

    //Method to get access of Getting Commitment object
    @AuraEnabled
    public static Map<String, Boolean> getGettingCommitmentAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Getting_Commitment__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    //Method to get access of CommitmentQuestion object
    @AuraEnabled
    public static Map<String, Boolean> getCommitmentQuestionAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Commitment_Question__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    private class GettingCommitmentException extends Exception {
    }
}