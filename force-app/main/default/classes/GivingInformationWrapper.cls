public with sharing class GivingInformationWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String soWhat { get; set; }
    @AuraEnabled
    public String greenSheet { get; set; }
    @AuraEnabled
    public String proveIt { get; set; }
    @AuraEnabled
    public boolean isPerspective { get; set; }
    @AuraEnabled
    public String perspective { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public GivingInformationWrapper(Giving_Information__c givingInfo) {
        this.id = givingInfo.Id;
        this.title = givingInfo.Title__C;
        this.description = givingInfo.Description__c;
        this.proveIt = givingInfo.Prove_It__c;
        this.perspective = givingInfo.Providing_Perspective__c;
        this.isPerspective = givingInfo.IsProviding_Perspective__c;
        this.soWhat = givingInfo.So_What__c;
        this.greenSheet = givingInfo.Green_Sheet__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}