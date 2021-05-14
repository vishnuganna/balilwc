public with sharing class StrategicStrengthWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String strategicStrength { get; set; }
    @AuraEnabled
    public String ssDescription { get; set; }
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

    public StrategicStrengthWrapper(FOP_Strategic_Strength__c fopSS, boolean hasEditAccess) {
        this.id = fopSS.Id;
        this.name = fopSS.Name;
        this.strategicStrength = fopSS.Strength__c;
        this.ssDescription = fopSS.Strength_Description__c;
        this.goldSheet = fopSS.Gold_Sheet__c;
        this.hasEditAccess = hasEditAccess;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }

    public static FOP_Strategic_Strength__c convertWrapperToObject(StrategicStrengthWrapper ssWrapper) {
        FOP_Strategic_Strength__c fopSS = new FOP_Strategic_Strength__c();
        fopSS.Gold_Sheet__c = ssWrapper.goldSheet;
        fopSS.Strength__c = ssWrapper.strategicStrength;
        fopSS.Strength_Description__c = ssWrapper.ssDescription;
        return fopSS;
    }
}