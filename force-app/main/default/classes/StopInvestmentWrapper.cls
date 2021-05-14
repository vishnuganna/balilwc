@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class StopInvestmentWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String foiName { get; set; }
    @AuraEnabled
    public String foiInvestmentTitle { get; set; }
    @AuraEnabled
    public String foiDescription { get; set; }
    @AuraEnabled
    public String foiStatus { get; set; }
    @AuraEnabled
    public Decimal foiAmount { get; set; }
    @AuraEnabled
    public String goldSheet { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public StopInvestmentWrapper(Stop_Investment__c focusInvesment, boolean hasEditAccess) {
        this.id = focusInvesment.Id;
        this.foiName = focusInvesment.Name;
        this.foiInvestmentTitle = focusInvesment.Investment_Title__c;
        this.foiDescription = focusInvesment.Description__c;
        this.foiStatus = focusInvesment.Status__c;
        this.foiAmount = focusInvesment.Amount__c;
        this.goldSheet = focusInvesment.Fields_of_Play_Gold_Sheet__c;
        this.hasEditAccess = hasEditAccess;
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}