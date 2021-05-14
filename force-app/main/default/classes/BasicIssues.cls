public with sharing class BasicIssues {
    /*Method to get access details for Basic Issues Question*/
    @AuraEnabled
    public static Map<String, Boolean> getBasicIssueAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Basic_Issues__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
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
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                basicIssuesQuestionsWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new GreenSheetBasicIssuesException('Error occured while fetching Basic Issues Questions');
        }
        return basicIssuesQuestionsWrapperListToReturn;
    }

    /*Method to create/update Basic Issues Question records*/
    @AuraEnabled
    public static void upsertBasicIssueRecords(String basicIssueQuestions, Map<String, Map<String, Boolean>> rfsMap) {
        List<Basic_Issues__c> basicIssuesQuestionsList = new List<Basic_Issues__c>();
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        BasicIssuesWrapper basicIssuesWrapper = (BasicIssuesWrapper) JSON.deserialize(
            basicIssueQuestions,
            BasicIssuesWrapper.class
        );
        String greenSheet = BasicIssuesWrapper.greenSheet;

        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Basic_Issues__c');
        if (greenSheet != null) {
            Basic_Issues__c basicIssueQuest = new Basic_Issues__c();
            if (BasicIssuesWrapper.id != null) {
                basicIssueQuest.Id = BasicIssuesWrapper.id;
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    basicIssueQuest.Id,
                    greenSheet,
                    rfsMap
                );
            } else {
                markerList = RedFlagStrengthData.createRFSrecords(greenSheet, objectApiName, rfsMap);
            }
            basicIssueQuest.Green_Sheet__c = greenSheet;
            basicIssueQuest.Question_Type__c = BasicIssuesWrapper.questionType;
            basicIssueQuest.Question__c = BasicIssuesWrapper.question;
            basicIssuesQuestionsList.add(basicIssueQuest);
        }
        Database.UpsertResult[] basicIssueQuestList = DataFactory.upsurt(basicIssuesQuestionsList);
        for (Database.UpsertResult issue : basicIssueQuestList) {
            if (issue.isSuccess() && !markerList.isEmpty()) {
                DataFactory.create(markerList);
            }
        }
        List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c marker : markerList) {
            marker.Source_ID__c = basicIssueQuestList[0].getId();
            markerListUpdated.add(marker);
        }
        DataFactory.modify(markerListUpdated);
    }

    /*Method to remove Basic Issues Question*/
    @AuraEnabled
    public static void removeBasicIssueRecords(String recordId) {
        try {
            String objName = 'Basic_Issues__c';
            ApexCommonUtil.deleteRecord(recordId, objName);
        } catch (Exception ex) {
            throw new GreenSheetBasicIssuesException('Error occured while deleting Basic Issues Question');
        }
    }

    public class GreenSheetBasicIssuesException extends Exception {
    }
}