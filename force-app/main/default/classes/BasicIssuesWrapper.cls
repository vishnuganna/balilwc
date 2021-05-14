@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class BasicIssuesWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String questionType { get; set; }
    @AuraEnabled
    public String question { get; set; }
    @AuraEnabled
    public String greenSheet { get; set; }
    @AuraEnabled
    public boolean basicIssueQuestionSelected { get; set; }
    @AuraEnabled
    public boolean basicIssueSelected { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public BasicIssuesWrapper(Basic_Issues__c issue) {
        this.id = issue.Id;
        this.questionType = issue.Question_Type__c;
        this.question = issue.Question__c;
        this.greenSheet = issue.Green_Sheet__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}