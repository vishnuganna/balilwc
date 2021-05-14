public with sharing class GreenSheetBuyingInfluence {
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
                wrapper.rfsMarkerWrapper = rfsWrapperList;

                biWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
        }
        return biWrapperListToReturn;
    }

    @AuraEnabled
    public static void removeGreenBuyingInfluence(string recordId) {
        try {
            String objName = 'Green_Sheet_Buying_Influence__c';
            ApexCommonUtil.deleteRecord(recordId, objName);
        } catch (Exception ex) {
            throw new GreenSheetBuyingInfluenceException(
                'Error occured while deleting data from Green Sheet Buying Influence'
            );
        }
    }

    @AuraEnabled
    public static Map<String, Boolean> getGreenBuyingInfluenceAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Green_Sheet_Buying_Influence__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    @AuraEnabled
    public static void createGSBIRec(String inputString, Map<String, Map<String, Boolean>> rfsMap) {
        List<Green_Sheet_Buying_Influence__c> listGSBI = new List<Green_Sheet_Buying_Influence__c>();
        List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
        GreenSheetBuyingInfluenceWrapper wrapper = (GreenSheetBuyingInfluenceWrapper) System.JSON.deserialize(
            inputString,
            GreenSheetBuyingInfluenceWrapper.class
        );
        String greenSheetId = wrapper.greenSheet;

        String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Green_Sheet_Buying_Influence__c');
        if (greenSheetId != null) {
            Green_Sheet_Buying_Influence__c greensheetBI = new Green_Sheet_Buying_Influence__c();
            if (wrapper.id != null) {
                greensheetBI.Id = wrapper.id;
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                    objectApiName,
                    greensheetBI.Id,
                    greenSheetId,
                    rfsMap
                );
            } else {
                markerList = RedFlagStrengthData.createRFSrecords(greenSheetId, objectApiName, rfsMap);
            }
            if (greensheetBI.id == null) {
                greensheetBI.Green_Sheet__c = greenSheetId;
            }
            greensheetBI.Concept__c = wrapper.concept;
            greensheetBI.Contact__c = wrapper.contactId;
            greensheetBI.Buying_Influence_Role__c = wrapper.buyingInfluenceRole;
            listGSBI.add(greensheetBI);
        }
        List<Database.UpsertResult> srList = DataFactory.upsurt(listGSBI);

        for (Database.UpsertResult sr : srList) {
            if (sr.isSuccess() && !markerList.isEmpty()) {
                DataFactory.create(markerList);
            }
        }
        List<Red_Flag_Strength_Marker__c> markerListUpdated = new List<Red_Flag_Strength_Marker__c>();
        for (Red_Flag_Strength_Marker__c marker : markerList) {
            marker.Source_ID__c = srList[0].getId();
            markerListUpdated.add(marker);
        }
        DataFactory.modify(markerListUpdated);
    }
    private class GreenSheetBuyingInfluenceException extends Exception {
    }
}