public with sharing class GreenSheetBIandVBRCredPDF {
    public String greenSheetComponentsPDFData { get; set; }
    public static GreenSheetPDFWrapper greenSheetPDFWrapper { get; set; }

    public GreenSheetBIandVBRCredPDF() {
        String recordId = System.currentPageReference().getParameters().get('id');
        greenSheetPDFWrapper = new GreenSheetPDFWrapper();
        if (recordId != null) {
            greenSheetPDFWrapper.greenSheetBuyingInfluence = getGreenBuyingInfluenceRecords(recordId);
            greenSheetPDFWrapper.greenSheet = getGreenSheetVBR(recordId);
            greenSheetComponentsPDFData = JSON.serialize(greenSheetPDFWrapper);
        }
    }

    /*Method to get Green sheet Buying Influence records*/
    @AuraEnabled
    public static List<GreenSheetBuyingInfluenceWrapper> getGreenBuyingInfluenceRecords(String greenSheetId) {
        List<Green_Sheet_Buying_Influence__c> listBI = new List<Green_Sheet_Buying_Influence__c>();
        List<GreenSheetBuyingInfluenceWrapper> biWrapperListToReturn = new List<GreenSheetBuyingInfluenceWrapper>();

        try {
            //formation of query
            String biQuery = 'Select Id,Name,Contact__c,Contact__r.Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingState,Contact__r.MailingCountry,Contact__r.title,Buying_Influence_Role__c,Green_Sheet__c,Concept__c FROM Green_Sheet_Buying_Influence__c WHERE Green_Sheet__c=:greenSheetId ORDER BY createddate DESC';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greenSheetId', greenSheetId);
            //get data from BI section
            listBI = DataFactory.read(biQuery, paramters);

            for (Green_Sheet_Buying_Influence__c bi : listBI) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = bi.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                GreenSheetBuyingInfluenceWrapper wrapper = new GreenSheetBuyingInfluenceWrapper(bi);
                wrapper.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                biWrapperListToReturn.add(wrapper);
            }
            //System.debug('biWrapperListToReturn>>>' + biWrapperListToReturn);
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GreenSheetBIException('Error occured while getting data from Green Sheet Buying Influence');
        }
        return biWrapperListToReturn;
    }

    /*Method to get Valid Business Reason and Credibility records*/
    @AuraEnabled
    public static List<GreenSheetWrapper> getGreenSheetVBR(String greenSheetId) {
        List<Green_Sheet__c> greenSheetList = new List<Green_Sheet__c>();
        List<GreenSheetWrapper> greenSheetWrapperList = new List<GreenSheetWrapper>();

        try {
            String greenSheetQuery = 'SELECT Id,Name,Credibility__c,Reason__c,To_Increase_Credibility__c FROM Green_Sheet__c WHERE Id =:greenSheetId';
            Map<String, Object> gsParams = new Map<String, Object>();
            gsParams.put('greenSheetId', greenSheetId);
            greenSheetList = DataFactory.read(greenSheetQuery, gsParams);

            Boolean isUpdatable = false;
            if (Schema.sObjectType.Green_Sheet__c.isUpdateable()) {
                isUpdatable = true;
            }

            if (greenSheetList != null && !greenSheetList.isEmpty()) {
                for (Green_Sheet__c gs : greenSheetList) {
                    GreenSheetWrapper gsWrap = new GreenSheetWrapper(gs);
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                    String sourceId = gs.Id;
                    rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                    gsWrap.rfsMarkerPdfWrapper = convertRfsMarkerToPdfWrapper(rfsWrapperList);
                    greenSheetWrapperList.add(gsWrap);
                }
            }
            //System.debug('greenSheetWrapperList>>>' + greenSheetWrapperList);
        } catch (Exception ex) {
            //System.debug('exception ----' + ex);
            //System.debug('exception line----' + ex.getLineNumber());
            throw new GreenSheetVBRException('Error occured while getting data from Green Sheet');
        }
        return greenSheetWrapperList;
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

    private class GreenSheetVBRException extends Exception {
    }

    private class GreenSheetBIException extends Exception {
    }
}