@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class GettingInformationWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String questionType { get; set; }
    @AuraEnabled
    public String question { get; set; }
    @AuraEnabled
    public String iconName { get; set; }
    @AuraEnabled
    public String greenSheet { get; set; }
    @AuraEnabled
    public boolean goldenSilence { get; set; }
    @AuraEnabled
    public boolean newInformationSelected { get; set; }
    @AuraEnabled
    public boolean attitudeSelected { get; set; }
    @AuraEnabled
    public boolean confirmationSelected { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public GettingInformationWrapper(Getting_Information__c gettingInfo) {
        this.id = gettingInfo.Id;
        this.questionType = gettingInfo.Question_Type__c;
        this.question = gettingInfo.Question__c;
        this.greenSheet = gettingInfo.Green_Sheet__c;
        this.goldenSilence = gettingInfo.Golden_Silence__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}