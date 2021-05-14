//KFS- 5 : This class is used to write all DML operations and business logic to show data on UI
public with sharing class Competition {
    @AuraEnabled
    public static wrapperLookupObject getObjectName() {
        wrapperLookupObject wrapper = new wrapperLookupObject();
        wrapper.lookupOnObject = util.getNamespaceWithUnderScores() == ''
            ? 'Competition__c'
            : util.getNamespaceWithUnderScores() + 'Competition__c';
        wrapper.targetField = util.getNamespaceWithUnderScores() == ''
            ? 'Account__c'
            : util.getNamespaceWithUnderScores() + 'Account__c';
        return wrapper;
    }

    //Method to fetch data from competiton table and show it on UI under cometition section of blue sheet
    @AuraEnabled
    public static List<CompetitionWrapperClass> getCompetition(string oppId) {
        List<Competition__c> listCompetition = new List<Competition__c>();
        Boolean isUpdatable;
        if (Schema.sObjectType.opportunity.isUpdateable()) {
            isUpdatable = true;
        }
        List<CompetitionWrapperClass> competitonWrapperListToReturn = new List<CompetitionWrapperClass>();
        try {
            //formation of query
            String competitonQuery =
                'Select Id,Name,Competitior_Name__c,Competitive_Detail__c,Account__c,Account__r.Name,Blue_Sheet__c,Competitor_Type__c,My_Position_Vs_Competitor__c' +
                ' FROM Competition__c WHERE Blue_Sheet__r.Opportunity__c=:oppId ORDER BY createdDate';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('oppId', oppId);
            //get data from cometition section
            listCompetition = DataFactory.read(competitonQuery, paramters);
            //iterate through list to get list of wrapper to return to UI
            for (Competition__c competition : listCompetition) {
                List<RedFlagStrengthMarkerWrapper> rfsWrapperList = new List<RedFlagStrengthMarkerWrapper>();
                //rfsWrapperList=getRFSWrapperList(competition);
                String sourceId = competition.Id;
                rfsWrapperList = RedFlagStrengthData.getRFSWrapperList(sourceId);
                CompetitionWrapperClass wrapper = new CompetitionWrapperClass(competition, isUpdatable);
                wrapper.rfsMarkerWrapper = rfsWrapperList;
                competitonWrapperListToReturn.add(wrapper);
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            system.System.debug('exception line----' + ex.getLineNumber());
            throw new CompetitionException('Error occured while getting data from Competition');
        }
        //return list of wrapper containing all competition data
        return competitonWrapperListToReturn;
    }

    @AuraEnabled
    public static void removeCompetition(string recordId, String oppId) {
        List<Competition__c> listCompetition = new List<Competition__c>();
        try {
            //formation of query
            String competitonQuery =
                'Select Id,Name,Competitior_Name__c,Competitive_Detail__c,Competitor_Type__c,My_Position_Vs_Competitor__c' +
                ' FROM Competition__c WHERE Id=:recordId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('recordId', recordId);
            //get data from cometition section to delete
            listCompetition = DataFactory.read(competitonQuery, paramters);

            List<Red_Flag_Strength_Marker__c> rfsRecords = RedFlagStrengthData.getRFSrecords(recordId);
            List<Database.DeleteResult> srList = DataFactory.remove(listCompetition);
            for (Database.DeleteResult sr : srList) {
                if (sr.isSuccess()) {
                    DataFactory.remove(rfsRecords);
                }
            }
        } catch (Exception ex) {
            system.System.debug('exception ----' + ex);
            throw new CompetitionException('Error occured while deleting data from Competition');
        }
    }

    @AuraEnabled
    public static void updateCompetitorData(
        map<String, String> competitorData,
        String oppId,
        Map<String, Map<String, Object>> rfsData
    ) {
        String objectName = util.getNamespaceWithUnderScores() == ''
            ? 'Competition__c'
            : util.getNamespaceWithUnderScores() + 'Competition__c';
        try {
            string competitiorId = competitorData.get('recordId');
            //formation of query
            String competitonQuery =
                'Select Id,Name,Competitior_Name__c,Competitive_Detail__c,Account__c,Account__r.Name,Blue_Sheet__c,Competitor_Type__c,My_Position_Vs_Competitor__c' +
                ' FROM Competition__c WHERE Id=:competitiorId';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('competitiorId', competitiorId);

            List<Competition__c> competition = DataFactory.read(competitonQuery, paramters);

            if (competition.size() > 0) {
                if (competitorData.get('accountId') != null) {
                    competition[0].Account__c = competitorData.get('accountId');
                } else {
                    competition[0].Account__c = null;
                }
                competition[0].Competitive_Detail__c = competitorData.get('details');
                competition[0].Competitor_Type__c = competitorData.get('compType');
                competition[0].My_Position_Vs_Competitor__c = competitorData.get('posVsCmp');
                competition[0].Competitior_Name__c = competitorData.get('compNameType');
                List<Database.SaveResult> srList = DataFactory.modify(competition);
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        List<RedFlagStrengthMarkerWrapper> rfsWrapperList = RedFlagStrengthData.updateRFSRecords(
                            objectName,
                            competitiorId,
                            oppId,
                            rfsData
                        );
                    }
                }
            }
        } catch (exception e) {
            system.debug('exception --' + e);
            system.debug('line number ---' + e.getLineNumber());
            throw new AuraHandledException('unable to update the record.');
        }
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static List<CompetitionWrapperClass> saveCompetition(
        map<String, String> competitorData,
        String oppId,
        String account,
        Map<String, Map<String, Boolean>> rfsMap
    ) {
        List<Competition__c> listCompetitionToInsert = new List<Competition__c>();
        String accoundId = account;

        String bluesheetQuery = 'SELECT Id FROM Blue_Sheet__c WHERE Opportunity__c =:oppId';
        Map<String, Object> paramters = new Map<String, Object>();
        paramters.put('oppId', oppId);
        List<Blue_Sheet__c> bluesheet = DataFactory.read(bluesheetQuery, paramters);

        String accountQuery = 'Select Id,Name from Account where Id=:accoundId LIMIT 1';
        Map<String, Object> paramtersAcc = new Map<String, Object>();
        paramtersAcc.put('accoundId', accoundId);

        List<Database.SaveResult> srList;

        List<Account> AccountRec = DataFactory.read(accountQuery, paramtersAcc);
        if (!bluesheet.isEmpty()) {
            Competition__c competition = new Competition__c();
            competition.Competitive_Detail__c = competitorData.get('details');
            competition.Competitor_Type__c = competitorData.get('compType');
            competition.My_Position_Vs_Competitor__c = competitorData.get('posVsCmp');
            competition.Competitior_Name__c = competitorData.get('compNameType');
            Competition.Blue_Sheet__c = bluesheet[0].Id;
            if (AccountRec.size() > 0) {
                Competition.Account__c = AccountRec[0].Id;
            }
            listCompetitionToInsert.add(competition);

            srList = DataFactory.create(listCompetitionToInsert);

            String blueSheetId = bluesheet[0].Id;
            //String objectApiName = 'Competition__c';
            String objectApiName = util.getNamespaceWithUnderScores() == ''
                ? 'Competition__c'
                : util.getNamespaceWithUnderScores() + 'Competition__c';
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

        List<CompetitionWrapperClass> wrapperToReturn = getCompetition(oppId);
        return wrapperToReturn;
    }
    private class CompetitionException extends Exception {
    }

    public class wrapperLookupObject {
        @AuraEnabled
        public String lookupOnObject;
        @AuraEnabled
        public String targetField;
    }

    @AuraEnabled
    public static List<SObject> findAccountRecords(String searchKey) {
        String queryMDT = 'SELECT MasterLabel, DeveloperName, Record_Type_API_Name__c FROM Configure_Competition_RecordType_Filters__mdt ';
        Map<String, Object> paramets = new Map<String, Object>();
        List<Configure_Competition_RecordType_Filters__mdt> recordTypesList = DataFactory.read(queryMDT, paramets);
        List<String> recordTypeNamesList = new List<String>();
        for (Configure_Competition_RecordType_Filters__mdt recordType : recordTypesList) {
            recordTypeNamesList.add(recordType.Record_Type_API_Name__c);
        }

        String key = '%' + searchKey + '%';
        String query;
        if (!recordTypeNamesList.isEmpty()) {
            query = 'Select Id, Name From Account Where Name LIKE :key AND RecordType.DeveloperName IN :recordTypeNamesList ';
        } else {
            query = 'Select Id, Name From Account Where Name LIKE :key';
        }
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', key);
        params.put('recordTypeNamesList', recordTypeNamesList);
        return DataFactory.read(query, params);
    }

    @AuraEnabled
    public static Map<String, Boolean> getCompetitionAccess() {
        Map<String, Boolean> accessMap = new Map<String, Boolean>();
        //String objName = 'Competition__c';
        String objName = util.getNamespaceWithUnderScores() == ''
            ? 'Competition__c'
            : util.getNamespaceWithUnderScores() + 'Competition__c';
        Boolean isCreateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isCreateable();
        Boolean isUpdateableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isUpdateable();
        Boolean isDeletableObj = Schema.getGlobalDescribe().get(objName).getDescribe().isDeletable();
        accessMap.put('isCreateable', isCreateableObj);
        accessMap.put('isUpdateable', isUpdateableObj);
        accessMap.put('isDeletable', isDeletableObj);
        return accessMap;
    }
}