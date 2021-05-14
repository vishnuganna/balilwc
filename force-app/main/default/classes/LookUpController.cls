public with sharing class LookUpController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(string searchText) {
        String newSearchText;
        if (searchText == null) {
            newSearchText = '%' + searchText + '%';
        } else {
            newSearchText = '%' + String.escapeSingleQuotes(searchText) + '%';
        }
        List<Contact> contacts = new List<Contact>();
        Map<String, Object> params = new Map<String, Object>();
        String soql = 'SELECT Id, Name FROM Contact WHERE Name LIKE :newSearchText LIMIT 100';
        params.put('newSearchText', newSearchText);
        contacts = DataFactory.read(soql, params);
        return contacts;
    }
}