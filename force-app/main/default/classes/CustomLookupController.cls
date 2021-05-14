public with sharing class CustomLookupController {
    @AuraEnabled
    public static List<SObject> findRecords(String searchKey, String accountId) {
        String key = '%' + searchKey + '%';
        String query;
        if (accountId != null) {
            query =
                'Select Id, Title, MailingState, MailingCountry, Account.Name, Name From Contact' +
                ' Where AccountId = :accountId AND Name LIKE :key LIMIT 10';
        } else {
            query =
                'Select Id, Title, MailingState, MailingCountry, Account.Name, Name From Contact' +
                ' Where Name LIKE :key LIMIT 10';
        }
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', key);
        params.put('accountId', accountId);
        return DataFactory.read(query, params);
    }

    @AuraEnabled(cacheable=true)
    public static List<StrategicPlayerWrapper> findStrategicPlayerRecords(String searchKey, String goldSheetId) {
        string key = '%' + searchKey + '%';
        Boolean isUpdatable = false;
        if (Schema.sObjectType.Strategic_Player__c.isDeletable()) {
            isUpdatable = true;
        }
        List<StrategicPlayerWrapper> wrapperToReturn = new List<StrategicPlayerWrapper>();
        List<Strategic_Player__c> listStrategicPlayers = new List<Strategic_Player__c>();
        string query =
            'SELECT Id, Strategic_Player__r.name,Strategic_Player__r.title,Strategic_Player_Role__c FROM Strategic_Player__c' +
            ' WHERE Gold_Sheet__c=:goldSheetId AND Strategic_Player__r.name LIKE :key LIMIT 6';
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', key);
        params.put('goldSheetId', goldSheetId);
        listStrategicPlayers = DataFactory.read(query, params);
        for (Strategic_Player__c player : listStrategicPlayers) {
            StrategicPlayerWrapper wrapper = new StrategicPlayerWrapper(player, isUpdatable, true);
            wrapperToReturn.add(wrapper);
        }
        return wrapperToReturn;
    }
}