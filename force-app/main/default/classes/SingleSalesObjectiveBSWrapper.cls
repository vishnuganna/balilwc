public with sharing class SingleSalesObjectiveBSWrapper {
    @AuraEnabled
    public String singleSalesObjectiveBS { get; set; }
    @AuraEnabled
    public String blueSheetId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public boolean strengthSelected { get; set; }
    @AuraEnabled
    public boolean redFlagSelected { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }
    @SuppressWarnings('PMD.EmptyStatementBlock')
    public SingleSalesObjectiveBSWrapper() {
    }
    public SingleSalesObjectiveBSWrapper(Blue_Sheet__c bs, Boolean hasEditAccess) {
        this.singleSalesObjectiveBS = bs.Single_Sales_Objective__c;
        this.blueSheetId = bs.Id;
        this.hasEditAccess = hasEditAccess;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}