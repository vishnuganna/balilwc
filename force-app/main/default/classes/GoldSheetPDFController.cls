// Apex controller for GoldSheet PDF
public with sharing class GoldSheetPDFController {
    public String goldSheetPDFData { get; set; }
    public Gold_Sheet__c goldSheet { get; set; }
    public static GoldSheetPDFWrapper goldSheetPDFWrapper { get; set; }

    public GoldSheetPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        goldSheetPDFWrapper = new GoldSheetPDFWrapper();
        if (recordId != null) {
            goldSheetPDFWrapper.goldSheetAccountInfo = getGoldSheetById(recordId);
            goldSheetPDFData = JSON.serialize(goldSheetPDFWrapper);
            ApexCommonUtil.pdfDownload(goldSheetPDFWrapper.goldSheetAccountInfo.fopName);
        }
    }

    @AuraEnabled
    public static GoldSheetAndAccountDataWrapperClass getGoldSheetById(String goldsheetId) {
        GoldSheetAndAccountDataWrapperClass goldSheetWrapper = new GoldSheetAndAccountDataWrapperClass();
        if (
            Schema.sObjectType.Account.isAccessible() &&
            Schema.sObjectType.Gold_Sheet__c.isAccessible() &&
            Schema.sObjectType.User.isAccessible()
        ) {
            List<Gold_Sheet__c> listGoldSheet = new List<Gold_Sheet__c>();
            String query = 'SELECT Id, Name, Account__r.Name, Account__r.OwnerId, FOP_Name__c FROM Gold_Sheet__c WHERE id = :goldsheetId LIMIT 1';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('goldsheetId', goldsheetId);
            listGoldSheet = DataFactory.read(query, paramters);

            Gold_Sheet__c goldSheetData = listGoldSheet[0];

            String accountOwnerId = goldSheetData.Account__r.OwnerId;
            List<User> usersList = new List<User>();
            String userQuery = 'SELECT Name FROM User WHERE id = :accountOwnerId LIMIT 1';

            Map<String, Object> params = new Map<String, Object>();
            params.put('accountOwnerId', accountOwnerId);
            usersList = DataFactory.read(userQuery, params);

            User user = new User();
            if (!usersList.isEmpty()) {
                user = usersList[0];
            }

            goldSheetWrapper.goldSheetName = goldSheetData.Name;
            goldSheetWrapper.accountName = goldSheetData.Account__r.Name;
            goldSheetWrapper.fopName = goldSheetData.FOP_Name__c;
            goldSheetWrapper.accountOwnerName = user.Name;
        }
        return goldSheetWrapper;
    }
}