@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class GoldSheetSSOWrapper {
    @AuraEnabled
    public String stageName { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public String opportunityName { get; set; }
    @AuraEnabled
    public String closeDate { get; set; }
    @AuraEnabled
    public Decimal expectedRevenue { get; set; }
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public Boolean hasDeleteAccess { get; set; }
    @AuraEnabled
    public String oppId { get; set; }
    @AuraEnabled
    public String opptyLinkName { get; set; }
    @AuraEnabled
    public String acctLinkName { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }
    @AuraEnabled
    public Decimal expectedRevenueTotal { get; set; }

    public GoldSheetSSOWrapper(Opportunity opp, string fieldName) {
        this.stageName = opp.StageName;
        Date dt = (Date) opp.CloseDate;
        if (dt != null) {
            this.closeDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('MM/dd/YYYY');
        }
        this.expectedRevenue = (decimal) opp.get(fieldName);
        this.accountName = opp.Account.Name;
        this.opportunityName = opp.Name;
        this.oppId = opp.id;
    }
    public GoldSheetSSOWrapper(Gold_Sheet_Single_Sales_Objective__c gsSSO, boolean hasDeleteAccess, string fieldName) {
        this.stageName = gsSSO.Opportunity__r.StageName;
        Date dt = (Date) gsSSO.Opportunity__r.CloseDate;
        if (dt != null) {
            this.closeDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('MM/dd/YYYY');
        }
        this.expectedRevenue = (decimal) gsSSO.Opportunity__r.get(fieldName);
        this.accountName = gsSSO.Opportunity__r.Account.Name;
        this.opportunityName = gsSSO.Opportunity__r.Name;
        this.id = gsSSO.id;
        this.hasDeleteAccess = hasDeleteAccess;
        if (!this.hasDeleteAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
        this.oppId = gsSSO.Opportunity__c;
        this.opptyLinkName = '/' + gsSSO.Opportunity__c;
        if (gsSSO.Opportunity__r.AccountId != null) {
            this.acctLinkName = '/' + gsSSO.Opportunity__r.AccountId;
        }
    }
    public GoldSheetSSOWrapper(Gold_Sheet_Single_Sales_Objective__c gsSSO, string fieldName) {
        Date dt = (Date) gsSSO.Opportunity__r.CloseDate;
        if (dt != null) {
            this.closeDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('MM/dd/YYYY');
        }
        this.stageName = gsSSO.Opportunity__r.StageName;
        this.expectedRevenue = (decimal) gsSSO.Opportunity__r.get(fieldName);
        this.accountName = gsSSO.Opportunity__r.Account.Name;
        this.opportunityName = gsSSO.Opportunity__r.Name;
    }
}