public with sharing class GoldSheetAndAccountDataWrapperClass {
    @AuraEnabled
    public String goldSheetName { get; set; }
    @AuraEnabled
    public String accountOwnerName { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String fopName { get; set; }
}