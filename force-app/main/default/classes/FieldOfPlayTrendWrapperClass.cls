public with sharing class FieldOfPlayTrendWrapperClass {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String trendDescription { get; set; }
    @AuraEnabled
    public String trendTitle { get; set; }
    @AuraEnabled
    public String goldSheet { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    //parameterised constructor that accepts the data from object and assigns it to wrapper
    public FieldOfPlayTrendWrapperClass(Field_of_Play_Trend__c fieldOfPlayTrends, boolean hasEditAccess) {
        this.id = fieldOfPlayTrends.Id;
        this.name = fieldOfPlayTrends.Name;
        this.trendTitle = fieldOfPlayTrends.Trend__c;
        this.trendDescription = fieldOfPlayTrends.Trend_Description__c;
        this.goldSheet = fieldOfPlayTrends.Gold_Sheet__c;
        this.hasEditAccess = hasEditAccess;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }

    public static Field_of_Play_Trend__c convertWrapperToObject(FieldOfPlayTrendWrapperClass trendsWrapper) {
        Field_of_Play_Trend__c fopTrend = new Field_of_Play_Trend__c();
        fopTrend.Gold_Sheet__c = trendsWrapper.goldSheet;
        fopTrend.Trend__c = trendsWrapper.trendTitle;
        fopTrend.Trend_Description__c = trendsWrapper.trendDescription;
        return fopTrend;
    }
}