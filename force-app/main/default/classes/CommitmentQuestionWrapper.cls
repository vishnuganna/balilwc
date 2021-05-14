public with sharing class CommitmentQuestionWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String commitmentQuestion { get; set; }
    @AuraEnabled
    public String gettingCommitment { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public CommitmentQuestionWrapper(Commitment_Question__c question) {
        this.id = question.Id;
        this.name = question.Name;
        this.commitmentQuestion = question.Question__c;
        this.gettingCommitment = question.Getting_Commitment__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}