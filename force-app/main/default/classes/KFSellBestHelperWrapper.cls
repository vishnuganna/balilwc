@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class KFSellBestHelperWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String managerRecommendedAction { get; set; }
    @AuraEnabled
    public String sellerRecommendedAction { get; set; }
    @AuraEnabled
    public String recommendations { get; set; }
    @AuraEnabled
    public String blueSheet { get; set; }
    @AuraEnabled
    public String opportunity { get; set; }
    @AuraEnabled
    public String managerURLText { get; set; }
    @AuraEnabled
    public String managerURLLink { get; set; }
    @AuraEnabled
    public String sellerURLLink { get; set; }
    @AuraEnabled
    public String sellerURLText { get; set; }
    @AuraEnabled
    public String actionTitle { get; set; }
    @AuraEnabled
    public String sellerTitle { get; set; }
    @AuraEnabled
    public String managerTitle { get; set; }
    @AuraEnabled
    public String sellerEmailText { get; set; }
    @AuraEnabled
    public String associatedObject { get; set; }
    @AuraEnabled
    public String greenSheet { get; set; }
    @AuraEnabled
    public String alertType { get; set; }
    @AuraEnabled
    public String brId { get; set; }
}