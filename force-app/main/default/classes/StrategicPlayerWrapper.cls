@SuppressWarnings('PMD.ExcessivePublicCount')
public class StrategicPlayerWrapper {
    @AuraEnabled
    public String buySellPosition { get; set; }
    @AuraEnabled
    public String goldsheetId { get; set; }
    @AuraEnabled
    public String ourTeamMember { get; set; }
    @AuraEnabled
    public String ourTeamMemberName { get; set; }
    @AuraEnabled
    public String ourTeamMemberTitle { get; set; }
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
    @AuraEnabled
    public String id { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public String cssClassforReadOnlyUsers { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public String accountOwnerId { get; set; }
    @AuraEnabled
    public String accountOwnerTitle { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public StrategicPlayerWrapper(Strategic_Player__c spRecord, boolean isUpdatable, boolean customLookup) {
        this.role = spRecord.Strategic_Player_Role__c;
        this.strategicPlayerName = spRecord.Strategic_Player__r.Name;
        this.strategicPlayerTitle = spRecord.Strategic_Player__r.title;
        this.id = spRecord.Id;
        this.hasEditAccess = isUpdatable;
        if (!customLookup) {
            this.buySellPosition = spRecord.Buy_Sell_Position__c;
            this.goldsheetId = spRecord.Gold_Sheet__c;
            this.ourTeamMember = spRecord.Team_Member__c;
            this.ourTeamMemberName = spRecord.Team_Member__r.Name;
            this.ourTeamMemberTitle = spRecord.Team_Member__r.title;
            this.strategicPlayer = spRecord.Strategic_Player__c;
            this.strategicPlayerFirstName = spRecord.Strategic_Player__r.FirstName;
            this.strategicPlayerLastName = spRecord.Strategic_Player__r.LastName;
        }
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
        if (!this.hasEditAccess) {
            this.cssClassforReadOnlyUsers = 'slds-hide';
        }
    }
}