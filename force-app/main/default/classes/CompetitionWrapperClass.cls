//KFS-5 : created wrapper to hold the data from object veriables
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class CompetitionWrapperClass {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String competitiveDetail { get; set; }
    @AuraEnabled
    public String accountName { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public Id blueSheet { get; set; }
    @AuraEnabled
    public String competitorType { get; set; }
    @AuraEnabled
    public String myPositionVsCompetitor { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String competitiorTyepName { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    //parameter constructor that excepts the data from object and assign it to wrapper
    public CompetitionWrapperClass(Competition__c competition, boolean hasEditAccess) {
        this.Id = competition.Id;
        this.name = competition.Name;
        this.competitiveDetail = competition.Competitive_Detail__c;
        this.accountName = competition.Account__r.Name;
        this.accountId = competition.Account__c;
        this.blueSheet = competition.Blue_Sheet__c;
        this.competitorType = competition.Competitor_Type__c;
        this.myPositionVsCompetitor = competition.My_Position_Vs_Competitor__c;
        this.hasEditAccess = hasEditAccess;
        this.competitiorTyepName = competition.Competitior_Name__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
    }
}