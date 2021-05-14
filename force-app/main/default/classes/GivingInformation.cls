public with sharing class GivingInformation {
    /*Method to get access details for Giving Information Question*/
    @AuraEnabled
    public static Map<String, Boolean> getGivingInfoAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = 'Giving_Information__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    /*Method to create/update Giving Information records*/
    @AuraEnabled
    public static void upsertGivingInfo(String givingInfo, Map<String, Map<String, Boolean>> rfsMap) {
        try {
            List<Giving_Information__c> givingInfoList = new List<Giving_Information__c>();
            List<Red_Flag_Strength_Marker__c> markerList = new List<Red_Flag_Strength_Marker__c>();
            GivingInformationWrapper givingInformationWrapper = (GivingInformationWrapper) JSON.deserialize(
                givingInfo,
                GivingInformationWrapper.class
            );
            String greenSheet = givingInformationWrapper.greenSheet;

            String objectApiName = ApexCommonUtil.getObjectwithNameSpace('Giving_Information__c');
            if (greenSheet != null) {
                Giving_Information__c givingInfoObj = new Giving_Information__c();
                if (givingInformationWrapper.id != null) {
                    givingInfoObj.Id = givingInformationWrapper.id;
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectApiName,
                        givingInfoObj.Id,
                        greenSheet,
                        rfsMap
                    );
                } else {
                    markerList = RedFlagStrengthData.createRFSrecords(greenSheet, objectApiName, rfsMap);
                }

                if (givingInfoObj.id == null) {
                    givingInfoObj.Green_Sheet__c = greenSheet;
                }

                givingInfoObj.Title__C = givingInformationWrapper.title;
                givingInfoObj.Description__c = givingInformationWrapper.description;
                givingInfoObj.So_What__c = givingInformationWrapper.soWhat;
                givingInfoObj.Prove_It__c = givingInformationWrapper.proveIt;
                givingInfoObj.IsProviding_Perspective__c = givingInformationWrapper.isPerspective;
                givingInfoObj.Providing_Perspective__c = givingInformationWrapper.perspective;
                givingInfoList.add(givingInfoObj);
            }
            Database.UpsertResult[] infoQuestList = DataFactory.upsurt(givingInfoList);
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
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new GreenSheetGivingInformationException('Error occured while saving giving info');
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
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                infoQuestionsWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new GreenSheetGivingInformationException(
                'Error occured while fetching Getting Information Questions'
            );
        }
        return infoQuestionsWrapperListToReturn;
    }

    /*Method to remove Giving Information Record*/
    @AuraEnabled
    public static void removeGreenGivingInfo(String recordId) {
        try {
            String objName = 'Giving_Information__c';
            ApexCommonUtil.deleteRecord(recordId, objName);
        } catch (Exception ex) {
            throw new GreenSheetGivingInformationException('Error occured while deleting Giving Information Record');
        }
    }

    public class GreenSheetGivingInformationException extends Exception {
    }
}