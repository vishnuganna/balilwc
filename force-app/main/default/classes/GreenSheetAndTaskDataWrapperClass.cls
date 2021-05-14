public with sharing class GreenSheetAndTaskDataWrapperClass {
    @AuraEnabled
    public String greenSheetName { get; set; }
    @AuraEnabled
    public String taskOwnerName { get; set; }
    @AuraEnabled
    public String taskName { get; set; }
    @AuraEnabled
    public String greensheetLastUpdated { get; set; }
    @AuraEnabled
    public String meetingDate { get; set; }
    @AuraEnabled
    public String relatedTo { get; set; }
}