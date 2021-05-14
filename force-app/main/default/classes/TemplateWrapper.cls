@SuppressWarnings('PMD.TooManyFields,PMD.ExcessivePublicCount')
public with sharing class TemplateWrapper {
    public String ruleId { get; set; }
    public String actionTitle { get; set; }
    public String actionTitleManager { get; set; }
    public String actionTitleSeller { get; set; }
    public String ruleName { get; set; }
    public String sellerMsgBody { get; set; }
    public String sellerVideoUrl { get; set; }
    public String sellerVideoText { get; set; }
    public String managerMsgBody { get; set; }
    public String managerVideoUrl { get; set; }
    public String managerVideoText { get; set; }
    public String bestActionRecordId { get; set; }
    public List<EmailAlertOpportunityWrapper> sellerOpportunityWrappers = new List<EmailAlertOpportunityWrapper>();
    public List<EmailAlertGreenSheetWrapper> sellerGreenSheetWrappers = new List<EmailAlertGreenSheetWrapper>();
    /*Map<String, String> oppURLMap = new Map<String, String>();
    public void addOppUrlMapEntry(String opp, String url) {
        oppURLMap.put(opp, url);
    }*/
}