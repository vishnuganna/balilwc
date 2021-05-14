public with sharing class GreenSheetGettingGivingInformationPDF {
    public String greenSheetComponentsPDFData { get; set; }
    public static GreenSheetPDFWrapper greenSheetPDFWrapper { get; set; }

    public GreenSheetGettingGivingInformationPDF() {
        String recordId = System.currentPageReference().getParameters().get('id');
        greenSheetPDFWrapper = new GreenSheetPDFWrapper();
        if (recordId != null) {
            greenSheetPDFWrapper.givingInformation = getGivingInformationRecords(recordId);
            greenSheetPDFWrapper.gettingInformation = getGIQuestions(recordId);
            //System.debug('greenSheetPDFWrapper>>>' + greenSheetPDFWrapper);
            greenSheetComponentsPDFData = JSON.serialize(greenSheetPDFWrapper);
        }
    }

    /*Method to get Giving Information  records*/
    @AuraEnabled
    public static List<GivingInformationWrapper> getGivingInformationRecords(String greenSheetId) {
        List<Giving_Information__c> infoQuestions = new List<Giving_Information__c>();
        List<GivingInformationWrapper> infoQuestionsWrapperListToReturn = new List<GivingInformationWrapper>();
        try {
            String getInfoQuery = 'SELECT Id, Title__C, Description__c, Green_Sheet__c, Prove_It__c,Providing_Perspective__c,IsProviding_Perspective__c,So_What__c FROM Giving_Information__c WHERE Green_Sheet__c =:greenSheetId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greenSheetId', greenSheetId);
            infoQuestions = DataFactory.read(getInfoQuery, paramters);
            for (Giving_Information__c gi : infoQuestions) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = gi.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                GivingInformationWrapper wrapper = new GivingInformationWrapper(gi);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                infoQuestionsWrapperListToReturn.add(wrapper);
            }
            //System.debug('infoQuestionsWrapperListToReturn>>>' + infoQuestionsWrapperListToReturn);
        } catch (Exception ex) {
            //system.System.debug('exception ----' + ex);
            throw new GreenSheetGivingInformationException(
                'Error occured while fetching Getting Information Questions'
            );
        }
        return infoQuestionsWrapperListToReturn;
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
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                infoQuestionsWrapperListToReturn.add(wrapper);
            }
            //System.debug('infoQuestionsWrapperListToReturn>>>' + infoQuestionsWrapperListToReturn);
        } catch (Exception ex) {
            //system.System.debug('exception ----' + ex);
            throw new GreenSheetGettingInformationException(
                'Error occured while fetching Getting Information Questions'
            );
        }
        return infoQuestionsWrapperListToReturn;
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

    private class GreenSheetGettingInformationException extends Exception {
    }

    private class GreenSheetGivingInformationException extends Exception {
    }
}