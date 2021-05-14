@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class FieldOfPlayOppController {
    @AuraEnabled
    public static wrapperLookupObject getObjectName() {
        wrapperLookupObject wrapper = new wrapperLookupObject();
        wrapper.lookupOnObject = ApexCommonUtil.getObjectwithNameSpace('Field_of_Play_Opportunity__c');
        wrapper.targetField = ApexCommonUtil.getObjectwithNameSpace('FOP_Owner__c');

        return wrapper;
    }

    @AuraEnabled
    public static void createFoPORec(Map<String, String> recData, Map<String, Map<String, Boolean>> rfsMap) {
        Field_of_Play_Opportunity__c fopoRec = new Field_of_Play_Opportunity__c();

        fopoRec.Opportunity_Title__c = recData.get('Title');
        fopoRec.KPI__c = recData.get('KPI');
        fopoRec.FOP_Owner__c = recData.get('Owner');
        fopoRec.FOP_Opportunity_Desc__c = recData.get('Description');
        fopoRec.Gold_Sheet__c = recData.get('GoldSheetId');
        List<Database.SaveResult> srList;
        srList = DataFactory.create(fopoRec);

        String objectApiName = util.getNamespaceWithUnderScores() == ''
            ? 'Field_of_Play_Opportunity__c'
            : util.getNamespaceWithUnderScores() + 'Field_of_Play_Opportunity__c';
        List<Red_Flag_Strength_Marker__c> markerList = RedFlagStrengthData.createRFSrecords(
            recData.get('GoldSheetId'),
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
    public static List<PlayOppWrapper> getFOPORec(String accId) {
        List<Field_of_Play_Opportunity__c> fopoRecData = new List<Field_of_Play_Opportunity__c>();
        List<PlayOppWrapper> wrapDatatoReturn = new List<PlayOppWrapper>();
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Field_of_Play_Opportunity__c.isUpdateable()) {
            isUpdatable = true;
        }
        try {
            string fopoQuery = 'select id,Opportunity_Title__c, KPI__c,FOP_Owner__c,FOP_Owner__r.Name,FOP_Opportunity_Desc__c from Field_of_Play_Opportunity__c where Gold_Sheet__c=: accId ORDER BY createdDate DESC';
            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('accId', accId);
            fopoRecData = DataFactory.read(fopoQuery, paramters);
            for (Field_of_Play_Opportunity__c rec : fopoRecData) {
                PlayOppWrapper wrap = new PlayOppWrapper(rec, isUpdatable);
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                String sourceId = rec.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                wrap.rfsMarkerWrapper = rfsWrapperList;
                wrapDatatoReturn.add(wrap);
            }
        } catch (Exception e) {
            throw new FOPOException('Error occured while getting data from FOPO' + e);
        }
        return wrapDatatoReturn;
    }

    @AuraEnabled
    public static Map<String, String> updateFOPORec(
        Map<String, String> fopoRecData,
        Map<String, Map<String, Object>> rfsData,
        String goldSheetId
    ) {
        List<Database.SaveResult> srList;
        String objectName = util.getNamespaceWithUnderScores() == ''
            ? 'Field_of_Play_Opportunity__c'
            : util.getNamespaceWithUnderScores() + 'Field_of_Play_Opportunity__c';
        Map<String, String> resultMap = new Map<String, String>();
        String fopId = fopoRecData.get('Id');
        try {
            if (!fopoRecData.isEmpty()) {
                Field_of_Play_Opportunity__c fopoRec = new Field_of_Play_Opportunity__c();
                fopoRec.Id = fopoRecData.get('Id');
                fopoRec.Opportunity_Title__c = fopoRecData.get('Title');
                fopoRec.KPI__c = fopoRecData.get('KPI');
                fopoRec.FOP_Owner__c = fopoRecData.get('Owner');
                fopoRec.FOP_Opportunity_Desc__c = fopoRecData.get('Description');
                srList = DataFactory.modify(fopoRec);
                //srList will always have 1 record as update is being done from UI
                if (srList[0].isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    resultMap.put('recordId', srList[0].getId());
                    String sourceId = srList[0].getId();
                    List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRedFlagStrengthRecords(
                        objectName,
                        fopId,
                        goldSheetId,
                        rfsData
                    );
                }

                resultMap.put('status', System.Label.success_header);
                resultMap.put('msg', System.Label.success_header);
            }
        } catch (Exception ex) {
            resultMap.put('status', System.Label.error_header);
            resultMap.put('msg', ex.getMessage());
            system.System.debug('exception ----' + ex);
        }
        return resultMap;
    }

    @AuraEnabled
    public static void deleteFOPORec(String recId) {
        List<Field_of_Play_Opportunity__c> fopoRecData = new List<Field_of_Play_Opportunity__c>();
        string fopoQuery = 'select id from Field_of_Play_Opportunity__c where Id=: recId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('recId', recId);
        fopoRecData = DataFactory.read(fopoQuery, paramters);
        List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(recId);
        try {
            List<Database.DeleteResult> delResultList = DataFactory.remove(fopoRecData);
            //delResultList will always have 1 record as delete is being done from UI
            if (delResultList[0].isSuccess()) {
                DataFactory.remove(rfsRecords);
            }
        } catch (Exception exp) {
            system.System.debug('exception ----' + exp.getMessage());
        }
    }

    //Method to get access of FoP Oppotunity oject
    @AuraEnabled
    public static Map<String, Boolean> getFoPOpportunityAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Field_of_Play_Opportunity__c'
            : util.getNamespaceWithUnderScores() + 'Field_of_Play_Opportunity__c';
        accessMap = ApexCommonUtil.getObjectAccess(objName);
        return accessMap;
    }

    public class PlayOppWrapper {
        @AuraEnabled
        public string id { get; set; }
        @AuraEnabled
        public string title { get; set; }
        @AuraEnabled
        public string kpi { get; set; }
        @AuraEnabled
        public string ownerId { get; set; }
        @AuraEnabled
        public string ownerName { get; set; }
        @AuraEnabled
        public string description { get; set; }
        @AuraEnabled
        public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
        @AuraEnabled
        public String cssClassforReadOnlyUsers { get; set; }
        @AuraEnabled
        public boolean hasEditAccess { get; set; }
        @AuraEnabled
        public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }
        @AuraEnabled
        public String ownerLinkName { get; set; }

        public PlayOppWrapper(Field_of_Play_Opportunity__c fopoRec, boolean hasEditAccess) {
            this.id = fopoRec.Id;
            this.title = fopoRec.Opportunity_Title__c;
            this.kpi = fopoRec.KPI__c;
            this.ownerId = fopoRec.FOP_Owner__c;
            this.ownerName = fopoRec.FOP_Owner__r.Name;
            this.description = fopoRec.FOP_Opportunity_Desc__c;
            this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
            this.hasEditAccess = hasEditAccess;
            if (!this.hasEditAccess) {
                this.cssClassforReadOnlyUsers = 'slds-hide';
            }
            if (fopoRec.FOP_Owner__c != null) {
                this.ownerLinkName = URL.getSalesforceBaseUrl().toExternalForm() + '/' + fopoRec.FOP_Owner__c;
            }
        }
    }

    private class FOPOException extends Exception {
    }

    public class wrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }
}