public with sharing class MyPositionController {
    @AuraEnabled
    public static void createSummaryRec(Map<String, String> sumData, String oppId) {
        String bluesheetQuery = 'SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c =:oppId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('oppId', oppId);
        List<Blue_Sheet__c> bluesheet = DataFactory.read(bluesheetQuery, paramters);
        if (!bluesheet.isEmpty()) {
            Summary_of_My_Position_Today__c somp = new Summary_of_My_Position_Today__c();
            somp.Blue_Sheet__c = bluesheet[0].Id;
            somp.Summary__c = sumData.get('summary');
            somp.Description__c = sumData.get('description');
            if (sumData.containsKey('redFlag')) {
                somp.Is_a_Red_Flag__c = true;
            }
            if (sumData.containsKey('strength')) {
                somp.Is_a_Strength__c = true;
            }
            DataFactory.create(somp);
        }
    }

    @AuraEnabled
    public static List<PositionSummaryWrapper> getSOMPRecords(String oppId) {
        Boolean isUpdatable;
        List<Summary_of_My_Position_Today__c> sompData = new List<Summary_of_My_Position_Today__c>();
        List<PositionSummaryWrapper> sompWrapDataToReturn = new List<PositionSummaryWrapper>();
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }

        try {
            string sompQuery = 'select id,Summary__c,Description__c,Is_a_Strength__c,Is_a_Red_Flag__c  from Summary_of_My_Position_Today__c WHERE Blue_Sheet__r.Opportunity__c=:oppId Order By CreatedDate ASC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from cometition section
            sompData = DataFactory.read(sompQuery, paramters);
            for (Summary_of_My_Position_Today__c somp : sompData) {
                PositionSummaryWrapper wrap = new PositionSummaryWrapper(somp, isUpdatable);
                sompWrapDataToReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new PSException('Error occured while getting data from ActionPlan');
        }

        return sompWrapDataToReturn;
    }

    @AuraEnabled
    public static void deleteSOMPRecord(String recordId) {
        String query = 'SELECT Id from Summary_of_My_Position_Today__c WHERE Id=:recordId';
        map<String, Object> params = new Map<String, Object>();
        params.put('recordId', recordId);
        List<Summary_of_My_Position_Today__c> sompRecord = DataFactory.read(query, params);
        DataFactory.remove(sompRecord);
    }

    @AuraEnabled
    public static void updateSOMPRecord(Map<String, String> sompRec) {
        string sompId = sompRec.get('recId');
        string query = 'select id,Summary__c,Description__c from Summary_of_My_Position_Today__c where id=:sompId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('sompId', sompId);
        List<Summary_of_My_Position_Today__c> summaryData = DataFactory.read(query, paramters);
        if (!summaryData.isEmpty()) {
            Summary_of_My_Position_Today__c somp = new Summary_of_My_Position_Today__c();
            somp.Id = sompRec.get('recId');
            somp.Summary__c = sompRec.get('summary');
            somp.Description__c = sompRec.get('description');
            DataFactory.modify(somp);
        }
    }

    // -- 10 June Dhananjay
    @AuraEnabled
    public static Map<String, Boolean> getMypositionAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        //String objName = 'Summary_of_My_Position_Today__c';
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Summary_of_My_Position_Today__c'
            : util.getNamespaceWithUnderScores() + 'Summary_of_My_Position_Today__c';
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        return accessMap;
    }
    // -- 10 June Dhananjay
    public with sharing class PositionSummaryWrapper {
        @AuraEnabled
        public String summary { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public String psId { get; set; }
        @AuraEnabled
        public Boolean strenghtFlag { get; set; }
        @AuraEnabled
        public Boolean redFlag { get; set; }

        public PositionSummaryWrapper(Summary_of_My_Position_Today__c somp, boolean hasEditAccess) {
            this.summary = somp.Summary__c;
            this.description = somp.Description__c;
            this.redFlag = somp.Is_a_Red_Flag__c;
            this.strenghtFlag = somp.Is_a_Strength__c;
            this.psId = somp.Id;
        }
    }

    private class PSException extends Exception {
    }
}