@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class MilestoneWrapper {
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public String msName { get; set; }
    @AuraEnabled
    public String msNumber { get; set; }

    @AuraEnabled
    public String milestoneNumber { get; set; }

    @AuraEnabled
    public Set<String> msPlayer { get; set; }
    @AuraEnabled
    public String msNotes { get; set; }
    @AuraEnabled
    public Date msDate { get; set; }
    @AuraEnabled
    public String goldSheet { get; set; }
    @AuraEnabled
    public List<PlayerWrapper> playerWrapperList { get; set; }
    @AuraEnabled
    public String msDateFormatted { get; set; }

    public MilestoneWrapper(Milestone__c milestone) {
        this.id = milestone.Id;
        this.msName = milestone.Name;
        this.msNumber = milestone.Milestone_Number__c;
        this.goldSheet = milestone.Gold_Sheet__c;
        this.msNotes = milestone.Meeting_Notes__c;
        this.msDate = milestone.Meeting_Date__c;
        this.milestoneNumber = milestone.Milestone_Number_Index__c;
        Date dateToFormat = this.msDate;
        DateTime dt = DateTime.newInstance(dateToFormat.year(), dateToFormat.month(), dateToFormat.day());
        this.msDateFormatted = dt.format('dd/MM/yyyy');
        this.msPlayer = new Set<String>();
        this.playerWrapperList = new List<PlayerWrapper>();
    }

    public class PlayerWrapper {
        @AuraEnabled
        public String spId { get; set; }
        @AuraEnabled
        public String role { get; set; }
        @AuraEnabled
        public String strategicPlayer { get; set; }
        @AuraEnabled
        public String strategicPlayerName { get; set; }
        @AuraEnabled
        public String strategicPlayerFirstName { get; set; }
        @AuraEnabled
        public String strategicPlayerLastName { get; set; }
        @AuraEnabled
        public String strategicPlayerTitle { get; set; }

        public PlayerWrapper(Strategic_Player__c spRecord) {
            this.spId = spRecord.Id;
            this.role = spRecord.Strategic_Player_Role__c;
            this.strategicPlayer = spRecord.Strategic_Player__c;
            this.strategicPlayerName = spRecord.Strategic_Player__r.Name;
            this.strategicPlayerFirstName = spRecord.Strategic_Player__r.FirstName;
            this.strategicPlayerLastName = spRecord.Strategic_Player__r.LastName;
            this.strategicPlayerTitle = spRecord.Strategic_Player__r.title;
        }
    }
}