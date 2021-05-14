public with sharing class GettingCommitmentWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String greenSheet { get; set; }
    @AuraEnabled
    public String bestActionCommitment { get; set; }
    @AuraEnabled
    public String acceptableActionCommitment { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public List<CommitmentQuestionWrapper> questionWrapperList { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public GettingCommitmentWrapper(Getting_Commitment__c gettingCommitment) {
        this.id = gettingCommitment.Id;
        this.name = gettingCommitment.Name;
        this.greenSheet = gettingCommitment.Green_Sheet__c;
        this.bestActionCommitment = gettingCommitment.Best_Action_Commitment__c;
        this.acceptableActionCommitment = gettingCommitment.Minimum_Acceptable_Action_Commit__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
        this.questionWrapperList = new List<CommitmentQuestionWrapper>();
    }
}