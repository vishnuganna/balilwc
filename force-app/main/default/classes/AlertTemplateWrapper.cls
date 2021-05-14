public with sharing class AlertTemplateWrapper {
    @AuraEnabled
    public String balId;
    @AuraEnabled
    public String alerId;
    @AuraEnabled
    public String defaultAlertHeader;
    @AuraEnabled
    public String defaultAlertMessage;
    @AuraEnabled
    public String customAlertHeader;
    @AuraEnabled
    public String customAlertMessage;
    @AuraEnabled
    public Boolean alertEnabled;
    @AuraEnabled
    public Boolean overrideHeader;
    @AuraEnabled
    public Boolean overrideMessage;
    @AuraEnabled
    public String alertType;
    @AuraEnabled
    public String associatedObject;
    @AuraEnabled
    public String urlText;
    @AuraEnabled
    public String urlLink;
    @AuraEnabled
    public String defaultAlertHeaderKey;
    @AuraEnabled
    public String defaultAlertMessageKey;
    // public String urlText;
    // public String urlLink;
    public AlertTemplateWrapper(Alert_Template__c alert, Boolean isUpdate) {
        this.alerId = alert.Id;
        this.alertEnabled = alert.Is_Alert_Enabled__c;
        this.customAlertHeader = alert.Custom_Alert_Email_Header__c;
        this.customAlertMessage = alert.Custom_Alert_Email_Text__c;
        this.defaultAlertHeader = alert.Default_Alert_Email_Header__c;
        this.defaultAlertMessage = alert.Default_Alert_Email_Text__c;
        this.overrideHeader = alert.Override_Alert_Email_Header__c;
        this.overrideMessage = alert.Override_Alert_Email_Text__c;
        this.defaultAlertHeaderKey = alert.Default_Alert_Email_Header__c;
        this.defaultAlertMessageKey = alert.Default_Alert_Email_Text__c;
    }
    public AlertTemplateWrapper(Alert_Template__c alertObj) {
        this.balId = alertObj.BestActionRuleId__c;
        this.defaultAlertHeader = alertObj.Default_Alert_Email_Header__c;
        this.defaultAlertMessage = alertObj.Default_Alert_Email_Text__c;
        this.customAlertHeader = alertObj.Custom_Alert_Email_Header__c;
        this.customAlertMessage = alertObj.Custom_Alert_Email_Text__c;
        this.alertEnabled = alertObj.Is_Alert_Enabled__c;
        this.overrideHeader = alertObj.Override_Alert_Email_Header__c;
        this.overrideMessage = alertObj.Override_Alert_Email_Text__c;
        this.alertType = alertObj.Alert_Type__c;
        this.urlLink = alertObj.URL_Link__c;
        this.urlText = alertObj.URL_Text__c;
        if (
            alertObj.BestActionRuleId__c == 'BAL_1' ||
            alertObj.BestActionRuleId__c == 'BAL_2' ||
            alertObj.BestActionRuleId__c == 'BAL_3'
        ) {
            this.associatedObject = System.Label.BlueSheet;
        } else if (alertObj.BestActionRuleId__c == 'BAL_4') {
            this.associatedObject = System.Label.CategoryOpportunity;
        } else if (
            alertObj.BestActionRuleId__c == 'BAL_11' ||
            alertObj.BestActionRuleId__c == 'BAL_14' ||
            alertObj.BestActionRuleId__c == 'BAL_15' ||
            alertObj.BestActionRuleId__c == 'BAL_16' ||
            alertObj.BestActionRuleId__c == 'BAL_17'
        ) {
            this.associatedObject = System.Label.strategicSellingScorecard;
        } else if (alertObj.BestActionRuleId__c == 'BAL_6' || alertObj.BestActionRuleId__c == 'BAL_7') {
            this.associatedObject = System.Label.actionPlan;
        } else if (alertObj.BestActionRuleId__c == 'BAL_5' || alertObj.BestActionRuleId__c == 'BAL_13') {
            this.associatedObject = System.Label.SingleSalesObjectives;
        } else if (
            alertObj.BestActionRuleId__c == 'BAL_12' ||
            alertObj.BestActionRuleId__c == 'BAL_18' ||
            alertObj.BestActionRuleId__c == 'BAL_19' ||
            alertObj.BestActionRuleId__c == 'BAL_20' ||
            alertObj.BestActionRuleId__c == 'BAL_21' ||
            alertObj.BestActionRuleId__c == 'BAL_22' ||
            alertObj.BestActionRuleId__c == 'BAL_23' ||
            alertObj.BestActionRuleId__c == 'BAL_24'
        ) {
            this.associatedObject = System.Label.buyingInfluence;
        } else if (alertObj.BestActionRuleId__c == 'BAL_9' || alertObj.BestActionRuleId__c == 'BAL_10') {
            this.associatedObject = System.Label.competition;
        } else if (alertObj.BestActionRuleId__c == 'BAL_8') {
            this.associatedObject = System.Label.currentPosition;
        } else if (alertObj.BestActionRuleId__c == 'BAL_25') {
            this.associatedObject = System.Label.GSGetting_Commitment;
        } else if (alertObj.BestActionRuleId__c == 'BAL_26') {
            this.associatedObject = System.Label.GSGetting_Commitment;
        } else if (alertObj.BestActionRuleId__c == 'BAL_27') {
            this.associatedObject = System.Label.GreenSheet;
        } else if (alertObj.BestActionRuleId__c == 'BAL_28') {
            this.associatedObject = System.Label.GSBuyingInfluence;
        }
    }
}