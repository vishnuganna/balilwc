public with sharing class GettingInformation {
    /*Method to get access details for Getting Information Question*/
    @AuraEnabled
    public static Map<String, Boolean> getInfoQuestionsAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Getting_Information__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    /*Method to get Getting Information Question records*/
    @AuraEnabled
    public static List<GettingInformationWrapper> getGIQuestions(String greenSheetId) {
        List<Getting_Information__c> infoQuestions = new List<Getting_Information__c>();
        List<GettingInformationWrapper> infoQuestionsWrapperListToReturn = new List<GettingInformationWrapper>();
        try {
            String getInfoQuery = 'SELECT Id, Question_Type__c, Question__c, Green_Sheet__c, Golden_Silence__c FROM Getting_Information__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greenSheetId', greenSheetId);
            //get data from Getting_Information__c section
            infoQuestions = DataFactory.read(getInfoQuery, paramters);
            for (Getting_Information__c gi : infoQuestions) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = gi.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                GettingInformationWrapper wrapper = new GettingInformationWrapper(gi);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                infoQuestionsWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new GreenSheetGettingInformationException(
                'Error occured while fetching Getting Information Questions'
            );
        }
        return infoQuestionsWrapperListToReturn;
    }

    /*Method to create/update Getting Information Question records*/
    @AuraEnabled
    public static void upsertGIQuestions(String infoQuestions, Map<String, Map<String, Boolean>> rfsMap) {
        List<Getting_Information__c> infoQuestionsList = new List<Getting_Information__c>();
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        GettingInformationWrapper gettingInformationWrapper = (GettingInformationWrapper) JSON.deserialize(
            infoQuestions,
            GettingInformationWrapper.class
        );
        String greenSheet = gettingInformationWrapper.greenSheet;

        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Getting_Information__c');
        if (greenSheet != null) {
            Getting_Information__c infoQuest = new Getting_Information__c();
            if (gettingInformationWrapper.id != null) {
                infoQuest.Id = gettingInformationWrapper.id;
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    infoQuest.Id,
                    greenSheet,
                    rfsMap
                );
            } else {
                markerList = RedFlagStrengthData.createRFSrecords(greenSheet, objectApiName, rfsMap);
            }
            if (infoQuest.id == null) {
                infoQuest.Green_Sheet__c = greenSheet;
            }
            infoQuest.Question_Type__c = gettingInformationWrapper.questionType;
            infoQuest.Question__c = gettingInformationWrapper.question;
            infoQuest.Golden_Silence__c = gettingInformationWrapper.goldenSilence;
            infoQuestionsList.add(infoQuest);
        }
        Database.UpsertResult[] infoQuestList = DataFactory.upsurt(infoQuestionsList);
        for (Database.UpsertResult info : infoQuestList) {
            if (info.isSuccess() && !markerList.isEmpty()) {
                DataFactory.create(markerList);
            }
        }
        List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c marker : markerList) {
            marker.Source_ID__c = infoQuestList[0].getId();
            markerListUpdated.add(marker);
        }
        DataFactory.modify(markerListUpdated);
    }

    /*Method to remove Getting Information Question*/
    @AuraEnabled
    public static void removeGreenGIQuestions(String recordId) {
        try {
            String objName = 'Getting_Information__c';
            ApexCommonUtil.deleteRecord(recordId, objName);
        } catch (Exception ex) {
            throw new GreenSheetGettingInformationException(
                'Error occured while deleting Getting Information Question'
            );
        }
    }

    public class GreenSheetGettingInformationException extends Exception {
    }
}