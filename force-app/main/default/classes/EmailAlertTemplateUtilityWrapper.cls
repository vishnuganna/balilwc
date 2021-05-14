public with sharing class EmailAlertTemplateUtilityWrapper {
    public List<String> actionName;
    public String actionTitle;
    public List<String> textBody;
    public Boolean isHaveOpportunities = false;
    public Boolean isHaveGreenSheets = false;
    public Boolean isManager = false;
    public String sellerName;
    public string videoURLs;
    public string videoURLsName;
    public List<EmailAlertOpportunityWrapper> opportunities;
    public List<EmailAlertGreenSheetWrapper> greenSheets;
}