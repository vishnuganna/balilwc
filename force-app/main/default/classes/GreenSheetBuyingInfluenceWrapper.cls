public with sharing class GreenSheetBuyingInfluenceWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String contactId { get; set; }
    @AuraEnabled
    public String greenSheet { get; set; }
    @AuraEnabled
    public String concept { get; set; }
    @AuraEnabled
    public String contactName { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String state { get; set; }
    @AuraEnabled
    public String country { get; set; }
    @AuraEnabled
    public string buyingInfluenceRole { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public GreenSheetBuyingInfluenceWrapper(Green_Sheet_Buying_Influence__c bi) {
        this.id = bi.Id;
        this.concept = bi.Concept__c;
        this.greenSheet = bi.Green_Sheet__c;
        this.contactName = bi.Contact__r.Name;
        this.title = bi.Contact__r.Title;
        this.state = bi.Contact__r.MailingState;
        this.country = bi.Contact__r.MailingCountry;
        this.buyingInfluenceRole = bi.Buying_Influence_Role__c;
        this.contactId = bi.Contact__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}