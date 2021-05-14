public with sharing class GreenSheetPDFController {
    public String greenSheetPDFData { get; set; }
    public Green_Sheet__c greenSheet { get; set; }
    public static GreenSheetPDFWrapper greenSheetPDFWrapper { get; set; }

    public GreenSheetPDFController() {
        String recordId = System.currentPageReference().getParameters().get('id');
        greenSheetPDFWrapper = new GreenSheetPDFWrapper();
        if (recordId != null) {
            greenSheetPDFWrapper.greenSheetTaskInfo = getGreenSheetById(recordId);
            greenSheetPDFData = JSON.serialize(greenSheetPDFWrapper);

            ApexCommonUtil.pdfDownload(greenSheetPDFWrapper.greenSheetTaskInfo.greenSheetName);
        }
    }

    @AuraEnabled
    public static GreenSheetAndTaskDataWrapperClass getGreenSheetById(String greensheetId) {
        GreenSheetAndTaskDataWrapperClass greenSheetWrapper = new GreenSheetAndTaskDataWrapperClass();
        if (
            Schema.sObjectType.Task.isAccessible() &&
            Schema.sObjectType.Green_Sheet__c.isAccessible() &&
            Schema.sObjectType.User.isAccessible()
        ) {
            List<Green_Sheet__c> listGreenSheet = new List<Green_Sheet__c>();
            String query = 'SELECT Id, Name,Task_Name__c,Task_Owner__c,Task_Owner_Id__c,Last_Updated__c,Meeting_Date__c,Related_To_Name__c FROM Green_Sheet__c WHERE id = :greensheetId LIMIT 1';

            Map<String, Object> paramters = new Map<String, Object>();
            paramters.put('greensheetId', greensheetId);
            listGreenSheet = DataFactory.read(query, paramters);

            Green_Sheet__c greenSheetData = listGreenSheet[0];

            String taskOwnerId = greenSheetData.Task_Owner_Id__c;
            List<User> usersList = new List<User>();
            String userQuery = 'SELECT Name FROM User WHERE id = :taskOwnerId LIMIT 1';

            Map<String, Object> params = new Map<String, Object>();
            params.put('taskOwnerId', taskOwnerId);
            usersList = DataFactory.read(userQuery, params);

            User user = new User();
            if (!usersList.isEmpty()) {
                user = usersList[0];
            }

            greenSheetWrapper.greenSheetName = greenSheetData.Name;
            greenSheetWrapper.taskName = greenSheetData.Task_Name__c;
            greenSheetWrapper.greensheetLastUpdated = String.valueOf(greenSheetData.Last_Updated__c);
            greenSheetWrapper.meetingDate = String.valueOf(greenSheetData.Meeting_Date__c);
            greenSheetWrapper.relatedTo = greenSheetData.Related_To_Name__c;
            greenSheetWrapper.taskOwnerName = user.Name;
        }
        //system.debug('GreensheetWrapper ' + greenSheetWrapper);
        return greenSheetWrapper;
    }
}