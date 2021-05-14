@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class SingleSalesObjectiveController {
    @AuraEnabled
    public static void createSSORecord(String jsonString, String oppId, Map<String, Map<String, Boolean>> rfsMap) {
        String bluesheetQuery = 'SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c =:oppId';
        Map<String, Object> paramters = new Map<String, Object>();
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        paramters.put('oppId', oppId);
        List<Blue_Sheet__c> bluesheet = DataFactory.read(bluesheetQuery, paramters);
        SingleSalesObjectiveWrapper ssoWrapper = (SingleSalesObjectiveWrapper) JSON.deserialize(
            jsonString,
            SingleSalesObjectiveWrapper.class
        );
        List<Single_Sales_Objective__c> ssoList = new List<Single_Sales_Objective__c>();
        if (!bluesheet.isEmpty()) {
            //SingleSalesObjectiveWrapper wrapObj = new SingleSalesObjectiveWrapper();
            Single_Sales_Objective__c recData = ssoWrapper.convertWrappertoObject(ssoWrapper);
            recData.Blue_Sheet__c = bluesheet[0].Id;
            srList = DataFactory.create(recData);
        }
        // List<Database.SaveResult> srList = DataFactory.create(ssoList);
        String blueSheetId = bluesheet[0].Id;
        //String objectApiName = 'Single_Sales_Objective__c';
        String objectApiName = util.getNamespaceWithUnderScores() == ''
            ? 'Single_Sales_Objective__c'
            : util.getNamespaceWithUnderScores() + 'Single_Sales_Objective__c';
        List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
            blueSheetId,
            objectApiName,
            rfsMap
        );

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
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

    @AuraEnabled
    public static List<SingleSalesObjectiveWrapper> getSSORecords(String oppId) {
        Boolean isUpdatable;
        List<Single_Sales_Objective__c> ssoData = new List<Single_Sales_Objective__c>();
        List<SingleSalesObjectiveWrapper> ssoWrapDataToReturn = new List<SingleSalesObjectiveWrapper>();
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }

        try {
            string ssoQuery = 'select id,Customer_Timing_for_Priorities__c, Customers_Stated_Objectives__c,Evaluation_of_Objectives__c from Single_Sales_Objective__c WHERE Blue_Sheet__r.Opportunity__c=:oppId';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from cometition section
            ssoData = DataFactory.read(ssoQuery, paramters);
            for (Single_Sales_Objective__c sso : ssoData) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = sso.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                SingleSalesObjectiveWrapper wrap = new SingleSalesObjectiveWrapper(sso, isUpdatable);
                wrap.rfsMarkerWrapper = rfsWrapperList;
                ssoWrapDataToReturn.add(wrap);
            }
            // for(Single_Sales_Objective__c sso: ssoData){
            //     SingleSalesObjectiveWrapper wrap = new SingleSalesObjectiveWrapper(sso,isUpdatable);
            //     ssoWrapDataToReturn.add(wrap);
            // }
        } catch (Exception e) {
            throw new SSOException('Error occured while getting data from SSO');
        }

        return ssoWrapDataToReturn;
    }

    @AuraEnabled
    public static void emptySSORecord(
        String jsonString,
        String oppId,
        Map<String, Map<String, Object>> rfsData,
        Boolean empty
    ) {
        //String ssoId = ssoRec.Id;
        //String objectName = 'Single_Sales_Objective__c';
        String objectName = util.getNamespaceWithUnderScores() == ''
            ? 'Single_Sales_Objective__c'
            : util.getNamespaceWithUnderScores() + 'Single_Sales_Objective__c';
        SingleSalesObjectiveWrapper ssoWrapper = (SingleSalesObjectiveWrapper) JSON.deserialize(
            jsonString,
            SingleSalesObjectiveWrapper.class
        );
        //SingleSalesObjectiveWrapper wrapObj = new SingleSalesObjectiveWrapper();
        Single_Sales_Objective__c ssoRec = ssoWrapper.convertWrappertoObject(ssoWrapper);
        ssoRec.id = ssoWrapper.ssoid;
        String ssoId = ssoRec.Id;
        List<Database.SaveResult> srList = DataFactory.modify(ssoRec);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRFSRecords(
                    objectName,
                    ssoId,
                    oppId,
                    rfsData
                );
            }
        }
        // DataFactory.modify(ssoRec);
    }

    @AuraEnabled
    public static Map<String, Boolean> getSSOAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        //String objName = 'Single_Sales_Objective__c';
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Single_Sales_Objective__c'
            : util.getNamespaceWithUnderScores() + 'Single_Sales_Objective__c';
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        return accessMap;
    }

    public with sharing class SingleSalesObjectiveWrapper {
        @AuraEnabled
        public String custTimingPriorities { get; set; }
        @AuraEnabled
        public String customerStatedObjective { get; set; }
        @AuraEnabled
        public String evaluationOfObjectives { get; set; }
        @AuraEnabled
        public String ssoId { get; set; }
        @AuraEnabled
        public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
        @AuraEnabled
        public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }
        @AuraEnabled
        public Id bluesheet { get; set; }
        @AuraEnabled
        public String id { get; set; }

        public SingleSalesObjectiveWrapper(Single_Sales_Objective__c sso, boolean hasEditAccess) {
            this.custTimingPriorities = sso.Customer_Timing_for_Priorities__c;
            this.customerStatedObjective = sso.Customers_Stated_Objectives__c;
            this.evaluationOfObjectives = sso.Evaluation_of_Objectives__c;
            this.ssoId = sso.Id;
            this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
        }

        public Single_Sales_Objective__c convertWrappertoObject(SingleSalesObjectiveWrapper ssoWrapper) {
            Single_Sales_Objective__c ssoObj = new Single_Sales_Objective__c();
            ssoObj.Blue_Sheet__c = ssoWrapper.bluesheet;
            ssoObj.Evaluation_of_Objectives__c = ssoWrapper.evaluationOfObjectives;
            ssoObj.Customer_Timing_for_Priorities__c = ssoWrapper.custTimingPriorities;
            ssoObj.Customers_Stated_Objectives__c = ssoWrapper.customerStatedObjective;
            //ssoObj.Id = ssoWrapper.ssoId;
            return ssoObj;
        }
    }

    private class SSOException extends Exception {
    }
}