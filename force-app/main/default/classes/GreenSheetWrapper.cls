public with sharing class GreenSheetWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String reason { get; set; }
    @AuraEnabled
    public String credibility { get; set; }
    @AuraEnabled
    public String toIncreaseCredibility { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }

    public GreenSheetWrapper(Green_Sheet__c greenSheet) {
        this.id = greenSheet.Id;
        this.name = greenSheet.Name;
        this.credibility = greenSheet.Credibility__c;
        this.reason = greenSheet.Reason__c;
        this.toIncreaseCredibility = greenSheet.To_Increase_Credibility__c;
        // this.hasEditAccess = hasEditAccess;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}