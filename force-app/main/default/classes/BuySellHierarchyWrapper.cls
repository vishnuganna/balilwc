@SuppressWarnings('PMD.ExcessivePublicCount')
public class BuySellHierarchyWrapper {
    @AuraEnabled
    public String buySellhierarchyName { get; set; }
    @AuraEnabled
    public Date buySellhierarchyDate { get; set; }
    @AuraEnabled
    public String buySellhierarchyDateString { get; set; }
    @AuraEnabled
    public String fieldOfPlayCustomYear { get; set; }
    @AuraEnabled
    public String fieldOfPlayLastYear { get; set; }
    @AuraEnabled
    public String fieldOfPlayNextYear { get; set; }
    @AuraEnabled
    public String fieldOfPlayThisYear { get; set; }
    @AuraEnabled
    public String goldSheetId { get; set; }
    @AuraEnabled
    public String usCustomYear { get; set; }
    @AuraEnabled
    public String usLastYear { get; set; }
    @AuraEnabled
    public String usNextYear { get; set; }
    @AuraEnabled
    public String usThisYear { get; set; }
    @AuraEnabled
    public List<RedFlagStrengthMarkerWrapper> rfsMarkerWrapper { get; set; }
    @AuraEnabled
    public boolean hasEditAccess { get; set; }
    @AuraEnabled
    public Map<String, RedFlagStrengthMarkerWrapper> rfsMarkerPdfWrapper { get; set; }

    public BuySellHierarchyWrapper(Gold_Sheet__c bshRecord, boolean isUpdatable) {
        this.buySellhierarchyName = bshRecord.Name;
        this.buySellhierarchyDate = bshRecord.Custom_Date__c;
        Date dt = (Date) bshRecord.Custom_Date__c;
        if (dt != null) {
            this.buySellhierarchyDateString = DateTime.newInstance(dt.year(), dt.month(), dt.day())
                .format('MM/dd/YYYY');
        }
        this.fieldOfPlayCustomYear = bshRecord.FOP_Custom__c;
        this.fieldOfPlayLastYear = bshRecord.FOP_Last_Year__c;
        this.fieldOfPlayNextYear = bshRecord.FOP_Next_Year__c;
        this.fieldOfPlayThisYear = bshRecord.FOP_This_Year__c;
        this.goldSheetId = bshRecord.Id;
        this.usCustomYear = bshRecord.Us_Custom__c;
        this.usLastYear = bshRecord.Us_Last_Year__c;
        this.usNextYear = bshRecord.Us_Next_Year__c;
        this.usThisYear = bshRecord.Us_This_Year__c;
        this.rfsMarkerWrapper = new List<RedFlagStrengthMarkerWrapper>();
        this.hasEditAccess = isUpdatable;
    }
}