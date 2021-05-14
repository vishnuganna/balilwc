/*
 * ─────────────────────────────────────────────────────────────────────────────────────────────────┐
 * KFS-277 (part of main US KFS-277) : Wrapper class to hold the data for BestAction messages
 * ──────────────────────────────────────────────────────────────────────────────────────────────────
 * @author         Rakesh Singh
 * @created        2020-05-30
 *
 */
public with sharing class RecommendationsActionWrapper {
    @AuraEnabled
    public String balId;
    @AuraEnabled
    public String evaluation;
    @AuraEnabled
    public String sellerRecommendedActionMessage;
    @AuraEnabled
    public String managerRecommendedActionMessage;
    @AuraEnabled
    public String actionMsg;
    @AuraEnabled
    public String sellerEmailText;
    @AuraEnabled
    public String sellerUrlText;
    @AuraEnabled
    public String sellerUrlLink;
    @AuraEnabled
    public String managerUrlText;
    @AuraEnabled
    public String managerUrlLink;
    @AuraEnabled
    public String associatedObject;
}