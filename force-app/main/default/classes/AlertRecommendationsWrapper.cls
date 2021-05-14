public with sharing class AlertRecommendationsWrapper {
    @AuraEnabled
    public String balId;
    @AuraEnabled
    public String businessRulesId;
    @AuraEnabled
    public Boolean isUpdate;
    @AuraEnabled
    public AlertTemplateWrapper action;
    @AuraEnabled
    public AlertTemplateWrapper sellerEmail;
    @AuraEnabled
    public AlertTemplateWrapper managerEmail;
}