public with sharing class LandingFOPKFSActions {
    public class LandingFOPKFSActionsInfo {
        @AuraEnabled
        public Integer totalRecordCount { get; set; }

        @AuraEnabled
        public List<LandingKFSellFOPActionsWrapper> fOPKFSRecords { get; set; }

        public LandingFOPKFSActionsInfo(Integer totalRecordCount, List<LandingKFSellFOPActionsWrapper> fOPKFSRecords) {
            this.totalRecordCount = totalRecordCount;
            this.fOPKFSRecords = fOPKFSRecords;
        }
    }
    @AuraEnabled
    public static LandingFOPKFSActionsInfo getFoPRecords(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        return new LandingFOPKFSActionsInfo(
            countFOPKFSActions(userIdSet),
            getFoPRecordData(userIdSet, queryLimit, queryOffset)
        );
    }
    @AuraEnabled
    public static Integer countFOPKFSActions(List<String> userIdSet) {
        Integer fopKFSActionCount = 0;
        String query =
            'SELECT COUNT()' +
            ' FROM KF_Sell_Best__c WHERE Fields_of_Play_Gold_Sheet__c != null AND Activity_Due_Date__c = null AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('userIdSet', userIdSet);
        fopKFSActionCount = DataFactory.countQuery(query, paramters);
        return fopKFSActionCount;
    }
    @AuraEnabled
    public static List<LandingKFSellFOPActionsWrapper> getFoPRecordData(
        List<String> userIdSet,
        Integer queryLimit,
        Integer queryOffset
    ) {
        List<LandingKFSellFOPActionsWrapper> fopListToReturn = new List<LandingKFSellFOPActionsWrapper>();
        try {
            String query =
                'SELECT Id, Name, Fields_of_Play_Gold_Sheet__r.FOP_Name__c, Fields_of_Play_Gold_Sheet__r.Id,' +
                ' Fields_of_Play_Gold_Sheet__r.Account__r.Name, Gold_Sheet_AccountOwner__c, Fields_of_Play_Gold_Sheet__r.Last_Updated__c,' +
                ' Fields_of_Play_Gold_Sheet__r.Account__r.Id,Fields_of_Play_Gold_Sheet__r.Owner.Name  ' +
                'FROM KF_Sell_Best__c WHERE Fields_of_Play_Gold_Sheet__c != null AND Activity_Due_Date__c = null AND Fields_of_Play_Gold_Sheet__r.OwnerId =:userIdSet ORDER BY createdDate DESC LIMIT :queryLimit OFFSET :queryOffset';
            Map<String, Object> params = new Map<String, Object>();
            params.put('userIdSet', userIdSet);
            params.put('queryLimit', queryLimit);
            params.put('queryOffset', queryOffset);
            List<KF_Sell_Best__c> fopList = DataFactory.read(query, params);
            for (KF_Sell_Best__c sheet : fopList) {
                LandingKFSellFOPActionsWrapper wrapperObj = new LandingKFSellFOPActionsWrapper(sheet);
                wrapperObj.actionTitle = System.Label.UpdatePastDue;
                fopListToReturn.add(wrapperObj);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new LandingFOPKFSActionsException('Error occured while getting Field of Play record');
        }
        return fopListToReturn;
    }
    private class LandingFOPKFSActionsException extends Exception {
    }
}